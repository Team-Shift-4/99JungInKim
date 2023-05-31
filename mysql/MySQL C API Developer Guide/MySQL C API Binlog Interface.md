# MySQL 8.0 C API Binary Log Interface 개요

* `mysql`이 유효한 Connection Handler란 가정
* 초기 `set`문은 Server가 Client가 Checksum을 인식한다는 표시로 `@source_binlog_checksum` 사용자 정의 변수를 설정
    * 이 Client는 Checksum을 사용하지 않지만 이 `set`문이 없다면 Binary Log Event에 Checksum을 포함하는 Server가 Checksum을 포함하는 Event를 읽을 때 오류 반환

```c
if (mysql_query(mysql, "SET @source_binlog_checksum='ALL'"))
{
  fprintf(stderr, "mysql_query() failed\n");
  fprintf(stderr, "Error %u: %s\n",
           mysql_errno(mysql), mysql_error(mysql));
  exit(1);
}

MYSQL_RPL rpl;

rpl.file_name_length = 0;
rpl.file_name = NULL;
rpl.start_position = 4;
rpl.server_id = 0;
rpl.flags = 0;

if (mysql_binlog_open(mysql, &rpl))
{
  fprintf(stderr, "mysql_binlog_open() failed\n");
  fprintf(stderr, "Error %u: %s\n",
           mysql_errno(mysql), mysql_error(mysql));
  exit(1);
}
for (;;)  /* read events until error or EOF */
{
  if (mysql_binlog_fetch(mysql, &rpl))
  {
    fprintf(stderr, "mysql_binlog_fetch() failed\n");
    fprintf(stderr, "Error %u: %s\n",
             mysql_errno(mysql), mysql_error(mysql));
    break;
  }
  if (rpl.size == 0)  /* EOF */
  {
    fprintf(stderr, "EOF event received\n");
    break;
  }
  fprintf(stderr, "Event received of size %lu.\n", rpl.size);
}
mysql_binlog_close(mysql, &rpl);
```

다른 예시

