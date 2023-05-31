# MySQL C API Client Plugin Interface

Client 측 Plugin을 관리할 수 있음

Client Program이 MySQL C API Client Plugin Function을 호출할 필요가 거의 없음
일반적으로 `mysql_options()`의 Option `MYSQL_DEFAULT_AUTH`, `MYSQL_PLUGIN_DIR`을 설정하기 위해 호출해 Plugin을 Load함

```c
char *plugin_dir = "path_to_plugin_dir";
char *default_auth = "plugin_name";

/* ... process command-line options ... */

mysql_options(&mysql, MYSQL_PLUGIN_DIR, plugin_dir);
mysql_options(&mysql, MYSQL_DEFAULT_AUTH, default_auth);
```

일반적으로 Program은 사용자가 기본값을 재정의 할 수 있는 Option `--plugin-dir`과 `--default-auth`도 허용함

# MySQL C API Plugin Function

| Function Name                                                | Description                | Introduced |
| :----------------------------------------------------------- | :------------------------- | :--------- |
| [`mysql_client_find_plugin()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-client-find-plugin.html) | Plugin에 대한 Pointer 반환 |            |
| [`mysql_client_register_plugin()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-client-register-plugin.html) | Plugin 등록                |            |
| [`mysql_load_plugin()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-load-plugin.html) | Plugin 로드                |            |
| [`mysql_load_plugin_v()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-load-plugin-v.html) | Plugin 로드                |            |
| [`mysql_plugin_get_option()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-plugin-get-option.html) | Plugin Option 가져오기     | 8.0.27     |
| [`mysql_plugin_options()`](https://dev.mysql.com/doc/c-api/8.0/en/mysql-plugin-options.html) | Plugin Option 설정         |            |