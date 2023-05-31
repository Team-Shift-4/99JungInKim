[toc]

# C API 비동기 Interface

MySQL 8.0.16부터 C API에 MySQL Server와 비동기 통신 가능하게 하는 함수 포함
비동기 기능은 Server Connection에서 읽기나 쓰기가 대기해야 하는 경우 비동기 기능 기반 Query 처리 모델과 다른 Application 개발 가능
비동기 기능을 사용해 Application은 Server Connection 작업을 진행할 준비가 되었는지 여부를 확인 가능
Server Connection 작업 진행할 준비가 되지 않았다면 Application은 나중에 확인하기 전 다른 작업 수행 가능

예로 Application은 Server에 대한 여러 Connection을 열고 사용해 Execution을 위해 여러 Statement를 제출할 수 있음
그 이후 Application은 Connection을 Polling하여 다른 작업을 수행하는 동안 가져올 결과가 있는 Connection을 확인 가능
위 예시처럼 Multi Connection을 사용하고 하나당 하나의 명령문을 실행해야 함
비동기 인터페이스는 Connection당 여러 동시 명령문을 실행할 수 있지 않음
Application은 Server 작업이 완료될 때 까지 기다리지 않고 다른 작업 수행 가능

비동기 C API Function은 Initial Connection 작업, Query 보내기, Result 읽기 등 Server Connection 에서 읽거나 쓸 때 차단될 수 있는 작업을 다룸
각 비동기 Function은 동기 Function과 이름이 같고 `_nonblocking` 접미사가 붙음

- `mysql_fetch_row_nonblocking()`: Result Set에서 다음 Row를 비동기적으로 Fetch
- `mysql_free_result_nonblocking()`: Result Set에서 사용하는 Memory를 비동기적으로 해제
- `mysql_next_result_nonblocking()`: Multi Result Execution에서 다음 Result를 비동기적으로 반환/초기화
- `mysql_real_connection_nonblocking()`: MySQL Server에 비동기적 Connection
- `mysql_real_query_nonblocking()`: Counted String으로 지정된 SQL Query를 비동기적 실행
- `mysql_store_result_nonblocking()`: Client에 대한 전체 Result Set을 비동기적으로 검색

비동기적으로 수행할 필요가 없거나 비동기 Function이 적용되지 않는 작업의 경우 Application은 비동기와 동기 Function 혼합 가능

## 비동기 Function 호출 규칙

모든 비동기 C API Function은 `enum net_async_status` 값을 반환
반환 값은 작업 상태를 나타내는 아래 값 중 하나:

- `NET_ASYNC_NOT_READY`: 작업이 아직 진행중이며 완료되지 않음
- `NET_ASYNC_COMPLETE`: 작업이 성공적으로 완료
- `NET_ASYNC_ERROR`: 작업이 요류로 종료
- `NET_ASYNC_COMPLETE_NO_MORE_RESULTS`: 작업이 성공적으로 완료되었으며 더 이상 사용할 Result가 없음
    이 상태는 `mysql_next_result_nonblocking()`에만 적용

일반적으로 비동기 함수를 사용하는 방법:

- 더 이상 `NET_ASYNC_NOT_READY`상태를 반환하지 않을 때까지 함수를 반복해 호출
- 최종 상태가 `NET_ASYNC_COMPLETE`인지 `NET_ASTNC_ERROR`인 지 확인

아래 예는 일반적인 호출 패턴을 보여줌:

- 작업이 진행되는 동안 다른 처리를 수행하는 경우:
    ```c
    enum net_async_status status;
    
    status = function(args);
    while (status == NET_ASYNC_NOT_READY) {
      /* perform other processing */
      other_processing ();
      /* invoke same function and arguments again */
      status = function(args);
    }
    if (status == NET_ASYNC_ERROR) {
      /* call failed; handle error */
    } else {
      /* call successful; handle result */
    }
    ```

- 작업이 진행되는 동안 다른 처리를 수행하지 않는 경우:
    ```c 
    enum net_async_status status;
    
    while ((status = function(args)) == NET_ASYNC_NOT_READY)
      ; /* empty loop */
    if (status == NET_ASYNC_ERROR) {
      /* call failed; handle error */
    } else {
      /* call successful; handle result */
    }
    ```

- Function의 성공과 실패 결과가 중요하지 않고 작업이 완료되었는지 확인하는 경우:
    ```c
    while (function (args) != NET_ASYNC_COMPLETE); /* empty loop */
    ```

