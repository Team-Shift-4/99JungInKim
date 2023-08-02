[toc]

# C API Prepared Statement Interface 개요

MySQL Client/Server Protocol은 Prepared Statement의 사용을 제공
이 기능은 `mysql_stmt_init()` 초기화 함수에 의해 반환된 `MYSQL_STMT` Statement Handler Data Type을 사용
Prepared Execution은 Statement를 두 번 이상 실행하는 효율적인 방법
Statement는 Execution을 준비하기 위해 먼저 Parse되고 난 후 초기화 함수에 의해 반환된 Statement Handler를 사용해 한번 이상 실행

Prepared Execution은 주로 Query가 한 번만 Parse되기 때문에 두 번 이상 실행된 Statement에 대한 Direct Execution보다 빠름
Direct Execution의 경우 Query 실행 시마다 Parse함
Prepared Execution은 Prepared Statement의 각 Execution마다 Parameter에 대한 데이터만 전송하면 되기에 Network Traffic을 줄일 수 있음

Prepared Statement는 일부 상황에서 성능 향상이 되지 않을 수 있음
좋은 성능을 위해서 Prepared Statement와 Non-Prepared Statement를 Application에서 Test하고 성능 좋은 Statement 중 하나를 선택

Prepared Statement는 Client와 Server간의 데이터 전송을 더 효율적으로 만드는 Binary Protocol을 사용

Prepared Statement는 Table이나 View의 Metadata 변경을 감지하고 다음에 Statement가 실행될 때 자동으로 다시 준비됨

