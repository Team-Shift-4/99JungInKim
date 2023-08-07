위 문서는 PostgreSQL 11버전을 기반으로 작성되었다.

# PostgreSQL: Logical Decoding

PostgreSQL은 SQL을 통해 수행된 수정 사항을 외부 소비자에게 스트리밍하는 인프라를 제공한다.
이 기능은 복제 솔루션과 감사를 비롯한 다양한 용도로 사용 가능하다.

변경 사항은 논리적 복제 슬롯으로 식별되는 스트림으로 전송된다.

이러한 변경 사항이 스트리밍 되는 형식은 사용된 출력 플러그인에 의해 결정된다.
예제 플러그인은 PostgreSQL 배포판에서 제공된다.
핵심 코드를 수정하지 않고 사용 가능한 형식의 선택을 확장하기 위해 추가 플러그인을 작성할 수 있다.
모든 출력 플러그인은 INSERT에서 생성된 각각의 개별 새 행과 UPDATE에서 생성된 새 행 버전에 엑세스할 수 있다.
UPDATE와 DELETE에 대한 이전 행 버전의 가용성은 구성된 복제본 ID에 따라 다르다.

변경 사항은 복제 프로토콜을 사용하거나 SQL을 통해 함수를 호출하여 사용할 수 있다.
핵심 코드를 수정하지 않고 복제 슬롯의 출력을 소비하는 추가 방법을 작성할 수도 있다.

## Logical Decoding Examples

다음 예제는 SQL 인터페이스를 사용하여 논리적 디코딩을 제어하는 방법을 보여준다.

논리적 디코딩을 사용하려면 먼저 wal_level을 `logical`로, max_replication_slots를 최소 `1` 이상으로 설정해야 한다.
그 후 대상 DB에 수퍼유저로 연결해야 한다.

```postgresql
postgres=# -- Create a slot named 'regression_slot' using the output plugin 'test_decoding'
postgres=# SELECT * FROM pg_create_logical_replication_slot('regression_slot', 'test_decoding');
    slot_name    |    lsn
-----------------+-----------
 regression_slot | 0/16B1970
(1 row)

postgres=# SELECT slot_name, plugin, slot_type, database, active, restart_lsn, confirmed_flush_lsn FROM pg_replication_slots;
    slot_name    |    plugin     | slot_type | database | active | restart_lsn | confirmed_flush_lsn
-----------------+---------------+-----------+----------+--------+-------------+-----------------
 regression_slot | test_decoding | logical   | postgres | f      | 0/16A4408   | 0/16A4440
(1 row)

postgres=# -- There are no changes to see yet
postgres=# SELECT * FROM pg_logical_slot_get_changes('regression_slot', NULL, NULL);
 lsn | xid | data 
-----+-----+------
(0 rows)

postgres=# CREATE TABLE data(id serial primary key, data text);
CREATE TABLE

postgres=# -- DDL isn't replicated, so all you'll see is the transaction
postgres=# SELECT * FROM pg_logical_slot_get_changes('regression_slot', NULL, NULL);
    lsn    |  xid  |     data     
-----------+-------+--------------
 0/BA2DA58 | 10297 | BEGIN 10297
 0/BA5A5A0 | 10297 | COMMIT 10297
(2 rows)

postgres=# -- Once changes are read, they're consumed and not emitted
postgres=# -- in a subsequent call:
postgres=# SELECT * FROM pg_logical_slot_get_changes('regression_slot', NULL, NULL);
 lsn | xid | data 
-----+-----+------
(0 rows)

postgres=# BEGIN;
postgres=# INSERT INTO data(data) VALUES('1');
postgres=# INSERT INTO data(data) VALUES('2');
postgres=# COMMIT;

postgres=# SELECT * FROM pg_logical_slot_get_changes('regression_slot', NULL, NULL);
    lsn    |  xid  |                          data                           
-----------+-------+---------------------------------------------------------
 0/BA5A688 | 10298 | BEGIN 10298
 0/BA5A6F0 | 10298 | table public.data: INSERT: id[integer]:1 data[text]:'1'
 0/BA5A7F8 | 10298 | table public.data: INSERT: id[integer]:2 data[text]:'2'
 0/BA5A8A8 | 10298 | COMMIT 10298
(4 rows)

postgres=# INSERT INTO data(data) VALUES('3');

postgres=# -- You can also peek ahead in the change stream without consuming changes
postgres=# SELECT * FROM pg_logical_slot_peek_changes('regression_slot', NULL, NULL);
    lsn    |  xid  |                          data                           
-----------+-------+---------------------------------------------------------
 0/BA5A8E0 | 10299 | BEGIN 10299
 0/BA5A8E0 | 10299 | table public.data: INSERT: id[integer]:3 data[text]:'3'
 0/BA5A990 | 10299 | COMMIT 10299
(3 rows)

postgres=# -- The next call to pg_logical_slot_peek_changes() returns the same changes again
postgres=# SELECT * FROM pg_logical_slot_peek_changes('regression_slot', NULL, NULL);
    lsn    |  xid  |                          data                           
-----------+-------+---------------------------------------------------------
 0/BA5A8E0 | 10299 | BEGIN 10299
 0/BA5A8E0 | 10299 | table public.data: INSERT: id[integer]:3 data[text]:'3'
 0/BA5A990 | 10299 | COMMIT 10299
(3 rows)

postgres=# -- options can be passed to output plugin, to influence the formatting
postgres=# SELECT * FROM pg_logical_slot_peek_changes('regression_slot', NULL, NULL, 'include-timestamp', 'on');
    lsn    |  xid  |                          data                           
-----------+-------+---------------------------------------------------------
 0/BA5A8E0 | 10299 | BEGIN 10299
 0/BA5A8E0 | 10299 | table public.data: INSERT: id[integer]:3 data[text]:'3'
 0/BA5A990 | 10299 | COMMIT 10299 (at 2017-05-10 12:07:21.272494-04)
(3 rows)

postgres=# -- Remember to destroy a slot you no longer need to stop it consuming
postgres=# -- server resources:
postgres=# SELECT pg_drop_replication_slot('regression_slot');
 pg_drop_replication_slot
-----------------------

(1 row)
```

