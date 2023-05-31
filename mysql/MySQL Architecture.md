# MySQL Architecture

<aside>
📖 **MySQL Architecture 목차**

</aside>

# MySQL Architecture 개요

![제목 없음.png](./MySQL Architecture/%25EC%25A0%259C%25EB%25AA%25A9_%25EC%2597%2586%25EC%259D%258C.png)

- MySQL Architectrue는 Server - Client 구조로 이루어짐
    - MySQL DB가 Server, DB에 연결하는 Application이 Client
- MySQL Server는 MySQL Engine과 Storage Engine으로 구분
    - MySQL Engine은 DBMS의 Logical한 부분, Storage Engine은 Physical한 부분을 담당
- Engine 간 역할이 달라 Data 요청과 전송을 해야하기에 Handler가 필요
    - Handler API를 통해 요청하여 Engine 간 Data를 주고 받음

# MySQL Engine

- Connection Pool Layer, SQL Interface, Parser, Optimizer, Cache, Buffer로 이루어짐
- Storage Engine은 여러 개 사용 가능하나 MySQL Engine은 하나만 사용 가능

## Connection Pool Layer

- Connection Pool은 MySQL Architecture의 최상위 계층으로 Client의 Connection을 생성 및 관리해 요청한 Query를 처리
    - Connection 처리
        - MySQL Server는 Client의 Connection 요청에 대해 Thread 할당
        - Client는 할당받은 Thread에서 Query 수행
        - Thread는 Server에 의해 캐시되므로 새로운 Connection에 대해 항상 재생성할 필요 없음
    - Authentication
        - Client가 연결될 때마다 Host, User ID, Password 기반으로 Authentication 수행
    - Security
        - Client가 특정 Query를 수행할 Privilege가 있는지 확인

## SQL Interface

- Command를 수신하고 Client에게 결과를 전송하는 Interface
- ANSI SQL 표준 준수
- DML, DDL, Stored Procedure, View, Trigger 등으로 구성

## Parser

- User 요청 Query를 Token으로 분리해 Tree 형태 구조로 만드는 작업

## Optimizer

- Query를 효율적으로 처리하는 역할을 수행
    - Query 재작성
    - Scan 순서 조정
    - Index 선택 등

## Cache & Buffer

- Data와 Index에 빠르게 읽고 쓰기 위한 Memory 공간(보조 저장소)
    - MyISAM의 Key Cache
    - InnoDB Buffer Pool 등

# Storage Engine

- Data를 Disk Storage에 쓰거나 읽는 부분을 담당
- Plugin 방식으로 사용하기에 원하는 Storage Engine을 구성해 사용 가능하며 여러개 사용 가능
    - 해당 Table이 사용할 Storage Engine을 지정 가능
- MySQL Server에 포함되지 않은 Storage Engine을 사용하기 위해 MySQL Server를 다시 Build해야 하나 Plugin 형태로 Build되어 제공되는 Storage Engine의 경우 Library를 다운받아 쉽게 추가 및 업그레이드 가능

```sql
SHOW ENGINES;
+--------------------+---------+----------------------------------------------------------------+--------------+------+------------+
| Engine             | Support | Comment                                                        | Transactions | XA   | Savepoints |
+--------------------+---------+----------------------------------------------------------------+--------------+------+------------+
| ndbcluster         | NO      | Clustered, fault-tolerant tables                               | NULL         | NULL | NULL       |
| FEDERATED          | NO      | Federated MySQL storage engine                                 | NULL         | NULL | NULL       |
| MEMORY             | YES     | Hash based, stored in memory, useful for temporary tables      | NO           | NO   | NO         |
| InnoDB             | DEFAULT | Supports transactions, row-level locking, and foreign keys     | YES          | YES  | YES        |
| PERFORMANCE_SCHEMA | YES     | Performance Schema                                             | NO           | NO   | NO         |
| MyISAM             | YES     | MyISAM storage engine                                          | NO           | NO   | NO         |
| ndbinfo            | NO      | MySQL Cluster system information storage engine                | NULL         | NULL | NULL       |
| MRG_MYISAM         | YES     | Collection of identical MyISAM tables                          | NO           | NO   | NO         |
| BLACKHOLE          | YES     | /dev/null storage engine (anything you write to it disappears) | NO           | NO   | NO         |
| CSV                | YES     | CSV storage engine                                             | NO           | NO   | NO         |
| ARCHIVE            | YES     | Archive storage engine                                         | NO           | NO   | NO         |
+--------------------+---------+----------------------------------------------------------------+--------------+------+------------+
11 rows in set (0.00 sec)
```