> [Caching of Prepared Statements And Stored Programs](https://dev.mysql.com/doc/refman/8.0/en/statement-caching.html)

Statement를 Prepare하고 Execute하기 위해 Application은 다음 단계를 따름:

1. `mysql_stmt_init()`을 사용해 Prepared Statement Handler를 만듬
    Server에서 Statement를 Prepare하려면 `mysql_stmt_prepare()`를 호출하고 SQL Statement가 포함된 문자열 전달
2. `mysql_stmt_bind_param()`을 사용해 모든 Parameter의 값을 설정
    모든 Parameter를 설정하지 않으면 Statement Excution이 오류나 예상하지 못한 결과가 발생
    큰 Text나 Binary Data Value를 전송해야 하는 경우 `mysql_send_long_data()`을 이용해 Server에 Chunk로 전송 가능
3. `mysql_stmt_execute()`를 호출해 Statement 실행
4. Statement가 SELECT나 Result Set을 생성하는 Statement일 경우 Result Set Metadata를 받기 위해 `mysql_stmt_result_metadata()` 호출
    이 Metadata 자체는 `MYSQL_RES` Result Set의 형태아니 Query에 의해 반환된 Row가 포함된 Result Set과는 별개
    Metadata Result Set은 Result의 Row 수를 나타내며 각 Column에 대한 정보 포함
5. Statement가 Result Set을 생성하는 경우 `mysql_stmt_bind_result()`를 호출해 Row 값을 검색하는 데 사용할 Data Buffer를 Binding
6. 더 이상 Row를 찾을 수 없을 때까지 `mysql_stmt_fetch()`를 반복적으로 호출해 데이터를 Row별로 Buffer 로 가져옴
7. 필요하다면 3에서 6단계를 반복
    `mysql_stmt_bind_param()`을 통해 제공된 각 Buffer의 Parameter값을 변경해 `mysql_stmt_execute()`를 반복해 Statement 재실행 가능
8. Statement Execution이 완료되면 `mysql_stmt_close()`를 사용해 Statement Handler를 닫아 관련 모든 Resource 확보
    `mysql_stmt_close()` 이후 Handler는 유효하지 않아 더 이상 사용할 수 없음
9. `mysql_stmt_result_metadata()`를 호출해 SELECT Statement의 Result Set Metadata를 얻은 경우 `mysql_free_result()`를 사용해 Metadata를 해제해야 함

`mysql_stmt_prepare()`가 호출되면 MySQL Client/Server Protocol이 수행하는 작업:

- Server는 Statement를 Parsing 한 후 Statement ID를 할당해 Client에 확인 상태를 다시 보냄
    Result Set 지향 Statement인 경우 총 Parameter 수, Column 수, Metadata를 전송함
    Statement의 모든 Syntax와 Semantic은 이 호출 중에 Server에서 확인됨
- Client는 추가 작업에 이 Statement ID를 사용하므로 Server는 Statement Pool에서 Statement 식별 가능

`mysql_stmt_execute()`가 호출되면 MySQL Client/Server Protocol이 수행하는 작업:

- Client는 Statement Handler를 사용해 Parameter Data를 Server로 보냄
- Server는 Client가 제공한 ID를 사용해 Statement를 식별하고 Parameter Marker를 새로 제공된 데이터로 교체한 후 Statement를 실행
    Statement가 Result Set을 생성하는 경우 Server는 데이터를 Client로 다시 보냄
    Result Set을 생성하지 않는 경우 확인 상태와 변경이나 삭제나 삽입된 Row 수를 보냄

`mysql_stmt_fetch`가 호출되면 MySQL Client/Server Protocol이 수행하는 작업

- Client는 Result Set의 현재 Row에서 데이터를 읽고 필요한 변환을 수행해 Application Data Buffer에 배치
    Application Buffer Type이 Server에서 반환된 Field Type과 동일한 경우 변환이 쉬움

오류 발생 시 `mysql_stmt_errno()`와 `mysql_stmt_error()`, `mysql_state()`를 사용해 Statement 오류 번호, 메세지 SQLSTATE Code를 얻을 수 있음

## Prepared Statement Logging

`mysql_stmt_prepare()`와 `mysql_stmt_execute()` C API Function으로 실행되는 Prepared Statement의 경우 Server는 Prepare와 Execute 시간을 알 수 있도록 일반 Query Log에 Prepare와 Execute Row를 기록

예시:

1. `mysql_stmt_prepare()`를 호출해 Statement 문자열 "SELECT?"를 Prepare
2. `mysql_stmt_bind_param()`을 호출해 값 3을 Prepared Statement의 Parameter에 Binding
3. `mysql_stmt_execute()`를 호출해 Prepared Statement를 실행

위 예시의 결과로 Server는 다음 Line을 일반 Query Log에 기록함

```sql
Prepare  [1] SELECT ?
Execute  [1] SELECT 3
```

Log의 각 Prepare와 Execute Line에는 [N] Statement Identifier가 태그되어 기록중인 Prepared Statement를 추적 가능(N은 양의 정수)
Client에 대해 동시에 활성화 된 여러 Prepared Statement가 있는 경우 N은 1보다 클 수 있음
각 Execute 시 `?` Parameter에 대한 데이터 값을 대체한 후 Prepared Statement가 표시

# C API Prepared Statement Data 구조

Prepared Statement는 여러 데이터 구조를 사용:

- Statement Handler를 가져오기 위해 `MYSQL` Connection Handler를 `MYSQL_STMT` 데이터 구조로 Pointer를 반환하는 `mysql_stmt_init()`으로 전달
    이 구조는 Statement를 사용한 추가 작업에 사용
    Prepared Statement를 지정하기 위해 `MYSQL_STMT` Pointer와 Statement 문자열을 `mysql_prepare()`로 전달
- Prepared Statement에 대한 입력 Parameter를 제공하기 위해 `MYSQL_BIND` 구조를 설정하고 `mysql_stmt_bind_param()`에 전달
    출력 Column 값을 수신받기 위해 `MYSQL_BIND` 구조를 설정하고 `mysql_stmt_bind_result()`에 전달
- `MYSQL_BIND` 구조는 `mysql_bind_param()`과 함께 사용되기도 함
    Server로 전송되는 다음 Query에 적용되는 속성을 정의할 수 있게 함

- `MYSQL_TIME` 구조는 양방향으로 시간 데이터를 전송하는데 사용

Prepared Statement Data Type에 대한 설명:

- `MYSQL_STMT`

    - 이 구조는 Prepared Statement에 대한 Handler, `mysql_stmt_init()`을 호출하여 Handler를 생성
        이 Handler는 `mysql_stmt_close()`를 사용해 닫을 때까지 Statement와 함께 모든 후속 작업에 사용됨
        `mysql_stmt_close()`를 사용해 닫은 Statement는 유효하지 않아 더 이상 사용할 수 없음
    - `MYSQL_STMT` 구조에는 Application을 사용할 Member가 없음
        Application은 `MYSQL_STMT` 구조를 복사해서는 안됨(복사본이 사용 가능하다는 보장이 없음)
    - 하나의 Connection에 여러 Statement Handler를 연결할 수 있음
        Handler의 제한은 사용 가능한 System Resource에 따라 다름

- `MYSQL_BIND`

    - 이 구조는 Statement Input(Server로 전송된 데이터 값)과 Output(Server에서 반환된 결과 값) 모두에 사용

        - Input의 경우 `MYSQL_BIND` 구조를 `mysql_bind_param()`과 함께 사용해 Query에 대한 속성 정의
        - Output의 경우 `MYSQL_BIND` 구조를 `mysql_stmt_bind_result()`와 함께 사용해 Result Set Column에 Buffer를 바인딩하여 `mysql_stmt_fetch()`가 있는 Row를 가져오는 데 사용

    - `MYSQL_BIND` 구조를 사용하기 위해 Contents를 0으로 초기화 한 후 Member를 적적히 설정
        ex) 3개의 `MYSQL_BIND` 구조의 배열을 선언한 후 초기화하는 코드

        ```c
        MYSQL_BIND bind[3];
        memset(bind, 0, sizeof(bind));
        ```

    - `MYSQL_BIND` 구조에는 Application에서 사용할 수 있는 다음과 같은 Member가 포함되어 있음(I/O에 사용되는지에 따라 사용 방법 다름):

        - `enum enum_field_types buffer_type`
            - Buffer의 Type
            - 이 Member는 Statement Parameter 또는 Result Set Column에 Binding된 C 언어 변수의 Data Type을 나타냄
            - Input의 경우 Server로 보낼 값을 포함하는 변수의 Type을 나타냄
            - Output의 경우 Server로 부터 받은 값이 저장되어야 하는 변수의 Type을 나타냄

        - `void *buffer`
            - 데이터 전송에 사용할 Buffer의 Pointer(C 언어 변수의 주소)
            - Input의 경우 Statement Parameter의 데이터 값을 저장하는 변수에 대한 Pointer
                `mysql_stmt_execute()`를 호출하면 MySQL은 Statement Parameter Marker(Statement 문자열에서 ?)에 저장된 값을 사용
            - Output의 경우 Result Set Column 값을 반환할 변수에 대한 Pointer
                `mysql_stmt_fetch()`를 호출해 MySQL은 이 변수에 있는 Result Set의 현재 Row에 있는 Column 값을 저장
                호출이 돌아오면 값에 Access 가능
            - Client 측 C 언어 값과 Server 측 SQL 값 사이 MySQL이 Type 변환 수행을 최소화 하기 위해 해당 SQL 값과 유사한 C 변수 사용해야 함
                - Numeric Data Type의 경우 Buffer는 적절한 Numeric C Type 변수를 가리켜야 함
                    정수 변수의 경우 `in_unsigned` Member를 설정해 변수에 Unsigned 속성 여부도 표시해야 함
                - Binary와 Non-Binary 문자열 Data Type의 경우 `*buffer`는 문자 Buffer를 가리켜야 함
                - Date와 Time Data Type의 경우 Buffer가 `MYSQL_TIME` 구조를 가리켜야 함

        - `unsigned long buffer_length`
            - `*buffer`의 실제 Byte 크기, Buffer에 저장할 수 있는 최대 데이터 양을 나타냄
            - 문자와 Binary C Data의 경우 Input 값을 지정하기 위해 `mysql_stmt_bind_param()`과 함께 사용할 때 `*buffer`의 길이를 지정하거나 `mysql_stmt_bind_result()`와 함께 사용할 때 Buffer로 가져올 수 있는 최대 Output 데이터 Byte 수를 지정 

        - `unsigned long *length`
            - `*buffer`에 저장된 데이터의 실제 Byte 수를 나타내는 Pointer, `*length`는 문자나 Binary C 데이터에 사용됨
            - Input Parameter Data Binding의 경우 `*length`를 설정해 `*buffer`에 저장된 Parameter 값의 실제 길이를 나타냄
                `mysql_stmt_execute()`에서 사용
            - Output Value Binding의 경우 MySQL은 `mysql_stmt_fetch()`를 호출할 때 `*length`를 설정
                `mysql_stmt_fetch()`의 반환 값은 길이를 해석하는 방법을 결정
                - 반환 값이 0이면 `*length`는 Parameter 값의 실제 길이를 나타냄
                - 반환 값이 `MYSQL_DATA_TRUNCATED`이면 `*length`는 Parameter 값의 잘리지 않은 길이를 나타냄
                    이 경우 `*length`와 `buffer_length`의 최소 값은 실제 길이를 나타냄

            - `buffer_type` 값이 데이터 값의 길이를 결정하기에 Numeric과 Time Data Type의 경우 `length`가 무시됨

        - `bool *is_null`
            - 이 Member는 값이 `NULL`이면 `TRUE`, 아닐 경우 `FALSE`인 Boolean Variable을 가리킴
            - Input의 경우 `*is_null`을 `TRUE`로 설정해 `NULL` 값을 Statement Variable로 전달하고 있음을 나타냄
            - `is_null`은 `NULL` 값을 지정하는 방법에 유연성을 제공하기 위해 Bool Scalar에 대한 Pointer
                - 데이터 값이 항상 `NULL`인 경우 Column을 Binding할 때 `MYSQL_TYPE_NULL`을 `buffer_type` 값으로 사용
                    다른 `MYSQL_BIND` Member는 중요하지 않음
                - 데이터 값이 항상 `NULL`이 아닌 경우에는 `is_null = (bool*) 0`을 설정하고 Binding 중인 변수에 맞게 다른 Member 설정
                - 항상 `NULL`이 아닌 경우에 다른 Member를 적절히 설정하고 `is_null`을 Bool 변수 주소로 설정
                    해당 데이터 값이 `NULL`인지 `NOT NULL`인지 나타내기 위해 실행 간 해당 변수의 값을 `TRUE` 혹은 `FALSE`로 적절히 설정

            - Output의 경우 Row를 가져올 때 MySQL은 Statement에서 반환된 Result Set Column 값이 `NULL`인지 여부에 따라 `is_null`로 가리키는 값을 `TRUE`나 `FALSE`로 적절히 설정

        - `bool is_unsigned`
            - 이 Member는 Unsigned Data Type(char, short int, int, long int)을 가진 C 변수에 적용
            - `buffer`로 가리킨 변수가 Unsigned일 경우 `set_unsigned`가 `TRUE`이고 아닐 경우 `FALSE`
                (Signed, Unsigned에 대해 명시적으로 설명하는 것이 좋음)
            - `is_unsigned`는 Client 측 C 언어 변수에만 적용
            - Server 측 해당 SQL 값에 Signed에 대해 아무것도 표시하지 않음

        - `bool *error`
            - Output의 경우 이 Member가 Bool 변수를 가리키도록 설정해 Row Fetching 작업 후 Parameter에 대한 Truncation 정보를 저장
                - Truncate Reporting이 활성화 된 경우 `mysql_stmt_fetch()`는 `MYSQL_DATA_TRUNCATED`를 반환하고 `*error`는 Truncate가 발생한 Parameter의 `MYSQL_BIND` 구조에서 `TRUE`가 됨
                - Truncate Reporting은 기본적으로 활성화되나 `MYSQL_REPORT_DATA_TRUNCATION` Option을 사용해 `mysql_options()`을 호출해 제어 가능

