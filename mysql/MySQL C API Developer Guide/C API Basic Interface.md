# C API Basic Interface 개요

Application Program은 Client Library를 통해 MySQL과 상호 작용하기 위해 다음과 같은 일반적 개요을 사용:

1. `mysql_library_init()`을 호출해 MySQL Client Library를 초기화
2. `mysql_init()`을 호출해 Connection Handler를 초기화하고 `mysql_real_connect()`와 같은 Connection 설정 함수를 호출해 Server에 연결
3. SQL Statement를 발급하고 Result 처리
4. `mysql_close()` 호출해 MySQL Server에 대한 Connection 닫음
5. `mysql_library_end()` 호출해 MySQL Client Library 종료

`mysql_library_init()`과 `mysql_library_end()`를 호출하는 이유는 MySQL Client Library의 적절한 초기화와 종료를 제공하기 위함
Client Library와 Connect된 Application의 경우 향상된 Memory 관리 기능을 제공
`mysql_library_end()`를 호출하지 않을 시 Memory Block이 할당된 채로 남아있음(Memory 사용량이 증가하지 않으나 누수 감지)

Non-MultiThread 환경에서 `mysql_library_init()`에 대한 호출이 생략될 수 있음(`mysql_init()`이 필요에 따라 자동 호출)
`mysql_library_init()`은 MultiThread환경에서 Thread-Safe가 아니므로 `mysql_library_init()`을 호출하는 `mysql_init()`역시 Thread-Safe가 아님
Thread를 생성하기 전 `mysql_library_init()`을 호출하거나 Mutex를 사용해 호출을 보호해야 함
`mysql_library_init()`을 통해 호출해도 `mysql_init()`을 통해 간접적으로 호출해도 상관 없음
이 작업은 다른 Client Library를 호출하기 전에 수행해야 함

Server에 Connect하기 위해 `mysql_init()`을 호출해 Connection Handler를 초기화한 후 해당 Handler를 사용해 `mysql_real_connect()`와 같은 Connection 설정 함수를 호출(Host Name, User Name, Password 등)
Connect가 완료되면 `mysql_close()`를 호출해 종료
Handler를 닫은 후 Handler를 사용하면 안됨

Connect 시 `mysql_real_connect()`는 Reconnection Flag(`MYSQL`구조의 일부)를 0으로 설정
`MYSQL_OPT_RECONNECT` Option을 `mysql_options()`에 사용해 Reconnect 동작을 제어할 수 있음
Flag가 1일 시 Reconnect를 실행하기 전에 Server에 다시 연결하려고 시도함

Connection이 활성화되어 있는 동인 Client는 `mysql_real_query()`나 `mysql_query()`를 사용해 SQL Statement를 Server로 송신 가능
`mysql_query()`는 Query가 `null-terminated` 문자열로 지정되는 반면 `mysql_real_query`는 Count된 문자열로 지정
문자열에 Binary Data(`NULL` Byte가 포함될 수 있음)가 포함될 경우 `mysql_real_query()`를 사용해야 함

각각의 Non-Select Query(INSERT, UPDATE, DELETE)에 대해 `mysql_affected_rows()`를 호출해 몇 개의 Row가 영향받았는지 확인 가능

SELECT Query의 경우 선택한 Row를 Result Set으로 검색(몇 Statement(SHOW, DESCRIBE, EXPLAIN 등)는 SELECT Statement와 동일 처리)

Client가 Result Set을 처리하는 방법 중 하나는 `mysql_store_result()` 호출해 전체 Result Set을 한번에 검색하는 것과 `mysql_use_result()` 호출해 Row 별 Result Set 검색을 하는 것
`mysql_store_result()`는 Query에서 반환된 모든 Row를 Server에서 가져와 Client에 저장
`mysql_use_result()`는 검색을 초기화하나 실제로 Server에서 Row를 가져오지 않음
두 경우 모두 `mysql_fetch_row()`를 호출해 Row에 Access함
`mysql_store_result()`를 사용하면 `mysql_fetch_row()`가 이전에 Server에서 가져온 Row에 Access함
`mysql_use_result()`를 사용할 시 `mysql_fetch_row()`가 실제로 Server에서 Row를 검색함
각 Row에 데이터 크기에 대한 정보는 `mysql_fetch_lengths()`를 호출해 얻을 수 있음

Result Set을 완료한 후 `mysql_free_result()`를 호출해 사용된 Memory를 확보

두 검색 메커니즘은 상호 보완적, 각 Client Application에 적합한 방법을 선택(실제로 Client는 `mysql_store_result()`를 더 자주 사용)

