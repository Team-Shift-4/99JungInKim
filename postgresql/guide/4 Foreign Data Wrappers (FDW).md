# 4. Foreign Data Wrappers (FDW)

# FDW

- 2003년 [SQL Management of External Data(SQL/MED)](https://wiki.postgresql.org/wiki/SQL/MED)라는 원격 Data Accesss 사양이 SQL 표준에 추가되었음
- Ver 9.1부터 SQL/MED의 일부를 구현하기 위한 것
- SQL/MED에서 원격 Server의 Table을 Foreign Table(외부 Table)이라 함
- PostgreSQL의 FDW는 SQL/MED를 사용해 Local Table과 유사한 Foreign Table을 관리하는 것

![FDW의 기본 개념](./4 Foreign Data Wrappers (FDW)/Untitled.png)

FDW의 기본 개념

- 필요한 확장을 설치 / 설정한 후 원격 Server의 Foreign Table에 Access 가능
- ex) `foreign_pg_tbl` Table과 `foreign_mytbl` Table이 있는 두개의 원격 Server가 있다고 가정

```sql
-- foreign_pg_tbl is on the remote postgresql server.
SELECT count(*) FROM foreign_pg_tbl;

 count 
-------
 20000

-- foreign_my_tbl is on the remote mysql server.
SELECT count(*) FROM foreign_my_tbl;
 count 
-------
 10000
```

```sql
SELECT count(*) FROM foreign_pg_tbl AS p, foreign_my_tbl AS m WHERE p.id = m.id;

 count 
-------
 10000
```

## FDW 개요

- FDW 기능을 사용하기 위해 확장 프로그램을 설치하고 `CREATE FOREIGN TABLE`, `CREATE SERVER`, `CREATE USER MAPPING`과 같은 Command Setting을 실행해야 함
- Setting 후 확장에 정의된 Function은 Foreign Table에 Access하기 위해 Query Processing 중 호출

![PostgreSQL에서 FDW 수행 과정](./4 Foreign Data Wrappers (FDW)/Untitled%201.png)

PostgreSQL에서 FDW 수행 과정

1. Analyzer가 입력 SQL의 Query Tree를 생성
2. Planner(또는 Executor)가 원격 Server에 연결
3. `use_remote_estimate` 옵션이 `on`이면(Default: `off`) Planner는 각 Plan Path의 비용을 추정하기 위해 `EXPLAIN` Command 실행
4. Planner는 내부적으로 `deparesing`이라고 하는 Plan Tree에서 일반 Text SQL문을 생성
5. Executor는 일반 Text SQL문을 원격 Server로 보낸 후 결과를 받음
- Executor는 필요한 경우 수신된 Data를 처리
    - ex) Multi Table Query가 실행된 경우 Executor는 수신 Data와 다른 Table의 `JOIN` 처리 수행

### Query Tree 만들기

- Analyzer는 `CREATE FOREIGN TABLE` 또는 `IMPORT FOREIGN TABLE` Command로 `pg_catalog.pg_class`와 `pg_catalog.pg_foreign_table` Catalog에 저장된 Foreign Table의 정의를 사용하여 입력 SQL의 Query Tree를 생성

### 원격 Server에 연결

- 원격 Server에 연결하기 위해 Planner(또는 Executor)는 특정 Library를 사용해 원격 DB Server에 연결함
    - ex) postgres_fdw → libpq를 사용
- User Name, Server의 IP Address, Port 번호와 같은 연결 매개변수는 `CREATE USER MAPPING`, `CREATE SERVER` Command를 사용해 `pg_catalog.pg_user_mapping`, `pg_catalog.pg_foreign_server` Catalog에 저장

### `EXPLAIN` Command를 사용해 Plan Tree 생성(선택 사항)

- PostgreSQL의 일부 FDW는 확장에서 사용되는 Query의 Plan Tree를 추정하기 위해 Foreign Table의 통계를 얻는 기능 지원
- `ALTER SERVER` Command를 사용해 `user_remote_estimate` 옵션을 `on`으로 설정할 시 Planner는 `EXPLAIN` Command를 실행해 원격 Server에 Plan 비용을 Query함
    - 위 경우가 아닐 경우 기본적으로 포함된 상수 값 사용

```sql
ALTER SERVER remote_server_name OPTIONS (use_remote_estimate 'on');
```

### **Deparsing**

![Foreign Table을 Scan하는 Plan Tree의 예
아래 SQL문의 Plan Tree](./4 Foreign Data Wrappers (FDW)/Untitled%202.png)

Foreign Table을 Scan하는 Plan Tree의 예
아래 SQL문의 Plan Tree

```sql
SELECT * FROM tbl_a AS a WHERE a.id < 10;
```

- Plan Tree를 생성하기 위해 Planner는 Foreign Table의 Plan Tree Scan Path에서 일반 Text SQL문 생성
- 위 그림은 `PlannedStmt`의 Plan Tree에서 Link된 ForeignScan Node가 일반 `SELECT` Text를 저장
- postgres_fdw는 Parsing & Analyzing을 통해 생성된 Query Tree에서 일반 `SELECT` Text를 생성
    - 위 과정을 PostgreSQL에서는 Deparsing이라 함

### SQL문 송신 및 결과 수신

- Deparsing 후 Executor는 Deparsing된 SQL문을 원격 Server로 보내고 결과를 받음
- SQL문을 원격 Server로 보내는 방법은 각 확장마다 다름

<aside>
😮‍💨 여기서 부터 아래 내용은 Postgres_fdw만의 내용이므로 이후 추가 작성할 예정

</aside>