| DEFAULT | 기본 Storage Engine |
| --- | --- |
| YES | 사용 가능 Storage Engine |
| NO | 사용 불가능 Storage Engine |
| DISABLED | 사용 가능하나 비활성화 된 Storage Engine |

## 주류 Storage Engine

### MyISAM

- MySQL 5.5 이전 기본 Storage Engine
- Concurrency Control이 어려우나 빠름
- Full-Text Indexing, Compression, Function(GIS)등 여러 기능 제공
- Transaction 미지원
- Key Cache라는 Memory 영역으로 MyISAM Table의 Index를 저장하기 위해 할당한 영역이 존재
    - Key Cache는 Index를 대상으로 동작해 Index의 Disk Input에서는 Buffer 역할 수행
    - Table Data는 Cache와 Buffer 기능이 없어 Disk 읽기 사용
- Table-Level Lock을 제공
    - 모든 Table에 대해 읽고 쓰는 경우 공유된 읽기 권한, 배타적 쓰기 잠금 권한 필요
- Multi Insert를 지원해 Batch 작업에 적합
- 읽기 위주에 적합해 Read Query가 많은 [DW 환경](https://ko.wikipedia.org/wiki/%EB%8D%B0%EC%9D%B4%ED%84%B0_%EC%9B%A8%EC%96%B4%ED%95%98%EC%9A%B0%EC%8A%A4)에서 많이 쓰임

### Memory(Heap)

- Memory에 Data를 저장하는 Storage Engine
- I/O 효율이 높음
- Table-Level Lock 제공
- Memory에 저장해 속도가 빠르나 유실 가능성이 있음
    - Table 정의는 Data Dictionary에 저장되며 Disk에 File을 생성하지 않음
- Data 조회, Mapping, 주기적 집계, Data 분석 등에 주로 사용

### InnoDB

- MySQL 8.0 기본 Storage Engine
- Oracle과 유사한 구조
- DML은 ACID Model을 따름
- Commit, Rollback, Recovery 기능을 갖춘 Transaction으로 DB 보호
- Buffer Pool로 Disk I/O를 줄임
- PK 기반 Query에 최적화 되어 있음
    - Clustered Index라는 Primary Key Index가 있어 PK Search에 대한 I/O 최소화
- Row-Level Lock과 MVCC를 이용해 Multi User Concurrency Control 제공
- FK 지원, 관련 Data를 다른 Table로 분리할 때 참조 무결성을 위한 FK 설정 가능
- Dead Lock 발생 시 변경된 Record가 가장 적은 Transaction을 Rollback해 자동 Dead Lock 해제

### Archive

- 대량의 Data를 압축 저장하는 Storage Engine
- Row가 Insert 될 때 zlib로 압축해 Disk I/O가 적개 발생하고 Insert 작업이 빠름
- Insert, Replace, Select는 가능하나 Delete, Update는 불가
- Row-Level Lock 제공
- 다량의 Log성 Data를 저장하고 읽을 때 사용
- Index 지원하지 않음

### NDB(Network DB)

- MySQL Cluster를 구성할 때 사용하는 Storage Engine
- Cluster DB라고 부름
- Shared-nothing(Sharding) System에서 Memory 내 DB의 Clustering을 가능하게 해주는 기술
- MySQL과 별도의 Node로 동작해 Clustering을 처리
- User가 Custom Clients(NDBAPI)를 통해 Cluster에 Access하는 경우 MySQL Server와 독립적으로 사용 가능
    - Data Nodes: Data 저장, Query 주요 작업 수행
    - SQL Nodes: Query 실행(Instance)
    - Management Server: Cluster 구성 관리, 새 Connection 처리, Node 장애 시 Backup 생성
- NDB Storage Engine에 의해 Data가 저장시 Table과 Data는 Data Node에 저장됨
    - Cluster의 다른 모든 SQL Node에서 직접 Access 가능
- NDB Cluster에 연결되지 않은 MySQL Server는 NDB Storage Engine을 사용할 수 없고 NDB Cluster Data에 Access할 수 없음

### 주류 Storage Engine 기능 요약

| Feature | MyISAM | Memory | InnoDB | Archive | NDB |
| --- | --- | --- | --- | --- | --- |
| B-Tree Indexes | Yes | Yes | Yes | No | No |
| Backup / Point-in-time Recovery | Yes | Yes | Yes | Yes | Yes |
| Cluseter DB Support | No | No | No | No | Yes |
| Cluseterd Indexes | No | No | Yes | No | No |
| Compressed Data | Yes(Row 포맷만) | No | Yes | Yes | No |
| Data Caches | No | - | Yes | No | Yes |
| Encrypted Data | Yes(암호화 기능 통해서) | Yes | Yes(암호화 기능 통해서) | Yes(암호화 기능 통해서) | Yes(암호화 기능 통해서) |
| Foreign Key Support | No | No | Yes | No | Yes(7.3 이상) |
| Full-Text Search Indexes | Yes | No | Yes(5.6 이상) | No | No |
| Geospatial Data Type Support | Yes | No | Yes | Yes | Yes |
| Geospatial Indexing Support | Yes | No | Yes(5.7 이상) | No | No |
| Hash Indexes | No | Yes | 내부적 Hash Index | No | Yes |
| Index Caches | Yes | - | Yes | No | Yes |
| Locking Granularity | Table | Table | Row | Row | Row |
| MVCC | No | No | Yes | No | No |
| Replication Support | Yes | Limitied | Yes | Yes | Yes |
| Storage Limits | 256TB | RAM | 64TB | None | 384EB |
| T-Tree Indexes | No | No | No | No | Yes |
| Transactions | No | No | Yes | No | Yes |
| Updated Statistics for Data Dictionary | Yes | Yes | Yes | Yes | Yes |

## 비주류 Storage Engine

### Comma Separated Values(CSV)

- 쉼표로 구분된 값 형식의 텍스트 파일을 사용하는 Storage Engine
- 모든 Column NOT NULL
- Server 실행 중 DB 내외로 File 복사 가능
- CSV File의 유연성으로 다른 응용 프로그램과 쉽게 통합 가능

### Federated

- Physical한 MySQL Server를 하나의 Logical한 MySQL DB로 만들고 연결하는 Storage Engine
- 분산 Data 환경에 권장
- Remote Server와 Local Server로 구성됨
    - Remote Server: Table 정의 및 Data로 구성
    MyISAM이나 InnoDB를 포함해 Remote Server에서 지원하는 Storage Engine 사용 가능
    - Local Server: Remote Server의 Table 정의와 일치하는 Table 필요
    Remote Server와 달리 Federated Engine으로 Table 구성
    Local Server에는 실 Data가 없고 Remote Table을 가리키는 Connection 정보 포함
- Local Server에서 Federated Table을 Query할 경우 Remote Server 내의 Table을 참조
    - 모든 작업은 Remote Server에서 실행(연결)
    - 결과만 반환
- Data Access가 Remote 처리로 Index를 사용하는 곳은 Remote Table이기 때문에 Index사용이 불가해 Full Table Scan 시 성능 저하 및 Network 부하 발생

### Blackhole

- Data를 받아들이나 저장하지 않는 Storage Engine
- Table 생성 시 정의를 만들 뿐 실제 Table과 관련된 File은 없음
- Dump File 구문 확인, Binary Logging 활성화 여부 성능 비교, 병목 현상 탐색 등에 이용

### MRG_MyISAM

- 동일한 MyISAM Table 모음을 Logical 단위로 취급해 동시에 Query 할 수 있음
- Merge Engine이라고도 함
- 여러 Table에서 반환된 결과는 하나의 Table에서 반환된 결과와 같음
- Column이 다른 순서로 나열되거나 해당 Column에 동일한 Data 유형이 없거나 Index 순서가 다른 MyISAM Table은 Merge 불가능
- Merge Table에 Mapping되는 MyISAM Table에 대한 권한이 있어야 Merge Table에서 DML 가능
- Log Table과 같은 대규모 Data Set에 용이(병렬 처리와 유사)
- Index 읽기 속도가 느림

# Thread

- MySQL은 Thread 기반 동작
    - Foreground Thread: User Session
    - Background Thread: 내부적 처리 목적 Thread
        - Background Thread의 수는 버전과 설정에 따라 다를 수 있으며 병렬 작업을 수행하는 경우 동일한 이름의 Thread가 여러개 표시될 수 있음
- MySQL에서는 Thread Model을 사용하나 MySQL Enterprise Edition과 Percona Server for MySQL에서는 Thread Pool Plugin이 포함되어 있음
    - Community 버전의 Thread Model은 Client Connection 당 하나의 Thread를 사용해 명령 실행하나 Thread Pool Plugin은 Thread를 효율적으로 관리해 Server 성능을 향상시킴

```sql
select thread_id, name, type from performance_schema.threads;
+-----------+---------------------------------------------+------------+
| thread_id | name                                        | type       |
+-----------+---------------------------------------------+------------+
|         1 | thread/sql/main                             | BACKGROUND |
|         3 | thread/innodb/io_ibuf_thread                | BACKGROUND |
|         4 | thread/innodb/io_log_thread                 | BACKGROUND |
|         5 | thread/innodb/io_read_thread                | BACKGROUND |
|         6 | thread/innodb/io_read_thread                | BACKGROUND |
|         7 | thread/innodb/io_read_thread                | BACKGROUND |
|         8 | thread/innodb/io_read_thread                | BACKGROUND |
|         9 | thread/innodb/io_write_thread               | BACKGROUND |
|        10 | thread/innodb/io_write_thread               | BACKGROUND |
|        11 | thread/innodb/io_write_thread               | BACKGROUND |
|        12 | thread/innodb/io_write_thread               | BACKGROUND |
|        13 | thread/innodb/page_flush_coordinator_thread | BACKGROUND |
|        15 | thread/innodb/log_checkpointer_thread       | BACKGROUND |
|        16 | thread/innodb/log_flush_notifier_thread     | BACKGROUND |
|        17 | thread/innodb/log_flusher_thread            | BACKGROUND |
|        18 | thread/innodb/log_write_notifier_thread     | BACKGROUND |
|        19 | thread/innodb/log_writer_thread             | BACKGROUND |
|        20 | thread/innodb/log_files_governor_thread     | BACKGROUND |
|        23 | thread/innodb/srv_lock_timeout_thread       | BACKGROUND |
|        24 | thread/innodb/srv_error_monitor_thread      | BACKGROUND |
|        25 | thread/innodb/srv_monitor_thread            | BACKGROUND |
|        26 | thread/innodb/buf_resize_thread             | BACKGROUND |
|        27 | thread/innodb/srv_master_thread             | BACKGROUND |
|        28 | thread/innodb/dict_stats_thread             | BACKGROUND |
|        29 | thread/innodb/fts_optimize_thread           | BACKGROUND |
|        30 | thread/mysqlx/worker                        | BACKGROUND |
|        31 | thread/mysqlx/worker                        | BACKGROUND |
|        32 | thread/mysqlx/acceptor_network              | BACKGROUND |
|        36 | thread/innodb/buf_dump_thread               | BACKGROUND |
|        37 | thread/innodb/clone_gtid_thread             | BACKGROUND |
|        38 | thread/innodb/srv_purge_thread              | BACKGROUND |
|        39 | thread/innodb/srv_worker_thread             | BACKGROUND |
|        40 | thread/innodb/srv_worker_thread             | BACKGROUND |
|        41 | thread/innodb/srv_worker_thread             | BACKGROUND |
|        42 | thread/sql/event_scheduler                  | FOREGROUND |
|        43 | thread/sql/signal_handler                   | BACKGROUND |
|        44 | thread/mysqlx/acceptor_network              | BACKGROUND |
|        46 | thread/sql/compress_gtid_table              | FOREGROUND |
|        47 | thread/sql/one_connection                   | FOREGROUND |
+-----------+---------------------------------------------+------------+
39 rows in set (0.00 sec)
```

## Foreground Thread(Client Thread)

- Foreground Thread는 최소 MySQL Server에 접속한 Client 수만큼 존재
- 각 Client User가 요청한 Query 처리
- Session이 종료되면 Foreground Thread는 Thread Cache로 반환
    - 종료 시 일정 개수의 Thread만 Thread Cache에 유지
    - Thread Cache의 최대 Thread 개수는 thread_cache_size라는 System Variable로 설정
- 사용 중인 Storage Engine에 따라 역할 및 수행 범위가 달라짐

## Background Thread

- MySQL의 Storage Engine 중 InnoDB의 경우 많은 작업을 Background Thread가 수행
    - 읽기 작업의 경우 주로 Foreground Thread가 수행하나 쓰기 작업의 경우 대부분 Background Thread가 담당하므로 충분한 수의 Write Thread를 설정하는 것이 좋음

### InnoDB Engine의 주요 Background Thread

| Thread | Name | Description |
| --- | --- | --- |
| Master Thread | thread/innodb/srv_master_thread | Background Thread 관리 및 
스케줄링 담당,
Data 일관성 보장
(Buffer Pool의 Data 비동기 Flush) |
| Insert Buffer Thread | thread/innodb/io_ibuf_thread | Insert(Change) Buffer Merge |
| Log Thread | thread/innodb/io_log_thread | Redo Log 작성 |
| Read Thread | thread/innodb/io_read_thread | Read 요청 처리 |
| Write Thread | thread/innodb/io_write_thread | Write 요청 처리 |
| Page Cleaner Thread | thread/innodb/page_cleaner_thread | Dirty Page를 Disk로 Flush |
| Purge Thread | thread/innodb/srv_purge_thread | Rollback에 필요없는 Row 제거 |

### InnoDB Thread 상태 확인 방법

```sql
show engine innodb status;
```

- 결과
  
    ```sql
    +--------+------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    | Type   | Name | Status                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
    +--------+------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    | InnoDB |      |
    =====================================
    2022-12-27 13:37:09 140297792415488 INNODB MONITOR OUTPUT
    =====================================
    Per second averages calculated from the last 11 seconds
    -----------------
    BACKGROUND THREAD
    -----------------
    srv_master_thread loops: 2 srv_active, 0 srv_shutdown, 10276 srv_idle
    srv_master_thread log flush and writes: 0
    ----------
    SEMAPHORES
    ----------
    OS WAIT ARRAY INFO: reservation count 25
    OS WAIT ARRAY INFO: signal count 23
    RW-shared spins 0, rounds 0, OS waits 0
    RW-excl spins 0, rounds 0, OS waits 0
    RW-sx spins 0, rounds 0, OS waits 0
    Spin rounds per wait: 0.00 RW-shared, 0.00 RW-excl, 0.00 RW-sx
    ------------
    TRANSACTIONS
    ------------
    Trx id counter 8725
    Purge done for trx's n:o < 8715 undo n:o < 0 state: running but idle
    History list length 0
    LIST OF TRANSACTIONS FOR EACH SESSION:
    ---TRANSACTION 421772803706072, not started
    0 lock struct(s), heap size 1128, 0 row lock(s)
    ---TRANSACTION 421772803705264, not started
    0 lock struct(s), heap size 1128, 0 row lock(s)
    ---TRANSACTION 421772803704456, not started
    0 lock struct(s), heap size 1128, 0 row lock(s)
    --------
    FILE I/O
    --------
    I/O thread 0 state: waiting for completed aio requests (insert buffer thread)
    I/O thread 1 state: waiting for completed aio requests (log thread)
    I/O thread 2 state: waiting for completed aio requests (read thread)
    I/O thread 3 state: waiting for completed aio requests (read thread)
    I/O thread 4 state: waiting for completed aio requests (read thread)
    I/O thread 5 state: waiting for completed aio requests (read thread)
    I/O thread 6 state: waiting for completed aio requests (write thread)
    I/O thread 7 state: waiting for completed aio requests (write thread)
    I/O thread 8 state: waiting for completed aio requests (write thread)
    I/O thread 9 state: waiting for completed aio requests (write thread)
    Pending normal aio reads: [0, 0, 0, 0] , aio writes: [0, 0, 0, 0] ,
     ibuf aio reads:, log i/o's:
    Pending flushes (fsync) log: 0; buffer pool: 0
    1564 OS file reads, 278 OS file writes, 117 OS fsyncs
    0.00 reads/s, 0 avg bytes/read, 0.00 writes/s, 0.00 fsyncs/s
    -------------------------------------
    INSERT BUFFER AND ADAPTIVE HASH INDEX
    -------------------------------------
    Ibuf: size 1, free list len 0, seg size 2, 0 merges
    merged operations:
     insert 0, delete mark 0, delete 0
    discarded operations:
     insert 0, delete mark 0, delete 0
    Hash table size 34679, node heap has 1 buffer(s)
    Hash table size 34679, node heap has 0 buffer(s)
    Hash table size 34679, node heap has 6 buffer(s)
    Hash table size 34679, node heap has 1 buffer(s)
    Hash table size 34679, node heap has 1 buffer(s)
    Hash table size 34679, node heap has 0 buffer(s)
    Hash table size 34679, node heap has 1 buffer(s)
    Hash table size 34679, node heap has 1 buffer(s)
    0.00 hash searches/s, 0.00 non-hash searches/s
    ---
    LOG
    ---
    Log sequence number          21051424
    Log buffer assigned up to    21051424
    Log buffer completed up to   21051424
    Log written up to            21051424
    Log flushed up to            21051424
    Added dirty pages up to      21051424
    Pages flushed up to          21051424
    Last checkpoint at           21051424
    Log minimum file id is       6
    Log maximum file id is       6
    31 log i/o's done, 0.00 log i/o's/second
    ----------------------
    BUFFER POOL AND MEMORY
    ----------------------
    Total large memory allocated 0
    Dictionary memory allocated 604379
    Buffer pool size   8192
    Free buffers       7033
    Database pages     1148
    Old database pages 443
    Modified db pages  0
    Pending reads      0
    Pending writes: LRU 0, flush list 0, single page 0
    Pages made young 0, not young 0
    0.00 youngs/s, 0.00 non-youngs/s
    Pages read 1005, created 143, written 203
    0.00 reads/s, 0.00 creates/s, 0.00 writes/s
    No buffer pool page gets since the last printout
    Pages read ahead 0.00/s, evicted without access 0.00/s, Random read ahead 0.00/s
    LRU len: 1148, unzip_LRU len: 0
    I/O sum[0]:cur[0], unzip sum[0]:cur[0]
    --------------
    ROW OPERATIONS
    --------------
    0 queries inside InnoDB, 0 queries in queue
    0 read views open inside InnoDB
    Process ID=1944, Main thread ID=140297111594752 , state=sleeping
    Number of rows inserted 0, updated 0, deleted 0, read 0
    0.00 inserts/s, 0.00 updates/s, 0.00 deletes/s, 0.00 reads/s
    Number of system rows inserted 8, updated 331, deleted 8, read 7772
    0.00 inserts/s, 0.00 updates/s, 0.00 deletes/s, 0.00 reads/s
    ----------------------------
    END OF INNODB MONITOR OUTPUT
    ============================
     |
    +--------+------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    1 row in set (0.01 sec)
    ```
    

# Memory

- MySQL은 DB 작업 성능 향상을 위해 다양한 Memory 영역을 가짐
- Storage Engine과 사용 중인 기능에 따라 다르나 공유 가능 여부를 기준으로 나뉨
    - Global Memory(Shared Memory): 공유 가능
    - Local Memory: 공유 불가능

## Global Memory

- Foreground Thread 수와 관계 없이 공통으로 사용되는 메모리 공간
- 모든 Thread에서 공유 가능
- MySQL Server가 시작될 때 OS로 부터 할당
    - 설정 변경 시 MySQL Server를 재시작

### Query Cache(MySQL 4.0.1 ~ MySQL 5.7.20)

- Client로 전송된 Result Set과 Select 문장을 함께 저장
- 자주 변경되지 않는 Table에 동일한 Query를 사용할 때 유용

### Table Cache

- MySQL에선 Table을 사용할 때 열고 사용 후 닫아야 함
    - 위 작업이 반복될 경우 부하를 발생
- MySQL은 Multi Thread로 동작하므로 동시에 같은 Table에 많은 Query를 수행하는 Client가 있을 수 있으나 같은 Table을 Thread 간 공유할 수 없음
    - 같은 Table에 접근하는 Thread가 많을수록 많은 정보를 저장할 Memory 공간이 필요함

### InnoDB의 Buffer Pool

- Oracle의 Buffer Cache와 유사
- Data, Index, Lock, Data Dictionary 등의 정보를 저장

### InnoDB의 Change(Insert) Buffer

- Insert, Update, Delete와 DML시 사용되는 영역
- MySQL 5.5 이전은 Insert 작업에 대한 변경내역만 기록하여 Insert Buffer라 불렸음

### InnoDB의 Adaptive Hash Index

- B-Tree Index의 약점을 보완한 InnoDB의 기능
- 자주 사용되는 Column을 Hash로 정의해 Data에 바로 접근이 가능하게 하는 기능
    - 모든 Column이 아닌 자주 사용되는 Column만을 대상으로 Hash 생성
    - Buffer Pool의 64분의 1만큼으로 초기화

### InnoDB의 Log Buffer(MySQL 5.5 이하 Redo Log Buffer)

- Transaction Log(Redo Log) File에 기록할 내용을 보관하는 Memory 영역
- Log Buffer의 내용은 주기적으로 Disk에 Flush

### MyISAM의 Key Cache

- InnoDB의 Buffer Pool과 유사한 Memory 영역
- MyISAM Table의 Index를 Caching하기 위한 공간

## Local Memory

- Foreground Thread가 Query를 처리할 때 사용하는 개별 Memory 공간
- Client가 사용해 Client Memory라고도, Client와 Server의 Connection이 Session이기 때문에 Session Memory라고도 함
- Thread 별 독립 할당되어 공유되지 않음
- 필요한 경우에만 할당되며 필요하지 않은 경우 사용되지 않음

### Sort Buffer

- Index를 통한 정렬이 불가능한 경우 별도 정렬 작업을 하는데 사용되는 공간
- Query 실행 완료 시 시스템에 즉시 반환

### Join Buffer

- Join 시 Inner Table의 Join Column에 적절한 Index가 존재하지 않아 Index Scan, Index Range Scan, Full Table Scan을 수행할 경우 사용하는 영역
- Join Buffer가 필요한 시점에 모두 한꺼번에 할당받음

### Read Buffer

- 일반적으로 MyISAM Table에 대한 Full Table Scan할 때 각 Table에 Read Buffer 할당
- 다른 Storage Engine의 경우 ORDER BY로 Row 정렬, Index를 Temp File에 Cache, Partition에 대량 Insert, Nested Query의 결과를 Caching하는 경우 사용

### Connection Buffer & Result Buffer

- Server와 Client가 Connection 할 때 Thread가 생성되는데 각 Thread에 Connection Buffer와 Result Buffer라는 Memory 공간이 필요

### Binlog Cache

- Binary Log는 Replication이나 Recovery에 사용되는 DB 변경 사항 등을 기록하는 Log
    - STATEMENT: MySQL 5.7.6 이전 Default, SQL문 그래도 Binary Log에 기록
    - ROW: MySQL 5.7.6 이후 Default, Row에 대한 변경을 Binary Log에 기록
    - MIXED: STATEMENT를 주로 쓰되 필요시 ROW 방식 사용
- Binary Log를 바로 Disk에 쓰지 않고 Memory에 임시 공간에 Buffering하는 공간이 Binlog Cache

# 참고

[DB 인사이드 | MySQL Architecture - 1. MySQL 엔진](https://exem.tistory.com/1679)