`mysql_next_result_nonblocking()`의 경우 `NET_ASYNC_COMPLETE_NO_MORE_RESULTS`를 고려해야 함

```c
while ((status = mysql_next_result_nonblocking()) != NET_ASYNC_COMPLETE) {
  if (status == NET_ASYNC_COMPLETE_NO_MORE_RESULTS) {
    /* no more results */
  } else if (status == NET_ASYNC_ERROR) {
    /* handle error by calling mysql_error(); */
    break;
  }
}
```

대부분의 경우 비동기 Function의 인수와 동기 Function의 인수가 동일
예외는 [`mysql_fetch_row_nonblocking()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-fetch-row-nonblocking.html)과 [`mysql_store_result_nonblocking()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-store-result-nonblocking.html)이며 추가 인수를 사용함

## Example Program

비동기 C API Function을 사용하는 예제 C++ Program을 보여줌

Program에서 사용하는 SQL 개체를 설정하는 방법:
```sql
CREATE DATABASE db;
USE db;
CREATE TABLE test_table (id INT NOT NULL);
INSERT INTO test_table VALUES (10), (20), (30);

CREATE USER 'testuser'@'localhost' IDENTIFIED BY 'testpass';
GRANT ALL ON db.* TO 'testuser'@'localhost';
```

`async_app.cc`를 포하하는 이름의 File을 만듬(필요에 따라 Connection Parameter 조정)

```c++
#include <stdio.h>
#include <string.h>
#include <iostream>
#include <mysql.h>
#include <mysqld_error.h>

using namespace std;

/* change following connection parameters as necessary */
static const char * c_host = "localhost";
static const char * c_user = "testuser";
static const char * c_auth = "testpass";
static int          c_port = 3306;
static const char * c_sock = "/usr/local/mysql/mysql.sock";
static const char * c_dbnm = "db";

void perform_arithmetic() {
  cout<<"dummy function invoked\n";
  for (int i = 0; i < 1000; i++)
    i*i;
}

int main(int argc, char ** argv){
  MYSQL *mysql_local;
  MYSQL_RES *result;
  MYSQL_ROW row;
  net_async_status status;
  const char *stmt_text;

  if (!(mysql_local = mysql_init(NULL))) {
    cout << "mysql_init() failed\n";
    exit(1);
  }
  while ((status = mysql_real_connect_nonblocking(mysql_local, c_host, c_user, c_auth, 
												  c_dbnm, c_port, c_sock, 0)) == NET_ASYNC_NOT_READY); // empty loop
  if (status == NET_ASYNC_ERROR) {
    cout << "mysql_real_connect_nonblocking() failed\n";
    exit(1);
  }
  /* run query asynchronously */
  stmt_text = "SELECT * FROM test_table ORDER BY id";
  status = mysql_real_query_nonblocking(mysql_local, stmt_text, (unsigned long)strlen(stmt_text));
  /* do some other task before checking function result */
  perform_arithmetic();
  while (status == NET_ASYNC_NOT_READY) {
    status = mysql_real_query_nonblocking(mysql_local, stmt_text, (unsigned long)strlen(stmt_text));
    perform_arithmetic();
  }
  if (status == NET_ASYNC_ERROR) {
    cout << "mysql_real_query_nonblocking() failed\n";
    exit(1);
  }

  /* retrieve query result asynchronously */
  status = mysql_store_result_nonblocking(mysql_local, &result);
  /* do some other task before checking function result */
  perform_arithmetic();
  while (status == NET_ASYNC_NOT_READY) {
    status = mysql_store_result_nonblocking(mysql_local, &result);
    perform_arithmetic();
  }
  if (status == NET_ASYNC_ERROR) {
    cout << "mysql_store_result_nonblocking() failed\n";
    exit(1);
  }
  if (result == NULL) {
    cout << "mysql_store_result_nonblocking() found 0 records\n";
    exit(1);
  }

  /* fetch a row synchronously */
  row = mysql_fetch_row(result);
  if (row != NULL && strcmp(row[0], "10") == 0) {
    cout << "ROW: " << row[0] << "\n";  
  } else {
    cout << "incorrect result fetched\n";
  }
  /* fetch a row asynchronously, but without doing other work */
  while (mysql_fetch_row_nonblocking(result, &row) != NET_ASYNC_COMPLETE)
    ; /* empty loop */
  /* 2nd row fetched */
  if (row != NULL && strcmp(row[0], "20") == 0) {
    cout << "ROW: " << row[0] << "\n";
  } else {
    cout << "incorrect result fetched\n";
  }
  /* fetch a row asynchronously, doing other work while waiting */
  status = mysql_fetch_row_nonblocking(result, &row);
  /* do some other task before checking function result */
  perform_arithmetic();
  while (status != NET_ASYNC_COMPLETE) {
    status = mysql_fetch_row_nonblocking(result, &row);
    perform_arithmetic();
  }
  /* 3rd row fetched */
  if (row != NULL && strcmp(row[0], "30") == 0){
    cout<< "ROW: " << row[0] << "\n";
  } else {
    cout<< "incorrect result fetched\n";
  }
  /* fetch a row asynchronously (no more rows expected) */
  while ((status = mysql_fetch_row_nonblocking(result, &row))
           != NET_ASYNC_COMPLETE)
    ; /* empty loop */
  if (row == NULL) {
    cout << "No more rows to process.\n";
  } else {
    cout << "More rows found than expected.\n";
  }
  /* free result set memory asynchronously */
  while (mysql_free_result_nonblocking(result) != NET_ASYNC_COMPLETE); // empty loop
  mysql_close(mysql_local);
}
```