아래 예제는 PostgreSQL 배포판에 포함된 pg_recvlogical 프로그램을 사용해 스트리밍 복제 프로토콜을 통해 논리적 디코딩을 제어하는 방법을 보여준다.
이를 위해서는 클라이언트 인증이 복제 연결을 허용하도록 설정되고 난 뒤 max_wal_senders가 추가 연결을 허용할 만큼 설정되어야 한다.

```bash
pg_recvlogical -d postgres --slot=test --create-slot
pg_recvlogical -d postgres --slot=test --start -f -
(ctrl + z)
psql -d postgres -c "INSERT INTO data(data) VALUES ('4');"
fg
BEGIN 693
table public.data: INSERT: id[integer]:4 data[text]:'4'
COMMIT 693
(ctrl + c)
pg_recvlogical -d postgres --slot=test --drop-slot
```

## Logical Decoding Concepts

### 논리적 디코딩

논리적 디코딩은 DB의 내부 상태에 대한 자세한 지식 없이 해석할 수 있는 일관되고 이해하기 쉬운 형식으로 DB 테이블에 대한 지속적인 변경 사항을 추출하는 프로세스이다.

PostgreSQL에서 논리적 디코딩은 스토리지 수준의 변경 사항을 설명하는 미리 쓰기 로그의 내용을 튜플이나 SQL문 스트림과 같은 애플리케이션 별 형식으로 디코딩하여 구현된다.

### 복제 슬롯

논리적 복제의 맥락에서 슬롯은 원본 서버에서 만들어진 순서대로 클라이언트에 재생할 수 있는 변경 사항의 스트림을 나타낸다.
각 슬롯은 단일 DB에서 일련의 변경 사항을 스트리밍 한다(PostgreSQL에는 스트리밍 복제 슬롯도 있으나 다르게 사용된다.).

