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



### 출력 모드

### 출력 플러그인 콜백

### 출력 생성 기능