> [`client` Directory 안의 `mysqlbinlog.cc`](https://github.com/mysql/mysql-server/blob/8.0/client/mysqlbinlog.cc)
>
> [`testclients` Directory 안의 `mysql_client_test.cc`](https://github.com/mysql/mysql-server/blob/8.0/testclients/mysql_client_test.cc)

# C API Binary Log 데이터 구조

Replication Event Stream을 처리하기 위한 C API Function은 Connection Handler(`mysql *` pointer)와 Server Binary Log에서 읽을 Replication Event Stream을 설명하는 `MYSQL_RPL` 구조 Pointer가 필요

```c
MYSQL *mysql = mysql_real_connect(...);

MYSQL_RPL rpl;

# ... initialize MYSQL_RPL members ...

int result = mysql_binlog_open(mysql, &rpl);
```

적용 가능한 `MYSQL_RPL` 구조 Member는 수행할 Binary Log에 따라 다름

* `mysql_binlog_open()` 호출 전 Caller는 반드시 `MYSQL_RPL` Member를 `file_name_length` 부터 `flags`까지 설정해야 함
    * `flags`에 `MYSQL_RPL_GTID` flag가 설정되어 있는 경우 Caller는 반드시 `gtid_set_encoded_size`부터 `gtid_set_arg`까지 설정해야 함
* `mysq_binlog_fetch()` 호출 성공시 Caller는 `size`와 `buffer` Member를 검사

`MYSQL_RPL` 구조 Member 설명

* `file_name_length`

    * 읽을 Binary Log File의 이름의 길이, `file_name`과 함께 사용

* `file_name`

    * 읽을 Binary Log File의 이름
        * `file_name`이 `NULL`일 경우 Client Library는 빈 문자열로 설정하고 `file_name_length`는 0이 됨
        * `file_name`이 `NULL`이 아닐 경우 `file_name_length`는 이름의 길이이거나 0이여야 함
            * `file_name_length`가 0이면 Client Library는 `file_name`의 길이로 설정해야 함
                이 경우 `file_name`을 null-terminated String으로 지정해야 함
    * 가장 오래된 Binary Log File을 처음 부터 읽기 위해 `filename`은 `NULL`이나 빈 String으로 지정하고 `start_position`을 4로 지정

* `start_position`

    * Binary Log File을 읽기 시작할 위치
    * 첫 Event의 위치는 4

* `server_id`

    * Binary Log를 읽을 Server를 식별할 Server ID

* `flags`

    * Binary Log 읽기에 영향을 미치는 Flag의 조합, Flag 없을 시 0

        * `MYSQL_RPL_SKIP_HEARTBEAT`

            * `mysql_binlog_fetch()`가 heartbeat Event를 스킵하도록 설정하는 Flag

        * `MYSQL_RPL_GTID`

            * Global Transaction ID Data를 읽기 위해 설정하는 Flag

            * 설정된 경우 `mysql_binlog_open()`을 호출하기 전 `gtid_set_encoded_size`에서 `gtid_set_arg`로 `MYSQL_RPL` 구조 GTID 관련 Member를 초기화해야 함

                > [Client Program이 이런 GTID 관련 Member를 참조하기 위한 링크(mysqlbinlog.cc)](https://github.com/mysql/mysql-server/blob/8.0/client/mysqlbinlog.cc)
                >
                > [GTID-based Replication 관련 내용(Global Transaction Identifiers)](https://dev.mysql.com/doc/refman/8.0/en/replication-gtids.html)

* `gtid_set_encoded_size`

    * GTID 집합 데이터 크기이거나 0

* `fix_gtid_set`

    * Command Packet GTID 집합을 채우기 위해 호출할 `mysql_binlog_open()`에 대한 Callback Function의 주소, 함수 없을 시 `NULL`

    * Callback Function을 사용할 경우 다음 Call Signature가 있어야 함

        ```c
        void my_callback(MYSQL_RPL *rpl, unsigned char *packet_gtid_set);
        ```

* `gtid_set_arg`

    * GTID 집합 데이터에 대한 Pointer(`fix_gtid_set`이 `NULL`인 경우)나 Callback Function 내에서 사용할 수 있는 값에 대한 Pointer(`fix_gtid_set`이 `NULL`이 아닌 경우)
    * `gtid_set_arg`는 일반적인 Pointer이므로 모든 종류의 값을 가리킬 수 있음
    * Callback 내의 Callback의 해석은 Callback이 Callback을 어떻게 사용할 것인지에 따라 다름

* `size`

    * `mysql_binlog_fetch()` 호출 성공 후 반환 받은 Binary Log Event 크기
    * EOF Event의 경우 0, 아닐 경우 0보다 큼

* `buffer`

    * `mysql_binlog_fetch()` 호출 성공 후 Binary Log Event Content의 Pointer가 표시

# C API Binary Log Function 참조

| Name                                              | Description                             |
| :------------------------------------------------ | --------------------------------------- |
| [`mysql_binlog_close()`](#`mysql_binlog_close()`) | Replication Event Stream 닫기           |
| [`mysql_binlog_fetch()`](#`mysql_binlog_fetch()`) | Replication Event Stream에서 Event 읽기 |
| [`mysql_binlog_open()`](#`mysql_binlog_open()`)   | Replication Event Stream 열기           |



# C API Binary Log Function 설명

## `mysql_binlog_close()`

```c
void mysql_binlog_close(MYSQL *mysql, MYSQL_RPL *rpl)
```

### 설명

Replication Event Stream 닫기

Arguments

* `mysql`: `mysql_init()`에서 Connection Handler가 반환, `mysql_binlog_close()` 호출 후에도 Handler는 Open 상태
* `rpl`: Replication Stream 구조, `mysql_binlog_close()` 호출 후 다시 초기화 후 `mysql_binlog_open()`을 호출하지 않을 시 이 구조를 다시 사용할 수 없음

## `mysql_binlog_fetch()`

```c
int mysql_binlog_fetch(MYSQL *mysql, MYSQL_RPL *rpl)
```

### 설명

Replication Event Stream에서 Event 읽기

Arguments

* `mysql`: `mysql_init()`에서 Connection Handler가 반환
* `rpl`: Replication Stream 구조, 호출 성공 시 `size` Member가 Event의 크기를 표현함, EOF Event의 경우 0, EOF가 아닌 경우 0보다 크고 `buffer` Member가 Event Content를 가리킴

### 반환값

성공 시 0, 실패 시 0이 아닌 다른 값

## `mysql_binlog_open()`

```c
int mysql_binlog_open(MYSQL *mysql, MYSQL_RPL *rpl)
```

### 설명

Replication Event Stream 열기

Arguments

* `mysql`: `mysql_init()`에서 Connection Handler가 반환
* `rpl`: Replication Event Stream Source를 나타내기 위해 초기화된 `MYSQL_RPL` 구조

### 반환값

성공 시 0, 실패 시 0이 아닌 다른 값

### 에러

- [`CR_FILE_NAME_TOO_LONG`](https://dev.mysql.com/doc/mysql-errors/8.0/en/client-error-reference.html#error_cr_file_name_too_long)
    - Binary Log File 이름이 너무 길 때 발생하는 에러
- [`CR_OUT_OF_MEMORY`](https://dev.mysql.com/doc/mysql-errors/8.0/en/client-error-reference.html#error_cr_out_of_memory)
    - Memory 부족 시 발생하는 에러