# Oracle Dictionary

자주 사용하는 것들

### SESSION 관련

| 성능 View / Dictionary | Dictionary |
| --- | --- |
| V$SESSION | 세선에 대한 전반적인 정보를 보여줌 |
| V$SESSSTAT | 세션의 현황에 대한 통계 정보를 보여줌 |
| V$SESSION_WAIT | 세션의 WAITING 통계 정보를 보여줌 |
| V$SESSION_EVENT | 세션의 현재 WATING EVENT를 보여줌 |
| V$SESS_IO | 세션의 IO 현황을 보여줌 |
| V$STATNAME | SESSSTAT의 STATUS의 이름을 보여줌 |

### 성능 관련

| 성능 View / Dictionary | Dictionary |
| --- | --- |
| V$SYSTAT | 시스템 전반의 성능 통계 정보를 보여줌 |
| V$SYSTEM_EVENT | 시스템의 WATING EVENT별 통계정보를 보여줌 |
| V$LIBRARYCACHE | 라이브러리 캐시 사용 정보를 보여줌 |
| V$ROWCACHE | 데이터 딕셔너리의 사용정보를 보여줌 |
| V$LACTH | LATCH에 대한 정보 보여줌 |
| V$LOCK | LOCK에 대한 정보를 보여줌 |
| V$LOCKED_OBJECT | LOCK이 걸린 OBJECT에 대한 정보를 보여줌 |
| V$SQLAREA | SQLAREA에 대한 정보를 보여줌 |
| V$WAITSTAT | 시스템의 현재 WAITING 현황을 보여줌 |

### SQL 관련

| 성능 View / Dictionary | Dictionary |
| --- | --- |
| V$SQL | PARSE된 SQL문장을 보여줌 |
| V$SQLTEXT | LINE별로 SQL문장을 보여줌 |
| V$SQLTEXT_WITH_NEWLINES | NEWLINE을 포함하여 SQL문장을 보여줌 |

### SYSTEM 관련

| 성능 View / Dictionary | Dictionary |
| --- | --- |
| V$SGA | SGA의 정보를 보여줌 |
| V$PARAMETER | InitSID.ora 등에서 설정된 Parameter,
즉 DB의 구동되었을 때의 환경 Parameter 정보를 보여줌 |
| V$CONTROLFILE | Control File에 대한 정보를 보여줌 |
| V$DATAFILE | Data File에 대한 정보를 보여줌 |
| V$LOG, V$LOGFILE | Redo Log File에 대한 정보를 보여줌 |

### USER 관련

| 성능 View / Dictionary | Dictionary |
| --- | --- |
| DBA_USERS | DB USER에 대한 정보를 보여줌 |

### PRIVILEGE 관련

| 성능 View / Dictionary | Dictionary |
| --- | --- |
| DBA_ROLES | ROLE에 대한 정보를 보여줌 |
| DBA_TAB_PRIVS | Table에 대한 권한이 설정된 정보를 보여줌 |
| DBA_SYS_PRIVS | SYSTEM 권한이 설정된 정보를 보여줌 |
| DBA_ROLE_PRIVS | ROLE에 대한 권한이 설정된 정보를 보여줌 |
| DBA_COL_PRIVS | Column 단위로 권한이 설정된 정보를 보여줌 |

### SEGMENT, OBJECT 관련

| 성능 View / Dictionary | Dictionary |
| --- | --- |
| DBA_SEGMENTS | Segment에 대한 정보를 보여줌 |
| DBA_OBJECTS | 모든 Object에 대한 정보를 보여줌 |

### TABLE 관련

| 성능 View / Dictionary | Dictionary |
| --- | --- |
| V$TABLESPACE | Tablespace에 대한 정보를 보여줌 |
| DBA_TABLESPACES | Tablespace에 대한 정보를 보여줌 |
| DBA_DATA_FILES | Tablespace를 구성하고 있는 Datafile에 대한 정보를 보여줌 |
| DBA_FREE_SPACE | 아직 사용되지 않은 영역에 대한 정보를 보여줌 |
| DBA_EXTENTS | 할당된 Extent의 정보를 보여줌 |
| DBA_TS_QUOTAS | QUOTA가 설정된 정보를 보여줌 |
| DBA_TABLES | Table에 대한 정보를 보여줌 |
| DBA_TAB_COLUMNS | Table을 구성하는 Column에 대한 정보를 보여줌 |
| DBA_TAB_COMMENTS | Table의 설명에 대한 정보를 보여줌 |
| DBA_PART_TABLES | Partition Table에 대한 정보를 보여줌 |
| DBA_PART_KEY_COLUMNS | Partition을 구성하는 기준 Column에 대한 정보를 보여줌 |
| DBA_COL_COMMENTS | Column에 대한 설명에 대한 정보를 보여줌 |

### INDEX 관련

| 성능 View / Dictionary | Dictionary |
| --- | --- |
| DBA_INDEXES | Index에 대한 정보를 보여줌 |
| DBA_PART_INDEXES | Partition된 Index에 대한 정보를 보여줌 |
| DBA_IND_COLUMNS | Index를 구성하는 Column에 대한 정보를 보여줌 |

### CONSTRAINT 관련

| 성능 View / Dictionary | Dictionary |
| --- | --- |
| DBA_CONSTRAINTS | Table에 걸려있는 Constraint를 보여줌 |
| DBA_CONS_COLUMNS | Constraint를 구성하는 Column에 대한 조건을 보여줌 |

### VIEW 관련

| 성능 View / Dictionary | Dictionary |
| --- | --- |
| DBA_VIEWS | VIEW를 정의한 정보를 보여줌 |

### SYNONYM 관련

| 성능 View / Dictionary | Dictionary |
| --- | --- |
| DBA_SYNONYMS | Synonym에 대한 정보를 보여줌 |

### SEQUENCE 관련

| 성능 View / Dictionary | Dictionary |
| --- | --- |
| DBA_SEQUENCES | Sequence에 대한 정보를 보여줌 |

### DB LINK 관련

| 성능 View / Dictionary | Dictionary |
| --- | --- |
| DBA_DB_LINKS | DB Link에 대한 정보를 보여줌 |

### TRIGGER 관련

| 성능 View / Dictionary | Dictionary |
| --- | --- |
| DBA_TRIGGERS | Trigger에 대한 정보를 보여줌 |
| DBA_TRIGGER_COLS | Column 단위로 작성된 Trigger에 대한 정의를 보여줌 |

### ROLLBACK 관련

| 성능 View / Dictionary | Dictionary |
| --- | --- |
| DBA_ROLLBACK_SEGS | Rollback Segement에 대한 정보를 보여줌 |

### FUNCTION, PROCEDURE, PACKAGE 관련

| 성능 View / Dictionary | Dictionary |
| --- | --- |
| DBA_SOURCE | Function, Procedure, Package를 구성하는 PL/SQL에 대한 Source Code를 보여줌 |