`mysql_store_result()`의 장점은 Row가 모두 Client에 가져오기에 Row가 순차적으로 Access 할 수 있음
`mysql_data_seek()` 또는 `mysql_row_seek()`을 사용해 Result Set 내에서 현재 Row 위치를 변경할 수 있음
`mysql_num_rows()`를 호출해 몇 개의 Row가 있는지 확인 가능
단점은 Memory 요구 사항이 Result Set이 클 경우 매우 클 수 있으며 Memory 부족 상태가 발생할 수 있음

`mysql_use_result()`의 장점은 Client가 헌 번에 하나의 Row만 유지하기에 Result Set에 필요한 Memory가 적음(할당 Overhead가 적어 `mysql_use_result()`가 더 빠를 수 있음)
단점은 Server가 묶이지 않게 각 Row를 신속하게 처리해야 하고 Result Set 내의 Row에 임의로 Access할 수 없음(순차적으로 Row에 Access)
Result Set의 Row 수를 모두 검색해야 알 수 있으며 검색 도중에 찾으려는 Row를 찾아도 모든 Row를 검색해야 함

API를 사용하면 Client가 Statement가 SELECT인지 여부를 알지 못한 채 Statement에 적절히 응답할 수 있음(필요할 때만 Row 검색)
각 `mysql_real_query()`나 `mysql_query()` 이후 `mysql_store_result()`를 호출해 이 작업을 수 있음
Result Set 호출이 성공하면 SELECT 아닐 경우 `mysql_field_count()`를 통해 실제로 SELECT인 지 확인
0인 경우 INSERT, UPDATE, DELETE등의 Statement이며 Row를 반환하지 않음
0이 아닌 경우 SELECT Statement이나 실패한 SELECT임을 나타냄

`mysql_store_result()`와  `mysql_use_result()`를 사용하면 Result Set을 구성하는 Field(Field 수, 이름 및 유형 등)에 대한 정보 수집 가능
`mysql_fetch_field()`를 반복해 호출하거나 `mysql_fetch_field_direct()`를 호출해 Row 내 Field 별 Field 정보에 순차적으로 Access 가능
`mysql_field_seek()`를 호출해 현재 Field Cursor 위치를 변경 가능
Field Cursor를 설정하면 `mysql_fetch_field()`에 대한 후속 호출에 영향 미침
`mysql_fetch_fields()`를 호출해 Field에 대한 정보를 한 번에 얻을 수 있음

오류를 감지, 보고하기 위해 MySQL은 `mysql_errno()`와 `mysql_error()`를 통해 오류 정보에 대한 Access 제공
성공이나 실패할 수 있는 최근 호출된 함수에 대한 오류 코드 또는 메세지를 반환해 오류에 대한 정보 확인 가능

# C API Basic Data Structure

Prepared Statement, Asynchronous(비동기) Interface, Replication Stream Interface에 사용되는 C API 데이터 구조 이외의 데이터 구조

* `MYSQL`
    * 하나의 DB Connection에 대한 Handler(`MYSQL` 구조를 복사해도 사본이 사용 가능하다는 보장이 없음)
* `MYSQL_RES`
    * Row를 반환(SELECT, SHOW, DESCRIBE, EXPLAIN)하는 Query의 결과를 나타냄
    * Query에서 반환된 정보는 이 Section의 Result Set의 나머지 부분에 해당
* `MYSQL_ROW`
    * 데이터의 한 Row를 Type-Safe하게 표현한 것
    * 현재 Count된 Byte 문자열의 배열로 구현
    * Field 값에 Binary Data가 포함될 수 있는 경우 이러한 Value에 내부적으로 `NULL` Byte가 포함될 수 있으므로 `null-terminated` 문자열로 처리할 수 없음
    * Row는 `mysql_fetch_row()`로 가져옴
* `MYSQL_FIELD`
    * Field의 이름, Type, 크기와 같은 Metadata가 포함
    * `mysql_fetch_field()`를 반복해 호출하면 `MYSQL_FIELD`를 얻을 수 있음
* `MYSQL_FIELD_OFFSET`
    * MySQL Field 목록에 Offset을 Type-Safe하게 표현한 것(`mysql_field_seek()`에서 사용)
    * Offset은 Row 내의 Field 번호 0부터 시작
* `my_ulonglong`
    * MySQL 8.0.18 이전 64-bit Unsigned Integer에 사용
    * MySQL 8.0.18 이후 C Type인 uint64_t 사용
* `my_bool`
    * Bool Type, Type은 MySQL 8.0 이전 사용
    * MySQL 8.0 이후 bool이나 C Type을 사용
        * `my_bool`에서 bool로 바꾸었다는 뜻은 Header File인 `mysql.h`을 Complie하기 위해 C++이나 C99 Compiler가 필요하다는 뜻