복제 슬롯에는 PostgreSQL 클러스터의 모든 DB에서 고유한 식별자가 있다.
슬롯은 슬롯을 사용하는 연결과 독립적으로 유지되며 충돌로 부터 안전하다.

논리 슬롯은 정상 작동 시 각 변경 사항을 한 번만 내보낸다.
각 슬롯의 현재 위치는 체크포인트에서만 유지되므로 충돌 발생 시 슬롯이 이전 LSN으로 돌아갈 수 있다.
위의 경우 서버가 다시 시작될 때 최근 변경 사항이 다시 전송된다.
논리적 디코딩 클라이언트는 동일한 메세지를 두 번 이상 처리하여 악영향을 방지할 책임이 있다(멱등성 등을 이야기하는 것으로 보인다.).
클라이언트는 디코딩할 때 본 마지막 LSN을 기록하고 반복되는 데이터를 건너뛰거나 서버가 시작점을 결정하도록 하는 대신 해당 LSN에서 디코딩을 시작하도록 요청할 수 있다.
복제 진행률 추적 기능은 이 목적을 위해 설계되었다([복제 원본](https://www.postgresql.org/docs/11/replication-origins.html) 참조).

단일 DB에 대해 여러 독립 슬롯이 존재 가능하다.
각 슬롯에는 고유한 상태가 있어 서로 다른 소비자가 DB 변경 스트림의 서로 다른 지점에서 변경 사항을 수신할 수 있다.
대부분의 애플리케이션의 경우 각 소비자마다 별도의 슬롯이 필요하다.

논리적 복제 슬롯은 수신 측 상태에 대해 모른다.
다른 시간에 동일한 슬롯을 사용하는 여러 다른 수신자를 갖는 것도 가능하다.
논리적 복제 슬롯은 마지막 수신자가 소비하는 것을 멈추었을 때 부터 변경 사항을 수집한다.
주어진 시간에 하나의 수신자만 슬롯의 변경 사항을 사용할 수 있다.

복제 슬롯은 충돌 시 지속되며 소비자의 상태에 대해 모른다.
이를 사용하는 연결이 없는 경우에도 필수 리소스 제거를 방지한다.
필수 WAL이나 시스템 카탈로그의 필수 행이 복제 슬롯에 필요한 한 VACUUM에 의해 제거될 수 없기에 저장 공간을 소비하며 최악의 경우 트랜잭션 ID Wraparound를 방지하기 위해 DB가 종료될 수 있다.
슬롯이 더 이상 필요하지 않는 경우 삭제해야 한다.

### 출력 플러그인

출력 플러그인은 WAL의 내부 표현 데이터를 복제 슬롯의 소비자가 원하는 형식으로 변환한다.

### 내보낸 스냅샷

스트리밍 복제 인터페이스를 사용해 새 복제 슬롯을 생성되면 모든 변경 사항이 변경 스트림에 포함된 후 DB의 상태를 정확하게 보여주는 스냅샷이 내보내진다.
슬롯이 생성된 시점의 DB 상태를 읽기 위해 `SET TRANSACTION SNAPSHOT`을 사용해 새 복제본을 생성하는 데 사용할 수 있다.
그 후 이 트랜잭션을 사용해 해당 시점의 DB 상태를 덤프할 수 있으며 이후 변경 사항을 잃지 않고 슬롯의 내용을 사용하여 업데이트 가능하다.

스냅샷 생성이 항상 가능하지는 않다.
상시 대기에 연결될 경우 실패한다.
스냅샷 내보내기가 필요하지 않은 애플리케이션은 `NOEXPORT_SNAPSHOT` 옵션을 사용해 스냅샷 내보내기를 억제할 수 있다.

## Streaming Replication Protocol Interface

-   `CREATE_REPLICATION_SLOT slot_nameLOGICAL output_plugin`
-   `DROP_REPLICATION_SLOT slot_name [ WAIT ]`
-   `START_REPLICATION SLOT slot_name LOGICAL ...`

위 명령들은 각각 복제 슬롯에서 변경 사항을 생성, 삭제, 스트리밍하는 데 사용된다.
이러한 명령은 복제 연결을 통해서만 사용할 수 있다.
SQL을 통해서는 사용할 수 없다.

pg_recvlogical 명령은 스트리밍 복제 연결을 통한 논리적 디코딩을 제어하는 데 사용할 수 있다.

## Logical Decoding SQL Interface

>   [논리적 디코딩과 상호 작용하기 위한 SQL 수준 API에 대한 문서](https://www.postgresql.org/docs/11/functions-admin.html#FUNCTIONS-REPLICATION)
>
>   [스트리밍 복제 인터페이스를 통해 사용되는 복제 슬롯에서만 지원되는 동기식 복제](https://www.postgresql.org/docs/11/warm-standby.html#SYNCHRONOUS-REPLICATION)

함수 인터페이스와 추가 비핵심 인터페이스는 동기식 복제를 지원하지 않는다.

## System Catalogs Related to Logical Decoding

`pg_replication_slots`뷰와 `pg_stat_replication`뷰는 각각 복제 슬롯 및 스트리밍 복제 연결의 현재 상태에 대한 정보를 제공한다.
이러한 뷰는 물리적 복제와 논리적 복제 모두에 적용된다.

## Logical Decoding Output Plugins

예제 출력 플러그인은 PostgreSQL 소스 트리의 contrib/test_decoding 하위 디렉터리에서 찾을 수 있다.

### 초기화 기능

출력 플러그인은 출력 플러그인의 이름을 라이브러리 기본 이름으로 사용하여 공유 라이브러리를 동적으로 로드한다.
일반 라이브러리 검색 경로는 라이브러리를 찾는 데 사용된다.
필요한 출력 플러그인 콜백을 제공하고 라이브러리가 실제로 출력 플러그인임을 나타내려면 `_PG_output_plugin_init`이라는 함수를 제공해야 한다.
이 함수에는 개별 작업에 대한 콜백 함수 포인터로 채워야 하는 구조체가 전달된다.

```c
typedef struct OutputPluginCallbacks
{
    LogicalDecodeStartupCB startup_cb;
    LogicalDecodeBeginCB begin_cb;
    LogicalDecodeChangeCB change_cb;
    LogicalDecodeTruncateCB truncate_cb;
    LogicalDecodeCommitCB commit_cb;
    LogicalDecodeMessageCB message_cb;
    LogicalDecodeFilterByOriginCB filter_by_origin_cb;
    LogicalDecodeShutdownCB shutdown_cb;
} OutputPluginCallbacks;

typedef void (*LogicalOutputPluginInit) (struct OutputPluginCallbacks *cb);
```

`begin_cb`, `change_cb`, `commit_cb` 콜백은 필수이며 `startup_cb`, `filter_by_origin_cb`, `truncate_cb`, `shutdown_cb`는 선택 사항이다.
`truncate_cb`가 설정되지 않았지만 `TRUNCATE`가 디코딩되는 경우 작업이 무시된다.

### 기능

디코딩할 때 형식 변경과 출력 변경을 위해 출력 플러그인은 출력 함수 호출을 포함해 대부분의 백엔드 일반 인프라를 사용 가능하다.
관계에 대한 읽기 전용 접근은 `pg_catalog` 스키마에서 `initdb`에 의해 생성되었거나 아래 명령을 사용해 사용자 제공 카탈로그 테이블로 표시된 관계에만 접근되는 한 허용된다.

```postgresql
ALTER TABLE user_catalog_table SET (user_catalog_table = true);
CREATE TABLE another_catalog_table(data text) WITH (user_catalog_table = true);
```

트랜잭션 ID 할당으로 이어지는 모든 행위는 금지된다.
여기에는 테이블 쓰기, DDL 변경 수행, txid_current() 호출이 포함된다.

### 출력 모드

출력 플러그인 콜백은 거의 임의의 형식으로 소비자에게 데이터를 전달할 수 있다.
SQL을 통해 변경 사항을 보는 것과 같은 일부 사용 사례의 경우 임의의 데이터(bytea와 같이)를 포함할 수 있는 데이터 유형으로 데이터를 변환하는 것은 까다롭다.
출력 플러그인이 서버의 인코딩으로 텍스트 데이터만 출력하는 경우 시작 콜백에서 `OutputPluginOptions.output_type`을 `OUTPUT_PLUGIN_BINARY_OUTPUT` 대신 `OUTPUT_PLUGIN_TEXTUAL_OUTPUT`으로 설정해 선언할 수 있다.
이 경우 모든 데이터는 텍스트 데이텀(datum)에 포함될 수 있도록 서버의 인코딩에 존재해야 한다.

### 출력 플러그인 콜백

출력 플러그인은 제공해야 하는 다양한 콜백을 통해 발생하는 변경 사항에 대한 알림을 받는다.

동시 트랜잭션은 커밋 순서대로 디코딩되며 특정 트랜잭션에 속하는 변경 사항만 시작 및 커밋 콜백 사이에 디코딩된다.
명시적이거나 암시적으로 롤백된 트랜잭션은 디코딩되지 않는다.
성공적인 세이브포인트는 해당 트랜잭션 내에서 실행된 순서대로 이를 포함하는 트랜잭션으로 접힌다(folded).

이미 안전하게 디스크에 플러시된 트랜잭션만 디코딩된다.
이는 `synchronous_commit`이 `off`로 설정되었을 때 바로 뒤에 오는 `pg_logical_slot_get_changes()`에서 즉시 디코딩되지 않는 COMMIT으로 이어질 수 있다.

#### 시작 콜백

선택적인 `startup_cb` 콜백은 배포할 준비가 된 변경 사항의 수와 관계없이 복제 슬롯이 생성되거나 변경 사항을 스트리밍하도록 요청할 때마다 호출된다.

```c
typedef void (*LogicalDecodeStartupCB) (struct LogicalDecodingContext *ctx,
                                        OutputPluginOptions *options,
                                        boot is_init);
```

`is_init` 매개변수는 복제 슬롯이 생성될 때 true이고 그렇지 않으면 false이다.
options 출력 플러그인이 설정할 수 있는 옵션의 구조체를 가르킨다.

```c
typedef struct OutputPluginOptions
{
	OutputPluginOutputType	output_type;
    bool					receive_rewrites;
} OutputPluginOptions;
```

`output_type`은 `OUTPUT_PLUGIN_TEXTUAL_OUTPUT`이나  `OUTPUT_PLUGIN_BINARY_OUTPUT`으로 설정되어야 한다.
`receive_rewrites`가 true인 경우 특정 DDL 작업 중에 힙 재작성에 의해 변경된 사항에 대해 출력 플러그인도 호출된다.
이들은 DDL 복제를 처리하는 플러그인에 관심이 있지만 특별한 처리가 필요하다.

시작 콜백은 `ctx->output_plugin_options`에 있는 옵션의 유효성을 검사해야 한다.
출력 플러그인에 상태가 필요한 경우 `ctx->output_plugin_private`를 사용하여 저장할 수 있다.

#### 종료 콜백

선택적 `shutdown_cb` 콜백은 이전의 활성 복제 슬롯이 더 이상 사용되지 않을 때마다 호출되며 출력 플러그인 전용 리소스 할당을 해제하는 데 사용할 수 있다.
슬롯이 반드시 삭제되는 것은 아니며 스트리밍이 중지된다.

```c
typedef void (*LogicalDecodeShutdownCB) (struct LogicalDecodingContext *ctx);
```

#### 트랜잭션 시작 콜백

필수 `begin_cb` 콜백은 커밋된 트랜잭션의 시작이 디코딩될 때마다 호출된다.
중단된 트랜잭션과 그 내용은 절대 디코딩되지 않는다.

```c
typedef void (*LogicalDecodeBeginCB) (struct LogicalDecodingContext *ctx,
                                      ReorderBufferTXN *txn);
```

`txn` 매개변수에는 트랜잭션이 커밋된 타임스탬프와 해당 XID와 같은 트랜잭션에 대한 메타 정보가 포함된다.

#### 트랜잭션 종료 콜백

필수 `commit_cb` 콜백은 트랜잭션 커밋이 디코딩될 때마다 호출된다.
수정된 행이 있는 경우 수정된 모든 행에 대한 `change_cb` 콜백이 `commit_cb`보다 먼저 호출된다.

```c
typedef void (*LogicalDecodeCommitCB) (struct LogicalDecodingContext *ctx,
                                       ReorderBufferTXN *txn,
                                       XLogRecPtr commit_lsn);
```

#### 변경 사항 콜백

필수 `change_cb` 콜백은 트랜잭션 내부의 모든 개별 행 수정에 대해 호출되며 INSERT, UPDATE, DELETE일 수 있다.
원래 명령이 한 번에 여러 행을 수정하여도 콜백은 각 행에 대해 개별적으로 호출된다.

```c
typedef void (*LogicalDecodeChangeCB) (struct LogicalDecodingContext *ctx,
                                       ReorderBufferTXN *txn,
                                       Relation relation,
                                       ReorderBufferChange *change);
```

`ctx`와 `txn` 매개변수의 내용은 `begin_cb`와 `commit_cb` 콜백과 동일하지만 추가로 행이 속한 관계를 가리키는 관계 설명자 관계와 행 수정을 설명하는 구조체 변경이 전달된다.

로그되지 않고 임시가 아닌 사용자 정의 테이블의 변경 사항만 논리적 디코딩을 사용해 추출 가능하다.

#### Truncate 콜백

`truncate_cb` 콜백은 TRUNCATE 명령에 대해 호출된다.

```c
typedef void (*LogicalDecodeTruncateCB) (struct LogicalDecodingContext *ctx,
                                         ReorderBufferTXN *txn,
                                         int nrelations,
                                         Relation relations[],
                                         ReorderBufferChange *change);
```

`change_cb` 콜백과 매개변수가 유사하나 외래 키로 연결된 테이블에 대한 TRUNCATE 작업은 함께 실행되어야 하므로 이 콜백은 하나의 관계가 아닌 관계의 배열을 받는다.

#### Origin 필터 콜백

선택적 `filter_by_origin_cb` 콜백은 `origin_id`에서 재생된 데이터가 출력 플러그인에 관심이 있는지 여부를 결정하기 위해 호출된다.

```c
typedef bool (*LogicalDecodeFilterByOriginCB) (struct LogicalDecodingContext *ctx,
                                               RepOriginId origin_id);
```

`ctx` 매개변수는 다른 콜백과 동일한 내용을 가진다.
정보가 없지만 출처(origin)은 있다.
전달된 노드에서 발생한 변경 사항이 관련이 없다는 신호를 보내려면 true를 반환해 해당 변경 사항이 필터링되도록 한다.
다른 콜백은 필터링된 트랜잭션과 변경 사항에 대해 호출되지 않는다.

계단식 또는 다방향 복제 솔루션을 구현할 때 유용하다.
원본으로 필터링하면 이런 설정에서 동일한 변경 사항을 앞뒤로 복제하는 것을 방지할 수 있다.
트랜잭션과 변경 사항도 원본에 대한 정보를 전달하나 이 콜백을 통한 필터링이 훨씬 더 효율적이다.

#### 일반 메세지 콜백

선택적 `message_cb` 콜백은 논리적 디코딩 메세지가 디코딩될 때마다 호출된다.

```c
typedef void (*LogicalDecodeMessageCB) (struct LogicalDecodingContext *ctx,
                                        ReorderBufferTXN *txn,
                                        XLogRecPtr message_lsn,
                                        bool transactional,
                                        const char *prefix,
                                        Size message_size,
                                        const char *message);
```

`txn` 매개변수에는 트랜잭션이 커밋된 타임스탬프와 해당 XID와 같은 트랜잭션에 대한 메타 정보가 포함된다.
메세지가 트랜잭션이 아니며 메세지를 기록한 트랜잭션에서 XID가 아직 할당되지 않은 경우 NULL이 될 수 있다.
`lsn`에는 메세지의 WAL 위치가 있다.
`transactional`은 메세지가 트랜잭션으로 전송되었는지 여부를 나타낸다.
`prefix`는 현재 플러그인에 대한 흥미로운 메세지를 식별하는 데 사용할 수 있는 임의의 null 종료 접두사이다.
`message` 매개변수는 `message_size` 크기의 실제 메세지를 보유한다.

출력 플러그인이 관심 있는 것으로 간주하는 접두사가 고유한지 확인하기 위해 각별한 주의를 기울여야 한다.

### 출력 생성 기능

실제로 출력을 생성하기 위해 출력 플러그인은 `begin_cb`, `commit_cb`, `change_cb` 콜백 내부에서 `ctx->out`의 `StringInfo` 출력 버퍼에 데이터를 쓸 수 있다.
출력 버퍼에 쓰기 전 `OutputPluginPrepareWrite(ctx, last_write)`를 호출해야 하며, 버퍼에 쓰기를 마친 후에는 `OutputPluginWrite(ctx, last_write)`를 호출하여 쓰기를 수행해야 한다.
`last_wrtie`는 특정 쓰기가 콜백의 마지막 쓰기인 지 여부를 나타낸다.

아래 예시는 출력 플러그인의 소비자에게 데이터를 출력하는 방법을 보여준다.

```c 
OutputPluginPrepareWrite(ctx, true);
appendStringInfo(ctx->out, "BEGIN %u", txn->xid);
OutputPluginWrite(ctx, true);
```

## Logical Decoding Output Writers

논리적 디코딩을 위해 더 많은 출력 방법을 추가할 수 있다.

>   [src/backend/replication/logical/logicalfuncs.c](https://github.com/postgres/postgres/blob/REL_11_STABLE/src/backend/replication/logical/logicalfuncs.c)

기본적으로 세 가지 기능이 제공되어야 한다(WAL을 읽고, 쓰기 출력을 준비하고, 출력을 쓰는 기능).

## Synchronous Replication Support for Logical Decoding

### 개요

스트리밍 복제를 위한 동기식 복제와 동일한 사용자 인터페이스로 동기식 복제 솔루션을 구축하는 데 논리적 디코딩을 사용할 수 있다.
위 내용과 같이 논리적 디코딩을 사용하려면 스트리밍 복제 인터페이스를 사용하여 데이터를 스트리밍해야 한다.
클라이언트는 스트리밍 복제 클라이언트와 마찬가지로 `Standby status update (F)` 메세지를 보내야 한다.

논리적 디코딩을 통해 변경 사항을 수신하는 동기식 복제본은 단일 데이터베이스 범위에서 작동한다.
이와 대조적으로 `synchronous_standby_names`는 현재 서버 전체이므로 둘 이상의 데이터베이스가 활발하게 사용되는 경우 이 기술이 제대로 작동하지 않는다.

### 주의 사항

동기식 복제 설정에서 트랜잭션이 [user] 카탈로그 테이블을 독점적으로 잠근 경우 교착 상태가 발생할 수 있다.
이는 트랜잭션의 논리적 디코딩이 카탈로그 테이블을 잠궈 접근할 수 있기 때문이다.
이를 방지하기 위해 사용자는 [user] 카탈로그 테이블에 대한 베타적 잠금을 지양해야 한다.
베타적 잠금은 아래와 같은 방식으로 발생할 수 있다.

-   트랜잭션에서 `pg_class`에 대한 명시적 `LOCK` 발행
-   트랜잭션의 `pg_class`에서 `CLUSTER`를 수행
-   트랜잭션의 [user] 카탈로그 테이블에서 TRUNCATE 실행

교착 상태를 유발할 수 있는 명령은 위에서 명시적으로 표시된 시스템 카탈로그 테이블 뿐만 아니라 다른 [user] 카탈로그 테이블에도 적용된다.

# Reference
