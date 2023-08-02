# 9. Tx Log 및 WAL Segment File

# Tx Log 및 WAL Segment File

- PostgreSQL은 8Byte(16ExaByre) 길이의 가상 File인 Tx Log에 XLOG Record를 작성
- Tx Log 용량은 사실상 무제한이고 8Byte 주소 공간으로 처리하기 크기에 PostgreSQL의 Tx Log는 기본적으로 WAL Segment로 알려진 16MB의 File로 나뉨

<aside>
💡 Ver 11 이상에서는 `initdb` 명령으로 PostgreSQL Cluster를 생성할 때 `--wal-segsize` 옵션을 사용해 WAL Segment File의 크기를 설정할 수 있음

</aside>

![Transaction Log 및 WAL Segment File](./9 Tx Log 및 WAL Segment File/Untitled.png)

Transaction Log 및 WAL Segment File

- WAL Segment File 이름은 16진수 24자리 숫자
- $wal\ segment\ filename=timeline\ id+(uint32)\frac{LSN-1}{16M*256}+(uint32)\frac{LSN-1}{16M}\%256$

<aside>
💡 Timeline ID

PostgreSQL의 WAL은 Point-In-Time-Recovery를 위한  Timeline ID(Unsigned int)를 포함
아래의 설명에서는 Timeline ID를 0x00000001로 고정

</aside>

- 첫 번째 WAL Segment File은 `00000001 00000000 000000 01`
- 첫 번째 Row가 XLOG Record 쓰기로 채워지면 두 번째 레코드 `00000001 00000000 000000 02` 제공
- 오름차순으로 사용되며 `00000001 0000000 000000 FF` 다음은 `00000001 00000001 000000 00`

<aside>
💡 pg_xlogfile_name / pg_walfile_name

내장 함수 pg_xlogfile_name(Ver 9.6 이하) 또는 pg_walfile_name(Ver 10 이상)을 사용해 지정된 LSN을 포함하는 WAL Segment File Name을 찾을 수 있음

```sql
SELECT pg_walfile_name('1/00002D3E');

     pg_walfile_name
------------------------
000000010000000100000000
(1 row)
```

</aside>

[The Internals of PostgreSQL : Chapter 9 Write Ahead Logging - WAL](https://www.interdb.jp/pg/pgsql09.html)