`MYSQL_FIELD` 구조에는 다음 목록에 설명된 Member가 포함되어 있음
주로 SELECT Statement에서 생성된 Result Set과 같은 Result Set의 Column에 적용
`MYSQL_FIELD` 구조 또한 Prepared `CALL` Statement를 사용해 실행된 Stored_Procedure에서 반환된 `OUT`과 `INOUT` Parameter에 대한 Metadata를 제공하는데 사용
이런 Parameter의 경우 일부 구조 Member는 Column Value와 다른 뜻을 가짐
Result Set에 대한 `MYSQL_FIELD` Member 값을 Interactive하게 보기 위해 `--column-type-info` Option을 사용해 `mysql` Command 호출

- `char * name`
    - `null-terminated` 문자열로 Field 이름
    - `AS` 절로 Alias 지정 시 `name` 값은 Alias
    - Procedure Parameter의 경우 Parameter 이름
- `unsigned int name_length`
    - `name`의 길이
- `char * org_name`
    - `null-terminated` 문자열로 Field 이름
    - `AS`절 Alias 지정 무시 원래 이름
    - Procedure Parameter의 경우 Parameter 이름
- `unsigend int org_length`
    - `org_name`의 길이
- `char * org_table`
    - 계산된 Field가 아닌 경우 이 Field를 포함하는 Table의 이름
    - 계산된 Field의 경우 `table` 값은 빈 문자열
    - Table이나 View에 `AS` 절로 Alias를 지정한 경우 `table` 값은 Alias
    - `UNION`의 경우 `table` 값은 빈 문자열
    - Procedure Parameter의 경우 `table` 값은 Procedure 이름
- `unsigned int table_length`
    - `table`의 길이
- `char * org_table`
    - 계산된 Field가 아닌 경우 이 Field를 포함하는 Table의 이름
    - 계산된 Field의 경우 `org_table` 값은 빈 문자열
    - Alias를 설정해도 무시됨
    - Column이 Expression인 경우 `org_table` 값은 빈 문자열
    - `UNION`의 경우 `org_table` 값은 빈 문자열
    - Procedure Parameter의 경우 Procedure 이름
- `unsigned int org_table_length`
    - `org_table`의 길이
- `char * db`
    - `null-terminated` 문자열로 Field의 원본 DB 이름
    - 계산된 Field일 경우 `db` 값은 빈 문자열
    - `UNION`의 경우 `db` 값은 빈 문자열
    - Procedure Parameter의 경우 Procedure가 들어 있는 DB 이름
- `unsigned int db_length`
    - `db`의 길이
- `char * catalog`
    - Catalog 이름 값은 항상 "def"
- `unsigned int catalog_length`
    - `catalog`의 길이
- `char * def`
    - `null-terminated` 문자열로 이 Feild의 기본 값
    - `mysql_list_fields()`를 사용하는 경우에만 설정
- `unsigned int def_length`
    - `def`의 길이
- `unsigned long length`
    - Field의 너비, Display Length를 Byte로 나타낸 값
    - Server는 Result Set을 생성하기 전 `length` 값을 결정하므로 Result Set에 대한 Query에 의해 생성될 실제 값을 미리 알지 않고 Result Column에서 가능한 가장 큰 값을 유지할 수 있는 Data Type에 필요한 최소 길이
    - 문자열 Column의 경우 Connection Character Set에 따라 `length` 값이 달라짐
- `unsigned long max_length`
    - Result Set에 대한 Field의 최대 너비(Result Set에 실제로 있는 Row에 대한 가장 긴 Field 값의 Byte 단위 길이)
    - `mysql_store_result()` 또는 `mysql_list_fields()`를 사용하는 경우 Field의 최대 길이가 포함
    - `mysql_use_result()`를 사용하는 경우 `max_length`는 0
    - `max_length` 값은 Result Set에 있는 값의 문자열 표현 길이
        - FLOAT Column을 검색한 후 가장 넓은 값이 `-12.345`의 경우 `max_length`는 7
    - Prepared Statemente를 사용하는 경우 Binary Protocol의 길이가 Result Set의 값 Type에 따라 달라지므로 `max_length`는 기본적으로 없음
        - `max_length` 값을 원하는 경우 `mysql_stmt_attr_set()`에서 `STMT_ATTR_UPDATE_MAX_LENGTH` Option을 사용하면 `mysql_store_result()`를 호출할 때 `length`가 설정됨