- `MYSQL_TIME`

    - 이 구조는 `DATE`, `TIME`, `DATETIME`, `TIMESTAMP` 데이터를 Server와 직접 주고받는 데에 사용

    - `buffer` Member가 `MYSQL_TIME` 구조를 가리키도록 설정하고 `MYSQL_TYPE_TIME`, `MYSQL_TYPE_DATE`, `MYSQL_TYPE_DATETIME`, `MYSQL_TYPE_TIMESTAMP` 중 하나로 `MYSQL_BIND` 구조의 `buffer_type` Member를 설정

    - `MYSQL_TIME` 구조에는 다음과 같은 Member가 포함:

        | Member                      | Description                               |
        | :-------------------------- | :---------------------------------------- |
        | `unsigned int year`         | 년도                                      |
        | `unsigned int month`        | 년도의 달                                 |
        | `unsigned int day`          | 달의 일                                   |
        | `unsigned int hour`         | 일의 시각                                 |
        | `unsigned int minute`       | 시각의 분                                 |
        | `unsigned int second`       | 분의 초                                   |
        | `bool neg`                  | 시간이 음수인지 여부를 나타내는 Bool Flag |
        | `unsigned long second_part` | 초의 마이크로초                           |

    - `MYSQL_TIME` 구조의 필요한 부분만 사용


