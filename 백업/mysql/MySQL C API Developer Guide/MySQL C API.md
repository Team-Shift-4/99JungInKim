# MySQL C API Function Table

| 이름                                                         | 설명                                                         | 도입   | 미사용 |
| :----------------------------------------------------------- | :----------------------------------------------------------- | :----- | :----- |
| [`mysql_affected_rows()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-affected-rows.html) | 마지막 [`UPDATE`](https://dev.mysql.com/doc/refman/8.0/en/update.html), [`DELETE`](https://dev.mysql.com/doc/refman/8.0/en/delete.html), [`INSERT`](https://dev.mysql.com/doc/refman/8.0/en/insert.html)문 에 의해 변경/삭제/삽입된 Row 수 |        |        |
| [`mysql_autocommit()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-autocommit.html) | Auto-commit Mode 설정                                        |        |        |
| [`mysql_bind_param()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-bind-param.html) | 다음에 실행되는 Statement에 대한 Query 속성 정의             | 8.0.23 |        |
| [`mysql_binlog_close()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-binlog-close.html) | Replication Event Stream 닫기                                |        |        |
| [`mysql_binlog_fetch()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-binlog-fetch.html) | Replication Event Stream에서 Event 읽기                      |        |        |
| [`mysql_binlog_open()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-binlog-open.html) | Replication Event Stream 열기                                |        |        |
| [`mysql_change_user()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-change-user.html) | 열린 Connection에서 User 및 DB 변경                          |        |        |
| [`mysql_character_set_name()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-character-set-name.html) | 현재 Connection의 기본 Charter Set 이름                      |        |        |
| [`mysql_client_find_plugin()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-client-find-plugin.html) | Plugin에 대한 Pointer 반환                                   |        |        |
| [`mysql_client_register_plugin()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-client-register-plugin.html) | Plugin 등록                                                  |        |        |
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
| [`mysql_fetch_row_nonblocking()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-fetch-row-nonblocking.html) | 다음 Result Set Row를 비동기식으로 가져오기                  | 8.0.16 |        |
| [`mysql_field_count()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-field-count.html) | 가장 최근 Command Statement의 결과 Column 수                 |        |        |
| [`mysql_field_seek()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-field-seek.html) | Result Set Row내에서 Column 찾기                             |        |        |
| [`mysql_field_tell()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-field-tell.html) | [`mysql_fetch_field()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-fetch-field.html)마지막 호출 을 위한 Field 위치 |        |        |
| [`mysql_free_result()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-free-result.html) | Free Result Set Memory                                       |        |        |
| [`mysql_free_result_nonblocking()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-free-result-nonblocking.html) | Result Set Memory를 비동기식으로 해제                        | 8.0.16 |        |
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
| [`mysql_load_plugin()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-load-plugin.html) | Plugin 로드                                                  |        |        |
| [`mysql_load_plugin_v()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-load-plugin-v.html) | Plugin 로드                                                  |        |        |
| [`mysql_more_results()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-more-results.html) | 더 많은 Result가 있는지 확인                                 |        |        |
| [`mysql_next_result()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-next-result.html) | Multiple Result 실행에서 다음 결과 반환/시작                 |        |        |
| [`mysql_next_result_nonblocking()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-next-result-nonblocking.html) | Multiple Result 실행에서 다음 결과를 비동기식으로 반환/시작  | 8.0.16 |        |
| [`mysql_num_fields()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-num-fields.html) | Result Set의 Column 수                                       |        |        |
| [`mysql_num_rows()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-num-rows.html) | Result Set의 Row 수                                          |        |        |
| [`mysql_options()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-options.html) | Connection 전 Option 설정                                    |        |        |
| [`mysql_options4()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-options4.html) | Connection 전 Option 설정                                    |        |        |
| [`mysql_ping()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-ping.html) | Server에 Ping                                                |        |        |
| [`mysql_plugin_get_option()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-plugin-get-option.html) | Plugin Option 가져오기                                       | 8.0.27 |        |
| [`mysql_plugin_options()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-plugin-options.html) | Plugin Option 설정                                           |        |        |
| [`mysql_query()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-query.html) | Statement 실행                                               |        |        |
| [`mysql_real_connect()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-real-connect.html) | MySQL Server에 Connect                                       |        |        |
| [`mysql_real_connect_dns_srv()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-real-connect-dns-srv.html) | DNS SRV Record를 사용하여 MySQL Server에 Connect             | 8.0.22 |        |
| [`mysql_real_connect_nonblocking()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-real-connect-nonblocking.html) | MySQL Server에 비동기식으로 Connect                          | 8.0.16 |        |
| [`mysql_real_escape_string()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-real-escape-string.html) | Command Statement 문자열의 특수 문자 인코딩                  |        |        |
| [`mysql_real_escape_string_quote()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-real-escape-string-quote.html) | 인용 Context를 설명하는 Command Statement 문자열의 특수 문자 인코딩 |        |        |
| [`mysql_real_query()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-real-query.html) | Statement 실행                                               |        |        |
| [`mysql_real_query_nonblocking()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-real-query-nonblocking.html) | Statemente 비동기식 실행                                     | 8.0.16 |        |
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
| [`mysql_stmt_affected_rows()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-stmt-affected-rows.html) | 마지막 Prepared Statement [`UPDATE`](https://dev.mysql.com/doc/refman/8.0/en/update.html), [`DELETE`](https://dev.mysql.com/doc/refman/8.0/en/delete.html), [`INSERT`](https://dev.mysql.com/doc/refman/8.0/en/insert.html)에 의해 변경/삭제/삽입된 Row수 |        |        |
| [`mysql_stmt_attr_get()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-stmt-attr-get.html) | Prepared Statement에 대한 속성 값 가져오기                   |        |        |
| [`mysql_stmt_attr_set()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-stmt-attr-set.html) | Prepared Statement에 대한 속성 값 설정                       |        |        |
| [`mysql_stmt_bind_param()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-stmt-bind-param.html) | Application Data Buffer를 Prepared Statement의 Parameter Marker와 연결 |        |        |
| [`mysql_stmt_bind_result()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-stmt-bind-result.html) | Application Data Buffer를 Result Set의 Column과 연결         |        |        |
| [`mysql_stmt_close()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-stmt-close.html) | Prepared Statement에서 사용하는 Free Memory(? 공문 그대로)   |        |        |
| [`mysql_stmt_data_seek()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-stmt-data-seek.html) | Prepared Statement Result Set에서 임의의 Row 번호를 찾음     |        |        |
| [`mysql_stmt_errno()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-stmt-errno.html) | 가장 최근에 호출된 MySQL ready-statement 함수의 오류 번호    |        |        |
| [`mysql_stmt_error()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-stmt-error.html) | 가장 최근에 호출된 MySQL ready-statement 함수에 대한 오류 메시지 |        |        |
| [`mysql_stmt_execute()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-stmt-execute.html) | Prepared Statement 실행                                      |        |        |
| [`mysql_stmt_fetch()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-stmt-fetch.html) | 다음 Result Set Row를 가져오고 바인딩된 모든 Row에 대한 데이터를 반환 |        |        |
| [`mysql_stmt_fetch_column()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-stmt-fetch-column.html) | 현재 Result Set Row의 한 Column에 대한 데이터를 가져옴       |        |        |
| [`mysql_stmt_field_count()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-stmt-field-count.html) | 가장 최근 Prepared Statemente Result Row 수                  |        |        |
| [`mysql_stmt_free_result()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-stmt-free-result.html) | Statement Handler에 할당된 사용 가능한 Resource              |        |        |
| [`mysql_stmt_init()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-stmt-init.html) | `MYSQL_STMT` 구조 에 대한 Memory 할당 및 초기화              |        |        |
| [`mysql_stmt_insert_id()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-stmt-insert-id.html) | `AUTO_INCREMENT`이전에 Prepared Statement에서 Column에 대해 생성된 ID |        |        |
| [`mysql_stmt_next_result()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-stmt-next-result.html) | Multiple Prepared Statement 실행에서 다음 Result 반환/시작   |        |        |
| [`mysql_stmt_num_rows()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-stmt-num-rows.html) | Buffering된 Statement Result Set의 Row 수                    |        |        |
| [`mysql_stmt_param_count()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-stmt-param-count.html) | Prepared Statement의 Parameter 수                            |        |        |
| [`mysql_stmt_param_metadata()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-stmt-param-metadata.html) | Parameter Metadata를 Result Set으로 반환                     |        |        |
| [`mysql_stmt_prepare()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-stmt-prepare.html) | 실행을 위한 Statement 준비                                   |        |        |
| [`mysql_stmt_reset()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-stmt-reset.html) | Server 측에서 Statement Buffer 재설정                        |        |        |
| [`mysql_stmt_result_metadata()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-stmt-result-metadata.html) | Prepared Statemente Metadata를 Result Set으로 반환           |        |        |
| [`mysql_stmt_row_seek()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-stmt-row-seek.html) | Prepared Statement Result Set에서 Row Offset을 찾음          |        |        |
| [`mysql_stmt_row_tell()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-stmt-row-tell.html) | Prepared Statement Result Set Row 내 현재 위치               |        |        |
| [`mysql_stmt_send_long_data()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-stmt-send-long-data.html) | 긴 데이터를 청크 단위로 Server에 전송                        |        |        |
| [`mysql_stmt_sqlstate()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-stmt-sqlstate.html) | 가장 최근에 호출된 MySQL ready-statement 함수의 SQLSTATE 값  |        |        |
| [`mysql_stmt_store_result()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-stmt-store-result.html) | 전체 Result Set 검색 및 저장                                 |        |        |
| [`mysql_store_result()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-store-result.html) | 전체 Result Set 검색 및 저장                                 |        |        |
| [`mysql_store_result_nonblocking()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-store-result-nonblocking.html) | 전체 Result Set 을 비동기식으로 검색 및 저장                 | 8.0.16 |        |
| [`mysql_thread_end()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-thread-end.html) | Thread Handler 종료                                          |        |        |
| [`mysql_thread_id()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-thread-id.html) | 현재 Thread ID                                               |        |        |
| [`mysql_thread_init()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-thread-init.html) | Thread Handler 초기화                                        |        |        |
| [`mysql_thread_safe()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-thread-safe.html) | Client가 Thread로부터 안전하게 Complie되었는지 여부          |        |        |
| [`mysql_use_result()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-use-result.html) | Row 별 Result Set 검색 시작                                  |        |        |
| [`mysql_warning_count()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-warning-count.html) | 이전 Statement에 대한 경고 횟수                              |        |        |