- `unsigned int flags`

    - Field를 설명하는 Bit-Flag

    - 0개 이상의 Bit Set를 가질 수 있음

        | Flag Value              | Flag Description                                             |
        | :---------------------- | :----------------------------------------------------------- |
        | `NOT_NULL_FLAG`         | Field가 `NOT NULL`                                           |
        | `PRI_KEY_FLAG`          | Field가 Primary Key(의 일부)일 때                            |
        | `UNIQUE_KEY_FLAG`       | Field가 Unique Key(의 일부)일 때                             |
        | `MULTIPLE_KEY_FLAG`     | Field가 Unique Key(의 일부)가 아닐 때                        |
        | `UNSIGNED_FLAG`         | Field가 `UNSIGNED` 속성이 있을 때                            |
        | `ZEROFILL_FLAG`         | Field가 `ZEROFILL` 속성이 있을 때                            |
        | `BINARY_FLAG`           | Field가 `BINARY` 속성이 있을 때                              |
        | `AUTO_INCREMENT_FLAG`   | Field가 `AUTO_INCREMENT` 속성이 있을 때                      |
        | `ENUM_FLAG`             | Field가 [`ENUM`](https://dev.mysql.com/doc/refman/8.0/en/enum.html)일 때 |
        | `SET_FLAG`              | Field가 [`SET`](https://dev.mysql.com/doc/refman/8.0/en/set.html)일 때 |
        | `BLOB_FLAG`             | Field가 [`BLOB`](https://dev.mysql.com/doc/refman/8.0/en/blob.html) 이거나 [`TEXT`](https://dev.mysql.com/doc/refman/8.0/en/blob.html)(미사용) |
        | `TIMESTAMP_FLAG`        | Field가 [`TIMESTAMP`](https://dev.mysql.com/doc/refman/8.0/en/datetime.html)(미사용) |
        | `NUM_FLAG`              | Field 가 numeric일 때 see additional notes following table   |
        | `NO_DEFAULT_VALUE_FLAG` | Field가 기본 값이 없을 때 see additional notes following table |

        이러한 Flag 중 일부는 Data Type 정보를 나타내며 `MYSQL_TYPE_XXX` 값과 함께 쓰이거나 대체됨

        `BLOB`나 `TIMESTAMP` 값을 확인하기 위해 Type이 `MYSQL_TYPE_BLOB`이거나 `MYSQL_TYPE_TIMESTAMP`인지 확인 필요
        (`BLOB_FLAG`나 `TIMESTAMP_FLAG`는 필요 없음)

        `ENUM`과 `SET` 값은 문자열로 반환됨
        Type 값이 `MYSQL_TYPE_STRING`이며 `ENUM_FLAG`나 `SET_FLAG` Flag가 설정되어 있는지 확인 필요

        `NUM_FLAG`는 Column이 숫자임을 나타냄

        - `MySQL_TYPE_DECIMAL`
        - `MYSQL_TYPE_NEWDECIMAL`
        - `MYSQL_TYPE_TINY`
        - `MYSQL_TYPE_SHORT`
        - `MYSQL_TYPE_LONG`
        - `MYSQL_TYPE_FLOAT`
        - `MYSQL_TYPE_DOUBLE`
        - `MYSQL_TYPE_NULL`
        - `MYSQL_TYPE_LONGLONG`
        - `MYSQL_TYPE_INT24`
        - `MYSQL_TYPE_YEAR`

    - `NO_DEFAULT_VALUE_FLAG`는 Column의 정의에 `DEFAULT`절이 없음을 나타냄

        - `NULL` Column과 `AUTO_INCREMENT` Column에는 적용되지 않음

    - Flag 값의 일번적인 사용 예

        ```c
        if (field->flags & NOT_NULL_FLAG)
            printf("Field cannot be null\n");
        ```

        - 아래 표에 표시된 단축 Macro를 사용하여 Flag 값의 Boolean 상태를 알 수 있음

        | Flag Status          | Description                                                  |
        | :------------------- | :----------------------------------------------------------- |
        | `IS_NOT_NULL(flags)` | `TRUE`일 시 Field가 `NOT NULL`                               |
        | `IS_PRI_KEY(flags)`  | `TRUE`일 시 Field가 Primary Key                              |
        | `IS_BLOB(flags)`     | `TRUE`일 시 Field가 [`BLOB`](https://dev.mysql.com/doc/refman/8.0/en/blob.html) or [`TEXT`](https://dev.mysql.com/doc/refman/8.0/en/blob.html) (미사용, 대신 `field->type`) |

- `unsigned int decimals`

    - Numeric Field에 대한 소수 자릿수와 `TIMSTAMP` Field의 소수(초) 정밀도 

- `unsigned int charsetnr`

    - Field에 대한 Character Set/Collation 쌍을 나타내는 ID 번호

        - 일반적으로 Character Set의 `character_set_results` System Variable에 의해 Character Set Indicated로 변환
            - 이 경우 `charsetnr`은 해당 System Variable로 표시된 Character Set Indicated에 해당
        - `character_set_results`를 `NULL`로 설정해 Character Set 변환을 막을 수 있음
            - 이 경우 `charsetnr`은 원 Table Column 또는 Expression의 Character Set에 해당

        > [Connection Character Sets & Collations](https://dev.mysql.com/doc/refman/8.0/en/charset-connection.html)

    - Binary와 Non-Binary 문자열 Data Type을 구분하기 위해 `charsetnr` 값이 63인지 확인

        - 63의 경우 Binary, 아닌 경우 Non-Binary
        - 이 값을 통해 `BINARY`와 `CHAR`, `VARBINARY`와 `VARCHAR`, `BLOG`와 `TEXT`를 구분할 수 있음

    - `charsetnr` 값은 `SHOW COLLACTION` Statement 문의 ID Column이나 `INFORMATION_SCHEMA` `COLLATIONS` Table ID Column 값과 동일

        - 이런 정보 소스를 사용해 Character Set과 Collection 별 `charsetnr` 값 확인 가능:

            ```sql
            SHOW COLLATION WHERE Id = 63;
            +-----------+---------+----+---------+----------+---------+
            | Collation | Charset | Id | Default | Compiled | Sortlen |
            +-----------+---------+----+---------+----------+---------+
            | binary    | binary  | 63 | Yes     | Yes      |       1 |
            +-----------+---------+----+---------+----------+---------+
            
            SELECT COLLATION_NAME, CHARACTER_SET_NAME
            FROM INFORMATION_SCHEMA.COLLATIONS WHERE ID = 33;
            +-----------------+--------------------+
            | COLLATION_NAME  | CHARACTER_SET_NAME |
            +-----------------+--------------------+
            | utf8_general_ci | utf8               |
            +-----------------+--------------------+
            ```

- `enum enum_field_types tpye`

    - Field의 Type

    - 아래 표에 나와 있는 `MYSQL_TYPE` Symbol 중 하나일 수 있음

        | Type Value              | Type Description                                             |
        | :---------------------- | :----------------------------------------------------------- |
        | `MYSQL_TYPE_TINY`       | [`TINYINT`](https://dev.mysql.com/doc/refman/8.0/en/integer-types.html) Field |
        | `MYSQL_TYPE_SHORT`      | [`SMALLINT`](https://dev.mysql.com/doc/refman/8.0/en/integer-types.html) Field |
        | `MYSQL_TYPE_LONG`       | [`INTEGER`](https://dev.mysql.com/doc/refman/8.0/en/integer-types.html) Field |
        | `MYSQL_TYPE_INT24`      | [`MEDIUMINT`](https://dev.mysql.com/doc/refman/8.0/en/integer-types.html) Field |
        | `MYSQL_TYPE_LONGLONG`   | [`BIGINT`](https://dev.mysql.com/doc/refman/8.0/en/integer-types.html) Field |
        | `MYSQL_TYPE_DECIMAL`    | [`DECIMAL`](https://dev.mysql.com/doc/refman/8.0/en/fixed-point-types.html)이나 [`NUMERIC`](https://dev.mysql.com/doc/refman/8.0/en/fixed-point-types.html) Field |
        | `MYSQL_TYPE_NEWDECIMAL` | 정밀한 [`DECIMAL`](https://dev.mysql.com/doc/refman/8.0/en/fixed-point-types.html)이나 [`NUMERIC`](https://dev.mysql.com/doc/refman/8.0/en/fixed-point-types.html) |
        | `MYSQL_TYPE_FLOAT`      | [`FLOAT`](https://dev.mysql.com/doc/refman/8.0/en/floating-point-types.html) Field |
        | `MYSQL_TYPE_DOUBLE`     | [`DOUBLE`](https://dev.mysql.com/doc/refman/8.0/en/floating-point-types.html)이나 [`REAL`](https://dev.mysql.com/doc/refman/8.0/en/floating-point-types.html) Field |
        | `MYSQL_TYPE_BIT`        | [`BIT`](https://dev.mysql.com/doc/refman/8.0/en/bit-type.html) Field |
        | `MYSQL_TYPE_TIMESTAMP`  | [`TIMESTAMP`](https://dev.mysql.com/doc/refman/8.0/en/datetime.html) Field |
        | `MYSQL_TYPE_DATE`       | [`DATE`](https://dev.mysql.com/doc/refman/8.0/en/datetime.html) Field |
        | `MYSQL_TYPE_TIME`       | [`TIME`](https://dev.mysql.com/doc/refman/8.0/en/time.html) Field |
        | `MYSQL_TYPE_DATETIME`   | [`DATETIME`](https://dev.mysql.com/doc/refman/8.0/en/datetime.html) Field |
        | `MYSQL_TYPE_YEAR`       | [`YEAR`](https://dev.mysql.com/doc/refman/8.0/en/year.html) Field |
        | `MYSQL_TYPE_STRING`     | [`CHAR`](https://dev.mysql.com/doc/refman/8.0/en/char.html)거나 [`BINARY`](https://dev.mysql.com/doc/refman/8.0/en/binary-varbinary.html) Field |
        | `MYSQL_TYPE_VAR_STRING` | [`VARCHAR`](https://dev.mysql.com/doc/refman/8.0/en/char.html)거나 [`VARBINARY`](https://dev.mysql.com/doc/refman/8.0/en/binary-varbinary.html) Field |
        | `MYSQL_TYPE_BLOB`       | [`BLOB`](https://dev.mysql.com/doc/refman/8.0/en/blob.html)나 [`TEXT`](https://dev.mysql.com/doc/refman/8.0/en/blob.html) Field (`max_length`를 사용해 최대 길이 결정) |
        | `MYSQL_TYPE_SET`        | [`SET`](https://dev.mysql.com/doc/refman/8.0/en/set.html) Field |
        | `MYSQL_TYPE_ENUM`       | [`ENUM`](https://dev.mysql.com/doc/refman/8.0/en/enum.html) Field |
        | `MYSQL_TYPE_GEOMETRY`   | 공간(지리) Field                                             |
        | `MYSQL_TYPE_NULL`       | `NULL`-Type Field                                            |

    - `MYSQL_TYPE_TIME2`, `MYSQL_TYPE_DATETIME2`, `MYSQL_TYPE_TIMESTAMP2` Type Code는 Server 측에서만 사용

        - Client에는 `MYSQL_TYPE_TIME`, `MYSQL_TYPE_DATETIME`, `MYSQL_TYPE_TIMESTAMP` Code가 표시

    - `IS_NUM()` Macro를 사용해 Field에 Numeric Type이 있는지 확인할 수 있음

        - Type 값을 `IS_NUM()`으로 전달해 Field가 Numeric Type인 경우 `TRUE` 반환

        ```c
        if (IS_NUM(field->type))
            printf("Field is numeric\n");
        ```

    - `ENUM`과 `SET` 값은 문자열로 반환
        - Type 값이 `MYSQL_TYPE_STRING`이고 `ENUM_FLAG`나 `SET_FLAG` Flag가 설정되어 있는지 확인

# C API Basic Function

| 이름                                                         | 설명                                                         | 도입   | 미사용 |
| :----------------------------------------------------------- | :----------------------------------------------------------- | :----- | :----- |
| [`mysql_affected_rows()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-affected-rows.html) | 마지막 [`UPDATE`](https://dev.mysql.com/doc/refman/8.0/en/update.html), [`DELETE`](https://dev.mysql.com/doc/refman/8.0/en/delete.html), [`INSERT`](https://dev.mysql.com/doc/refman/8.0/en/insert.html)문 에 의해 변경/삭제/삽입된 Row 수 |        |        |
| [`mysql_autocommit()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-autocommit.html) | Auto-commit Mode 설정                                        |        |        |
| [`mysql_bind_param()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-bind-param.html) | 다음에 실행되는 Statement에 대한 Query 속성 정의             | 8.0.23 |        |
| [`mysql_change_user()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-change-user.html) | 열린 Connection의 User와  DB 변경                            |        |        |
| [`mysql_character_set_name()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-character-set-name.html) | 현재 Connection의 기본 Character Set 이름                    |        |        |
| [`mysql_close()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-close.html) | Server에 대한 Connection닫기                                 |        |        |
| [`mysql_commit()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-commit.html) | Transaction Commit                                           |        |        |
| [`mysql_connect()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-connect.html) | MySQL Server에 Connect                                       |        | Y      |
| [`mysql_create_db()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-create-db.html) | DB 생성                                                      |        | Y      |
| [`mysql_data_seek()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-data-seek.html) | Query Result Set에서 임의의 Row 번호를 찾음                  |        |        |
| [`mysql_debug()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-debug.html) | `DBUG_PUSH`를 주어진 문자열로 수행                           |        |        |
| [`mysql_drop_db()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-drop-db.html) | DB 삭제                                                      |        | Y      |
| [`mysql_dump_debug_info()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-dump-debug-info.html) | Server가 오류 로그에 디버그 정보를 쓰도록 함                 |        |        |
| [`mysql_eof()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-eof.html) | Result Set의 마지막 Row을 읽었는지 확인                      |        | Y      |
| [`mysql_errno()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-errno.html) | 가장 최근에 호출된 MySQL Function의 오류 번호                |        |        |
| [`mysql_error()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-error.html) | 가장 최근에 호출된 MySQL Function에 대한 오류 메시지         |        |        |
| [`mysql_escape_string()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-escape-string.html) | SQL Statement에서 사용하기 위해 문자열의 특수 문자를 이스케이프 처리 |        |        |
| [`mysql_fetch_field()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-fetch-field.html) | 다음 Table Field Type                                        |        |        |
| [`mysql_fetch_field_direct()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-fetch-field-direct.html) | 주어진 Field 번호에 대한 Table Field Type                    |        |        |
| [`mysql_fetch_fields()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-fetch-fields.html) | 모든 Field 구조의 반환 배열                                  |        |        |
| [`mysql_fetch_lengths()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-fetch-lengths.html) | 현재 Row의 모든 Column 길이 반환                             |        |        |
| [`mysql_fetch_row()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-fetch-row.html) | 다음 Result Set Row 가져오기                                 |        |        |
| [`mysql_field_count()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-field-count.html) | 가장 최근 Command Statement의 결과 Column 수                 |        |        |
| [`mysql_field_seek()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-field-seek.html) | Result Set Row내에서 Column 찾기                             |        |        |
| [`mysql_field_tell()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-field-tell.html) | [`mysql_fetch_field()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-fetch-field.html)마지막 호출 을 위한 Field 위치 |        |        |
| [`mysql_free_result()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-free-result.html) | Free Result Set Memory                                       |        |        |
| [`mysql_free_ssl_session_data()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-free-ssl-session-data.html) | 마지막 [`mysql_get_ssl_session_data()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-get-ssl-session-data.html)호출 에서 Session 데이터 Handler 삭제 | 8.0.29 |        |
| [`mysql_get_character_set_info()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-get-character-set-info.html) | 기본 Charter Set에 대한 정보                                 |        |        |
| [`mysql_get_client_info()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-get-client-info.html) | Client Version(문자열)                                       |        |        |
| [`mysql_get_client_version()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-get-client-version.html) | Client Version(정수)                                         |        |        |
| [`mysql_get_host_info()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-get-host-info.html) | Connection에 대한 정보                                       |        |        |
| [`mysql_get_option()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-get-option.html) | [`mysql_options()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-options.html) Option Value |        |        |
| [`mysql_get_proto_info()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-get-proto-info.html) | Connection에 사용된 Protocol Version                         |        |        |
| [`mysql_get_server_info()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-get-server-info.html) | Server Version(문자열)                                       |        |        |
| [`mysql_get_server_version()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-get-server-version.html) | Server Version(정수)                                         |        |        |
| [`mysql_get_ssl_cipher()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-get-ssl-cipher.html) | 현재 SSL 암호                                                |        |        |
| [`mysql_get_ssl_session_data()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-get-ssl-session-data.html) | SSL 사용 Connection에 대한 Session 데이터 반환               | 8.0.29 |        |
| [`mysql_get_ssl_session_reused()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-get-ssl-session-reused.html) | Session 재사용 여부                                          | 8.0.29 |        |
| [`mysql_hex_string()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-hex-string.html) | 문자열을 16진수 형식으로 인코딩                              |        |        |
| [`mysql_info()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-info.html) | 가장 최근에 실행된 Statement에 대한 정보                     |        |        |
| [`mysql_init()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-init.html) | `MYSQL`구조체 가져오기 또는 초기화                           |        |        |
| [`mysql_insert_id()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-insert-id.html) | `AUTO_INCREMENT`이전 Statement에 의해 Column에 대해 생성된 ID |        |        |
| [`mysql_kill()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-kill.html) | Thread 종료                                                  |        | Y      |
| [`mysql_library_end()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-library-end.html) | MySQL C API Library 종료                                     |        |        |
| [`mysql_library_init()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-library-init.html) | MySQL C API Library 초기화                                   |        |        |
| [`mysql_list_dbs()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-list-dbs.html) | 정규 표현식과 일치하는 DB 이름 반환                          |        |        |
| [`mysql_list_fields()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-list-fields.html) | 정규 표현식과 일치하는 Field이름 반환                        |        |        |
| [`mysql_list_processes()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-list-processes.html) | 현재 Server Thread 목록                                      |        |        |
| [`mysql_list_tables()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-list-tables.html) | 정규 표현식과 일치하는 Table 이름 반환                       |        |        |
| [`mysql_more_results()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-more-results.html) | 더 많은 Result가 있는지 확인                                 |        |        |
| [`mysql_next_result()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-next-result.html) | Multiple Result 실행에서 다음 결과 반환/시작                 |        |        |
| [`mysql_num_fields()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-num-fields.html) | Result Set의 Column 수                                       |        |        |
| [`mysql_num_rows()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-num-rows.html) | Result Set의 Row 수                                          |        |        |
| [`mysql_options()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-options.html) | Connection 전 Option 설정                                    |        |        |
| [`mysql_options4()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-options4.html) | Connection 전 Option 설정                                    |        |        |
| [`mysql_ping()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-ping.html) | Server에 Ping                                                |        |        |
| [`mysql_query()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-query.html) | Statement 실행                                               |        |        |
| [`mysql_real_connect()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-real-connect.html) | MySQL Server에 Connect                                       |        |        |
| [`mysql_real_connect_dns_srv()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-real-connect-dns-srv.html) | DNS SRV Record를 사용하여 MySQL Server에 Connect             | 8.0.22 |        |
| [`mysql_real_escape_string()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-real-escape-string.html) | Command Statement 문자열의 특수 문자 인코딩                  |        |        |
| [`mysql_real_escape_string_quote()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-real-escape-string-quote.html) | 인용 Context를 설명하는 Command Statement 문자열의 특수 문자 인코딩 |        |        |
| [`mysql_real_query()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-real-query.html) | Statement 실행                                               |        |        |
| [`mysql_refresh()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-refresh.html) | Table 및 Cache Flush 또는 재설정                             |        |        |
| [`mysql_reload()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-reload.html) | Grant Table 다시 로드                                        |        | Y      |
| [`mysql_reset_connection()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-reset-connection.html) | Session 상태를 지우려면 Connection을 재설정                  |        |        |
| [`mysql_reset_server_public_key()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-reset-server-public-key.html) | Client Library에서 Cache된 RSA Public 키 지우기              |        |        |
| [`mysql_result_metadata()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-result-metadata.html) | Result Set에 Metadata가 있는지 여부                          | 8.0.13 |        |
| [`mysql_rollback()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-rollback.html) | Transaction Rollback                                         |        |        |
| [`mysql_row_seek()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-row-seek.html) | Result Set에서 Row Offset 찾기                               |        |        |
| [`mysql_row_tell()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-row-tell.html) | Result Set Row 내 현재 위치                                  |        |        |
| [`mysql_select_db()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-select-db.html) | DB 선택                                                      |        |        |
| [`mysql_server_end()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-server-end.html) | MySQL C API Library 종료                                     |        |        |
| [`mysql_server_init()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-server-init.html) | MySQL C API Library 초기화                                   |        |        |
| [`mysql_session_track_get_first()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-session-track-get-first.html) | Sesssion 상태 변경 정보의 첫 번째 부분                       |        |        |
| [`mysql_session_track_get_next()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-session-track-get-next.html) | Session 상태 변경 정보의 다음 부분                           |        |        |
| [`mysql_set_character_set()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-set-character-set.html) | 현재 Connection 기본 Character Set 설정                      |        |        |
| [`mysql_set_local_infile_default()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-set-local-infile-default.html) | [`LOAD DATA LOCAL`](https://dev.mysql.com/doc/refman/8.0/en/load-data.html) Handler Callback을 기본값으로 설정 |        |        |
| [`mysql_set_local_infile_handler()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-set-local-infile-handler.html) | Application 별 [`LOAD DATA LOCAL`](https://dev.mysql.com/doc/refman/8.0/en/load-data.html) Handler Callback 설치 |        |        |
| [`mysql_set_server_option()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-set-server-option.html) | 현재 Connection Option 설정                                  |        |        |
| [`mysql_shutdown()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-shutdown.html) | MySQL Server 종료                                            |        |        |
| [`mysql_sqlstate()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-sqlstate.html) | 가장 최근에 호출된 MySQL 함수의 SQLSTATE 값                  |        |        |
| [`mysql_ssl_set()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-ssl-set.html) | Server에 대한 SSL Connect 설정 준비                          |        |        |
| [`mysql_stat()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-stat.html) | Server 상태                                                  |        |        |
| [`mysql_store_result()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-store-result.html) | 전체 Result Set 검색 및 저장                                 |        |        |
| [`mysql_thread_id()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-thread-id.html) | 현재 Thread ID                                               |        |        |
| [`mysql_use_result()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-use-result.html) | Row 별 Result Set 검색 시작                                  |        |        |
| [`mysql_warning_count()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-warning-count.html) | 이전 Statement에 대한 경고 횟수                              |        |        |