Command를 사용해 Program을 Compile함(필요에 따라 Compiler와 Option을 조정)
```bash
gcc -g async_app.cc -std=c++11 \
  -I/usr/local/mysql/include \
  -o async_app -L/usr/lib64/ -lstdc++ \
  -L/usr/local/mysql/lib/ -lmysqlclient
```

Program 실행, 다양한 수의 `dummy function invoked` 호출 Instance가 호출될 수 있으나 결과는 아래와 유사
```
dummy function invoked
dummy function invoked
ROW: 10
ROW: 20
dummy function invoked
ROW: 30
No more rows to process.
```

프로그램을 test하기 위해 `test_table`에 Row를 추가하거나 제거하고 변경할 때마다 다시 Program 실행

## 비동기 Function 제한 사항

- `mysql_real_connect_nonblocking()`: `mysql_native_password`, `sha256_password`, `caching_sha2_password`로 인증하는 계정에만 사용 가능
- `mysql_real_connect_nonblocking()`: TCP/IP 또는 Unix Socket File Connection을 설정하는 데에만 사용 가능
- `LOAD DATA`, `LOAD XML`문은 지원되지 않으며 동기 C API Function을 사용해 처리해야 함
- Non-Blocking 작업을 시작하는 비동기 C API 호출에 전달된 인수는 작업이 나중에 종료될 때 까지 계속 사용 중일 수 있음
    종료될 때 까지 재사용하면 안됨
- Protocol 압축은 비동기 C API Function에서 지원되지 않음

# C API 비동기 Interface Data 구조

- `enum net_async_status`

    - 비동기 C API Function의 반환 Status를 표현하는데 사용되는 `enum`

    | Status Value                         | Description                                                  |
    | ------------------------------------ | ------------------------------------------------------------ |
    | `NET_ASYNC_COMPLETE`                 | 비동기 작업이 완료                                           |
    | `NET_ASYNC_NOT_READY`                | 비동기 작업이 진행중                                         |
    | `NET_ASYNC_ERROR`                    | 비동기 작업이 오류로 종료                                    |
    | `NET_ASYNC_COMPLETE_NO_MORE_RESULTS` | `mysql_next_result_nonblocking()` 더 이상 사용할 수 있는 결과가 없음 |

# C API 비동기 Function

| Function Name                                                | Description                                                  | Introduced |
| ------------------------------------------------------------ | ------------------------------------------------------------ | ---------- |
| [`mysql_fetch_row_nonblocking()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-fetch-row-nonblocking.html) | 다음 Result Set Row를 비동기식으로 가져옴                    | 8.0.16     |
| [`mysql_free_result_nonblocking()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-free-result-nonblocking.html) | Result Set Memory를 비동기식으로 해제                        | 8.0.16     |
| [`mysql_next_result_nonblocking()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-next-result-nonblocking.html) | Multi Result Execution에서 다음 Result를 비동기식으로 반환/시작 | 8.0.16     |
| [`mysql_real_connect_nonblocking()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-real-connect-nonblocking.html) | MySQL Server에 비동기식으로 Connection                       | 8.0.16     |
| [`mysql_real_query_nonblocking()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-real-query-nonblocking.html) | 비동기식 Statement 실행                                      | 8.0.16     |
| [`mysql_store_result_nonblocking()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-store-result-nonblocking.html) | 전체 Result Set을 비동기식으로 검색 및 저장                  | 8.0.16     |

