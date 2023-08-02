[<img src="https://capsule-render.vercel.app/api?type=waving&color=auto&height=200&section=header&text=MySQL Binlog Parser&fontSize=50&fontColor=ffffff"/>](https://lab.idatabank.com/gitlab/ARK/Research/mysql_binlog_parser)

# MySQL Binlog Parser

이 프로그램은 MySQL 8.0(Log Version 4)의 Binlog File을 읽어 원하는 데이터를 추출해 필요한 양식으로 만들기 위해 제작 중
MySQL의 C API는 C++을 사용하고 추가적으로 Library를 정의한 후 Build해야만 사용할 수 있는 단점을 해결하기 위해 제작

## 목차

- [Current Version](#current-version230125)
- [`23.01.20](#ver-230120)

## Current Version(`23.01.25)

### 목차

- [Input](#input)
- [Output](#output)
- [Memo](#memo)

### Input

DB 접속을 위해 해당 정보 값을 `DB_XXXX`에 기입

읽기 원하는 파일명을 입력

#### Example

```
mysql-bin.000025
```



### Output

입력 전 DB의 `SHOW BINARY LOGS`의 결과 값을 출력해 읽을 수 있는 파일 리스트 출력

입력 후 파일명 출력 후 한 Buffer마다 구분번호, 서버 ID, 출력 길이(총 길이), Event Type, CRC32 값 출력
나오는 Buffer의 경우 현재 파악하지 못한 값 출력(파악된 값은 따로 변수에 저장)

공통 양식인 Timestamp, Flag, Server ID, Length는 따로 변수에 저장하였고 POS의 경우 길이가 명확하지 않아 정의하지 않음
(차후 테스트 후 정리할 예정)

#### Example

```
List

	mysql-bin.000007
	mysql-bin.000008
	mysql-bin.000009
	mysql-bin.000010
	mysql-bin.000011
	mysql-bin.000012
	mysql-bin.000013
	mysql-bin.000014
	mysql-bin.000015
	mysql-bin.000016
	mysql-bin.000017
	mysql-bin.000018
	mysql-bin.000019
	mysql-bin.000020
	mysql-bin.000021
	mysql-bin.000022
	mysql-bin.000023
	mysql-bin.000024
	mysql-bin.000025

Enter the file name you want to read: mysql-bin.000025

File name: mysql-bin.000025

0001)	LEN: 105(122)	SERVER ID: 2	EVENT TYPE: FORMAT DESCRIPTION EVENT	CRC32: 332B964A
7E 00 00 00 01 00 04 00 38 2E 30 2E 33 31 00 00 
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
00 00 00 00 00 00 00 00 00 00 76 86 D0 63 13 00 
0D 00 08 00 00 00 00 04 00 04 00 00 00 62 00 04 
1A 08 00 00 00 08 08 08 02 00 00 00 0A 0A 0A 2A 
2A 00 12 34 00 0A 28 00 01 

0002)	LEN: 14(31)	SERVER ID: 2	EVENT TYPE: PREVIOUS GTIDS LOG EVENT	CRC32: 73B0C26A
9D 00 00 00 80 00 00 00 00 00 00 00 00 00 

0003)	LEN: 14(31)	SERVER ID: 2	EVENT TYPE: PREVIOUS GTIDS LOG EVENT	CRC32: 73B0C26A
0E 00 00 00 00 00 00 00 5D 12 40 00 00 00 

Process finished with exit code 0

```

### Memo

차후 Query Event에 대한 처리 추가 예정

## Ver `23.01.20

### Input

입력 없이 `BINLOG_FILE`에 해당 파일의 경로를 넣어 실행

### Output

파일명과 구분, 총 길이를 나타냄
나오는 Buffer의 경우 현재 파악하지 못한 값을 출력함(파악된 값은 따로 변수에 저장)

공통 양식인 Timestamp, Flag, Server ID, Length는 따로 변수에 저장하였고 POS의 경우 길이가 명확하지 않아 정의하지 않음
(차후 테스트 후 정리할 예정)

#### Example

```
File name: /var/lib/mysql/mysql-bin.000015

0001) length: 122
7E 00 00 00 00 00 04 00 38 2E 30 2E 33 31 00 00 
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
00 00 00 00 00 00 00 00 00 00 67 87 BF 63 13 00 
0D 00 08 00 00 00 00 04 00 04 00 00 00 62 00 04 
1A 08 00 00 00 08 08 08 02 00 00 00 0A 0A 0A 2A 
2A 00 12 34 00 0A 28 00 01 ED 7A 4A 01 

0002) length: 31
9D 00 00 00 80 00 00 00 00 00 00 00 00 00 93 C3 
75 74 

0003) length: 31
10 FF 5D EA FE 7F 00 00 12 00 00 00 00 00 00 00 
00 00 

Process finished with exit code 0

```
