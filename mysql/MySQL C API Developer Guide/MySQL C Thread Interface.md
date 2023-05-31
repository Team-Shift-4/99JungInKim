# MySQL C API Thread Interface

MySQL C API에는 Thread Client Application을 작성할 수 있는 기능이 포함되어 있음
이런 Function은 Client와 Thread 초기화와 종료에 대한 제어를 제공

MySQL C API Function인 `mysql_thread_id()`는 이름에 `thread`가 들어 있으나 Client Threading 목적으로 사용되지 않음
`CONNECTION_ID()` 대신 SQL Function과 마찬가지로 Client와 연결된 Server Thread의 ID를 반환

## MySQL C API Thread Function

| Function Name                                                | Description                                         |
| :----------------------------------------------------------- | :-------------------------------------------------- |
| [`mysql_thread_end()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-thread-end.html) | Thread Handler 종료                                 |
| [`mysql_thread_init()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-thread-init.html) | Thread Handler 초기화                               |
| [`mysql_thread_safe()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-thread-safe.html) | Client가 Thread로부터 안전하게 Compile되었는지 확인 |