<img src="https://capsule-render.vercel.app/api?type=waving&color=auto&height=200&section=header&text=MySQL Binlog Parser&fontSize=50&fontColor=ffffff"/>

# MySQL Binlog Parser(`23.03.08)

이 프로그램은 MySQL 8.0(Log Version 4)의 Binlog File을 읽어 원하는 데이터를 추출해 필요한 양식으로 만들기 위해 제작 중
MySQL의 C API는 C++을 사용하고 추가적으로 Library를 정의한 후 Build해야만 사용할 수 있는 단점을 해결하기 위해 제작

### 설정할 목록

```bash
## my.cnf ##
log-bin						# Binlog를 남기게 설정
binlog_format		= ROW	# MIXED가 Default
binlog_row_metadata	= FULL	# FULL이 Default
```

### 목차

- [Input](#input)
- [Output](#output)
- [Description](#description)
- [Check List](#check-list)

### Input

실행 시 파라미터에 MySQL Binlog File의 이름을 입력하거나 실행 후 원하는 MySQL Binlog File의 이름을 입력

- -v 옵션을 통해 UNKNOWN 값 출력 가능
- -x 옵션을 통해 Hex값 출력 가능
- -d 옵션을 통해 기본 값이 아닌 디렉터리 사용 가능

따로 DB 연결 없이 작동

#### Example

```
mysql_binlog_parser -v -x bin.000039
```

### Output

파라미터로 입력 시 바로 MySQL Binlog File의 분석 값이 옵션에 따라 출력

#### 실행한 Statement

```sql
create table test(column1 int primary key, column2 char(50), column3 varchar(50), column4 datetime(5) not null, column5 timestamp(6));
 
insert into test values (1, 'test mysql binlog parser', testing...!', now(5), now(6));
 
update test set column4 = now(), column5 = now() where column1 = 1;
 
delete from test where column1 = 1;
```

#### Example

```
/clion/project/mysql_binlog_parser/cmake-build-debug/mysql_binlog_parser -v -x bin.000039
Verbose Hex 
File name: bin.000039

0001) 2023-03-08 17:55:03 End_log pos 126(0x7E) LEN: 122(7A) EVENT TYPE: FORMAT DESCRIPTION EVENT Server ID: 1 Flag: 0000 CRC32: E9822AC7

HEX
	00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F
	-----------------------------------------------
	67 4D 08 64 0F 01 00 00 00 7A 00 00 00 7E 00 00 
	00 00 00 04 00 38 2E 30 2E 33 32 00 00 00 00 00 
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
	00 00 00 00 00 00 00 00 00 00 00 13 00 0D 00 08 
	00 00 00 00 04 00 04 00 00 00 62 00 04 1A 08 00 
	00 00 08 08 08 02 00 00 00 0A 0A 0A 2A 2A 00 12 
	34 00 0A 28 00 01 

VERBOSE
	binlog version: 4, server version: 8.0.32, common header length: 19, date: 1970-01-01 09:00:00(0), number of event_types: 1
	Post-Header length per event
		QUERY EVENT: 13	ROTATE EVENT: 8	APPEND BLOCK EVENT: 4	DELETE FILE EVENT: 4	FORMAT DESCRIPTION EVENT: 98	BEGIN LOAD QUERY EVENT: 4	EXECUTE LOAD QUERY EVENT: 26
		TABLE MAP EVENT: 8	WRITE ROWS EVENT V1: 8	UPDATE ROWS EVENT V1: 8	DELETE ROWS EVENT V1: 8	INCIDENT EVENT: 2	WRITE ROWS EVENT: 10	UPDATE ROWS EVENT: 10
		DELETE ROWS EVENT: 10	GTID LOG EVENT: 42	ANONYMOUS GTID LOG EVENT: 42	TRANSACTION CONTEXT EVENT: 18	VIEW CHANGE EVENT: 52	PARTIAL UPDATE ROWS EVENT: 10	TRANSACTION PAYLOAD EVENT: 40

+------------------------------------------------------+
0002) 2023-03-08 17:55:03 End_log pos 157(0x9D) LEN: 31(1F) EVENT TYPE: PREVIOUS GTIDS LOG EVENT Server ID: 1 Flag: 0080 CRC32: 185299BA

HEX
	00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F
	-----------------------------------------------
	67 4D 08 64 23 01 00 00 00 1F 00 00 00 9D 00 00 
	00 80 00 00 00 00 00 00 00 00 00 

VERBOSE
	buffer size(?): 0, buffer(?): NULL

+------------------------------------------------------+
0003) 2023-03-08 17:55:20 End_log pos 234(0xEA) LEN: 77(4D) EVENT TYPE: ANONYMOUS GTID LOG EVENT Server ID: 1 Flag: 0000 CRC32: EABC03B1

HEX
	00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F
	-----------------------------------------------
	78 4D 08 64 22 01 00 00 00 4D 00 00 00 EA 00 00 
	00 00 00 01 00 00 00 00 00 00 00 00 00 00 00 00 
	00 00 00 00 00 00 00 00 00 00 00 00 02 00 00 00 
	00 00 00 00 00 01 00 00 00 00 00 00 00 E3 B4 15 
	B0 5F F6 05 BF A0 38 01 00 

VERBOSE
	last committed: 0, sequence number: 1, original committed timestamp: 2954212579, immediate_commit_timestamp: 2954212579, transaction length: 191, original server version: 80032, immediate server version: 80032

+------------------------------------------------------+
0004) 2023-03-08 17:55:20 End_log pos 348(0x15C) LEN: 114(72) EVENT TYPE: QUERY EVENT Server ID: 1 Flag: 0008 CRC32: 5CDDE2B5

HEX
	00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F
	-----------------------------------------------
	78 4D 08 64 02 01 00 00 00 72 00 00 00 5C 01 00 
	00 08 00 0A 00 00 00 00 00 00 00 06 00 00 31 00 
	00 00 00 00 00 01 20 00 A0 45 00 00 00 00 06 03 
	73 74 64 04 FF 00 FF 00 FF 00 0C 01 70 61 72 73 
	65 72 00 11 32 00 00 00 00 00 00 00 12 FF 00 14 
	00 70 61 72 73 65 72 00 63 72 65 61 74 65 20 64 
	61 74 61 62 61 73 65 20 70 61 72 73 65 72 

VERBOSE
	db name: parser, execute time: 0ms, error code: 0, thread id: 10
	query: create database parser

+------------------------------------------------------+
0005) 2023-03-08 17:56:59 End_log pos 427(0x1AB) LEN: 79(4F) EVENT TYPE: ANONYMOUS GTID LOG EVENT Server ID: 1 Flag: 0000 CRC32: 6B93A71

HEX
	00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F
	-----------------------------------------------
	DB 4D 08 64 22 01 00 00 00 4F 00 00 00 AB 01 00 
	00 00 00 01 00 00 00 00 00 00 00 00 00 00 00 00 
	00 00 00 00 00 00 00 00 00 00 00 00 02 01 00 00 
	00 00 00 00 00 02 00 00 00 00 00 00 00 5C 82 00 
	B6 5F F6 05 FC 32 01 A0 38 01 00 

VERBOSE
	last committed: 1, sequence number: 2, original committed timestamp: 3053486684, immediate_commit_timestamp: 3053486684, transaction length: 306, original server version: 80032, immediate server version: 80032

+------------------------------------------------------+
0006) 2023-03-08 17:56:59 End_log pos 654(0x28E) LEN: 227(E3) EVENT TYPE: QUERY EVENT Server ID: 1 Flag: 0000 CRC32: DEA267AD

HEX
	00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F
	-----------------------------------------------
	DB 4D 08 64 02 01 00 00 00 E3 00 00 00 8E 02 00 
	00 00 00 0A 00 00 00 00 00 00 00 06 00 00 33 00 
	00 00 00 00 00 01 20 00 A0 45 00 00 00 00 06 03 
	73 74 64 04 FF 00 FF 00 FF 00 0C 01 70 61 72 73 
	65 72 00 10 01 11 37 00 00 00 00 00 00 00 12 FF 
	00 13 00 70 61 72 73 65 72 00 63 72 65 61 74 65 
	20 74 61 62 6C 65 20 74 65 73 74 28 63 6F 6C 75 
	6D 6E 31 20 69 6E 74 20 70 72 69 6D 61 72 79 20 
	6B 65 79 2C 20 63 6F 6C 75 6D 6E 32 20 63 68 61 
	72 28 35 30 29 2C 20 63 6F 6C 75 6D 6E 33 20 76 
	61 72 63 68 61 72 28 35 30 29 2C 20 63 6F 6C 75 
	6D 6E 34 20 64 61 74 65 74 69 6D 65 28 35 29 20 
	6E 6F 74 20 6E 75 6C 6C 2C 20 63 6F 6C 75 6D 6E 
	35 20 74 69 6D 65 73 74 61 6D 70 28 36 29 29 

VERBOSE
	db name: parser, execute time: 0ms, error code: 0, thread id: 10
	query: create table test(column1 int primary key, column2 char(50), column3 varchar(50), column4 datetime(5) not null, column5 timestamp(6))

+------------------------------------------------------+
0007) 2023-03-08 17:58:05 End_log pos 733(0x2DD) LEN: 79(4F) EVENT TYPE: ANONYMOUS GTID LOG EVENT Server ID: 1 Flag: 0000 CRC32: C9D710F9

HEX
	00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F
	-----------------------------------------------
	1D 4E 08 64 22 01 00 00 00 4F 00 00 00 DD 02 00 
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
	00 00 00 00 00 00 00 00 00 00 00 00 02 02 00 00 
	00 00 00 00 00 03 00 00 00 00 00 00 00 3D A1 F7 
	B9 5F F6 05 FC 96 01 A0 38 01 00 

VERBOSE
	last committed: 2, sequence number: 3, original committed timestamp: 3120013629, immediate_commit_timestamp: 3120013629, transaction length: 406, original server version: 80032, immediate server version: 80032

+------------------------------------------------------+
0008) 2023-03-08 17:58:05 End_log pos 822(0x336) LEN: 89(59) EVENT TYPE: QUERY EVENT Server ID: 1 Flag: 0008 CRC32: 45E7091A

HEX
	00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F
	-----------------------------------------------
	1D 4E 08 64 02 01 00 00 00 59 00 00 00 36 03 00 
	00 08 00 0A 00 00 00 00 00 00 00 06 00 00 29 00 
	00 00 00 00 00 01 20 00 A0 45 00 00 00 00 06 03 
	73 74 64 04 FF 00 FF 00 FF 00 05 06 53 59 53 54 
	45 4D 0D E2 D1 0C 12 FF 00 70 61 72 73 65 72 00 
	42 45 47 49 4E 

VERBOSE
	db name: parser, execute time: 0ms, error code: 0, thread id: 10
	query: BEGIN

+------------------------------------------------------+
0009) 2023-03-08 17:58:05 End_log pos 937(0x3A9) LEN: 115(73) EVENT TYPE: TABLE MAP EVENT Server ID: 1 Flag: 0000 CRC32: AB7B7F0D

HEX
	00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F
	-----------------------------------------------
	1D 4E 08 64 13 01 00 00 00 73 00 00 00 A9 03 00 
	00 00 00 7F 00 00 00 00 00 01 00 06 70 61 72 73 
	65 72 00 04 74 65 73 74 00 05 03 FE 0F 12 11 06 
	FE C8 C8 00 05 06 16 01 01 00 02 03 FC FF 00 04 
	28 07 63 6F 6C 75 6D 6E 31 07 63 6F 6C 75 6D 6E 
	32 07 63 6F 6C 75 6D 6E 33 07 63 6F 6C 75 6D 6E 
	34 07 63 6F 6C 75 6D 6E 35 08 01 00 0C 01 F8 

VERBOSE
# object name: `parser`.`test`, table id: 127, flags: 0001
## `column1`, INT NOT NULL, PRIMARY KEY /* meta = 0 visible */
## `column2`, CHAR /* meta = 65224 charset = 0 visible */
## `column3`, VARCHAR /* meta = 200 charset = 0 visible */
## `column4`, DATETIME NOT NULL /* meta = 5 visible */
## `column5`, TIMESTAMP /* meta = 6 visible */

+------------------------------------------------------+
0010) 2023-03-08 17:58:05 End_log pos 1029(0x405) LEN: 92(5C) EVENT TYPE: WRITE ROWS EVENT Server ID: 1 Flag: 0000 CRC32: DF5B4B38

HEX
	00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F
	-----------------------------------------------
	1D 4E 08 64 1E 01 00 00 00 5C 00 00 00 05 04 00 
	00 00 00 7F 00 00 00 00 00 01 00 02 00 05 FF 00 
	01 00 00 00 18 74 65 73 74 20 6D 79 73 71 6C 20 
	62 69 6E 6C 6F 67 20 70 61 72 73 65 72 0B 74 65 
	73 74 69 6E 67 2E 2E 2E 21 99 AF 91 1E 85 0C D1 
	E0 64 08 4E 1D 0C D1 E2 

VERBOSE
# INSERT `parser`.`test`
##	AFTER
###		@1=1 /* INT meta=0 nullable=0, is_null=0 */
###		@2='test mysql binlog parser' /* CHAR(200) meta=65224 nullable=1, is_null=0 */
###		@3='testing...!' /* VARCHAR(200) meta=200 nullable=1, is_null=0 */
###		@4=2023-03-08 17:58:05.84016 /* DATETIME(5) meta=5 nullable=0, is_null=0 */
###		@5=2023-03-08 17:58:05.840162 /* TIMESTAMP(6) meta=6 nullable=1, is_null=0 */

+------------------------------------------------------+
0011) 2023-03-08 17:58:05 End_log pos 1060(0x424) LEN: 31(1F) EVENT TYPE: XID EVENT Server ID: 1 Flag: 0000 CRC32: FA1E0E9E

HEX
	00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F
	-----------------------------------------------
	1D 4E 08 64 10 01 00 00 00 1F 00 00 00 24 04 00 
	00 00 00 39 00 00 00 00 00 00 00 

VERBOSE
	COMMIT /* Xid = 57 */

+------------------------------------------------------+
0012) 2023-03-08 17:58:58 End_log pos 1139(0x473) LEN: 79(4F) EVENT TYPE: ANONYMOUS GTID LOG EVENT Server ID: 1 Flag: 0000 CRC32: F9B41D05

HEX
	00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F
	-----------------------------------------------
	52 4E 08 64 22 01 00 00 00 4F 00 00 00 73 04 00 
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
	00 00 00 00 00 00 00 00 00 00 00 00 02 03 00 00 
	00 00 00 00 00 04 00 00 00 00 00 00 00 86 BF 1E 
	BD 5F F6 05 FC D5 01 A0 38 01 00 

VERBOSE
	last committed: 3, sequence number: 4, original committed timestamp: 3172908934, immediate_commit_timestamp: 3172908934, transaction length: 469, original server version: 80032, immediate server version: 80032

+------------------------------------------------------+
0013) 2023-03-08 17:58:58 End_log pos 1233(0x4D1) LEN: 94(5E) EVENT TYPE: QUERY EVENT Server ID: 1 Flag: 0008 CRC32: 55143F96

HEX
	00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F
	-----------------------------------------------
	52 4E 08 64 02 01 00 00 00 5E 00 00 00 D1 04 00 
	00 08 00 0A 00 00 00 00 00 00 00 06 00 00 2E 00 
	00 00 00 00 00 01 20 00 A0 45 00 00 00 00 06 03 
	73 74 64 04 FF 00 FF 00 FF 00 05 06 53 59 53 54 
	45 4D 09 01 00 00 00 00 00 00 00 12 FF 00 70 61 
	72 73 65 72 00 42 45 47 49 4E 

VERBOSE
	db name: parser, execute time: 0ms, error code: 0, thread id: 10
	query: BEGIN

+------------------------------------------------------+
0014) 2023-03-08 17:58:58 End_log pos 1348(0x544) LEN: 115(73) EVENT TYPE: TABLE MAP EVENT Server ID: 1 Flag: 0000 CRC32: C7BC0E40

HEX
	00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F
	-----------------------------------------------
	52 4E 08 64 13 01 00 00 00 73 00 00 00 44 05 00 
	00 00 00 7F 00 00 00 00 00 01 00 06 70 61 72 73 
	65 72 00 04 74 65 73 74 00 05 03 FE 0F 12 11 06 
	FE C8 C8 00 05 06 16 01 01 00 02 03 FC FF 00 04 
	28 07 63 6F 6C 75 6D 6E 31 07 63 6F 6C 75 6D 6E 
	32 07 63 6F 6C 75 6D 6E 33 07 63 6F 6C 75 6D 6E 
	34 07 63 6F 6C 75 6D 6E 35 08 01 00 0C 01 F8 

VERBOSE
# object name: `parser`.`test`, table id: 127, flags: 0001
## `column1`, INT NOT NULL, PRIMARY KEY /* meta = 0 visible */
## `column2`, CHAR /* meta = 65224 charset = 0 visible */
## `column3`, VARCHAR /* meta = 200 charset = 0 visible */
## `column4`, DATETIME NOT NULL /* meta = 5 visible */
## `column5`, TIMESTAMP /* meta = 6 visible */

+------------------------------------------------------+
0015) 2023-03-08 17:58:58 End_log pos 1498(0x5DA) LEN: 150(96) EVENT TYPE: UPDATE ROWS EVENT Server ID: 1 Flag: 0000 CRC32: E6D3C6FF

HEX
	00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F
	-----------------------------------------------
	52 4E 08 64 1F 01 00 00 00 96 00 00 00 DA 05 00 
	00 00 00 7F 00 00 00 00 00 01 00 02 00 05 FF FF 
	00 01 00 00 00 18 74 65 73 74 20 6D 79 73 71 6C 
	20 62 69 6E 6C 6F 67 20 70 61 72 73 65 72 0B 74 
	65 73 74 69 6E 67 2E 2E 2E 21 99 AF 91 1E 85 0C 
	D1 E0 64 08 4E 1D 0C D1 E2 00 01 00 00 00 18 74 
	65 73 74 20 6D 79 73 71 6C 20 62 69 6E 6C 6F 67 
	20 70 61 72 73 65 72 0B 74 65 73 74 69 6E 67 2E 
	2E 2E 21 99 AF 91 1E BA 00 00 00 64 08 4E 52 00 
	00 00 

VERBOSE
# UPDATE `parser`.`test`
##	BEFORE
###		@1=1 /* INT meta=0 nullable=0, is_null=0 */
###		@2='test mysql binlog parser' /* CHAR(200) meta=65224 nullable=1, is_null=0 */
###		@3='testing...!' /* VARCHAR(200) meta=200 nullable=1, is_null=0 */
###		@4=2023-03-08 17:58:05.84016 /* DATETIME(5) meta=5 nullable=0, is_null=0 */
###		@5=2023-03-08 17:58:05.840162 /* TIMESTAMP(6) meta=6 nullable=1, is_null=0 */
##	AFTER
###		@1=1 /* INT meta=0 nullable=0, is_null=0 */
###		@2='test mysql binlog parser' /* CHAR(200) meta=65224 nullable=1, is_null=0 */
###		@3='testing...!' /* VARCHAR(200) meta=200 nullable=1, is_null=0 */
###		@4=2023-03-08 17:58:58.00000 /* DATETIME(5) meta=5 nullable=0, is_null=0 */
###		@5=2023-03-08 17:58:58.000000 /* TIMESTAMP(6) meta=6 nullable=1, is_null=0 */

+------------------------------------------------------+
0016) 2023-03-08 17:58:58 End_log pos 1529(0x5F9) LEN: 31(1F) EVENT TYPE: XID EVENT Server ID: 1 Flag: 0000 CRC32: 871BFC5

HEX
	00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F
	-----------------------------------------------
	52 4E 08 64 10 01 00 00 00 1F 00 00 00 F9 05 00 
	00 00 00 3A 00 00 00 00 00 00 00 

VERBOSE
	COMMIT /* Xid = 58 */

+------------------------------------------------------+
0017) 2023-03-08 17:59:33 End_log pos 1608(0x648) LEN: 79(4F) EVENT TYPE: ANONYMOUS GTID LOG EVENT Server ID: 1 Flag: 0000 CRC32: C81E6F4D

HEX
	00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F
	-----------------------------------------------
	75 4E 08 64 22 01 00 00 00 4F 00 00 00 48 06 00 
	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
	00 00 00 00 00 00 00 00 00 00 00 00 02 04 00 00 
	00 00 00 00 00 05 00 00 00 00 00 00 00 8D 7F 34 
	BF 5F F6 05 FC 8A 01 A0 38 01 00 

VERBOSE
	last committed: 4, sequence number: 5, original committed timestamp: 3207888781, immediate_commit_timestamp: 3207888781, transaction length: 394, original server version: 80032, immediate server version: 80032

+------------------------------------------------------+
0018) 2023-03-08 17:59:33 End_log pos 1685(0x695) LEN: 77(4D) EVENT TYPE: QUERY EVENT Server ID: 1 Flag: 0008 CRC32: 22961621

HEX
	00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F
	-----------------------------------------------
	75 4E 08 64 02 01 00 00 00 4D 00 00 00 95 06 00 
	00 08 00 0A 00 00 00 00 00 00 00 06 00 00 1D 00 
	00 00 00 00 00 01 20 00 A0 45 00 00 00 00 06 03 
	73 74 64 04 FF 00 FF 00 FF 00 12 FF 00 70 61 72 
	73 65 72 00 42 45 47 49 4E 

VERBOSE
	db name: parser, execute time: 0ms, error code: 0, thread id: 10
	query: BEGIN

+------------------------------------------------------+
0019) 2023-03-08 17:59:33 End_log pos 1800(0x708) LEN: 115(73) EVENT TYPE: TABLE MAP EVENT Server ID: 1 Flag: 0000 CRC32: E026E3C0

HEX
	00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F
	-----------------------------------------------
	75 4E 08 64 13 01 00 00 00 73 00 00 00 08 07 00 
	00 00 00 7F 00 00 00 00 00 01 00 06 70 61 72 73 
	65 72 00 04 74 65 73 74 00 05 03 FE 0F 12 11 06 
	FE C8 C8 00 05 06 16 01 01 00 02 03 FC FF 00 04 
	28 07 63 6F 6C 75 6D 6E 31 07 63 6F 6C 75 6D 6E 
	32 07 63 6F 6C 75 6D 6E 33 07 63 6F 6C 75 6D 6E 
	34 07 63 6F 6C 75 6D 6E 35 08 01 00 0C 01 F8 

VERBOSE
# object name: `parser`.`test`, table id: 127, flags: 0001
## `column1`, INT NOT NULL, PRIMARY KEY /* meta = 0 visible */
## `column2`, CHAR /* meta = 65224 charset = 0 visible */
## `column3`, VARCHAR /* meta = 200 charset = 0 visible */
## `column4`, DATETIME NOT NULL /* meta = 5 visible */
## `column5`, TIMESTAMP /* meta = 6 visible */

+------------------------------------------------------+
0020) 2023-03-08 17:59:33 End_log pos 1892(0x764) LEN: 92(5C) EVENT TYPE: DELETE ROWS EVENT Server ID: 1 Flag: 0000 CRC32: 9EF1292E

HEX
	00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F
	-----------------------------------------------
	75 4E 08 64 20 01 00 00 00 5C 00 00 00 64 07 00 
	00 00 00 7F 00 00 00 00 00 01 00 02 00 05 FF 00 
	01 00 00 00 18 74 65 73 74 20 6D 79 73 71 6C 20 
	62 69 6E 6C 6F 67 20 70 61 72 73 65 72 0B 74 65 
	73 74 69 6E 67 2E 2E 2E 21 99 AF 91 1E BA 00 00 
	00 64 08 4E 52 00 00 00 

VERBOSE
# DELETE `parser`.`test`
##	BEFORE
###		@1=1 /* INT meta=0 nullable=0, is_null=0 */
###		@2='test mysql binlog parser' /* CHAR(200) meta=65224 nullable=1, is_null=0 */
###		@3='testing...!' /* VARCHAR(200) meta=200 nullable=1, is_null=0 */
###		@4=2023-03-08 17:58:58.00000 /* DATETIME(5) meta=5 nullable=0, is_null=0 */
###		@5=2023-03-08 17:58:58.000000 /* TIMESTAMP(6) meta=6 nullable=1, is_null=0 */

+------------------------------------------------------+
0021) 2023-03-08 17:59:33 End_log pos 1923(0x783) LEN: 31(1F) EVENT TYPE: XID EVENT Server ID: 1 Flag: 0000 CRC32: F2E373E2

HEX
	00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F
	-----------------------------------------------
	75 4E 08 64 10 01 00 00 00 1F 00 00 00 83 07 00 
	00 00 00 3B 00 00 00 00 00 00 00 

VERBOSE
	COMMIT /* Xid = 59 */

+------------------------------------------------------+
0022) 2023-03-08 18:06:11 End_log pos 1946(0x79A) LEN: 23(17) EVENT TYPE: STOP EVENT Server ID: 1 Flag: 0000 CRC32: A1CD158B

HEX
	00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F
	-----------------------------------------------
	03 50 08 64 03 01 00 00 00 17 00 00 00 9A 07 00 
	00 00 00 

VERBOSE
	STOP

+------------------------------------------------------+
Process finished with exit code 0

```

### Description

구조와 중요 이벤트 위주로 설명

#### 공통 구조

구조는 크게 4가지로 구성

- Common-Header: 모든 이벤트가 갖는 공통 구조, 19 Byte

  | Name            | Byte   | Description                                                  |
  | --------------- | ------ | ------------------------------------------------------------ |
  | when            | 4 Byte | Timestamp(Unix Timestamp)                                    |
  | op_code         | 1 Byte | Event를 구분하는 구분자                                      |
  | server_id       | 4 Byte | Server ID                                                    |
  | length          | 4 Byte | Event의 길이                                                 |
  | master_position | 4 Byte | Master Server에서의 다음 이벤트의 시작 위치                  |
  | flags           | 2 Byte | Format Description의 flags가 0x0001일 시 완료되지 않은 Binlog File, 나머지는 불확실 |




- Post-Header: 같은 이벤트끼리 같은 구조를 갖는 Event Header, 이벤트 당 고정 길이



- Body: 가변 길이의 데이터



- Footer: CRC32, Header의 length에 포함

  | Name  | Byte   | Description |
  | ----- | ------ | ----------- |
  | crc32 | 4 Byte | CRC32       |

#### Format Description

File Header에 해당

```
2023-03-08 17:55:03 End_log pos 126(0x7E) LEN: 122(7A) EVENT TYPE: FORMAT DESCRIPTION EVENT Server ID: 1 Flag: 0001 CRC32: E9822AC7
 
HEX
    00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F
    -----------------------------------------------
    67 4D 08 64 0F 01 00 00 00 7A 00 00 00 7E 00 00
    00 01 00 04 00 38 2E 30 2E 33 32 00 00 00 00 00
    00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    00 00 00 00 00 00 00 00 00 00 00 13 00 0D 00 08
    00 00 00 00 04 00 04 00 00 00 62 00 04 1A 08 00
    00 00 08 08 08 02 00 00 00 0A 0A 0A 2A 2A 00 12
    34 00 0A 28 00 01
 
VERBOSE
    binlog version: 4, server version: 8.0.32, common header length: 19, date: 1970-01-01 09:00:00(0), number of event_types: 1
    Post-Header length per event
        QUERY EVENT: 13 ROTATE EVENT: 8 APPEND BLOCK EVENT: 4   DELETE FILE EVENT: 4    FORMAT DESCRIPTION EVENT: 98    BEGIN LOAD QUERY EVENT: 4   EXECUTE LOAD QUERY EVENT: 26
        TABLE MAP EVENT: 8  WRITE ROWS EVENT V1: 8  UPDATE ROWS EVENT V1: 8 DELETE ROWS EVENT V1: 8 INCIDENT EVENT: 2   WRITE ROWS EVENT: 10    UPDATE ROWS EVENT: 10
        DELETE ROWS EVENT: 10   GTID LOG EVENT: 42  ANONYMOUS GTID LOG EVENT: 42    TRANSACTION CONTEXT EVENT: 18   VIEW CHANGE EVENT: 52   PARTIAL UPDATE ROWS EVENT: 10   TRANSACTION PAYLOAD EVENT: 40
 
+------------------------------------------------------+
```

Binlog Version, Server Version, Common-Header Length, Event 별 Post-Header Length를 나타내 줌

#### Anonymous GTID

Transaction의 시작 시 발생

Master와 Slave를 운영하면 길이가 바뀔 것으로 예상(Original, Immediate)(테스트 필수)

```
2023-03-08 17:55:20 End_log pos 234(0xEA) LEN: 77(4D) EVENT TYPE: ANONYMOUS GTID LOG EVENT Server ID: 1 Flag: 0000 CRC32: EABC03B1
 
HEX
    00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F
    -----------------------------------------------
    78 4D 08 64 22 01 00 00 00 4D 00 00 00 EA 00 00
    00 00 00 01 00 00 00 00 00 00 00 00 00 00 00 00
    00 00 00 00 00 00 00 00 00 00 00 00 02 00 00 00
    00 00 00 00 00 01 00 00 00 00 00 00 00 E3 B4 15
    B0 5F F6 05 BF A0 38 01 00
 
VERBOSE
    last committed: 0, sequence number: 1, original committed timestamp: 2954212579, immediate_commit_timestamp: 2954212579, transaction length: 191, original server version: 80032, immediate server version: 80032
 
+------------------------------------------------------+
```

#### Query

DDL들이 Query 형태 그대로 나타남

DB Name, Execute Time, Error Code, Thread ID, Query를 나타냄

```
2023-03-08 17:55:20 End_log pos 348(0x15C) LEN: 114(72) EVENT TYPE: QUERY EVENT Server ID: 1 Flag: 0008 CRC32: 5CDDE2B5
 
HEX
    00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F
    -----------------------------------------------
    78 4D 08 64 02 01 00 00 00 72 00 00 00 5C 01 00
    00 08 00 0A 00 00 00 00 00 00 00 06 00 00 31 00
    00 00 00 00 00 01 20 00 A0 45 00 00 00 00 06 03
    73 74 64 04 FF 00 FF 00 FF 00 0C 01 70 61 72 73
    65 72 00 11 32 00 00 00 00 00 00 00 12 FF 00 14
    00 70 61 72 73 65 72 00 63 72 65 61 74 65 20 64
    61 74 61 62 61 73 65 20 70 61 72 73 65 72
 
VERBOSE
    db name: parser, execute time: 0ms, error code: 0, thread id: 10
    query: create database parser
 
+------------------------------------------------------+
```

#### Table Map

매 DML 이전 Table의 Metadata를 나타내 줌

Object Name, Table ID, Column Name, Type, Meta, Visible 등을 나타냄

```
2023-03-08 17:58:05 End_log pos 937(0x3A9) LEN: 115(73) EVENT TYPE: TABLE MAP EVENT Server ID: 1 Flag: 0000 CRC32: AB7B7F0D
 
HEX
    00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F
    -----------------------------------------------
    1D 4E 08 64 13 01 00 00 00 73 00 00 00 A9 03 00
    00 00 00 7F 00 00 00 00 00 01 00 06 70 61 72 73
    65 72 00 04 74 65 73 74 00 05 03 FE 0F 12 11 06
    FE C8 C8 00 05 06 16 01 01 00 02 03 FC FF 00 04
    28 07 63 6F 6C 75 6D 6E 31 07 63 6F 6C 75 6D 6E
    32 07 63 6F 6C 75 6D 6E 33 07 63 6F 6C 75 6D 6E
    34 07 63 6F 6C 75 6D 6E 35 08 01 00 0C 01 F8
 
VERBOSE
# object name: `parser`.`test`, table id: 127, flags: 0001
## `column1`, INT NOT NULL, PRIMARY KEY /* meta = 0 visible */
## `column2`, CHAR /* meta = 65224 charset = 0 visible */
## `column3`, VARCHAR /* meta = 200 charset = 0 visible */
## `column4`, DATETIME NOT NULL /* meta = 5 visible */
## `column5`, TIMESTAMP /* meta = 6 visible */
 
+------------------------------------------------------+
```

##### Minimal 시 변경 사항

PK와 Column Name이 있음에도 Binlog에서 기록하지 않음

```
2023-03-08 18:12:58 End_log pos 1298(0x512) LEN: 66(42) EVENT TYPE: TABLE MAP EVENT Server ID: 1 Flag: 0000 CRC32: 41364C64

HEX
	00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F
	-----------------------------------------------
	9A 51 08 64 13 01 00 00 00 42 00 00 00 12 05 00 
	00 00 00 7D 00 00 00 00 00 01 00 04 74 65 73 74 
	00 07 6D 69 6E 69 6D 61 6C 00 04 FE 0F 03 11 05 
	FE 14 14 00 06 0B 01 01 00 02 03 FC FF 00 

VERBOSE
# object name: `test`.`minimal`, table id: 125, flags: 0001
## ``, CHAR /* meta = 65044 charset = 0 invisible */
## ``, VARCHAR /* meta = 20 charset = 0 invisible */
## ``, INT NOT NULL /* meta = 0 invisible */
## ``, TIMESTAMP /* meta = 6 invisible */

+------------------------------------------------------+
```

#### Write Rows(INSERT)

DML 중 INSERT에 해당

Object Name과 함께 After Image의 정보가 나타남

```
2023-03-08 17:58:05 End_log pos 1029(0x405) LEN: 92(5C) EVENT TYPE: WRITE ROWS EVENT Server ID: 1 Flag: 0000 CRC32: DF5B4B38
 
HEX
    00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F
    -----------------------------------------------
    1D 4E 08 64 1E 01 00 00 00 5C 00 00 00 05 04 00
    00 00 00 7F 00 00 00 00 00 01 00 02 00 05 FF 00
    01 00 00 00 18 74 65 73 74 20 6D 79 73 71 6C 20
    62 69 6E 6C 6F 67 20 70 61 72 73 65 72 0B 74 65
    73 74 69 6E 67 2E 2E 2E 21 99 AF 91 1E 85 0C D1
    E0 64 08 4E 1D 0C D1 E2
 
VERBOSE
# INSERT `parser`.`test`
##  AFTER
###     @1=1 /* INT meta=0 nullable=0, is_null=0 */
###     @2='test mysql binlog parser' /* CHAR(200) meta=65224 nullable=1, is_null=0 */
###     @3='testing...!' /* VARCHAR(200) meta=200 nullable=1, is_null=0 */
###     @4=2023-03-08 17:58:05.84016 /* DATETIME(5) meta=5 nullable=0, is_null=0 */
###     @5=2023-03-08 17:58:05.840162 /* TIMESTAMP(6) meta=6 nullable=1, is_null=0 */
 
+------------------------------------------------------+
```

#### Update Rows

DML 중 UPDATE에 해당

Object Name과 함께 Before, After Image의 정보가 나타남

```
2023-03-08 17:58:58 End_log pos 1498(0x5DA) LEN: 150(96) EVENT TYPE: UPDATE ROWS EVENT Server ID: 1 Flag: 0000 CRC32: E6D3C6FF
 
HEX
    00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F
    -----------------------------------------------
    52 4E 08 64 1F 01 00 00 00 96 00 00 00 DA 05 00
    00 00 00 7F 00 00 00 00 00 01 00 02 00 05 FF FF
    00 01 00 00 00 18 74 65 73 74 20 6D 79 73 71 6C
    20 62 69 6E 6C 6F 67 20 70 61 72 73 65 72 0B 74
    65 73 74 69 6E 67 2E 2E 2E 21 99 AF 91 1E 85 0C
    D1 E0 64 08 4E 1D 0C D1 E2 00 01 00 00 00 18 74
    65 73 74 20 6D 79 73 71 6C 20 62 69 6E 6C 6F 67
    20 70 61 72 73 65 72 0B 74 65 73 74 69 6E 67 2E
    2E 2E 21 99 AF 91 1E BA 00 00 00 64 08 4E 52 00
    00 00
 
VERBOSE
# UPDATE `parser`.`test`
##  BEFORE
###     @1=1 /* INT meta=0 nullable=0, is_null=0 */
###     @2='test mysql binlog parser' /* CHAR(200) meta=65224 nullable=1, is_null=0 */
###     @3='testing...!' /* VARCHAR(200) meta=200 nullable=1, is_null=0 */
###     @4=2023-03-08 17:58:05.84016 /* DATETIME(5) meta=5 nullable=0, is_null=0 */
###     @5=2023-03-08 17:58:05.840162 /* TIMESTAMP(6) meta=6 nullable=1, is_null=0 */
##  AFTER
###     @1=1 /* INT meta=0 nullable=0, is_null=0 */
###     @2='test mysql binlog parser' /* CHAR(200) meta=65224 nullable=1, is_null=0 */
###     @3='testing...!' /* VARCHAR(200) meta=200 nullable=1, is_null=0 */
###     @4=2023-03-08 17:58:58.00000 /* DATETIME(5) meta=5 nullable=0, is_null=0 */
###     @5=2023-03-08 17:58:58.000000 /* TIMESTAMP(6) meta=6 nullable=1, is_null=0 */
 
+------------------------------------------------------+
```

#### Delete Rows

DML 중 DELETE에 해당

Object Name과 함께 Before Image의 정보가 나타남

```
2023-03-08 17:59:33 End_log pos 1892(0x764) LEN: 92(5C) EVENT TYPE: DELETE ROWS EVENT Server ID: 1 Flag: 0000 CRC32: 9EF1292E
 
HEX
    00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F
    -----------------------------------------------
    75 4E 08 64 20 01 00 00 00 5C 00 00 00 64 07 00
    00 00 00 7F 00 00 00 00 00 01 00 02 00 05 FF 00
    01 00 00 00 18 74 65 73 74 20 6D 79 73 71 6C 20
    62 69 6E 6C 6F 67 20 70 61 72 73 65 72 0B 74 65
    73 74 69 6E 67 2E 2E 2E 21 99 AF 91 1E BA 00 00
    00 64 08 4E 52 00 00 00
 
VERBOSE
# DELETE `parser`.`test`
##  BEFORE
###     @1=1 /* INT meta=0 nullable=0, is_null=0 */
###     @2='test mysql binlog parser' /* CHAR(200) meta=65224 nullable=1, is_null=0 */
###     @3='testing...!' /* VARCHAR(200) meta=200 nullable=1, is_null=0 */
###     @4=2023-03-08 17:58:58.00000 /* DATETIME(5) meta=5 nullable=0, is_null=0 */
###     @5=2023-03-08 17:58:58.000000 /* TIMESTAMP(6) meta=6 nullable=1, is_null=0 */
 
+------------------------------------------------------+
```

#### Xid

COMMIT에 해당

XID(Transaction ID)를 나타냄

```
2023-03-08 17:58:05 End_log pos 1060(0x424) LEN: 31(1F) EVENT TYPE: XID EVENT Server ID: 1 Flag: 0000 CRC32: FA1E0E9E
 
HEX
    00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F
    -----------------------------------------------
    1D 4E 08 64 10 01 00 00 00 1F 00 00 00 24 04 00
    00 00 00 39 00 00 00 00 00 00 00
 
VERBOSE
    COMMIT /* Xid = 57 */
 
+------------------------------------------------------+
```

### Check List

- [ ] UK
- [ ] Charset(Collation)
- [ ] 나머지 Event
- [ ] NDB(Network DB), Master- Slave(MySQL Replication)등 다양한 환경
- [x] Datetime Minute & Second Fix