## C API Prepared Statement Type Codes

`MYSQL_BIND` 구조의 `buffer_type` Member는 Statement Parameter나 Result Set Column에 Binding 된 C 언어 변수의 Data Type을 나타냄
Input의 경우 `buffer_type`은 Server로 보낼 값을 포함하는 변수의 Data Type을 나타냄
Output의 경우 Server로부터 받은 값이 저장되어야 하는 변수의 Type을 나타냄

다음 표는 `MYSQL_BIND` 구조의 `buffer_type` Member가 Server로 전송되는 Input 값에 대해 허용되는 값을 보여줌
다음 표에는 사용할 수 있는 C 변수 Type, 해당 Type Code와 제공된 값을 변환하지 않고 사용할 수 있는 SQL Data Type이 나와 있음
Binding할 C 언어 변수의 Data Type에 따라 `buffer_type` 값 선택
Integer Type의 경우 변수가 Signed인지 Unsigned 인지 여부를 나타내도록 `is_unsigned` Member를 설정해야 함

| Input Variable C Type | `buffer_type` Value    | SQL Type of Destination Value                                |
| :-------------------- | :--------------------- | :----------------------------------------------------------- |
| `signed char`         | `MYSQL_TYPE_TINY`      | [`TINYINT`](https://dev.mysql.com/doc/refman/8.0/en/integer-types.html) |
| `short int`           | `MYSQL_TYPE_SHORT`     | [`SMALLINT`](https://dev.mysql.com/doc/refman/8.0/en/integer-types.html) |
| `int`                 | `MYSQL_TYPE_LONG`      | [`INT`](https://dev.mysql.com/doc/refman/8.0/en/integer-types.html) |
| `long long int`       | `MYSQL_TYPE_LONGLONG`  | [`BIGINT`](https://dev.mysql.com/doc/refman/8.0/en/integer-types.html) |
| `float`               | `MYSQL_TYPE_FLOAT`     | [`FLOAT`](https://dev.mysql.com/doc/refman/8.0/en/floating-point-types.html) |
| `double`              | `MYSQL_TYPE_DOUBLE`    | [`DOUBLE`](https://dev.mysql.com/doc/refman/8.0/en/floating-point-types.html) |
| `MYSQL_TIME`          | `MYSQL_TYPE_TIME`      | [`TIME`](https://dev.mysql.com/doc/refman/8.0/en/time.html)  |
| `MYSQL_TIME`          | `MYSQL_TYPE_DATE`      | [`DATE`](https://dev.mysql.com/doc/refman/8.0/en/datetime.html) |
| `MYSQL_TIME`          | `MYSQL_TYPE_DATETIME`  | [`DATETIME`](https://dev.mysql.com/doc/refman/8.0/en/datetime.html) |
| `MYSQL_TIME`          | `MYSQL_TYPE_TIMESTAMP` | [`TIMESTAMP`](https://dev.mysql.com/doc/refman/8.0/en/datetime.html) |
| `char[]`              | `MYSQL_TYPE_STRING`    | [`TEXT`](https://dev.mysql.com/doc/refman/8.0/en/blob.html), [`CHAR`](https://dev.mysql.com/doc/refman/8.0/en/char.html), [`VARCHAR`](https://dev.mysql.com/doc/refman/8.0/en/char.html) |
| `char[]`              | `MYSQL_TYPE_BLOB`      | [`BLOB`](https://dev.mysql.com/doc/refman/8.0/en/blob.html), [`BINARY`](https://dev.mysql.com/doc/refman/8.0/en/binary-varbinary.html), [`VARBINARY`](https://dev.mysql.com/doc/refman/8.0/en/binary-varbinary.html) |
|                       | `MYSQL_TYPE_NULL`      | `NULL`                                                       |

Input 문자열 데이터의 경우 값이 문자(Non-Binary)인지 Binary 문자열인지에 따라 `MYSQL_TYPE_STRING`이나 `MYSQL_TYPE_BLOB`를 사용:

- `MYSQL_TYPE_STRING`은 문자 입력 문자열 데이터를 나타냄
    값은 `character_set_clinet` System Variable로 표시되는 Character Set에 있는 것으로 가정
    Server가 값을 다른 Character Set이 있는 Column에 저장할 경우 값을 해당 Character Set으로 변환함
- `MYSQL_TYPE_BLOB`는 Binary 입력 문자열 데이터를 나타냄
    값은 Binary Character Set으로 처리됨(Btye 문자열로 처리되며 변환 발생하지 않음)

아래 표는 `MYSQL_BIND` 구조의 `buffer_type` Member가 Server로부터 받은 출력 값에 허용되는 값을 보여줌
아래 표는 수신된 값의 SQL Type, Result Set Metadata에 있는 해당 Type Code, 변환 없이 SQL 값을 수신하기 위해 `MYSQL_BIND` 구조에 Binding할 권장 C 언어 Data Type을 보여줌
Binding할 C 언어 변수의 Data Type에 따라 `buffer_type` 값을 선택
Integer Type의 경우 Signed인지 Unsigned인지 여부를 나타내도록 `is_unsigned` Member를 설정해야 함

| QL Type of Received Value                                    | `buffer_type` Value      | Output Variable C Type |
| :----------------------------------------------------------- | :----------------------- | :--------------------- |
| [`TINYINT`](https://dev.mysql.com/doc/refman/8.0/en/integer-types.html) | `MYSQL_TYPE_TINY`        | `signed char`          |
| [`SMALLINT`](https://dev.mysql.com/doc/refman/8.0/en/integer-types.html) | `MYSQL_TYPE_SHORT`       | `short int`            |
| [`MEDIUMINT`](https://dev.mysql.com/doc/refman/8.0/en/integer-types.html) | `MYSQL_TYPE_INT24`       | `int`                  |
| [`INT`](https://dev.mysql.com/doc/refman/8.0/en/integer-types.html) | `MYSQL_TYPE_LONG`        | `int`                  |
| [`BIGINT`](https://dev.mysql.com/doc/refman/8.0/en/integer-types.html) | `MYSQL_TYPE_LONGLONG`    | `long long int`        |
| [`FLOAT`](https://dev.mysql.com/doc/refman/8.0/en/floating-point-types.html) | `MYSQL_TYPE_FLOAT`       | `float`                |
| [`DOUBLE`](https://dev.mysql.com/doc/refman/8.0/en/floating-point-types.html) | `MYSQL_TYPE_DOUBLE`      | `double`               |
| [`DECIMAL`](https://dev.mysql.com/doc/refman/8.0/en/fixed-point-types.html) | `MYSQL_TYPE_NEWDECIMAL`  | `char[]`               |
| [`YEAR`](https://dev.mysql.com/doc/refman/8.0/en/year.html)  | `MYSQL_TYPE_SHORT`       | `short int`            |
| [`TIME`](https://dev.mysql.com/doc/refman/8.0/en/time.html)  | `MYSQL_TYPE_TIME`        | `MYSQL_TIME`           |
| [`DATE`](https://dev.mysql.com/doc/refman/8.0/en/datetime.html) | `MYSQL_TYPE_DATE`        | `MYSQL_TIME`           |
| [`DATETIME`](https://dev.mysql.com/doc/refman/8.0/en/datetime.html) | `MYSQL_TYPE_DATETIME`    | `MYSQL_TIME`           |
| [`TIMESTAMP`](https://dev.mysql.com/doc/refman/8.0/en/datetime.html) | `MYSQL_TYPE_TIMESTAMP`   | `MYSQL_TIME`           |
| [`CHAR`](https://dev.mysql.com/doc/refman/8.0/en/char.html), [`BINARY`](https://dev.mysql.com/doc/refman/8.0/en/binary-varbinary.html) | `MYSQL_TYPE_STRING`      | `char[]`               |
| [`VARCHAR`](https://dev.mysql.com/doc/refman/8.0/en/char.html), [`VARBINARY`](https://dev.mysql.com/doc/refman/8.0/en/binary-varbinary.html) | `MYSQL_TYPE_VAR_STRING`  | `char[]`               |
| [`TINYBLOB`](https://dev.mysql.com/doc/refman/8.0/en/blob.html), [`TINYTEXT`](https://dev.mysql.com/doc/refman/8.0/en/blob.html) | `MYSQL_TYPE_TINY_BLOB`   | `char[]`               |
| [`BLOB`](https://dev.mysql.com/doc/refman/8.0/en/blob.html), [`TEXT`](https://dev.mysql.com/doc/refman/8.0/en/blob.html) | `MYSQL_TYPE_BLOB`        | `char[]`               |
| [`MEDIUMBLOB`](https://dev.mysql.com/doc/refman/8.0/en/blob.html), [`MEDIUMTEXT`](https://dev.mysql.com/doc/refman/8.0/en/blob.html) | `MYSQL_TYPE_MEDIUM_BLOB` | `char[]`               |
| [`LONGBLOB`](https://dev.mysql.com/doc/refman/8.0/en/blob.html), [`LONGTEXT`](https://dev.mysql.com/doc/refman/8.0/en/blob.html) | `MYSQL_TYPE_LONG_BLOB`   | `char[]`               |
| [`BIT`](https://dev.mysql.com/doc/refman/8.0/en/bit-type.html) | `MYSQL_TYPE_BIT`         | `char[]`               |

## C API Prepared Statement Type Conversions

Prepared Statement는 Server 측 SQL 값에 해당하는 Client 측 C 언어 변수를 사용해 Client와 Server 간 데이터를 전송
Client 측의 C 변수 Type과 Server 측 SQL 값 Type이 일치하지 않는 경우 MySQL은 양방향 암시적 Type Conversion을 수행

MySQL은 Server 측의 SQL 값에 대한 Type Code를 알고 있음
`MYSQL_BIND` 구조의 `buffer_type` 값은 Client 측의 값을 유지하는 C 변수의 Type Code를 나타냄
두 코드가 함께 MySQL에 어떤 Conversion을 수행해야 하는지 알려줌
예시:

- Integer 값을 Float Column에 저장할 Server에 전달하기 위해 int 변수와 함께 `MYSQL_TYPE_LONG`을 사용하는 경우 MySQL은 값을 저장하기 전  부동 소수점 형식으로 변환

- SQL `MEDIUMINT` Column 값을 가져오지만 `buffer_type` 값을 `MYSQL_TYPE_LONGLONG`으로 지정하고 long int Type의 C 변수를 대상 Buffer로 사용하는 경우 MySQL은 저장을 위한 `MEDIUMINT` 값(8Byte 미만)을 ling int(8Byte)로 변환

- 값이 255인 숫자 Column을 char[4] 문자 배열로 가져와 `buffer_type` 값을 `MYSQL_TYPE_STRING`으로 지정하면 배열의 결과 값은 4Byte 문자열 `255\0`이 됨

- MySQL은 원래 Server 측 값의 문자열 표현으로 `DECIMAL` 값을 반환하며 이는 해당 C 유형이 char[]임
    예로 12.345 는 "12.345"로 Client에 반환
    `MYSQL_TYPE_NEWDECIMAL`을 지정하고 문자열 Buffer를 `MYSQL_BIND` 구조에 Binding하면 `mysql_stmt_fetch()`는 변환하지 않고 Code를 입력하는 경우 `mysql_stmt_fetch()`는 문자열 형식의 `DECIMAL` 값을 Numeric Type으로 변환

- `MYSQL_TYPE_BIT`의 경우 Type Code, `BIT` 값이 문자열 Buffer로 반환되기에 해당 C Type이 char[]임
    이 값은 Client 측에서 해석이 필요한 Bit 문자열을 나타냄
    처리하기 쉬운 Type으로 값을 반환하려면 다음 식 Type 중 하나를 사용해 Integer Type으로 Casting 할 수 있음

    ```sql
    SELECT bit_col + 0 FROM t
    SELECT CAST(bit_col AS UNSIGNED) FROM t
    ```

- 값 검색을 위해 값을 유지할 수 있을 만큼 충분히 큰 Interger 변수를 Binding하고 해당하는 Interger Type Code를 지정

Column 값을 가져오는 데 사용할 `MYSQL_BIND` 구조에 변수를 Binding하기 전 Result Set의 각 Column에 대한 Type Code를 확인할 수 있음
Type Conversion을 방지하기 위해 어떤 변수 Type을 사용하는 것이 적합한 지 결정하려는 경우 이 방법이 좋음
Type Code를 가져오려면 `mysql_stmt_extecute()`로 Statement를 실행한 후 `mysql_stmt_result_metadata()`를 호출

Server에서 반환된 Result Set의 출력 문자열 값에 Binary Data가 포함되어 있는지 아닌지를 확인하기 위해 Result Set Metadata의 `charsetnr` 값이 63인지 확인(이 경우 Character Set은 Binary)
이를 통해 `BINARY`와 `CHAR`, `VARBINARY`와 `VARCHAR`, `BLOB`와 `TEXT` Type을 구분할 수 있음

`MYSQL_FIELD` Column Metadata 구조의 `max_length` Member를 설정하는 경우(`mysql_stmt_attr_set()`) Result Set의 `max_length` 값은 Binary 표현 길이가 아닌 문자열 표현의 길이를 나타냄
`max_length`는 Prepared Statement에 사용되는 Binary Protocol로 가져오는 데 필요한 Buffer 크기와 반드시 일치하지 않음
값을 가져올 Variable Type에 따라 Buffer 크기를 선택해야 함
예로 -128 값이 포함된 `TINYINT` 값의 Binary 표현은 저장에 1Byte만 필요하지만 `TINYINT`열의 `max_length` 값은 4일 수 있음
값을 저장하고 `is_unsigend`를 지정해 값이 Signed인지 Unsigned인지 나타 낼 부호 있는 문자 변수를 제공할 수 있음

Prepared Statement에서 참조하는 Table 또는 View에 대한 Metadata 변경이 감지되고 다음에 실행될 때 Statement가 자동으로 다시 Prepare됨

> [Caching of Prepared Statements and Stored Programs](https://dev.mysql.com/doc/refman/8.0/en/statement-caching.html)

# C API Prepared Statement Function

다음 표에는 Prepared Statement Processing에 사용할 수 있는 기능이 요약되어 있음

| Name                                                         | Description                                                  |
| :----------------------------------------------------------- | :----------------------------------------------------------- |
| [`mysql_stmt_affected_rows()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-stmt-affected-rows.html) | 마지막 Prepared Statement [`UPDATE`](https://dev.mysql.com/doc/refman/8.0/en/update.html), [`DELETE`](https://dev.mysql.com/doc/refman/8.0/en/delete.html), [`INSERT`](https://dev.mysql.com/doc/refman/8.0/en/insert.html)에 의해 변경/삭제/삽입된 Row수 |
| [`mysql_stmt_attr_get()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-stmt-attr-get.html) | Prepared Statement에 대한 속성 값 가져오기                   |
| [`mysql_stmt_attr_set()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-stmt-attr-set.html) | Prepared Statement에 대한 속성 값 설정                       |
| [`mysql_stmt_bind_param()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-stmt-bind-param.html) | Application Data Buffer를 Prepared Statement의 Parameter Marker와 연결 |
| [`mysql_stmt_bind_result()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-stmt-bind-result.html) | Application Data Buffer를 Result Set의 Column과 연결         |
| [`mysql_stmt_close()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-stmt-close.html) | Prepared Statement에서 사용하는 Free Memory(? 공문 그대로)   |
| [`mysql_stmt_data_seek()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-stmt-data-seek.html) | Prepared Statement Result Set에서 임의의 Row 번호를 찾음     |
| [`mysql_stmt_errno()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-stmt-errno.html) | 가장 최근에 호출된 MySQL ready-statement 함수의 오류 번호    |
| [`mysql_stmt_error()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-stmt-error.html) | 가장 최근에 호출된 MySQL ready-statement 함수에 대한 오류 메시지 |
| [`mysql_stmt_execute()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-stmt-execute.html) | Prepared Statement 실행                                      |
| [`mysql_stmt_fetch()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-stmt-fetch.html) | 다음 Result Set Row를 가져오고 바인딩된 모든 Row에 대한 데이터를 반환 |
| [`mysql_stmt_fetch_column()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-stmt-fetch-column.html) | 현재 Result Set Row의 한 Column에 대한 데이터를 가져옴       |
| [`mysql_stmt_field_count()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-stmt-field-count.html) | 가장 최근 Prepared Statemente Result Row 수                  |
| [`mysql_stmt_free_result()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-stmt-free-result.html) | Statement Handler에 할당된 사용 가능한 Resource              |
| [`mysql_stmt_init()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-stmt-init.html) | `MYSQL_STMT` 구조 에 대한 Memory 할당 및 초기화              |
| [`mysql_stmt_insert_id()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-stmt-insert-id.html) | `AUTO_INCREMENT`이전에 Prepared Statement에서 Column에 대해 생성된 ID |
| [`mysql_stmt_next_result()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-stmt-next-result.html) | Multiple Prepared Statement 실행에서 다음 Result 반환/시작   |
| [`mysql_stmt_num_rows()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-stmt-num-rows.html) | Buffering된 Statement Result Set의 Row 수                    |
| [`mysql_stmt_param_count()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-stmt-param-count.html) | Prepared Statement의 Parameter 수                            |
| [`mysql_stmt_param_metadata()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-stmt-param-metadata.html) | Parameter Metadata를 Result Set으로 반환                     |
| [`mysql_stmt_prepare()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-stmt-prepare.html) | 실행을 위한 Statement 준비                                   |
| [`mysql_stmt_reset()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-stmt-reset.html) | Server 측에서 Statement Buffer 재설정                        |
| [`mysql_stmt_result_metadata()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-stmt-result-metadata.html) | Prepared Statemente Metadata를 Result Set으로 반환           |
| [`mysql_stmt_row_seek()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-stmt-row-seek.html) | Prepared Statement Result Set에서 Row Offset을 찾음          |
| [`mysql_stmt_row_tell()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-stmt-row-tell.html) | Prepared Statement Result Set Row 내 현재 위치               |
| [`mysql_stmt_send_long_data()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-stmt-send-long-data.html) | 긴 데이터를 청크 단위로 Server에 전송                        |
| [`mysql_stmt_sqlstate()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-stmt-sqlstate.html) | 가장 최근에 호출된 MySQL ready-statement 함수의 SQLSTATE 값  |
| [`mysql_stmt_store_result()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-stmt-store-result.html) | 전체 Result Set 검색 및 저장                                 |

