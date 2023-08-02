# MySQL Binary Log

이 문서는 MySQL 8.0.32(MySQL 8.0)을 기준으로 작성되었습니다.

MySQL의 Binlog의 단위는 Event입니다.

예시로 `INSERT INTO test VALUES(1)`이라는 DML을 실행시킬 시 `ANONYMOUS_GTID_LOG_EVENT`, `QUERY_EVENT`, `TABLE_MAP_EVENT`, `WRITE_ROWS_EVENT`, `XID_EVENT`가 실행됩니다.

MySQL은 Write Ahead Logging이 아니라 선택에 의해 Log를 작성할 수 있습니다.
`COMMIT`하지 않을 시 Log에 남지 않습니다(따라서 `ROLLBACK`은 남지 않습니다).
위와 같은 이유로 MySQL은 대량의 처리보다 소량에 처리에 유리하다는 특징을 가집니다(Memory에 적재하기 때문에 대량의 Transaction을 처리하기 힘들기 때문입니다.).

## MySQL Binary Log Structure

### Architecture

MySQL의 Binlog는 크게 Common-Header, Post-Header, Body, Footer라는 4가지 구조로 이루어집니다.

#### 1. Common-Header

공통 양식입니다(19 Byte).

| Name                 | Format | Description                                                  |
| -------------------- | :----: | ------------------------------------------------------------ |
| `when`               | 4 Byte | Unix Timestamp이며 이 Query가 시작했을 시간을 나타냅니다.    |
| `type_code`          | 1 Byte | 아래의 [Event Type](#event-type)에 해당하는 코드입니다.      |
| `unmasked_server_id` | 4 Byte | 이 이벤트가 생성된 Server의 ID입니다.                        |
| `data_written`       | 4 Byte | 이 이벤트의 길이입니다(Common_Header_Len + Post-Header_Len + Body_Len). |
| `log_pos`            | 4 Byte | 다음 Master Server Binary Log의 위치                         |
| `flags`              | 2 Byte | 버전에 따른 Binary Log Flag                                  |

#### 2. Post-Header

Event Type에 따라 다른 고정 크기 Header입니다.
아래 [Event Type](#event-type) 참조

#### 3. Body

가변 길이의 데이터입니다.
같은 Event Type을 가져도 내용과 길이가 다를 수 있습니다.

#### 4. Footer

선택 양식입니다(0 or 4 Byte).

| Name           | Format | Description                                                  |
| -------------- | :----: | ------------------------------------------------------------ |
| `checksum_alg` | 4 Byte | Checksum(CRC32)를 사용할 때 추가로 Event 뒤에 붙으며 Common-Header의 `data_written`을 수정함 |

해당 Event의 Checksum 값은 이벤트를 Binary Log에 기록하기 직전에 계산합니다.
Checksum 값인 Footer는 이벤트의 일부로 간주되도록 이 이벤트의 `data_written` Field가 조정됩니다(+ `BINLOG_CHECKSUM_LEN`).

### Event Type

> [mysql-server/libbinlogevents/include/binlog_event.h 참고](https://github.com/mysql/mysql-server/blob/8.0/libbinlogevents/include/binlog_event.h)

| Event Name                  | Identifier | Post Header Length | Description                                                  |
| --------------------------- | :--------: | :----------------: | ------------------------------------------------------------ |
| `UNKNOWN_EVENT`             |  0x00(0)   |         -          | 존재할 수 없는 Event                                         |
| `START_EVENT_V3`            |  0x01(1)   |      56 Byte       | 2 + (`ST_SERVER_VER_LEN` = 50) + 4                           |
| `QUERY_EVENT`               |  0x02(2)   |      13 Byte       |                                                              |
| `STOP_EVENT`                |  0x03(3)   |       0 Byte       |                                                              |
| `ROTATE_EVENT`              |  0x04(4)   |       8 Byte       |                                                              |
| `INTVAR_EVENT`              |  0x05(5)   |       0 Byte       |                                                              |
| `SLAVE_EVENT`               |  0x07(7)   |       0 Byte       |                                                              |
| `APPEND_BLOCK_EVENT`        |  0x09(9)   |       4 Byte       |                                                              |
| `DELETE_FILE_EVENT`         |  0x0B(11)  |       4 Byte       |                                                              |
| `RAND_EVENT`                |  0x0D(13)  |       0 Byte       |                                                              |
| `USER_VAR_EVENT`            |  0x0E(14)  |       0 Byte       |                                                              |
| `FORMAT_DESCRIPTION_EVENT`  |  0x0F(15)  |      98 Byte       | `START_EVENT_V3_HEADER_LEN` + 1 + (`ENUM_END_EVENT` -1)      |
| `XID_EVENT`                 |  0x10(16)  |       0 Byte       |                                                              |
| `BEGIN_LOAD_QUERY_EVENT`    |  0x11(17)  |       4 Byte       |                                                              |
| `EXECUTE_LOAD_QUERY_EVENT`  |  0x12(18)  |      26 Byte       | `QUERY_HEADER_LEN` + (`EXECUTE_LOAD_QUERY_EXTRA_HEADER_LEN` = 13) |
| `TABLE_MAP_EVENT`           |  0x13(19)  |       8 Byte       |                                                              |
| `WRITE_ROWS_EVENT_V1`       |  0x17(23)  |       8 Byte       |                                                              |
| `UPDATE_ROWS_EVENT_V1`      |  0x18(24)  |       8 Byte       |                                                              |
| `DELETE_ROWS_EVENT_V1`      |  0x19(25)  |       8 Byte       |                                                              |
| `INCIDENT_EVENT`            |  0x1A(26)  |       2 Byte       |                                                              |
| `HEARTBEAT_LOG_EVENT`       |  0x1B(27)  |       0 Byte       |                                                              |
| `IGNORABLE_LOG_EVENT`       |  0x1C(28)  |       0 Byte       |                                                              |
| `ROWS_QUERY_LOG_EVENT`      |  0x1D(29)  |       0 Byte       |                                                              |
| `WRITE_ROWS_EVENT`          |  0x1E(30)  |      10 Byte       |                                                              |
| `UPDATE_ROWS_EVENT`         |  0x1F(31)  |      10 Byte       |                                                              |
| `DELETE_ROWS_EVENT`         |  0x20(32)  |      10 Byte       |                                                              |
| `GTID_LOG_EVENT`            |  0x21(33)  |      42 Byte       |                                                              |
| `ANONYMOUS_GTID_LOG_EVENT`  |  0x22(34)  |      42 Byte       |                                                              |
| `PREVIOUS_GTIDS_LOG_EVENT`  |  0x23(35)  |       0 Byte       |                                                              |
| `TRANSACTION_CONTEXT_EVENT` |  0x24(36)  |      18 Byte       |                                                              |
| `VIEW_CHANGE_EVENT`         |  0x25(37)  |      52 Byte       |                                                              |
| `XA_PREPARE_LOG_EVENT`      |  0x26(38)  |       0 Byte       |                                                              |
| `PARTIAL_UPDATE_ROWS_EVENT` |  0x27(39)  |      10 Byte       |                                                              |
| `TRANSACTION_PAYLOAD_EVENT` |  0x28(40)  |      40 Byte       |                                                              |
| `HEARTBEAT_LOG_EVENT_V2`    |  0x29(41)  |       ? Byte       |                                                              |
| `ENUM_END_EVENT`            |  0x2A(42)  |         -          | End Marker(다른 수식에 이용)                                 |

### Packed Integer

Unsigend Integer를 효율적으로 나타내기 위한 특별한 형식입니다.
최대 9 Byte를 사용할 수 있지만 값이 작을 경우 1, 3, 4 Byte만 사용할 수도 있습니다.
첫 Byte의 값에 따라 읽는 방법이 달라집니다.

| First Byte  | Range                                                        | Description                             |
| ----------- | ------------------------------------------------------------ | --------------------------------------- |
| 0x00 ~ 0xFA | 0x00 ~ 0xFA(0~250)                                           | 1 Byte만 사용하며 첫 Byte가 해당하는 값 |
| 0xFC        | 0xFB ~ 0xFFFF(251 ~ 65535)                                   | 3 Byte를 사용하며 첫 Byte를 제외한 값   |
| 0xFD        | 0xFFFF ~ 0xFFFFFF(65535 ~ 16777215)                          | 4 Byte를 사용하며 첫 Byte를 제외한 값   |
| 0xFE        | 0xFFFFFF ~ 0xFFFFFFFFFFFFFFFF(16777215 ~ 18446744073709552000) | 9 Byte를 사용하며 첫 Byte를 제외한 값   |

## Event Type Struct

### START_EVENT_V3

### QUERY_EVENT

`QUERY_EVENT`는 13 Byte의 Post-Header와 가변 길이의 Body로 이루어져 있습니다.

<table><thead><tr><th colspan="16">OPCODE: QUERY</th></tr></thead><tbody><tr><td>6f</td><td>70</td><td>e4</td><td>63</td><td>02</td><td>01</td><td>00</td><td>00</td><td>00</td><td>b8</td><td>00</td><td>00</td><td>00</td><td>a4</td><td>01</td><td>00</td></tr><tr><td colspan="16">1</td></tr><tr><td>00</td><td>00</td><td>00</td><td>24</td><td>00</td><td>00</td><td>00</td><td>00</td><td>00</td><td>00</td><td>00</td><td>01</td><td>00</td><td>00</td><td>2e</td><td>00</td></tr><tr><td colspan="3">1</td><td colspan="4">2</td><td colspan="4">3</td><td>4</td><td colspan="2">5</td><td colspan="2">6</td></tr><tr><td>00</td><td>00</td><td>00</td><td>00</td><td>00</td><td>01</td><td>20</td><td>00</td><td>a0</td><td>45</td><td>00</td><td>00</td><td>00</td><td>00</td><td>06</td><td>03</td></tr><tr><td colspan="16">7</td></tr><tr><td>73</td><td>74</td><td>64</td><td>04</td><td>ff</td><td>00</td><td>ff</td><td>00</td><td>ff</td><td>00</td><td>0c</td><td>01</td><td>61</td><td>00</td><td>10</td><td>01</td></tr><tr><td colspan="16">7</td></tr><tr><td>11</td><td>ce</td><td>07</td><td>00</td><td>00</td><td>00</td><td>00</td><td>00</td><td>00</td><td>12</td><td>ff</td><td>00</td><td>13</td><td>00</td><td>61</td><td>00</td></tr><tr><td colspan="14">7</td><td colspan="2">8</td></tr><tr><td>2f</td><td>2a</td><td>20</td><td>41</td><td>70</td><td>70</td><td>6c</td><td>69</td><td>63</td><td>61</td><td>74</td><td>69</td><td>6f</td><td>6e</td><td>4e</td><td>61</td></tr><tr><td colspan="16">9</td></tr><tr><td>6d</td><td>65</td><td>3d</td><td>44</td><td>61</td><td>74</td><td>61</td><td>47</td><td>72</td><td>69</td><td>70</td><td>20</td><td>32</td><td>30</td><td>32</td><td>31</td></tr><tr><td colspan="16">9</td></tr><tr><td>2e</td><td>31</td><td>2e</td><td>33</td><td>20</td><td>2a</td><td>2f</td><td>20</td><td>63</td><td>72</td><td>65</td><td>61</td><td>74</td><td>65</td><td>20</td><td>74</td></tr><tr><td colspan="16">9</td></tr><tr><td>61</td><td>62</td><td>6c</td><td>65</td><td>20</td><td>74</td><td>65</td><td>73</td><td>74</td><td>5f</td><td>61</td><td>67</td><td>61</td><td>69</td><td>6e</td><td>28</td></tr><tr><td colspan="16">9</td></tr><tr><td>63</td><td>31</td><td>20</td><td>69</td><td>6e</td><td>74</td><td>20</td><td>70</td><td>72</td><td>69</td><td>6d</td><td>61</td><td>72</td><td>79</td><td>20</td><td>6b</td></tr><tr><td colspan="16">9</td></tr><tr><td>65</td><td>79</td><td>2c</td><td>20</td><td>63</td><td>32</td><td>20</td><td>74</td><td>69</td><td>6d</td><td>65</td><td>73</td><td>74</td><td>61</td><td>6d</td><td>70</td></tr><tr><td colspan="16">9</td></tr><tr><td>28</td><td>36</td><td>29</td><td>29</td><td>9b</td><td>17</td><td>ee</td><td>f8</td><td colspan="8" rowspan="2"></td></tr><tr><td colspan="4">9</td><td colspan="4">10</td></tr></tbody></table>

| Num  | Name              | Length    | Description                |
| ---- | ----------------- | --------- | -------------------------- |
| 1    | Common-Header     | 19 Byte   |                            |
| 2    | `thread_id`       | 4 Byte    |                            |
| 3    | `query_exec_time` | 4 Byte    |                            |
| 4    | `db_len`          | 1 Byte    |                            |
| 5    | `error_code`      | 4 Byte    |                            |
| 6    | `status_vars_len` | 2 Byte    |                            |
| 7    | `status_vars`     | 가변 길이 | `status_vars_len`          |
| 8    | `m_db`            | 가변 길이 | `db_len`                   |
| 9    | `m_query`         | 가변 길이 | 남은 Event Length에서 계산 |
| 10   | Footer            | 4 Byte    |                            |

#### `status_vars`의 구분자와 형태

| Identifier | Name                                | Format    | Description                                                  |
| ---------- | ----------------------------------- | --------- | ------------------------------------------------------------ |
| 0x00(0)    | `Q_FLAGS2_CODE`                     | 5 Byte    | ID + 4 Byte `flag2`                                          |
| 0x01(1)    | `Q_SQL_MODE_CODE`                   | 9 Byte    | ID + 8 Byte `sql_mode`                                       |
| 0x02(2)    | `Q_CATALOG_CODE`                    | -         | 사용하지 않음 binlog ver 1~3                                 |
| 0x03(3)    | `Q_AUTO_INCREMENT`                  | 5 Byte    | ID + 2 Byte `increment` + 2 Byte  `offset`                   |
| 0x04(4)    | `Q_CHARSET_CODE`                    | 7 Byte    | ID + 2 Byte `client` + 2 Byte `connection` + 2 Byte `server` |
| 0x05(5)    | `Q_TIME_ZONE_CODE`                  | 가변 길이 | ID + 1 Byte `LEN` + `LEN` * `uint8_t`                        |
| 0x06(6)    | `Q_CATALOG_NZ_CODE`                 | 가변 길이 | ID + 1 Byte `LEN` + `LEN` * `uint8_t`                        |
| 0x07(7)    | `Q_LC_TIME_NAMES_CODE`              | 3 Byte    | ID + 2 Byte `?`                                              |
| 0x08(8)    | `Q_CHARSET_DATABASE_CODE`           | 3 Byte    | ID + 2 Byte `?`                                              |
| 0x09(9)    | `Q_TABLE_MAP_FOR_UPDATE_CODE`       | 9 Byte    | ID + 8 Byte `?`                                              |
| 0x0A(10)   | `Q_MASTER_DATA_WRITTEN_CODE`        | 5 Byte    | ID + 4 Byte `?`, 사용하지 않음(placeholder)                  |
| 0x0B(11)   | `Q_INVOKER`                         | 가변 길이 | ID + 2 Byte `LEN` + `LEN` * `uint8_t`                        |
| 0x0C(12)   | `Q_UPDATED_DB_NAMES`                | 가변 길이 | ID + `2-D array` `?`                                         |
| 0x0D(13)   | `Q_MICROSECONDS`                    | -         | 사용하지 않음                                                |
| 0x0E(14)   | `Q_COMMIT_TS`                       | -         | 사용하지 않음                                                |
| 0x0F(15)   | `Q_COMMIT_TS2`                      | -         | `GTID_EVENT`를 Migration 한 후 사용하지 않음                 |
| 0x10(16)   | `Q_EXPLICIT_DEFAULTS_FOR_TIMESTAMP` | 2 Byte    | ID + 1 Byte `boolean`                                        |
| 0x11(17)   | `Q_DDL_LOGGED_WITH_XID`             | 9 Byte    | ID + 8 Byte `xid`                                            |
| 0x12(18)   | `Q_DEFAULT_COLLATION_FOR_UTF8MB4`   | 3 Byte    | ID + 2 Byte `default_collation_charset`                      |
| 0x13(19)   | `Q_SQL_REQUIRE_PRIMARY_KEY`         | 3 Byte    | ID + 2 Byte `sql_require_primary_key`                        |
| 0x14(20)   | `Q_DEFAULT_TABLE_ENCRYPTION`        | 3 Byte    | ID + 2 Byte `default_table_encryption`                       |



### STOP_EVENT

`STOP_EVENT`는 Common-Header밖에 존재하지 않습니다.

### ROTATE_EVENT

`ROTATE_EVENT`는 8 Byte의 Post-Header와 가변 길이의 Body로 이루어져 있습니다. 

<table><thead><tr><th colspan="16">OPCODE: ROTATE</th></tr></thead><tbody><tr><td>cc</td><td>69</td><td>e4</td><td>63</td><td>04</td><td>01</td><td>00</td><td>00</td><td>00</td><td>29</td><td>00</td><td>00</td><td>00</td><td>02</td><td>13</td><td>00</td></tr><tr><td colspan="16">1</td></tr><tr><td>00</td><td>00</td><td>00</td><td>04</td><td>00</td><td>00</td><td>00</td><td>00</td><td>00</td><td>00</td><td>00</td><td>62</td><td>69</td><td>6e</td><td>2e</td><td>30</td></tr><tr><td colspan="3">1</td><td colspan="8">2</td><td colspan="5">3</td></tr><tr><td>30</td><td>30</td><td>30</td><td>30</td><td>33</td><td>d6</td><td>cb</td><td>e8</td><td>27</td><td colspan="7" rowspan="2"></td></tr><tr><td colspan="5">3</td><td colspan="4">4</td></tr></tbody></table>

| Num  | Name            | Length    | Description |
| ---- | --------------- | --------- | ----------- |
| 1    | Common-Header   | 19 Byte   |             |
| 2    | `position`      | 8 Byte    |             |
| 3    | `new_log_ident` | 가변 길이 |             |
| 4    | Footer          | 4 Byte    |             |

### INTVAR_EVENT

`QUERY_EVENT` 이전에 생기는 Event이며 Query에서 `LAST_INSERT_ID`나 `INSERT_ID`를 사용할 때 발생합니다.(테스트 예정)
`INTVAR_EVENT`는 Post-Header없이 9 Byte의 Body만 존재합니다.

| Num  | Name   | Length | Description                                                  |
| ---- | ------ | ------ | ------------------------------------------------------------ |
| -    | `type` | 1 Byte | `enum` 값, `LAST_INSERT_ID_EVENT` = 1, `INSERT_ID_EVENT` = 2 |
| -    | `val`  | 8 Byte | `uint64_t` 값                                                |



### SLAVE_EVENT

### APPEND_BLOCK_EVENT

`APPEND_BLOCK_EVENT`는 4 Byte의 Post-Header와 raw data인 Body로 이루어져 있습니다.

| Num  | Name      | Length | Description |
| ---- | --------- | ------ | ----------- |
| -    | `file_id` | 4 Byte |             |

### DELETE_FILE_EVENT

`DELETE_FILE_EVENT`는 Master Server에서 `LOAD DATA`가 실패할 경우 발생합니다.
`DELETE_FILE_EVENT`는  Body 없이 4 Byte의 Post-Header로 이루어져 있습니다.

| Num  | Name      | Length | Description |
| ---- | --------- | ------ | ----------- |
| -    | `file_id` | 4 Byte |             |

### RAND_EVENT

Binlog ver 4.1.0 이하에서 `RAND()`나 `PASSWORD()`를 사용할 때 랜덤 시드를 방생하는 Event입니다.
Binlog ver 4.1.1 이후 사용하지 않습니다.
`RAND_EVENT`는 Post-Header없이 16 Byte의 Body만 존재합니다.

| Num  | Name    | Length | Description |
| ---- | ------- | ------ | ----------- |
| -    | `seed1` | 8 Byte | First Seed  |
| -    | `seed2` | 8 Byte | Second Seed |

### USER_VAR_EVENT

`QUERY_EVENT` 이전에 생기는 Event이나 `row-base` Logging에서는 사용되지 않습니다.

### FORMAT_DESCRIPTION_EVENT

`FORMAT_DESCRIPTION_EVENT`는 Body 없이 Common-Header와 Post-Header로 구성되어 있습니다.

<table><thead><tr><th colspan="16">OPCODE: FORMAT DESCRIPTION</th></tr></thead><tbody><tr><td>29</td><td>45</td><td>e4</td><td>63</td><td>0f</td><td>01</td><td>00</td><td>00</td><td>00</td><td>7a</td><td>00</td><td>00</td><td>00</td><td>7e</td><td>00</td><td>00</td></tr><tr><td colspan="16">1</td></tr><tr><td>00</td><td>01</td><td>00</td><td>04</td><td>00</td><td>38</td><td>2e</td><td>30</td><td>2e</td><td>33</td><td>32</td><td>00</td><td>00</td><td>00</td><td>00</td><td>00</td></tr><tr><td colspan="3">1</td><td colspan="2">2</td><td colspan="11">3</td></tr><tr><td>00</td><td>00</td><td>00</td><td>00</td><td>00</td><td>00</td><td>00</td><td>00</td><td>00</td><td>00</td><td>00</td><td>00</td><td>00</td><td>00</td><td>00</td><td>00</td></tr><tr><td colspan="16">3</td></tr><tr><td>00</td><td>00</td><td>00</td><td>00</td><td>00</td><td>00</td><td>00</td><td>00</td><td>00</td><td>00</td><td>00</td><td>00</td><td>00</td><td>00</td><td>00</td><td>00</td></tr><tr><td colspan="16">3</td></tr><tr><td>00</td><td>00</td><td>00</td><td>00</td><td>00</td><td>00</td><td>00</td><td>29</td><td>45</td><td>e4</td><td>63</td><td>13</td><td>00</td><td>0d</td><td>00</td><td>08</td></tr><tr><td colspan="7">3</td><td colspan="4">4</td><td>5</td><td colspan="4">6</td></tr><tr><td>00</td><td>00</td><td>00</td><td>00</td><td>04</td><td>00</td><td>04</td><td>00</td><td>00</td><td>00</td><td>62</td><td>00</td><td>04</td><td>1a</td><td>08</td><td>00</td></tr><tr><td colspan="16">6</td></tr><tr><td>00</td><td>00</td><td>08</td><td>08</td><td>08</td><td>02</td><td>00</td><td>00</td><td>00</td><td>0a</td><td>0a</td><td>0a</td><td>2a</td><td>2a</td><td>00</td><td>12</td></tr><tr><td colspan="16">6</td></tr><tr><td>34</td><td>00</td><td>0a</td><td>28</td><td>00</td><td>01</td><td>03</td><td>ab</td><td>18</td><td>a6</td><td colspan="6" rowspan="2"></td></tr><tr><td colspan="5">6</td><td>7</td><td colspan="4">8</td></tr></tbody></table>

| Num  | Name                    | Length  | Description |
| ---- | ----------------------- | ------- | ----------- |
| 1    | Common-Header           | 19 Byte |             |
| 2    | `binlog_version`        | 2 Byte  |             |
| 3    | `server_version`        | 50 Byte |             |
| 4    | `created_timestamp`     | 4 Byte  |             |
| 5    | `common_header_len`     | 1 Byte  |             |
| 6    | `post_header_len`       | 41 Byte |             |
| 7    | `number_of_event_types` | 1 Byte  |             |
| 8    | Footer                  | 4 Byte  |             |

### XID_EVENT

`XID_EVENT`는 Post-Header 없이 8 Byte의 Body만 가지고 있습니다.

<table><thead><tr><th colspan="16">OPCODE: XID</th></tr></thead><tbody><tr><td>1f</td><td>5f</td><td>e4</td><td>63</td><td>10</td><td>01</td><td>00</td><td>00</td><td>00</td><td>1f</td><td>00</td><td>00</td><td>00</td><td>fe</td><td>03</td><td>00</td></tr><tr><td colspan="16">1</td></tr><tr><td>00</td><td>00</td><td>00</td><td>38</td><td>00</td><td>00</td><td>00</td><td>00</td><td>00</td><td>00</td><td>00</td><td>7c</td><td>37</td><td>58</td><td>ed</td><td rowspan="2"></td></tr><tr><td colspan="3">1</td><td colspan="8">2</td><td colspan="4">3</td></tr></tbody></table>

| Num  | Name          | Length  | Description |
| ---- | ------------- | ------- | ----------- |
| 1    | Common-Header | 19 Byte |             |
| 2    | `xid`         | 8 Byte  |             |
| 3    | Footer        | 4 Byte  |             |

### BEGIN_LOAD_QUERY_EVENT

`BEGIN_LOAD_QUERY_EVENT`는 Common-Header로만 이루어져 있습니다.

### EXECUTE_LOAD_QUERY_EVENT

`EXECUTE_LOAD_QUERY_EVENT`는 `QUERY_EVENT`와 동일한 13 Byte의 Post-Header와 가변 길이의 Body로 이루어져 있습니다.

| Num  | Name              | Length | Description                                                  |
| ---- | ----------------- | ------ | ------------------------------------------------------------ |
| -    | `thread_id`       | 4 Byte |                                                              |
| -    | `query_exec_time` | 4 Byte |                                                              |
| -    | `db_len`          | 1 Byte |                                                              |
| -    | `error_code`      | 4 Byte |                                                              |
| -    | `file_id`         | 4 Byte |                                                              |
| -    | `fn_post_start`   | 4 Byte |                                                              |
| -    | `fn_pos_end`      | 4 Byte |                                                              |
| -    | `dump_handling`   | 1 Byte | `LOAD_DUP_ERROR` = 0, `LOAD_DUP_IGNORE` = 1, `LOAD_DUP_REPLACE` = 2 |

### TABLE_MAP_EVENT

`TABLE_MAP_EVENT`는 8 Byte의 Post-Header와 가변 길이의 Body로 이루어져 있습니다.

<table><thead><tr><th colspan="16">OPCODE: TABLE MAP</th></tr></thead><tbody><tr><td>1f</td><td>5f</td><td>e4</td><td>63</td><td>13</td><td>01</td><td>00</td><td>00</td><td>00</td><td>47</td><td>00</td><td>00</td><td>00</td><td>b7</td><td>03</td><td>00</td></tr><tr><td colspan="16">1</td></tr><tr><td>00</td><td>00</td><td>00</td><td>68</td><td>00</td><td>00</td><td>00</td><td>00</td><td>00</td><td>01</td><td>00</td><td>05</td><td>6d</td><td>79</td><td>73</td><td>71</td></tr><tr><td colspan="3">1</td><td colspan="6">2</td><td colspan="2">3</td><td colspan="5">4</td></tr><tr><td>6c</td><td>00</td><td>10</td><td>74</td><td>65</td><td>73</td><td>74</td><td>5f</td><td>61</td><td>75</td><td>74</td><td>6f</td><td>5f</td><td>63</td><td>6f</td><td>6d</td></tr><tr><td colspan="2">4</td><td colspan="14">5</td></tr><tr><td>6d</td><td>69</td><td>74</td><td>00</td><td>01</td><td>03</td><td>00</td><td>01</td><td>01</td><td>01</td><td>00</td><td>04</td><td>03</td><td>02</td><td>63</td><td>31</td></tr><tr><td colspan="4">5</td><td>6</td><td>7</td><td>8</td><td>9</td><td colspan="8">10</td></tr><tr><td>0c</td><td>01</td><td>80</td><td>23</td><td>91</td><td>01</td><td>ac</td><td colspan="9" rowspan="2"></td></tr><tr><td colspan="3">10</td><td colspan="4">11</td></tr></tbody></table>

| Num  | Name                       | Length    | Description                                              |
| ---- | -------------------------- | --------- | -------------------------------------------------------- |
| 1    | Common-Header              | 19 Byte   |                                                          |
| 2    | `table_id`                 | 6 Byte    | Mapped number                                            |
| 3    | `flags`                    | 2 Byte    | 어떤 의미를 가지는지 미지수                              |
| 4    | `database_name`            | 가변 길이 | 첫 Byte가 길이에 관한 값이고 해당 값만큼의 byte + 1 사용 |
| 5    | `table_name`               | 가변 길이 | 첫 Byte가 길이에 관한 값이고 해당 값만큼의 byte + 1 사용 |
| 6    | `column_count`             | 가변 길이 | `packed_integer`                                         |
| 7    | `column_type`              | 가변 길이 | `column_count`                                           |
| 8    | `metadata_length`          | 가변 길이 | `packed_integer`                                         |
| 9    | `null_bits`                | 가변 길이 | (int)((`column_count` + 7) / 8)                          |
| 10   | `optional_metadata_fields` | 가변 길이 | 매 첫 Byte는 Flag이며 해당 Flag에 맞는 처리              |
| 11   | Footer                     | 4 Byte    |                                                          |

#### [`column_type`에 해당하는 Metadata와 길이](#data-type)

#### `optional_metadata_fields`의 구분자와 형태

| Identifier | Name                          | Format                                 | Description                                                  |
| ---------- | ----------------------------- | -------------------------------------- | ------------------------------------------------------------ |
| 0x01(1)    | `SIGNEDNESS`                  | (int)((`column_count` + 7) / 8) + 0x00 | `numeric` Column의 Signed 여부(Signed = 1)                   |
| 0x02(2)    | `DEFAULT_CHARSET`             | Len + `packed_integer` + 0x00          | `packed_integer` 값이 Charset                                |
| 0x03(3)    | `COLUMN_CHARSET`              | ?                                      | 위와 동일할 것으로 예상, 테스트 예정                         |
| 0x04(4)    | `COLUMN_NAME`                 | `packed_integer ` + String             | `packed_integer` 값이 길이이고 이후로 Len + column_name 형식의 String |
| 0x05(5)    | `SET_STR_VALUE`               | ?                                      | `binlog_row_metadata` = FULL일 때 발생, 테스트 예정          |
| 0x06(6)    | `ENUM_STR_VALUE`              | ?                                      | `binlog_row_metadata` = FULL일 때 발생, 테스트 예정          |
| 0x07(7)    | `GEOMETRY_TYPE`               | ?                                      | `binlog_row_metadata` = FULL일 때 발생 테스트 예정           |
| 0x08(8)    | `SIMPLE_PRIMARY_KEY`          | `packed_integer` + pk columns          | `binlog_row_metadata` = FULL일 때 발생, `packed_integer`의 값이 개수이고 이후로 pk의 위치값 출력 |
| 0x09(9)    | `PRIMARY_KEY_WITH_PREFIX`     | ?                                      | `binlog_row_metadata` = FULL일 때 발생, 테스트 예정          |
| 0x0A(10)   | `ENUM_AND_SET_COLUMN_CHARSET` | ?                                      | `binlog_row_metadata` = FULL일 때 발생, 테스트 예정          |
| 0x0B(11)   | `ENUM_AND_SET_COLUMN_CHARSET` | ?                                      | `binlog_row_metadata` = FULL일 때 발생, 테스트 예정          |
| 0x0C(12)   | `COLUMN_VISIBILITY`           | ? (`packed_integer` + bit?)            | 명확한 테스트 예정                                           |



### WRITE_ROWS_EVENT_V1

`WRITE_ROWS_EVENT_V1`는 8 Byte의 Post-Header와 가변 길이의 Body로 이루어져 있습니다.

### UPDATE_ROWS_EVENT_V1

`UPDATE_ROWS_EVENT_V1`는 8 Byte의 Post-Header와 가변 길이의 Body로 이루어져 있습니다.

### DELETE_ROWS_EVENT_V1

`DELETE_ROWS_EVENT_V1`는 8 Byte의 Post-Header와 가변 길이의 Body로 이루어져 있습니다.

### INCIDENT_EVENT

### HEARTBEAT_LOG_EVENT

Replication 중 Source Server가 살아있는 지 확인하기 위한 Event입니다.
`HEARTBEAT_LOG_EVENT`는 Post-Header없이 가변 길이의 Body로 이루어져 있습니다.

| Num  | Name        | Length | Description |
| ---- | ----------- | ------ | ----------- |
| -    | `log_ident` | ?      |             |

### IGNORABLE_LOG_EVENT

`IGNORABLE_LOG_EVENT`는 Common-Header밖에 존재하지 않습니다.

### ROWS_QUERY_LOG_EVENT

`ROWS_QUERY_LOG_EVENT`는 Post-Header 없이 가변 길이의 Body로 이루어져 있습니다.

| Num  | Name           | Length | Description |
| ---- | -------------- | ------ | ----------- |
| -    | `m_rows_query` | ?      |             |

### WRITE_ROWS_EVENT

`WRITE_ROWS_EVENT`는 10 Byte의 Post-Header와 가변 길이의 Body로 이루어져 있습니다.

<table><thead><tr><th colspan="16">OPCODE: WRITE(INSERT) ROWS</th></tr></thead><tbody><tr><td>6f</td><td>e0</td><td>ee</td><td>63</td><td>1e</td><td>01</td><td>00</td><td>00</td><td>00</td><td>38</td><td>00</td><td>00</td><td>00</td><td>6f</td><td>04</td><td>00</td></tr><tr><td colspan="16">1</td></tr><tr><td>00</td><td>00</td><td>00</td><td>5a</td><td>00</td><td>00</td><td>00</td><td>00</td><td>00</td><td>01</td><td>00</td><td>02</td><td>00</td><td>05</td><td>ff</td><td>00</td></tr><tr><td colspan="3">1</td><td colspan="6">2</td><td colspan="2">3</td><td colspan="2">4</td><td>5</td><td>6</td><td>7</td></tr><tr><td>01</td><td>00</td><td>00</td><td>00</td><td>01</td><td>00</td><td>00</td><td>00</td><td>01</td><td>00</td><td>00</td><td>00</td><td>01</td><td>00</td><td>00</td><td>00</td></tr><tr><td colspan="16">8</td></tr><tr><td>01</td><td>00</td><td>00</td><td>00</td><td>40</td><td>af</td><td>67</td><td>4f</td><td colspan="8" rowspan="2"></td></tr><tr><td colspan="4">8</td><td colspan="4">9</td></tr></tbody></table>

| Num  | Name                  | Length    | Description                                        |
| ---- | --------------------- | --------- | -------------------------------------------------- |
| 1    | Common-header         | 19 Byte   |                                                    |
| 2    | `table_id`            | 6 Byte    |                                                    |
| 3    | `flags`               | 2 Byte    |                                                    |
| 4    | `unknown flags`       | 2 Byte    |                                                    |
| 5    | `width`               | 가변 길이 | `packed_integer`, column 개수                      |
| 6    | `cols`                | 가변 길이 | (int)((`width` + 7) / 8), 사용하는 column을 나타냄 |
| 7    | `extra_row_info`      | 가변 길이 | (Int)((`N` + 7) / 8), 값이 있는 column을 나타냄    |
| 8    | `columns_after_image` | 가변 길이 | Data와 Meta에 맞는 크기만큼 처리                   |
| 9    | Footer                | 4 Byte    |                                                    |

### UPDATE_ROWS_EVENT

`UPDATE_ROWS_EVENT`는 10 Byte의 Post-Header와 가변 길이의 Body로 이루어져 있습니다.

<table><thead><tr><th colspan="16">OPCODE: UPDATE ROWS</th></tr></thead><tbody><tr><td>1C</td><td>3B</td><td>C7</td><td>63</td><td>1F</td><td>01</td><td>00</td><td>00</td><td>00</td><td>58</td><td>00</td><td>00</td><td>00</td><td>C5</td><td>05</td><td>00</td></tr><tr><td colspan="16">1</td></tr><tr><td>00</td><td>00</td><td>00</td><td>6F</td><td>00</td><td>00</td><td>00</td><td>00</td><td>00</td><td>01</td><td>00</td><td>02</td><td>00</td><td>05</td><td>FF</td><td>FF</td></tr><tr><td colspan="3">1</td><td colspan="6">2</td><td colspan="2">3</td><td colspan="2">4</td><td>5</td><td>6</td><td>7</td></tr><tr><td>00</td><td>01</td><td>00</td><td>00</td><td>00</td><td>05</td><td>61</td><td>62</td><td>63</td><td>64</td><td>65</td><td>05</td><td>61</td><td>62</td><td>63</td><td>64</td></tr><tr><td>8</td><td colspan="15">9</td></tr><tr><td>65</td><td>63</td><td>C7</td><td>3A</td><td>B7</td><td>99</td><td>AF</td><td>24</td><td>94</td><td>7B</td><td>00</td><td>01</td><td>00</td><td>00</td><td>00</td><td>05</td></tr><tr><td colspan="10">9</td><td>10</td><td colspan="5">11</td></tr><tr><td>65</td><td>64</td><td>63</td><td>62</td><td>61</td><td>05</td><td>61</td><td>62</td><td>63</td><td>64</td><td>65</td><td>63</td><td>C7</td><td>3A</td><td>B7</td><td>99</td></tr><tr><td colspan="16">11</td></tr><tr><td>AF</td><td>24</td><td>94</td><td>7B</td><td>F5</td><td>10</td><td>0E</td><td>A3</td><td colspan="8" rowspan="2"></td></tr><tr><td colspan="4">11</td><td colspan="4">12</td></tr></tbody></table>

| Num  | Name                   | Length    | Description                                        |
| ---- | ---------------------- | --------- | -------------------------------------------------- |
| 1    | Common-header          | 19 Byte   |                                                    |
| 2    | `table_id`             | 6 Byte    |                                                    |
| 3    | `flags`                | 2 Byte    |                                                    |
| 4    | `unknown flags`        | 2 Byte    |                                                    |
| 5    | `width`                | 가변 길이 | `packed_integer`, column 개수                      |
| 6    | `cols`                 | 가변 길이 | (int)((`width` + 7) / 8), 사용하는 column을 나타냄 |
| 7    | `cols`                 | 가변 길이 | (int)((`width` + 7) / 8), 사용하는 column을 나타냄 |
| 8    | `columns_before_image` | 가변 길이 | (Int)((`N` + 7) / 8), 값이 있는 column을 나타냄    |
| 9    | `row`                  | 가변 길이 | Data와 Meta에 맞는 크기만큼 처리                   |
| 10   | `columns_after_image`  | 가변 길이 | (Int)((`N` + 7) / 8), 값이 있는 column을 나타냄    |
| 11   | `row`                  | 가변 길이 | Data와 Meta에 맞는 크기만큼 처리                   |
| 12   | Footer                 | 4 Byte    |                                                    |

### DELETE_ROWS_EVENT

`DELETE_ROWS_EVENT`는 10 Byte의 Post-Header와 가변 길이의 Body로 이루어져 있습니다.

<table><thead><tr><th colspan="16">OPCODE: DELETE ROWS</th></tr></thead><tbody><tr><td>64</td><td>3B</td><td>C7</td><td>63</td><td>20</td><td>01</td><td>00</td><td>00</td><td>00</td><td>3D</td><td>00</td><td>00</td><td>00</td><td>19</td><td>07</td><td>00</td></tr><tr><td colspan="16">1</td></tr><tr><td>00</td><td>00</td><td>00</td><td>6F</td><td>00</td><td>00</td><td>00</td><td>00</td><td>00</td><td>01</td><td>00</td><td>02</td><td>00</td><td>05</td><td>FF</td><td>00</td></tr><tr><td colspan="3">1</td><td colspan="6">2</td><td colspan="2">3</td><td colspan="2">4</td><td>5</td><td>6</td><td>7</td></tr><tr><td>01</td><td>00</td><td>00</td><td>00</td><td>05</td><td>65</td><td>64</td><td>63</td><td>62</td><td>61</td><td>05</td><td>61</td><td>62</td><td>63</td><td>64</td><td>65</td></tr><tr><td colspan="16">8</td></tr><tr><td>63</td><td>C7</td><td>3A</td><td>B7</td><td>99</td><td>AF</td><td>24</td><td>94</td><td>7B</td><td>65</td><td>6E</td><td>08</td><td>0F</td><td colspan="3" rowspan="2"></td></tr><tr><td colspan="9">8</td><td colspan="4">9</td></tr></tbody></table>

| Num  | Name                   | Length    | Description                                        |
| ---- | ---------------------- | --------- | -------------------------------------------------- |
| 1    | Common-header          | 19 Byte   |                                                    |
| 2    | `table_id`             | 6 Byte    |                                                    |
| 3    | `flags`                | 2 Byte    |                                                    |
| 4    | `unknown flags`        | 2 Byte    |                                                    |
| 5    | `width`                | 가변 길이 | `packed_integer`, column 개수                      |
| 6    | `cols`                 | 가변 길이 | (int)((`width` + 7) / 8), 사용하는 column을 나타냄 |
| 7    | `columns_before_image` | 가변 길이 | (Int)((`N` + 7) / 8), 값이 있는 column을 나타냄    |
| 8    | `row`                  | 가변 길이 | Data와 Meta에 맞는 크기만큼 처리                   |
| 9    | Footer                 | 4 Byte    |                                                    |

### GTID_LOG_EVENT

### ANONYMOUS_GTID_LOG_EVENT

`ANONYMOUS_GTID_LOG_EVENT`는 42 Byte의 Post-Header와 Body로 이루어져 있습니다.

### PREVIOUS_GTIDS_LOG_EVENT

`PREVIOUS_GTIDS_LOG_EVENT`는 Post-Header 없이 Body로만 이루어져 있습니다.

<table><thead><tr><th colspan="16">OPCODE: PREVIOUS GTIDS LOG</th></tr></thead><tbody><tr><td>a5</td><td>8a</td><td>ec</td><td>63</td><td>23</td><td>01</td><td>00</td><td>00</td><td>00</td><td>1f</td><td>00</td><td>00</td><td>00</td><td>9d</td><td>00</td><td>00</td></tr><tr><td colspan="16">1</td></tr><tr><td>00</td><td>80</td><td>00</td><td>00</td><td>00</td><td>00</td><td>00</td><td>00</td><td>00</td><td>00</td><td>00</td><td>5e</td><td>19</td><td>8f</td><td>db</td><td rowspan="2"></td></tr><tr><td colspan="3">1</td><td colspan="4">2</td><td colspan="4">3</td><td colspan="4">4</td></tr></tbody></table>

| Num  | Name          | Length    | Description |
| ---- | ------------- | --------- | ----------- |
| 1    | Common-Header | 19 Byte   |             |
| 2    | `buf`         | 가변 길이 | ??          |
| 3    | `buf-size`    | 4 Byte    | ??          |
| 4    | Footer        | 4 Byte    |             |

### TRANSACTION_CONTEXT_EVENT

`TRANSACTION_CONTEXT_EVENT`는 알 수 있는 정보가 적어 상세히 나타낼 수 없었습니다.

| Num  | Name                              | Length    | Description |
| ---- | --------------------------------- | --------- | ----------- |
| -    | `thread_id`                       | 4 Byte    |             |
| -    | `gtid_specified`                  | ?         |             |
| -    | `encoded_snapshot_version`        | 가변 길이 |             |
| -    | `encoded_snapshot_version_length` | 4 Byte    |             |
| -    | `write_set`                       | ?         |             |
| -    | `read_set`                        | ?         |             |

### VIEW_CHANGE_EVENT

`VIEW_CHANGE_EVENT`는 알 수 있는 정보가 적어 상세히 나타낼 수 없었습니다.

| Num  | Name                 | Length  | Description |
| ---- | -------------------- | ------- | ----------- |
| -    | `view_id`            | 40 Byte |             |
| -    | `seq_number`         | 8 Byte  |             |
| -    | `certification_info` | ?       |             |

### XA_PREPARE_LOG_EVENT

`XA_PREPARE_LOG_EVENT`는 Post-Header 없이 Body로만 이루어져 있습니다.(테스트 예정)

### PARTIAL_UPDATE_ROWS_EVENT

### TRANSACTION_PAYLOAD_EVENT

### HEARTBEAT_LOG_EVENT_V2

Server Ver 8.0.26 이상의 Source Server에서만 표기됩니다.
`HEARTBEAT_LOG_EVENT_V2`는 Post-Header없이 가변 길이의 Body로 이루어져 있습니다.

| Num  | Name             | Length | Description |
| ---- | ---------------- | ------ | ----------- |
| -    | `m_log_filename` | ?      |             |
| -    | `m_log_pos`      | 8 Byte |             |

## Data Type

| Identifier | Name          | Meta Length | Description |
| ---------- | ------------- | ----------- | ----------- |
| 0x00(0)    | `DECIMAL`     | 0 Byte      |             |
| 0x01(1)    | `TINY`        | 0 Byte      |             |
| 0x02(2)    | `SHORT`       | 0 Byte      |             |
| 0x03(3)    | `LONG`        | 0 Byte      |             |
| 0x04(4)    | `FLOAT`       | 1 Byte      |             |
| 0x05(5)    | `DOUBLE`      | 1 Byte      |             |
| 0x06(6)    | `NULL`        | 0 Byte      |             |
| 0x07(7)    | `TIMESTAMP`   | 0 Byte      |             |
| 0x08(8)    | `LONGLONG`    | 0 Byte      |             |
| 0x09(9)    | `INT24`       | 0 Byte      |             |
| 0x0A(10)   | `DATE`        | 0 Byte      |             |
| 0x0B(11)   | `TIME`        | 0 Byte      |             |
| 0x0C(12)   | `DATETIME`    | 0 Byte      |             |
| 0x0D(13)   | `YEAR`        | 0 Byte      |             |
| 0x0E(14)   | `NEWDATE`     | ? Byte      |             |
| 0x0F(15)   | `VARCHAR`     | 2 Byte      |             |
| 0x10(16)   | `BIT`         | 2 Byte      |             |
| 0x11(17)   | `TIMESTAMP2`  | 1 Byte      |             |
| 0x12(18)   | `DATETIME2`   | 1 Byte      |             |
| 0x13(19)   | `TIME2`       | ? Byte      |             |
| 0x14(20)   | `TYPED_ARRAY` | 4 Byte      |             |
| 0xF3(243)  | `INVALID`     | ? Byte      |             |
| 0xF4(244)  | `BOOL`        | ? Byte      |             |
| 0xF5(245)  | `JSON`        | ? Byte      |             |
| 0xF6(246)  | `NEWDECIMAL`  | 2 Byte      |             |
| 0xF7(247)  | `ENUM`        | ? Byte      |             |
| 0xF8(248)  | `SET`         | ? Byte      |             |
| 0xF9(249)  | `TINY_BLOB`   | ? Byte      |             |
| 0xFA(250)  | `MEDIUM_BLOB` | ? Byte      |             |
| 0xFB(251)  | `LONG_BLOB`   | ? Byte      |             |
| 0xFC(252)  | `BLOB`        | 1 Byte      |             |
| 0xFD(253)  | `VARSTRING`   | 2 Byte      |             |
| 0xFE(254)  | `STRING`      | 2 Byte      |             |
| 0xFF(255)  | `GEOMETRY`    | 1 Byte      |             |

# Checklist

- [ ] 다양한 형태의 Data Type 체크하기
- [ ] 알지 못하는 Meta 값 파악하기
- [ ] 시인성 좋은 SQL문 형태로 출력하기
- [ ] 다른 상황에서 추출할 수 있는 Binlog Event 확인하기
- [ ] 명확한 구조가 나오지 않은 Event 확인하기
