# PostgreSQL 정리

<aside>
📌 이 문서는 PostgreSQL Ver 11을 기준으로 정리한 자료

</aside>

<aside>
🔢 **목차**

</aside>

# PostgreSQL의 제한사항

| 항목 | 제한사항 |
| --- | --- |
| 최대 DB 크기 | 무제한 |
| 최대 테이블 크기 | 32TB |
| 최대 레코드 크기 | 1.6TB |
| 최대 컬럼 크기 | 1GB |
| 테이블당 최대 레코드 수 | 무제한 |
| 테이블당 최대 컬럼 개수 | 250 ~ 1600 개 ( 컬럼 타입에 의존적 ) |
| 테이블당 최대 인덱스 수 | 무제한 |

# PostgreSQL Data Type

| 분류 | 종류 | 내용 |
| --- | --- | --- |
| 숫자 | smallint | 작은 범위의 정수, 2 bytes(-32768 ~ +32767) |
|  | integer | 정수에 대한 일반적인 선택, 4 bytes(-2147483648 ~ +2147483647) |
|  | bigint | 큰 범위의 정수, 8 bytes(-9223372036854775808 ~ 9223372036854775807) |
|  | decimal | 사용자 지정 정밀도, variable, 정확(제한 없음) |
|  | numeric | 사용자 지정 정밀도, variable, 정확(제한 없음) |
|  | real | 가변 정밀도, 부정확, 4 bytes(6자리 소수점 정밀도) |
|  | double precision | 가변 정밀도, 부정확, 8 bytes(15자리 소수점 정밀도) |
|  | serial | 자동 증가 정수, 4 bytes(1 ~ 2147483647) |
|  | bigserial | 큰 자동 증가 정수, 8 bytes(1 ~ 9223372036854775807 |
| 화폐 | money | 통화 금액, 8 bytes(-92233720368547758.08 ~ +92233720368547758.07) |
| 문자 | character varying(n)
varchar(n) | 제한이있는 가변 길이 |
|  | character(n)
char(n) | 고정 길이, 공백 채우기 |
|  | text | 가변 길이 무제한 |
|  | "char" | 1byte 내부 유형, 1 byte |
|  | name | 개체 이름의 내부 유형, 64 bytes |
| 이진 데이터 | bytea | 가변 길이 이진 문자열, 1 또는 4 byte와 실제 2진 문자열 |
| 날짜/시간 | timestamp [(p)]
[without time zone] | 날짜와 시간 모두(시간대 없음), 8 bytes |
|  | timestamp [(p)]
with time zone | 시간대가 있는 날짜와 시간 모두, 8 bytes |
|  | date | 날짜(시간 없음), 4 bytes |
|  | time [(p)]
[without time zone] | 시간(날짜 없음), 8 bytes |
|  | time [(p)]
with time zone | 시간대만 포함, 12 bytes |
|  | interval [fields][(p)] | 시간 간격, 16 bytes |
| 부울 | boolean | 참 또는 거짓 상태, 1 byte |
| 기하학 | point | 비행기 위의 포인트, 16 bytes, (x,y) |
|  | line | 무한 라인(완전히 구현되지 않음), 32 bytes, ((x1,y1),(x2,y2)) |
|  | lseg | 유한 선분, 32 bytes, ((x1,y1),(x2,y2)) |
|  | box | 직사각형 상자, 32 bytes, ((x1,y1),(x2,y2)) |
|  | path | 닫힌 경로(폴리곤과 유사), 16+16n bytes, ((x1,y1),...) |
|  | path | 열린 경로, 16+16n bytes, [(x1,y1),...] |
|  | polygon | 다각형(닫힌 경로와 유사), 40+16n bytes, ((x1,y1),...) |
|  | circle | 원, 24 bytes, <(x,y),r> (중심점 및 반경) |
| 네트워크 주소 | cidr | IPv4 및 IPv6 네트워크, 7 또는 19 bytes |
|  | inet | IPv4 및 IPv6 호스트 및 네트워크, 7 또는 19 bytes |
|  | macaddr | MAC 주소, 6 bytes |
| 비트 문자열 | bit(n) | 길이 n과 정확히 일치 |
|  | bit varying(n) | 최대 길이 n까지 가변 길이 |
| 텍스트 검색 | tsvector | 텍스트 검색에 최적화된 형식의 문서 |
|  | tsquery | 유사한 텍스트 쿼리 |
| 개체 식별자 | oid | 숫자 객체 식별자 (예: 564182) |
|  | regproc | 함수 명 (예: sum) |
|  | regprocedure | 인수 유형이 있는 함수 (예: sum(int4)) |
|  | regoper | 연산자 이름 (예: +) |
|  | regoperator | 인수 유형이 있는 연산자 (예: *(integer,integer) 또는
-(NONE,integer)) |
|  | regclass | 관계 이름 (예: pg_type) |
|  | regtype | 데이터 유형 이름 (예: integer) |
|  | regconfig | 텍스트 검색 구성 (예: english) |
|  | regdictionary | 텍스트 검색 사전 (예: simple) |
| Pseudo | any | 함수가 모든 입력 데이터 유형을 허용 |
|  | anyarray | 함수가 모든 배열 데이터 유형을 허용 |
|  | anyelement | 함수가 모든 데이터 유형을 허용 |
|  | anyenum | 함수가 모든 열거형 데이터 유형을 허용 |
|  | anynonarray | 함수가 배열이 아닌 데이터 유형을 허용 |
|  | cstring | 함수가 null로 끝나는 C 문자열을 받거나 반환 |
|  | internal | 함수가 서버 내부 데이터 유형을 수락하거나 반환 |
|  | language_handler | 절차 언어 호출 핸들러가 language_handler를 반환하도록 선언 |
|  | record | 지정되지 않은 행 유형을 반환하는 함수를 식별 |
|  | trigger | 트리거를 반환하기 위해 트리거 함수가 선언 |
|  | void | 함수가 값을 반환하지 않음 |
|  | opaque | 이전에 위의 모든 목적을 수행했던 오래된 유형 이름 |
| 열거 |  | 열거형 값은 디스크에서 4 bytes를 차지 |
|  |  | 열거형 값의 텍스트 레이블 길이는 최대 63 bytes |
|  |  | 열거형 레이블은 대소문자를 구분 |
|  |  | 레이블의 공백도 중요 |
| UUID |  | 하이픈으로 구분, 8자리 그룹, 4자리 그룹 3개, 12자리 그룹 순으로 소문자 16진수 시퀀스(총 32자리) |
|  |  | 128 bits |
| XML |  | xml 데이터 유형을 사용하여 XML 데이터를 저장 |
| 배열 |  | 테이블의 열을 가변 길이 다차원 배열로 정의 |
|  |  | 내장 또는 사용자 정의 기본 유형
열거 유형 또는 복합 유형의 배열을 작성 |
|  |  | 특정 배열 요소를 검색하는 것은 데이터베이스 설계 오류의 징후일 가능성
(배열 요소가 될 각 항목에 대해 행이 있는 별도의 테이블을 사용하는 것 권장) |
| 복합 |  | 행 또는 레코드의 구조
(필드 이름과 데이터 유형의 목록) |

# PostgreSQL의 내부 구조

![Untitled](./PostgreSQL 정리/Untitled.png)

# PostgreSQL WAL

- PostgreSQL의 **WAL**은 **XLOG**와 같음(Ver 9.6 이하 XLOG, Ver 10 이상 WAL)

![전체적인 구조 사진](./PostgreSQL 정리/WAL.svg)

전체적인 구조 사진

## Transaction Log & WAL Segment File

### Transaction Log

- 논리적 파일
- 용량 무제한(순환형)

### WAL Segment File

- 물리적 파일
- 기본 크기: 16MB
- 파일명
  
  
    | 파일명 공식 | TimeLineId(TLI) | $\frac{(LSN-1)}{16M\times256}$ | $\{\frac{(LSN-1)}{16M}\}\% 256$ |
    | --- | --- | --- | --- |
    | 예제 | 0000001 | 0000001 | 00000000 |

## XLOG Page

- WAL Segment File은 여러 8KB의 XLOG Page로 구성
- XLOG Page는 XLOG Page Header와 XLOG Record로 나뉨

### XLOG Page Header

- 첫 Page는 XLogLongPageHeaderData 구조로 형성
  
    ```c
    typedef struct XLogLongPageHeaderData
    {
        XLogPageHeaderData std;     /* standard header fields */
        uint64      xlp_sysid;      /* system identifier from pg_control */
        uint32      xlp_seg_size;   /* just as a cross-check */
        uint32      xlp_xlog_blcksz;    /* just as a cross-check */
    } XLogLongPageHeaderData;
    ```
    
- 나머지 Page는 XLogPageHeaderData 구조로 형성
  
    ```c
    typedef struct XLogPageHeaderData
    {
        uint16      xlp_magic;      /* magic value for correctness checks */
        uint16      xlp_info;       /* flag bits, see below */
        TimeLineID  xlp_tli;        /* TimeLineID of first record on page */
        XLogRecPtr  xlp_pageaddr;   /* XLOG address of this page */
     
        /*
         * When there is not enough space on current page for whole record, we
         * continue on the next page.  xlp_rem_len is the number of bytes
         * remaining from a previous page; it tracks xl_tot_len in the initial
         * header.  Note that the continuation data isn't necessarily aligned.
         */
        uint32      xlp_rem_len;    /* total len of remaining data for record */
    } XLogPageHeaderData;
    ```
    

## XLOG Record

- XLOG Record는 Header 부분과 Data 부분으로 구성

### XLOG Record의 Header

- XLogRecord 구조로 형성된 고정 길이 일반 Header
  
    ```c
    typedef struct XLogRecord {
        uint32        xl_tot_len; // total length of entire record
        TransactionId xl_xid;     // xact id
        XLogRecPtr.   xl_prev;    // ptr to previous record in log
        uint8         xl_info;    // flag bits, see below
        RmgrId        xl_rmid;    // resource manager for this record
        // 2 Bytes of Padding Here, Initiallize to zero
        pg_crc32      xl_crc;     // CRC for this record
        // XLogRecordBlockHeaders & XLogRecordDataHeader Follow, No Padding
    } XLogRecord;
    ```
    

### XLOG Record의 Data

- Resource Manager에 의존하지 않는 공통 구조화된 형식
- Header Part와 Data Part로 구분

**XLOG Record의 Data의 Header Part**

- Block 개수 만큼의 XLogRecordBlockHeader 포함(n(n≥0)개)
  
    ```c
    typedef struct XLogRecordBlockHeader
    {
    	uint8		id;				/* block reference ID */
    	uint8		fork_flags;		/* fork within the relation, and flags */
    	uint16		data_length;	/* number of payload bytes (not including page image) */
    	/* If BKPBLOCK_HAS_IMAGE, an XLogRecordBlockImageHeader struct follows */
    	/* If BKPBLOCK_SAME_REL is not set, a RelFileLocator follows */
    	/* BlockNumber follows */
    } XLogRecordBlockHeader;
    ```
    
    - Block이 Image가 있다면 XLogRecordBlockImagerHeader 포함
      
        ```c
        typedef struct XLogRecordBlockImageHeader
        {
        	uint16		length;			/* number of page image bytes */
        	uint16		hole_offset;	/* number of bytes before "hole" */
        	uint8		bimg_info;		/* flag bits, see below */
        	/*
        	 * If BKPIMAGE_HAS_HOLE and BKPIMAGE_IS_COMPRESSED, an
        	 * XLogRecordBlockCompressHeader struct follows.
        	 */
        } XLogRecordBlockImageHeader;
        
        /* Information stored in bimg_info */
        #define BKPIMAGE_HAS_HOLE	0x01	/* page image has "hole" */
        #define BKPIMAGE_IS_COMPRESSED 0x02	/* page image is compressed */
        #define BKPIMAGE_APPLY 0x04	/* page image should be restored during replay */
        ```
        
    - Block이 압축되어 있다면 XLogRecordBlockCompressHeader 포함
      
        ```c
        typedef struct XLogRecordBlockCompressHeader
        {
        	uint16		hole_length;	/* number of bytes in "hole" */
        } XLogRecordBlockCompressHeader;
        ```
    
- XLogRecordDataHeader 포함(1개)
  
    ```c
    #define XLR_MAX_BLOCK_ID			32 /* 의미 불명확(아래 BlockId 참고) */
    #define XLR_BLOCK_ID_DATA_SHORT		255 /* 만약 id가 FF라면 DataHeaderShort */
    #define XLR_BLOCK_ID_DATA_LONG		254 /* FE라면 DataHeaderLong */
    #define XLR_BLOCK_ID_ORIGIN			253 /* FD라면 Origin(의미 불명확) */
    ```
    
    - XLogRecordDataHeaderLong
      
        ```c
        typedef struct XLogRecordDataHeaderLong
        {
        	uint8		id;				/* XLR_BLOCK_ID_DATA_LONG */
        	/* followed by uint32 data_length, unaligned */
        }XLogRecordDataHeaderLong;
        ```
        
    - XLogRecordDataHeaderShort
      
        ```c
        typedef struct XLogRecordDataHeaderShort
        {
        	uint8		id;				/* XLR_BLOCK_ID_DATA_SHORT */
        	uint8		data_length;	/* number of payload bytes */
        }XLogRecordDataHeaderShort;
        ```
        

**XLOG Record의 Data의 Data Part**

- Block 개수 만큼의 XLogRecordBlock(= Block Data) 포함(n개)
  
    ```c
    typedef struct BlockIdData
    {
    	uint16		bi_hi;
    	uint16		bi_lo;
    } BlockIdData;
    
    typedef BlockIdData *BlockId;	/* block identifier */
    ```
    
    - Block은 Backup Block과 Non-Backup Block으로 구분
        - Backup Block: Block이 Image를 가지고 있음
        - Non-Backup Block: Block이 Image를 가지지 않음
- Main Data 포함(1개)
    - Main Data는 명령(작업)에 따라 달라짐
        - ex: xl_heap_insert, xl_heap_update, ETC

# WAL File 분석(Oracle GoldenGate, pg_waldump)

## pg_waldump 결과

```
-bash-4.2$ ./pg_waldump -f -p /var/lib/pgsql/11/data/pg_wal 000000010000000000000005
rmgr: Standby     len (rec/tot):     50/    50, tx:          0, lsn: 0/05000028, prev 0/04010618, desc: RUNNING_XACTS nextXid 717 latestCompletedXid 716 oldestRunningXid 717
rmgr: Standby     len (rec/tot):     50/    50, tx:          0, lsn: 0/05000060, prev 0/05000028, desc: RUNNING_XACTS nextXid 717 latestCompletedXid 716 oldestRunningXid 717
rmgr: XLOG        len (rec/tot):    106/   106, tx:          0, lsn: 0/05000098, prev 0/05000060, desc: CHECKPOINT_ONLINE redo 0/5000060; tli 1; prev tli 1; fpw true; xid 0:717; oid 24595; multi 1; offset 0; oldest xid 561 in DB 1; oldest multi 1 in DB 1; oldest/newest commit timestamp xid: 0/0; oldest running xid 717; online
rmgr: Standby     len (rec/tot):     50/    50, tx:          0, lsn: 0/05000108, prev 0/05000098, desc: RUNNING_XACTS nextXid 717 latestCompletedXid 716 oldestRunningXid 717
rmgr: Heap2       len (rec/tot):     59/  7775, tx:          0, lsn: 0/05000140, prev 0/05000108, desc: CLEAN remxid 711, blkref #0: rel 1663/16384/1255 blk 40 FPW
rmgr: Heap        len (rec/tot):    130/   130, tx:        717, lsn: 0/05001FA0, prev 0/05000140, desc: INSERT+INIT off 1, blkref #0: rel 1663/16384/16446 blk 0
rmgr: Btree       len (rec/tot):     94/    94, tx:        717, lsn: 0/05002040, prev 0/05001FA0, desc: NEWROOT lev 0, blkref #0: rel 1663/16384/16449 blk 1, blkref #2: rel 1663/16384/16449 blk 0
rmgr: Btree       len (rec/tot):     64/    64, tx:        717, lsn: 0/050020A0, prev 0/05002040, desc: INSERT_LEAF off 1, blkref #0: rel 1663/16384/16449 blk 1
rmgr: Heap        len (rec/tot):    130/   130, tx:        717, lsn: 0/050020E0, prev 0/050020A0, desc: INSERT off 2, blkref #0: rel 1663/16384/16446 blk 0
rmgr: Btree       len (rec/tot):     64/    64, tx:        717, lsn: 0/05002168, prev 0/050020E0, desc: INSERT_LEAF off 2, blkref #0: rel 1663/16384/16449 blk 1
rmgr: Heap        len (rec/tot):    130/   130, tx:        717, lsn: 0/050021A8, prev 0/05002168, desc: INSERT off 3, blkref #0: rel 1663/16384/16446 blk 0
rmgr: Btree       len (rec/tot):     64/    64, tx:        717, lsn: 0/05002230, prev 0/050021A8, desc: INSERT_LEAF off 3, blkref #0: rel 1663/16384/16449 blk 1
rmgr: Heap        len (rec/tot):    130/   130, tx:        717, lsn: 0/05002270, prev 0/05002230, desc: INSERT off 4, blkref #0: rel 1663/16384/16446 blk 0
rmgr: Btree       len (rec/tot):     64/    64, tx:        717, lsn: 0/050022F8, prev 0/05002270, desc: INSERT_LEAF off 4, blkref #0: rel 1663/16384/16449 blk 1
rmgr: Heap        len (rec/tot):    130/   130, tx:        717, lsn: 0/05002338, prev 0/050022F8, desc: INSERT off 5, blkref #0: rel 1663/16384/16446 blk 0
rmgr: Btree       len (rec/tot):     64/    64, tx:        717, lsn: 0/050023C0, prev 0/05002338, desc: INSERT_LEAF off 5, blkref #0: rel 1663/16384/16449 blk 1
rmgr: Heap        len (rec/tot):    130/   130, tx:        717, lsn: 0/05002400, prev 0/050023C0, desc: INSERT off 6, blkref #0: rel 1663/16384/16446 blk 0
rmgr: Btree       len (rec/tot):     64/    64, tx:        717, lsn: 0/05002488, prev 0/05002400, desc: INSERT_LEAF off 6, blkref #0: rel 1663/16384/16449 blk 1
rmgr: Heap        len (rec/tot):    130/   130, tx:        717, lsn: 0/050024C8, prev 0/05002488, desc: INSERT off 7, blkref #0: rel 1663/16384/16446 blk 0
rmgr: Btree       len (rec/tot):     64/    64, tx:        717, lsn: 0/05002550, prev 0/050024C8, desc: INSERT_LEAF off 7, blkref #0: rel 1663/16384/16449 blk 1
rmgr: Heap        len (rec/tot):    130/   130, tx:        717, lsn: 0/05002590, prev 0/05002550, desc: INSERT off 8, blkref #0: rel 1663/16384/16446 blk 0
rmgr: Btree       len (rec/tot):     64/    64, tx:        717, lsn: 0/05002618, prev 0/05002590, desc: INSERT_LEAF off 8, blkref #0: rel 1663/16384/16449 blk 1
rmgr: Heap        len (rec/tot):    130/   130, tx:        717, lsn: 0/05002658, prev 0/05002618, desc: INSERT off 9, blkref #0: rel 1663/16384/16446 blk 0
rmgr: Btree       len (rec/tot):     64/    64, tx:        717, lsn: 0/050026E0, prev 0/05002658, desc: INSERT_LEAF off 9, blkref #0: rel 1663/16384/16449 blk 1
rmgr: Heap        len (rec/tot):    130/   130, tx:        717, lsn: 0/05002720, prev 0/050026E0, desc: INSERT off 10, blkref #0: rel 1663/16384/16446 blk 0
rmgr: Btree       len (rec/tot):     64/    64, tx:        717, lsn: 0/050027A8, prev 0/05002720, desc: INSERT_LEAF off 10, blkref #0: rel 1663/16384/16449 blk 1
rmgr: Transaction len (rec/tot):     46/    46, tx:        717, lsn: 0/050027E8, prev 0/050027A8, desc: COMMIT 2022-12-06 12:26:59.522657 KST
rmgr: Standby     len (rec/tot):     54/    54, tx:          0, lsn: 0/05002818, prev 0/050027E8, desc: RUNNING_XACTS nextXid 718 latestCompletedXid 716 oldestRunningXid 717; 1 xacts: 717
rmgr: Standby     len (rec/tot):     50/    50, tx:          0, lsn: 0/05002850, prev 0/05002818, desc: RUNNING_XACTS nextXid 718 latestCompletedXid 717 oldestRunningXid 718
rmgr: XLOG        len (rec/tot):    106/   106, tx:          0, lsn: 0/05002888, prev 0/05002850, desc: CHECKPOINT_ONLINE redo 0/5002850; tli 1; prev tli 1; fpw true; xid 0:718; oid 24595; multi 1; offset 0; oldest xid 561 in DB 1; oldest multi 1 in DB 1; oldest/newest commit timestamp xid: 0/0; oldest running xid 718; online
rmgr: Standby     len (rec/tot):     50/    50, tx:          0, lsn: 0/050028F8, prev 0/05002888, desc: RUNNING_XACTS nextXid 718 latestCompletedXid 717 oldestRunningXid 718
rmgr: Heap2       len (rec/tot):     59/  7663, tx:          0, lsn: 0/05002930, prev 0/050028F8, desc: CLEAN remxid 714, blkref #0: rel 1663/16384/1255 blk 41 FPW
rmgr: Heap        len (rec/tot):    130/   130, tx:        718, lsn: 0/05004738, prev 0/05002930, desc: INSERT+INIT off 1, blkref #0: rel 1663/16384/16451 blk 0
rmgr: Standby     len (rec/tot):     54/    54, tx:          0, lsn: 0/050047C0, prev 0/05004738, desc: RUNNING_XACTS nextXid 719 latestCompletedXid 717 oldestRunningXid 718; 1 xacts: 718
rmgr: Btree       len (rec/tot):     94/    94, tx:        718, lsn: 0/050047F8, prev 0/050047C0, desc: NEWROOT lev 0, blkref #0: rel 1663/16384/16454 blk 1, blkref #2: rel 1663/16384/16454 blk 0
rmgr: Btree       len (rec/tot):     64/    64, tx:        718, lsn: 0/05004858, prev 0/050047F8, desc: INSERT_LEAF off 1, blkref #0: rel 1663/16384/16454 blk 1
rmgr: Heap        len (rec/tot):    130/   130, tx:        718, lsn: 0/05004898, prev 0/05004858, desc: INSERT off 2, blkref #0: rel 1663/16384/16451 blk 0
rmgr: Btree       len (rec/tot):     64/    64, tx:        718, lsn: 0/05004920, prev 0/05004898, desc: INSERT_LEAF off 2, blkref #0: rel 1663/16384/16454 blk 1
rmgr: Heap        len (rec/tot):    130/   130, tx:        718, lsn: 0/05004960, prev 0/05004920, desc: INSERT off 3, blkref #0: rel 1663/16384/16451 blk 0
rmgr: Btree       len (rec/tot):     64/    64, tx:        718, lsn: 0/050049E8, prev 0/05004960, desc: INSERT_LEAF off 3, blkref #0: rel 1663/16384/16454 blk 1
rmgr: Heap        len (rec/tot):    130/   130, tx:        718, lsn: 0/05004A28, prev 0/050049E8, desc: INSERT off 4, blkref #0: rel 1663/16384/16451 blk 0
rmgr: Btree       len (rec/tot):     64/    64, tx:        718, lsn: 0/05004AB0, prev 0/05004A28, desc: INSERT_LEAF off 4, blkref #0: rel 1663/16384/16454 blk 1
rmgr: Heap        len (rec/tot):    130/   130, tx:        718, lsn: 0/05004AF0, prev 0/05004AB0, desc: INSERT off 5, blkref #0: rel 1663/16384/16451 blk 0
rmgr: Btree       len (rec/tot):     64/    64, tx:        718, lsn: 0/05004B78, prev 0/05004AF0, desc: INSERT_LEAF off 5, blkref #0: rel 1663/16384/16454 blk 1
rmgr: Heap        len (rec/tot):    130/   130, tx:        718, lsn: 0/05004BB8, prev 0/05004B78, desc: INSERT off 6, blkref #0: rel 1663/16384/16451 blk 0
rmgr: Btree       len (rec/tot):     64/    64, tx:        718, lsn: 0/05004C40, prev 0/05004BB8, desc: INSERT_LEAF off 6, blkref #0: rel 1663/16384/16454 blk 1
rmgr: Heap        len (rec/tot):    130/   130, tx:        718, lsn: 0/05004C80, prev 0/05004C40, desc: INSERT off 7, blkref #0: rel 1663/16384/16451 blk 0
rmgr: Btree       len (rec/tot):     64/    64, tx:        718, lsn: 0/05004D08, prev 0/05004C80, desc: INSERT_LEAF off 7, blkref #0: rel 1663/16384/16454 blk 1
rmgr: Heap        len (rec/tot):    130/   130, tx:        718, lsn: 0/05004D48, prev 0/05004D08, desc: INSERT off 8, blkref #0: rel 1663/16384/16451 blk 0
rmgr: Btree       len (rec/tot):     64/    64, tx:        718, lsn: 0/05004DD0, prev 0/05004D48, desc: INSERT_LEAF off 8, blkref #0: rel 1663/16384/16454 blk 1
rmgr: Heap        len (rec/tot):    130/   130, tx:        718, lsn: 0/05004E10, prev 0/05004DD0, desc: INSERT off 9, blkref #0: rel 1663/16384/16451 blk 0
rmgr: Btree       len (rec/tot):     64/    64, tx:        718, lsn: 0/05004E98, prev 0/05004E10, desc: INSERT_LEAF off 9, blkref #0: rel 1663/16384/16454 blk 1
rmgr: Heap        len (rec/tot):    130/   130, tx:        718, lsn: 0/05004ED8, prev 0/05004E98, desc: INSERT off 10, blkref #0: rel 1663/16384/16451 blk 0
rmgr: Btree       len (rec/tot):     64/    64, tx:        718, lsn: 0/05004F60, prev 0/05004ED8, desc: INSERT_LEAF off 10, blkref #0: rel 1663/16384/16454 blk 1
rmgr: Transaction len (rec/tot):     46/    46, tx:        718, lsn: 0/05004FA0, prev 0/05004F60, desc: COMMIT 2022-12-06 12:32:32.580685 KST
rmgr: Standby     len (rec/tot):     50/    50, tx:          0, lsn: 0/05004FD0, prev 0/05004FA0, desc: RUNNING_XACTS nextXid 719 latestCompletedXid 718 oldestRunningXid 719
rmgr: Standby     len (rec/tot):     50/    50, tx:          0, lsn: 0/05005008, prev 0/05004FD0, desc: RUNNING_XACTS nextXid 719 latestCompletedXid 718 oldestRunningXid 719
rmgr: XLOG        len (rec/tot):    106/   106, tx:          0, lsn: 0/05005040, prev 0/05005008, desc: CHECKPOINT_ONLINE redo 0/5005008; tli 1; prev tli 1; fpw true; xid 0:719; oid 24595; multi 1; offset 0; oldest xid 561 in DB 1; oldest multi 1 in DB 1; oldest/newest commit timestamp xid: 0/0; oldest running xid 719; online
rmgr: Standby     len (rec/tot):     50/    50, tx:          0, lsn: 0/050050B0, prev 0/05005040, desc: RUNNING_XACTS nextXid 719 latestCompletedXid 718 oldestRunningXid 719
rmgr: Heap        len (rec/tot):    227/  1439, tx:        719, lsn: 0/050050E8, prev 0/050050B0, desc: HOT_UPDATE off 1 xmax 719 ; new off 11 xmax 0, blkref #0: rel 1663/16384/16446 blk 0 FPW
rmgr: Transaction len (rec/tot):     46/    46, tx:        719, lsn: 0/05005688, prev 0/050050E8, desc: COMMIT 2022-12-06 12:38:55.764277 KST
rmgr: Standby     len (rec/tot):     50/    50, tx:          0, lsn: 0/050056B8, prev 0/05005688, desc: RUNNING_XACTS nextXid 720 latestCompletedXid 719 oldestRunningXid 720
rmgr: Heap        len (rec/tot):    146/  1358, tx:        720, lsn: 0/050056F0, prev 0/050056B8, desc: HOT_UPDATE off 1 xmax 720 ; new off 11 xmax 0, blkref #0: rel 1663/16384/16451 blk 0 FPW
rmgr: Transaction len (rec/tot):     46/    46, tx:        720, lsn: 0/05005C40, prev 0/050056F0, desc: COMMIT 2022-12-06 12:39:34.351016 KST
rmgr: Standby     len (rec/tot):     50/    50, tx:          0, lsn: 0/05005C70, prev 0/05005C40, desc: RUNNING_XACTS nextXid 721 latestCompletedXid 720 oldestRunningXid 721
rmgr: Standby     len (rec/tot):     50/    50, tx:          0, lsn: 0/05005CA8, prev 0/05005C70, desc: RUNNING_XACTS nextXid 721 latestCompletedXid 720 oldestRunningXid 721
rmgr: XLOG        len (rec/tot):    106/   106, tx:          0, lsn: 0/05005CE0, prev 0/05005CA8, desc: CHECKPOINT_ONLINE redo 0/5005CA8; tli 1; prev tli 1; fpw true; xid 0:721; oid 24595; multi 1; offset 0; oldest xid 561 in DB 1; oldest multi 1 in DB 1; oldest/newest commit timestamp xid: 0/0; oldest running xid 721; online
rmgr: Standby     len (rec/tot):     50/    50, tx:          0, lsn: 0/05005D50, prev 0/05005CE0, desc: RUNNING_XACTS nextXid 721 latestCompletedXid 720 oldestRunningXid 721
rmgr: Heap        len (rec/tot):    227/  1547, tx:        721, lsn: 0/05005D88, prev 0/05005D50, desc: HOT_UPDATE off 11 xmax 721 ; new off 12 xmax 0, blkref #0: rel 1663/16384/16446 blk 0 FPW
rmgr: Transaction len (rec/tot):     46/    46, tx:        721, lsn: 0/050063B0, prev 0/05005D88, desc: COMMIT 2022-12-06 12:40:52.738770 KST
rmgr: Standby     len (rec/tot):     50/    50, tx:          0, lsn: 0/050063E0, prev 0/050063B0, desc: RUNNING_XACTS nextXid 722 latestCompletedXid 721 oldestRunningXid 722
rmgr: Heap        len (rec/tot):    146/  1466, tx:        722, lsn: 0/05006418, prev 0/050063E0, desc: HOT_UPDATE off 11 xmax 722 ; new off 12 xmax 0, blkref #0: rel 1663/16384/16451 blk 0 FPW
rmgr: Transaction len (rec/tot):     46/    46, tx:        722, lsn: 0/050069D8, prev 0/05006418, desc: COMMIT 2022-12-06 12:41:20.016334 KST
rmgr: Standby     len (rec/tot):     50/    50, tx:          0, lsn: 0/05006A08, prev 0/050069D8, desc: RUNNING_XACTS nextXid 723 latestCompletedXid 722 oldestRunningXid 723
rmgr: Heap        len (rec/tot):    135/   135, tx:        723, lsn: 0/05006A40, prev 0/05006A08, desc: DELETE off 2 KEYS_UPDATED , blkref #0: rel 1663/16384/16446 blk 0
rmgr: Transaction len (rec/tot):     46/    46, tx:        723, lsn: 0/05006AC8, prev 0/05006A40, desc: COMMIT 2022-12-06 12:43:23.704267 KST
rmgr: Standby     len (rec/tot):     50/    50, tx:          0, lsn: 0/05006AF8, prev 0/05006AC8, desc: RUNNING_XACTS nextXid 724 latestCompletedXid 723 oldestRunningXid 724
rmgr: Heap        len (rec/tot):    135/   135, tx:        724, lsn: 0/05006B30, prev 0/05006AF8, desc: DELETE off 12 KEYS_UPDATED , blkref #0: rel 1663/16384/16446 blk 0
rmgr: Transaction len (rec/tot):     46/    46, tx:        724, lsn: 0/05006BB8, prev 0/05006B30, desc: COMMIT 2022-12-06 12:43:48.426760 KST
rmgr: Standby     len (rec/tot):     50/    50, tx:          0, lsn: 0/05006BE8, prev 0/05006BB8, desc: RUNNING_XACTS nextXid 725 latestCompletedXid 724 oldestRunningXid 725
rmgr: Heap        len (rec/tot):     64/    64, tx:        725, lsn: 0/05006C20, prev 0/05006BE8, desc: DELETE off 2 KEYS_UPDATED , blkref #0: rel 1663/16384/16451 blk 0
rmgr: Transaction len (rec/tot):     46/    46, tx:        725, lsn: 0/05006C60, prev 0/05006C20, desc: COMMIT 2022-12-06 12:44:14.036951 KST
rmgr: Standby     len (rec/tot):     50/    50, tx:          0, lsn: 0/05006C90, prev 0/05006C60, desc: RUNNING_XACTS nextXid 726 latestCompletedXid 725 oldestRunningXid 726
rmgr: Heap        len (rec/tot):     64/    64, tx:        726, lsn: 0/05006CC8, prev 0/05006C90, desc: DELETE off 12 KEYS_UPDATED , blkref #0: rel 1663/16384/16451 blk 0
rmgr: Transaction len (rec/tot):     46/    46, tx:        726, lsn: 0/05006D08, prev 0/05006CC8, desc: COMMIT 2022-12-06 12:44:34.113441 KST
rmgr: Standby     len (rec/tot):     50/    50, tx:          0, lsn: 0/05006D38, prev 0/05006D08, desc: RUNNING_XACTS nextXid 727 latestCompletedXid 726 oldestRunningXid 727
rmgr: Standby     len (rec/tot):     50/    50, tx:          0, lsn: 0/05006D70, prev 0/05006D38, desc: RUNNING_XACTS nextXid 727 latestCompletedXid 726 oldestRunningXid 727
rmgr: XLOG        len (rec/tot):    106/   106, tx:          0, lsn: 0/05006DA8, prev 0/05006D70, desc: CHECKPOINT_ONLINE redo 0/5006D70; tli 1; prev tli 1; fpw true; xid 0:727; oid 24595; multi 1; offset 0; oldest xid 561 in DB 1; oldest multi 1 in DB 1; oldest/newest commit timestamp xid: 0/0; oldest running xid 727; online
rmgr: Standby     len (rec/tot):     42/    42, tx:        727, lsn: 0/05006E18, prev 0/05006DA8, desc: LOCK xid 727 db 16384 rel 16446
rmgr: Storage     len (rec/tot):     42/    42, tx:        727, lsn: 0/05006E48, prev 0/05006E18, desc: CREATE base/16384/16456
rmgr: Heap2       len (rec/tot):     60/    60, tx:        727, lsn: 0/05006E78, prev 0/05006E48, desc: NEW_CID rel 1663/16384/1259; tid 4/36; cmin: 4294967295, cmax: 0, combo: 4294967295
rmgr: Heap2       len (rec/tot):     60/    60, tx:        727, lsn: 0/05006EB8, prev 0/05006E78, desc: NEW_CID rel 1663/16384/1259; tid 4/37; cmin: 0, cmax: 4294967295, combo: 4294967295
rmgr: Heap        len (rec/tot):     65/  6793, tx:        727, lsn: 0/05006EF8, prev 0/05006EB8, desc: UPDATE off 36 xmax 727 ; new off 37 xmax 0, blkref #0: rel 1663/16384/1259 blk 4 FPW
rmgr: Btree       len (rec/tot):     53/  2473, tx:        727, lsn: 0/050089A0, prev 0/05006EF8, desc: INSERT_LEAF off 115, blkref #0: rel 1663/16384/2662 blk 2 FPW
rmgr: Btree       len (rec/tot):     53/  3321, tx:        727, lsn: 0/05009350, prev 0/050089A0, desc: INSERT_LEAF off 67, blkref #0: rel 1663/16384/2663 blk 2 FPW
rmgr: Btree       len (rec/tot):     53/  4093, tx:        727, lsn: 0/0500A068, prev 0/05009350, desc: INSERT_LEAF off 196, blkref #0: rel 1663/16384/3455 blk 4 FPW
rmgr: Standby     len (rec/tot):     42/    42, tx:        727, lsn: 0/0500B068, prev 0/0500A068, desc: LOCK xid 727 db 16384 rel 16449
rmgr: Storage     len (rec/tot):     42/    42, tx:        727, lsn: 0/0500B098, prev 0/0500B068, desc: CREATE base/16384/16457
rmgr: Heap2       len (rec/tot):     60/    60, tx:        727, lsn: 0/0500B0C8, prev 0/0500B098, desc: NEW_CID rel 1663/16384/1259; tid 4/33; cmin: 4294967295, cmax: 1, combo: 4294967295
rmgr: Heap2       len (rec/tot):     60/    60, tx:        727, lsn: 0/0500B108, prev 0/0500B0C8, desc: NEW_CID rel 1663/16384/1259; tid 4/38; cmin: 1, cmax: 4294967295, combo: 4294967295
rmgr: Heap        len (rec/tot):     87/    87, tx:        727, lsn: 0/0500B148, prev 0/0500B108, desc: UPDATE off 33 xmax 727 ; new off 38 xmax 0, blkref #0: rel 1663/16384/1259 blk 4
rmgr: Btree       len (rec/tot):     64/    64, tx:        727, lsn: 0/0500B1A0, prev 0/0500B148, desc: INSERT_LEAF off 117, blkref #0: rel 1663/16384/2662 blk 2
rmgr: Btree       len (rec/tot):     72/    72, tx:        727, lsn: 0/0500B1E0, prev 0/0500B1A0, desc: INSERT_LEAF off 76, blkref #0: rel 1663/16384/2663 blk 2
rmgr: Btree       len (rec/tot):     64/    64, tx:        727, lsn: 0/0500B228, prev 0/0500B1E0, desc: INSERT_LEAF off 197, blkref #0: rel 1663/16384/3455 blk 4
rmgr: XLOG        len (rec/tot):     49/   129, tx:        727, lsn: 0/0500B268, prev 0/0500B228, desc: FPI , blkref #0: rel 1663/16384/16457 blk 0 FPW
rmgr: Heap        len (rec/tot):    188/   188, tx:        727, lsn: 0/0500B2F0, prev 0/0500B268, desc: INPLACE off 38, blkref #0: rel 1663/16384/1259 blk 4
rmgr: Heap        len (rec/tot):     42/    42, tx:        727, lsn: 0/0500B3B0, prev 0/0500B2F0, desc: TRUNCATE nrelids 1 relids 16446
rmgr: Transaction len (rec/tot):    238/   238, tx:        727, lsn: 0/0500B3E0, prev 0/0500B3B0, desc: COMMIT 2022-12-06 12:45:01.372832 KST; rels: base/16384/16449 base/16384/16446; inval msgs: catcache 50 catcache 49 catcache 50 catcache 49 catcache 50 catcache 49 relcache 16446 relcache 16449 relcache 16449 relcache 16446
rmgr: Transaction len (rec/tot):     46/    46, tx:        728, lsn: 0/0500B4D0, prev 0/0500B3E0, desc: COMMIT 2022-12-06 12:45:01.600092 KST
rmgr: Transaction len (rec/tot):     46/    46, tx:        729, lsn: 0/0500B500, prev 0/0500B4D0, desc: COMMIT 2022-12-06 12:45:01.709775 KST
rmgr: Standby     len (rec/tot):     50/    50, tx:          0, lsn: 0/0500B530, prev 0/0500B500, desc: RUNNING_XACTS nextXid 730 latestCompletedXid 729 oldestRunningXid 730
rmgr: Standby     len (rec/tot):     42/    42, tx:        730, lsn: 0/0500B568, prev 0/0500B530, desc: LOCK xid 730 db 16384 rel 16451
rmgr: Storage     len (rec/tot):     42/    42, tx:        730, lsn: 0/0500B598, prev 0/0500B568, desc: CREATE base/16384/16458
rmgr: Heap2       len (rec/tot):     60/    60, tx:        730, lsn: 0/0500B5C8, prev 0/0500B598, desc: NEW_CID rel 1663/16384/1259; tid 4/34; cmin: 4294967295, cmax: 0, combo: 4294967295
rmgr: Heap2       len (rec/tot):     60/    60, tx:        730, lsn: 0/0500B608, prev 0/0500B5C8, desc: NEW_CID rel 1663/16384/1259; tid 4/39; cmin: 0, cmax: 4294967295, combo: 4294967295
rmgr: Heap        len (rec/tot):    127/   127, tx:        730, lsn: 0/0500B648, prev 0/0500B608, desc: UPDATE off 34 xmax 730 ; new off 39 xmax 0, blkref #0: rel 1663/16384/1259 blk 4
rmgr: Btree       len (rec/tot):     64/    64, tx:        730, lsn: 0/0500B6C8, prev 0/0500B648, desc: INSERT_LEAF off 119, blkref #0: rel 1663/16384/2662 blk 2
rmgr: Btree       len (rec/tot):     72/    72, tx:        730, lsn: 0/0500B708, prev 0/0500B6C8, desc: INSERT_LEAF off 51, blkref #0: rel 1663/16384/2663 blk 2
rmgr: Btree       len (rec/tot):     64/    64, tx:        730, lsn: 0/0500B750, prev 0/0500B708, desc: INSERT_LEAF off 198, blkref #0: rel 1663/16384/3455 blk 4
rmgr: Standby     len (rec/tot):     42/    42, tx:        730, lsn: 0/0500B790, prev 0/0500B750, desc: LOCK xid 730 db 16384 rel 16454
rmgr: Storage     len (rec/tot):     42/    42, tx:        730, lsn: 0/0500B7C0, prev 0/0500B790, desc: CREATE base/16384/16459
rmgr: Heap2       len (rec/tot):     60/    60, tx:        730, lsn: 0/0500B7F0, prev 0/0500B7C0, desc: NEW_CID rel 1663/16384/1259; tid 4/35; cmin: 4294967295, cmax: 1, combo: 4294967295
rmgr: Heap2       len (rec/tot):     60/    60, tx:        730, lsn: 0/0500B830, prev 0/0500B7F0, desc: NEW_CID rel 1663/16384/1259; tid 4/40; cmin: 1, cmax: 4294967295, combo: 4294967295
rmgr: Heap        len (rec/tot):     87/    87, tx:        730, lsn: 0/0500B870, prev 0/0500B830, desc: UPDATE off 35 xmax 730 ; new off 40 xmax 0, blkref #0: rel 1663/16384/1259 blk 4
rmgr: Btree       len (rec/tot):     64/    64, tx:        730, lsn: 0/0500B8C8, prev 0/0500B870, desc: INSERT_LEAF off 121, blkref #0: rel 1663/16384/2662 blk 2
rmgr: Btree       len (rec/tot):     72/    72, tx:        730, lsn: 0/0500B908, prev 0/0500B8C8, desc: INSERT_LEAF off 60, blkref #0: rel 1663/16384/2663 blk 2
rmgr: Btree       len (rec/tot):     64/    64, tx:        730, lsn: 0/0500B950, prev 0/0500B908, desc: INSERT_LEAF off 199, blkref #0: rel 1663/16384/3455 blk 4
rmgr: XLOG        len (rec/tot):     49/   129, tx:        730, lsn: 0/0500B990, prev 0/0500B950, desc: FPI , blkref #0: rel 1663/16384/16459 blk 0 FPW
rmgr: Heap        len (rec/tot):    188/   188, tx:        730, lsn: 0/0500BA18, prev 0/0500B990, desc: INPLACE off 40, blkref #0: rel 1663/16384/1259 blk 4
rmgr: Heap        len (rec/tot):     42/    42, tx:        730, lsn: 0/0500BAD8, prev 0/0500BA18, desc: TRUNCATE nrelids 1 relids 16451
rmgr: Transaction len (rec/tot):    238/   238, tx:        730, lsn: 0/0500BB08, prev 0/0500BAD8, desc: COMMIT 2022-12-06 12:45:51.403127 KST; rels: base/16384/16454 base/16384/16451; inval msgs: catcache 50 catcache 49 catcache 50 catcache 49 catcache 50 catcache 49 relcache 16451 relcache 16454 relcache 16454 relcache 16451
rmgr: Transaction len (rec/tot):     46/    46, tx:        731, lsn: 0/0500BBF8, prev 0/0500BB08, desc: COMMIT 2022-12-06 12:45:51.623183 KST
rmgr: Transaction len (rec/tot):     46/    46, tx:        732, lsn: 0/0500BC28, prev 0/0500BBF8, desc: COMMIT 2022-12-06 12:45:51.724673 KST
rmgr: Standby     len (rec/tot):     50/    50, tx:          0, lsn: 0/0500BC58, prev 0/0500BC28, desc: RUNNING_XACTS nextXid 733 latestCompletedXid 732 oldestRunningXid 733
rmgr: Standby     len (rec/tot):     50/    50, tx:          0, lsn: 0/0500BC90, prev 0/0500BC58, desc: RUNNING_XACTS nextXid 733 latestCompletedXid 732 oldestRunningXid 733
rmgr: XLOG        len (rec/tot):    106/   106, tx:          0, lsn: 0/0500BCC8, prev 0/0500BC90, desc: CHECKPOINT_ONLINE redo 0/500BC90; tli 1; prev tli 1; fpw true; xid 0:733; oid 24595; multi 1; offset 0; oldest xid 561 in DB 1; oldest multi 1 in DB 1; oldest/newest commit timestamp xid: 0/0; oldest running xid 733; online
rmgr: Standby     len (rec/tot):     50/    50, tx:          0, lsn: 0/0500BD38, prev 0/0500BCC8, desc: RUNNING_XACTS nextXid 733 latestCompletedXid 732 oldestRunningXid 733
```

## MetaData

### TEST_F(Replica Identity FULL)

```
Logdump 362 >n
TokenID x47 'G' Record Header    Info x01  Length  314
TokenID x48 'H' GHDR             Info x00  Length   46
 4500 0041 fc00 aa02 5be6 2dd5 5315 f302 a01f 0005 | E..A....[.-.S.......
 0000 0000 0100 0100 0352 0000 0001 0000 0000 0000 | .........R..........
 0000 0000 0000                                    | ......
TokenID x44 'D' Data             Info x00  Length  252
TokenID x5a 'Z' Record Trailer   Info x01  Length  314
___________________________________________________________________
Hdr-Ind    :     E  (x45)     Partition  :     .  (x00)
UndoFlag   :     .  (x00)     BeforeAfter:     A  (x41)
RecLength  :   252  (x00fc)   IO Time    : 2022/12/06 12:26:59.569.243
IOType     :   170  (xaa)     OrigNode   :     2  (x02)
TransInd   :     .  (x03)     FormatType :     R  (x52)
SyskeyLen  :     0  (x00)     Incomplete :     .  (x00)
DDR/TDR index:   (001, 001)     AuditPos   : 83894176
Continued  :     N  (x00)     RecCount   :     1  (x01)

2022/12/06 12:26:59.569.243 Metadata             Len 252 RBA 1526
Table Name: test.test_f
*
 1)Name          2)Data Type        3)External Length  4)Fetch Offset      5)Scale         6)Level
 7)Null          8)Bump if Odd      9)Internal Length 10)Binary Length    11)Table Length 12)Most Sig DT
13)Least Sig DT 14)High Precision  15)Low Precision   16)Elementary Item  17)Occurs       18)Key Column
19)Sub DataType 20)Native DataType 21)Character Set   22)Character Length 23)LOB Type     24)Partial Type
25)Remarks
*
TDR version: 11
Definition for table test.test_f
Record Length: 350
Columns: 4
int      134     23        0  0  0 0 0      8      8      8 0 0 0 0 1    0 1   0    4       -1      0 0 0
varchar   64    150       11  0  0 1 0    150    150      0 0 0 0 0 1    0 0   0   12       -1     50 0 0
time     192     26      166  6  0 1 0     26     26     26 0 6 0 0 1    0 0   0   11       -1      0 0 0
char      64    150      195  0  0 1 0    150    150      0 0 0 0 0 1    0 0   5    1        0     50 0 0
End of definition
```

### TEST_D(Replica Identity DEFAULT)

```
Logdump 374 >n
TokenID x47 'G' Record Header    Info x01  Length   58
TokenID x48 'H' GHDR             Info x00  Length   46
 4500 0041 0000 aa03 4a91 15e9 5315 f302 a01f 0005 | E..A....J...S.......
 0000 0000 0100 0100 0352 0000 0001 0000 0000 0000 | .........R..........
 0000 0000 0000                                    | ......
TokenID x5a 'Z' Record Trailer   Info x01  Length   58
___________________________________________________________________
Hdr-Ind    :     E  (x45)     Partition  :     .  (x00)
UndoFlag   :     .  (x00)     BeforeAfter:     A  (x41)
RecLength  :     0  (x0000)   IO Time    : 2022/12/06 12:32:33.518.922
IOType     :   170  (xaa)     OrigNode   :     3  (x03)
TransInd   :     .  (x03)     FormatType :     R  (x52)
SyskeyLen  :     0  (x00)     Incomplete :     .  (x00)
DDR/TDR index:   (001, 001)     AuditPos   : 83894176
Continued  :     N  (x00)     RecCount   :     1  (x01)

2022/12/06 12:32:33.518.922 Metadata             Len 0 RBA 3597
Table Name: test.test_d (Ref TDR Index: 1)
```

## Insert

### TEST_F

```
Logdump 363 >n
TokenID x47 'G' Record Header    Info x01  Length  208
TokenID x48 'H' GHDR             Info x00  Length   36
 450c 0041 7800 05ff 6130 2dd5 5315 f302 a01f 0005 | E..Ax...a0-.S.......
 0000 0000 0000 0000 0052 0000 0001 0000           | .........R......
TokenID x44 'D' Data             Info x00  Length  120
TokenID x54 'T' GGS Tokens       Info x00  Length   32
TokenID x5a 'Z' Record Trailer   Info x01  Length  208
___________________________________________________________________
Hdr-Ind    :     E  (x45)     Partition  :     .  (x0c)
UndoFlag   :     .  (x00)     BeforeAfter:     A  (x41)
RecLength  :   120  (x0078)   IO Time    : 2022/12/06 12:26:59.522.657
IOType     :     5  (x05)     OrigNode   :   255  (xff)
TransInd   :     .  (x00)     FormatType :     R  (x52)
SyskeyLen  :     0  (x00)     Incomplete :     .  (x00)
AuditRBA   :          0       AuditPos   : 83894176
Continued  :     N  (x00)     RecCount   :     1  (x01)

2022/12/06 12:26:59.522.657 Insert               Len   120 RBA 1840
Name: test.test_f  (TDR Index: 1)
After  Image:                                             Partition x0c   G  b
 0000 0a00 0000 0000 0000 0000 0001 0100 0c00 0000 | ....................
 0800 3176 6172 6368 6172 0200 1c00 0000 3139 3939 | ..1varchar......1999
 2d31 322d 3331 3a30 303a 3030 3a30 302e 3030 3030 | -12-31:00:00:00.0000
 3030 0300 3600 0000 3200 3163 6861 7220 2020 2020 | 00..6...2.1char
 2020 2020 2020 2020 2020 2020 2020 2020 2020 2020 |
 2020 2020 2020 2020 2020 2020 2020 2020 2020 2020 |
Column 0 (0x0000), Length 10 (0x000a).
 0000 0000 0000 0000 0001                          | ..........
Column 1 (0x0001), Length 12 (0x000c).
 0000 0800 3176 6172 6368 6172                     | ....1varchar
Column 2 (0x0002), Length 28 (0x001c).
 0000 3139 3939 2d31 322d 3331 3a30 303a 3030 3a30 | ..1999-12-31:00:00:0
 302e 3030 3030 3030                               | 0.000000
Column 3 (0x0003), Length 54 (0x0036).
 0000 3200 3163 6861 7220 2020 2020 2020 2020 2020 | ..2.1char
 2020 2020 2020 2020 2020 2020 2020 2020 2020 2020 |
 2020 2020 2020 2020 2020 2020 2020                |

GGS tokens:
TokenID x74 't' ORATAG           Info x01  Length    0
TokenID x4c 'L' LOGCSN           Info x00  Length   17
 3030 3030 3030 3030 2f30 3530 3032 3831 38        | 00000000/05002818
TokenID x36 '6' TRANID           Info x00  Length    3
 3731 37                                           | 717
```

- WAL
  
    ```
    00001fa0h: 82 00 00 00 CD 02 00 00 40 01 00 05 00 00 00 00 ; ?...?...@.......
    00001fb0h: 80 0A 00 00 50 AD 90 6C 00 60 51 00 7F 06 00 00 ; ...P춴l.`Q....
    00001fc0h: 00 40 00 00 3E 40 00 00 00 00 00 00 FF 03 04 00 ; .@..>@.........
    00001fd0h: 02 08 18 00 01 00 00 00 13 31 76 61 72 63 68 61 ; .........1varcha
    00001fe0h: 72 00 00 00 00 A0 28 E2 EB FF FF FF 67 31 63 68 ; r....?(瞬g1ch
    00001ff0h: 61 72 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ; ar              
    00002000h: 98 D0 05 00 01 00 00 00 00 20 00 05 00 00 00 00 ; 샫....... ......
    00002010h: 22 00 00 00 00 00 00 00 20 20 20 20 20 20 20 20 ; ".......        
    00002020h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ;                 
    00002030h: 20 20 20 20 20 20 20 01 00 08                   ;        ...
    
    XLogRecord: tot_len xid prev info rmid crc
    XLogRecordDataHeaderShort: id data_len
    ```
    

### TEST_D

```
Logdump 375 >n
TokenID x47 'G' Record Header    Info x01  Length  204
TokenID x48 'H' GHDR             Info x00  Length   36
 450c 0041 7800 05ff 4d40 07e9 5315 f302 3847 0005 | E..Ax...M@..S...8G..
 0000 0000 0000 0000 0052 0000 0001 0000           | .........R......
TokenID x44 'D' Data             Info x00  Length  120
TokenID x54 'T' GGS Tokens       Info x00  Length   28
TokenID x5a 'Z' Record Trailer   Info x01  Length  204
___________________________________________________________________
Hdr-Ind    :     E  (x45)     Partition  :     .  (x0c)
UndoFlag   :     .  (x00)     BeforeAfter:     A  (x41)
RecLength  :   120  (x0078)   IO Time    : 2022/12/06 12:32:32.580.685
IOType     :     5  (x05)     OrigNode   :   255  (xff)
TransInd   :     .  (x00)     FormatType :     R  (x52)
SyskeyLen  :     0  (x00)     Incomplete :     .  (x00)
AuditRBA   :          0       AuditPos   : 83904312
Continued  :     N  (x00)     RecCount   :     1  (x01)

2022/12/06 12:32:32.580.685 Insert               Len   120 RBA 3655
Name: test.test_d  (TDR Index: 2)
After  Image:                                             Partition x0c   G  b
 0000 0a00 0000 0000 0000 0000 0001 0100 0c00 0000 | ....................
 0800 7661 7263 6861 7231 0200 1c00 0000 3230 3030 | ..varchar1......2000
 2d30 312d 3031 3a30 303a 3030 3a30 302e 3030 3030 | -01-01:00:00:00.0000
 3030 0300 3600 0000 3200 6368 6172 3120 2020 2020 | 00..6...2.char1
 2020 2020 2020 2020 2020 2020 2020 2020 2020 2020 |
 2020 2020 2020 2020 2020 2020 2020 2020 2020 2020 |
Column 0 (0x0000), Length 10 (0x000a).
 0000 0000 0000 0000 0001                          | ..........
Column 1 (0x0001), Length 12 (0x000c).
 0000 0800 7661 7263 6861 7231                     | ....varchar1
Column 2 (0x0002), Length 28 (0x001c).
 0000 3230 3030 2d30 312d 3031 3a30 303a 3030 3a30 | ..2000-01-01:00:00:0
 302e 3030 3030 3030                               | 0.000000
Column 3 (0x0003), Length 54 (0x0036).
 0000 3200 6368 6172 3120 2020 2020 2020 2020 2020 | ..2.char1
 2020 2020 2020 2020 2020 2020 2020 2020 2020 2020 |
 2020 2020 2020 2020 2020 2020 2020                |

GGS tokens:
TokenID x4c 'L' LOGCSN           Info x00  Length   17
 3030 3030 3030 3030 2f30 3530 3034 4644 30        | 00000000/05004FD0
TokenID x36 '6' TRANID           Info x00  Length    3
 3731 38                                           | 718
```

- WAL
  
    ```
    00004738h: 82 00 00 00 CE 02 00 00 30 29 00 05 00 00 00 00 ; ?...?...0)......
    00004748h: 80 0A 00 00 BE 75 D5 AF 00 60 51 00 7F 06 00 00 ; ...푫亂.`Q....
    00004758h: 00 40 00 00 43 40 00 00 00 00 00 00 FF 03 04 00 ; .@..C@.........
    00004768h: 02 08 18 00 01 00 00 00 13 76 61 72 63 68 61 72 ; .........varchar
    00004778h: 31 00 00 00 00 00 00 00 00 00 00 00 67 63 68 61 ; 1...........gcha
    00004788h: 72 31 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ; r1              
    00004798h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ;                 
    000047a8h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 01 ;                .
    000047b8h: 00 08                                           ; ..
    
    XLogRecord: tot_len xid prev info rmid crc
    XLogRecordDataHeaderShort: id data_len
    ```
    

## UPDATE

### TEST_F

**WHERE PK**

```
Logdump 386 >n
TokenID x47 'G' Record Header    Info x01  Length  113
TokenID x48 'H' GHDR             Info x00  Length   36
 450c 0041 1d00 0fff 352b deff 5315 f302 e850 0005 | E..A....5+..S....P..
 0000 0000 0000 0000 0352 0000 0001 0000           | .........R......
TokenID x44 'D' Data             Info x00  Length   29
TokenID x54 'T' GGS Tokens       Info x00  Length   28
TokenID x5a 'Z' Record Trailer   Info x01  Length  113
___________________________________________________________________
Hdr-Ind    :     E  (x45)     Partition  :     .  (x0c)
UndoFlag   :     .  (x00)     BeforeAfter:     A  (x41)
RecLength  :    29  (x001d)   IO Time    : 2022/12/06 12:38:55.764.277
IOType     :    15  (x0f)     OrigNode   :   255  (xff)
TransInd   :     .  (x03)     FormatType :     R  (x52)
SyskeyLen  :     0  (x00)     Incomplete :     .  (x00)
AuditRBA   :          0       AuditPos   : 83906792
Continued  :     N  (x00)     RecCount   :     1  (x01)

2022/12/06 12:38:55.764.277 FieldComp            Len    29 RBA 5408
Name: test.test_f  (TDR Index: 1)
After  Image:                                             Partition x0c   G  s
 0000 0a00 0000 0000 0000 0000 0001 0100 0b00 0000 | ....................
 0700 7465 7374 696e 67                            | ..testing
Column 0 (0x0000), Length 10 (0x000a).
 0000 0000 0000 0000 0001                          | ..........
Column 1 (0x0001), Length 11 (0x000b).
 0000 0700 7465 7374 696e 67                       | ....testing

GGS tokens:
TokenID x4c 'L' LOGCSN           Info x00  Length   17
 3030 3030 3030 3030 2f30 3530 3035 3642 38        | 00000000/050056B8
TokenID x36 '6' TRANID           Info x00  Length    3
 3731 39                                           | 719
```

- WAL
  
    ```
    000050e8h: 9F 05 00 00 CF 02 00 00 B0 50 00 05 00 00 00 00 ; ?...?...캰......
    000050f8h: 40 0A 00 00 5F 4C 61 8F 00 30 51 00 BC 04 44 00 ; @..._La?.0Q.?.D.
    00005108h: 05 7F 06 00 00 00 40 00 00 3E 40 00 00 00 00 00 ; .....@..>@.....
    00005118h: 00 FF 5F 00 00 00 00 A8 27 00 05 00 00 00 00 44 ; ._....?'......D
    00005128h: 00 88 1B 00 20 04 20 CF 02 00 00 98 9F C6 00 30 ; .?.. . ?...삜?.0
    00005138h: 9F C6 00 C8 9E C6 00 60 9E C6 00 F8 9D C6 00 90 ; 읝.???.`왚.???.?
    00005148h: 9D C6 00 28 9D C6 00 C0 9C C6 00 58 9C C6 00 F0 ; 씶.(씶.핞?.X쑪.?
    00005158h: 9B C6 00 88 9B C6 00 CF 02 00 00 00 00 00 00 00 ; 쎟.닗?.?........
    00005168h: 00 00 00 00 00 00 00 0B 00 04 80 02 28 18 00 01 ; ...........(...
    00005178h: 00 00 00 11 74 65 73 74 69 6E 67 00 00 00 00 00 ; ....testing.....
    00005188h: A0 28 E2 EB FF FF FF 67 31 63 68 61 72 20 20 20 ; ?(瞬g1char   
    00005198h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ;                 
    000051a8h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ;                 
    000051b8h: 20 20 20 20 20 20 20 20 20 20 00 00 00 00 00 CD ;           .....?
    000051c8h: 02 00 00 00 00 00 00 09 00 00 00 00 00 00 00 0A ; ................
    000051d8h: 00 04 00 02 08 18 00 0A 00 00 00 15 31 30 76 61 ; ............10va
    000051e8h: 72 63 68 61 72 00 00 00 A0 28 E2 EB FF FF FF 67 ; rchar...?(瞬g
    000051f8h: 31 30 63 68 61 72 20 20 20 20 20 20 20 20 20 20 ; 10char          
    00005208h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ;                 
    00005218h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ;                 
    00005228h: 20 20 00 00 00 00 00 CD 02 00 00 00 00 00 00 08 ;   .....?........
    00005238h: 00 00 00 00 00 00 00 09 00 04 00 02 08 18 00 09 ; ................
    00005248h: 00 00 00 13 39 76 61 72 63 68 61 72 00 00 00 00 ; ....9varchar....
    00005258h: A0 28 E2 EB FF FF FF 67 39 63 68 61 72 20 20 20 ; ?(瞬g9char   
    00005268h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ;                 
    00005278h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ;                 
    00005288h: 20 20 20 20 20 20 20 20 20 20 00 00 00 00 00 CD ;           .....?
    00005298h: 02 00 00 00 00 00 00 07 00 00 00 00 00 00 00 08 ; ................
    000052a8h: 00 04 00 02 08 18 00 08 00 00 00 13 38 76 61 72 ; ............8var
    000052b8h: 63 68 61 72 00 00 00 00 A0 28 E2 EB FF FF FF 67 ; char....?(瞬g
    000052c8h: 38 63 68 61 72 20 20 20 20 20 20 20 20 20 20 20 ; 8char           
    000052d8h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ;                 
    000052e8h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ;                 
    000052f8h: 20 20 00 00 00 00 00 CD 02 00 00 00 00 00 00 06 ;   .....?........
    00005308h: 00 00 00 00 00 00 00 07 00 04 00 02 08 18 00 07 ; ................
    00005318h: 00 00 00 13 37 76 61 72 63 68 61 72 00 00 00 00 ; ....7varchar....
    00005328h: A0 28 E2 EB FF FF FF 67 37 63 68 61 72 20 20 20 ; ?(瞬g7char   
    00005338h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ;                 
    00005348h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ;                 
    00005358h: 20 20 20 20 20 20 20 20 20 20 00 00 00 00 00 CD ;           .....?
    00005368h: 02 00 00 00 00 00 00 05 00 00 00 00 00 00 00 06 ; ................
    00005378h: 00 04 00 02 08 18 00 06 00 00 00 13 36 76 61 72 ; ............6var
    00005388h: 63 68 61 72 00 00 00 00 A0 28 E2 EB FF FF FF 67 ; char....?(瞬g
    00005398h: 36 63 68 61 72 20 20 20 20 20 20 20 20 20 20 20 ; 6char           
    000053a8h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ;                 
    000053b8h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ;                 
    000053c8h: 20 20 00 00 00 00 00 CD 02 00 00 00 00 00 00 04 ;   .....?........
    000053d8h: 00 00 00 00 00 00 00 05 00 04 00 02 08 18 00 05 ; ................
    000053e8h: 00 00 00 13 35 76 61 72 63 68 61 72 00 00 00 00 ; ....5varchar....
    000053f8h: A0 28 E2 EB FF FF FF 67 35 63 68 61 72 20 20 20 ; ?(瞬g5char   
    00005408h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ;                 
    00005418h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ;                 
    00005428h: 20 20 20 20 20 20 20 20 20 20 00 00 00 00 00 CD ;           .....?
    00005438h: 02 00 00 00 00 00 00 03 00 00 00 00 00 00 00 04 ; ................
    00005448h: 00 04 00 02 08 18 00 04 00 00 00 13 34 76 61 72 ; ............4var
    00005458h: 63 68 61 72 00 00 00 00 A0 28 E2 EB FF FF FF 67 ; char....?(瞬g
    00005468h: 34 63 68 61 72 20 20 20 20 20 20 20 20 20 20 20 ; 4char           
    00005478h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ;                 
    00005488h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ;                 
    00005498h: 20 20 00 00 00 00 00 CD 02 00 00 00 00 00 00 02 ;   .....?........
    000054a8h: 00 00 00 00 00 00 00 03 00 04 00 02 08 18 00 03 ; ................
    000054b8h: 00 00 00 13 33 76 61 72 63 68 61 72 00 00 00 00 ; ....3varchar....
    000054c8h: A0 28 E2 EB FF FF FF 67 33 63 68 61 72 20 20 20 ; ?(瞬g3char   
    000054d8h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ;                 
    000054e8h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ;                 
    000054f8h: 20 20 20 20 20 20 20 20 20 20 00 00 00 00 00 CD ;           .....?
    00005508h: 02 00 00 00 00 00 00 01 00 00 00 00 00 00 00 02 ; ................
    00005518h: 00 04 00 02 08 18 00 02 00 00 00 13 32 76 61 72 ; ............2var
    00005528h: 63 68 61 72 00 00 00 00 A0 28 E2 EB FF FF FF 67 ; char....?(瞬g
    00005538h: 32 63 68 61 72 20 20 20 20 20 20 20 20 20 20 20 ; 2char           
    00005548h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ;                 
    00005558h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ;                 
    00005568h: 20 20 00 00 00 00 00 CD 02 00 00 CF 02 00 00 00 ;   .....?...?....
    00005578h: 00 00 00 00 00 00 00 0B 00 04 40 02 01 18 00 01 ; ..........@.....
    00005588h: 00 00 00 13 31 76 61 72 63 68 61 72 00 00 00 00 ; ....1varchar....
    00005598h: A0 28 E2 EB FF FF FF 67 31 63 68 61 72 20 20 20 ; ?(瞬g1char   
    000055a8h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ;                 
    000055b8h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ;                 
    000055c8h: 20 20 20 20 20 20 20 20 20 20 00 00 00 00 00 04 ;           ......
    000055d8h: 80 02 28 18 00 01 00 00 00 11 74 65 73 74 69 6E ; .(.......testin
    000055e8h: 67 00 00 00 00 00 A0 28 E2 EB FF FF FF 67 31 63 ; g.....?(瞬g1c
    000055f8h: 68 61 72 20 20 20 20 20 20 20 20 20 20 20 20 20 ; har             
    00005608h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ;                 
    00005618h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ;                 
    00005628h: CF 02 00 00 01 00 00 14 00 00 00 00 0B 00 04 40 ; ?..............@
    00005638h: 02 01 18 00 01 00 00 00 13 31 76 61 72 63 68 61 ; .........1varcha
    00005648h: 72 00 00 00 00 A0 28 E2 EB FF FF FF 67 31 63 68 ; r....?(瞬g1ch
    00005658h: 61 72 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ; ar              
    00005668h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ;                 
    00005678h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20    ;
    
    XLogRecord: tot_len xid prev info rmid crc
    XLogRecordDataHeaderShort: id data_len
    ```
    

**WHERE !PK**

```
Logdump 389 >n
TokenID x47 'G' Record Header    Info x01  Length  156
TokenID x48 'H' GHDR             Info x00  Length   36
 450c 0041 4800 0fff 95e9 cc06 5415 f302 885d 0005 | E..AH.......T....]..
 0000 0000 0000 0000 0352 0000 0001 0000           | .........R......
TokenID x44 'D' Data             Info x00  Length   72
TokenID x54 'T' GGS Tokens       Info x00  Length   28
TokenID x5a 'Z' Record Trailer   Info x01  Length  156
___________________________________________________________________
Hdr-Ind    :     E  (x45)     Partition  :     .  (x0c)
UndoFlag   :     .  (x00)     BeforeAfter:     A  (x41)
RecLength  :    72  (x0048)   IO Time    : 2022/12/06 12:40:52.073.877
IOType     :    15  (x0f)     OrigNode   :   255  (xff)
TransInd   :     .  (x03)     FormatType :     R  (x52)
SyskeyLen  :     0  (x00)     Incomplete :     .  (x00)
AuditRBA   :          0       AuditPos   : 83910024
Continued  :     N  (x00)     RecCount   :     1  (x01)

2022/12/06 12:40:52.073.877 FieldComp            Len    72 RBA 5724
Name: test.test_f  (TDR Index: 1)
After  Image:                                             Partition x0c   G  s
 0000 0a00 0000 0000 0000 0000 0001 0300 3600 0000 | ................6...
 3200 2174 6573 7421 2020 2020 2020 2020 2020 2020 | 2.!test!
 2020 2020 2020 2020 2020 2020 2020 2020 2020 2020 |
 2020 2020 2020 2020 2020 2020                     |
Column 0 (0x0000), Length 10 (0x000a).
 0000 0000 0000 0000 0001                          | ..........
Column 3 (0x0003), Length 54 (0x0036).
 0000 3200 2174 6573 7421 2020 2020 2020 2020 2020 | ..2.!test!
 2020 2020 2020 2020 2020 2020 2020 2020 2020 2020 |
 2020 2020 2020 2020 2020 2020 2020                |

GGS tokens:
TokenID x4c 'L' LOGCSN           Info x00  Length   17
 3030 3030 3030 3030 2f30 3530 3036 3345 30        | 00000000/050063E0
TokenID x36 '6' TRANID           Info x00  Length    3
 3732 31                                           | 721
```

- WAL
  
    ```
    00005d88h: 0B 06 00 00 D1 02 00 00 50 5D 00 05 00 00 00 00 ; ....?...P]......
    00005d98h: 40 0A 00 00 C6 78 F8 10 00 30 51 00 28 05 48 00 ; @...???..0Q.(.H.
    00005da8h: 05 7F 06 00 00 00 40 00 00 3E 40 00 00 00 00 00 ; .....@..>@.....
    00005db8h: 00 FF 5F 00 00 00 00 88 56 00 05 00 00 00 00 48 ; ._....늊......H
    00005dc8h: 00 20 1B 00 20 04 20 CF 02 00 00 98 9F C6 00 30 ; . .. . ?...삜?.0
    00005dd8h: 9F C6 00 C8 9E C6 00 60 9E C6 00 F8 9D C6 00 90 ; 읝.???.`왚.???.?
    00005de8h: 9D C6 00 28 9D C6 00 C0 9C C6 00 58 9C C6 00 F0 ; 씶.(씶.핞?.X쑪.?
    00005df8h: 9B C6 00 88 9B C6 00 20 9B C6 00 D1 02 00 00 00 ; 쎟.닗?. 쎟.?....
    00005e08h: 00 00 00 00 00 00 00 00 00 00 00 0C 00 04 80 02 ; ...............
    00005e18h: 28 18 00 01 00 00 00 11 74 65 73 74 69 6E 67 00 ; (.......testing.
    00005e28h: 00 00 00 00 A0 28 E2 EB FF FF FF 67 21 74 65 73 ; ....?(瞬g!tes
    00005e38h: 74 21 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ; t!              
    00005e48h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ;                 
    00005e58h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 00 00 ;               ..
    00005e68h: 00 00 00 CF 02 00 00 D1 02 00 00 00 00 00 00 00 ; ...?...?........
    00005e78h: 00 00 00 0C 00 04 C0 02 21 18 00 01 00 00 00 11 ; ......?.!.......
    00005e88h: 74 65 73 74 69 6E 67 00 00 00 00 00 A0 28 E2 EB ; testing.....?(瞬
    00005e98h: FF FF FF 67 31 63 68 61 72 20 20 20 20 20 20 20 ; g1char       
    00005ea8h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ;                 
    00005eb8h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ;                 
    00005ec8h: 20 20 20 20 20 20 00 00 00 00 00 CD 02 00 00 00 ;       .....?....
    00005ed8h: 00 00 00 09 00 00 00 00 00 00 00 0A 00 04 00 02 ; ................
    00005ee8h: 09 18 00 0A 00 00 00 15 31 30 76 61 72 63 68 61 ; ........10varcha
    00005ef8h: 72 00 00 00 A0 28 E2 EB FF FF FF 67 31 30 63 68 ; r...?(瞬g10ch
    00005f08h: 61 72 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ; ar              
    00005f18h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ;                 
    00005f28h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 00 00 ;               ..
    00005f38h: 00 00 00 CD 02 00 00 00 00 00 00 08 00 00 00 00 ; ...?............
    00005f48h: 00 00 00 09 00 04 00 02 09 18 00 09 00 00 00 13 ; ................
    00005f58h: 39 76 61 72 63 68 61 72 00 00 00 00 A0 28 E2 EB ; 9varchar....?(瞬
    00005f68h: FF FF FF 67 39 63 68 61 72 20 20 20 20 20 20 20 ; g9char       
    00005f78h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ;                 
    00005f88h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ;                 
    00005f98h: 20 20 20 20 20 20 00 00 00 00 00 CD 02 00 00 00 ;       .....?....
    00005fa8h: 00 00 00 07 00 00 00 00 00 00 00 08 00 04 00 02 ; ................
    00005fb8h: 09 18 00 08 00 00 00 13 38 76 61 72 63 68 61 72 ; ........8varchar
    00005fc8h: 00 00 00 00 A0 28 E2 EB FF FF FF 67 38 63 68 61 ; ....?(瞬g8cha
    00005fd8h: 72 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ; r               
    00005fe8h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ;                 
    00005ff8h: 20 20 20 20 20 20 20 20 98 D0 05 00 01 00 00 00 ;         샫......
    00006008h: 00 60 00 05 00 00 00 00 93 03 00 00 00 00 00 00 ; .`......?.......
    00006018h: 20 20 20 20 20 20 00 00 00 00 00 CD 02 00 00 00 ;       .....?....
    00006028h: 00 00 00 06 00 00 00 00 00 00 00 07 00 04 00 02 ; ................
    00006038h: 09 18 00 07 00 00 00 13 37 76 61 72 63 68 61 72 ; ........7varchar
    00006048h: 00 00 00 00 A0 28 E2 EB FF FF FF 67 37 63 68 61 ; ....?(瞬g7cha
    00006058h: 72 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ; r               
    00006068h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ;                 
    00006078h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 00 00 ;               ..
    00006088h: 00 00 00 CD 02 00 00 00 00 00 00 05 00 00 00 00 ; ...?............
    00006098h: 00 00 00 06 00 04 00 02 09 18 00 06 00 00 00 13 ; ................
    000060a8h: 36 76 61 72 63 68 61 72 00 00 00 00 A0 28 E2 EB ; 6varchar....?(瞬
    000060b8h: FF FF FF 67 36 63 68 61 72 20 20 20 20 20 20 20 ; g6char       
    000060c8h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ;                 
    000060d8h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ;                 
    000060e8h: 20 20 20 20 20 20 00 00 00 00 00 CD 02 00 00 00 ;       .....?....
    000060f8h: 00 00 00 04 00 00 00 00 00 00 00 05 00 04 00 02 ; ................
    00006108h: 09 18 00 05 00 00 00 13 35 76 61 72 63 68 61 72 ; ........5varchar
    00006118h: 00 00 00 00 A0 28 E2 EB FF FF FF 67 35 63 68 61 ; ....?(瞬g5cha
    00006128h: 72 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ; r               
    00006138h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ;                 
    00006148h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 00 00 ;               ..
    00006158h: 00 00 00 CD 02 00 00 00 00 00 00 03 00 00 00 00 ; ...?............
    00006168h: 00 00 00 04 00 04 00 02 09 18 00 04 00 00 00 13 ; ................
    00006178h: 34 76 61 72 63 68 61 72 00 00 00 00 A0 28 E2 EB ; 4varchar....?(瞬
    00006188h: FF FF FF 67 34 63 68 61 72 20 20 20 20 20 20 20 ; g4char       
    00006198h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ;                 
    000061a8h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ;                 
    000061b8h: 20 20 20 20 20 20 00 00 00 00 00 CD 02 00 00 00 ;       .....?....
    000061c8h: 00 00 00 02 00 00 00 00 00 00 00 03 00 04 00 02 ; ................
    000061d8h: 09 18 00 03 00 00 00 13 33 76 61 72 63 68 61 72 ; ........3varchar
    000061e8h: 00 00 00 00 A0 28 E2 EB FF FF FF 67 33 63 68 61 ; ....?(瞬g3cha
    000061f8h: 72 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ; r               
    00006208h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ;                 
    00006218h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 00 00 ;               ..
    00006228h: 00 00 00 CD 02 00 00 00 00 00 00 01 00 00 00 00 ; ...?............
    00006238h: 00 00 00 02 00 04 00 02 09 18 00 02 00 00 00 13 ; ................
    00006248h: 32 76 61 72 63 68 61 72 00 00 00 00 A0 28 E2 EB ; 2varchar....?(瞬
    00006258h: FF FF FF 67 32 63 68 61 72 20 20 20 20 20 20 20 ; g2char       
    00006268h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ;                 
    00006278h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ;                 
    00006288h: 20 20 20 20 20 20 00 00 00 00 00 CD 02 00 00 CF ;       .....?...?
    00006298h: 02 00 00 00 00 00 00 00 00 00 00 0B 00 04 40 02 ; ..............@.
    000062a8h: 05 18 00 01 00 00 00 13 31 76 61 72 63 68 61 72 ; ........1varchar
    000062b8h: 00 00 00 00 A0 28 E2 EB FF FF FF 67 31 63 68 61 ; ....?(瞬g1cha
    000062c8h: 72 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ; r               
    000062d8h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ;                 
    000062e8h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 00 00 ;               ..
    000062f8h: 00 00 00 04 80 02 28 18 00 01 00 00 00 11 74 65 ; .....(.......te
    00006308h: 73 74 69 6E 67 00 00 00 00 00 A0 28 E2 EB FF FF ; sting.....?(瞬
    00006318h: FF 67 21 74 65 73 74 21 20 20 20 20 20 20 20 20 ; g!test!        
    00006328h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ;                 
    00006338h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ;                 
    00006348h: 20 20 20 20 D1 02 00 00 0B 00 00 14 00 00 00 00 ;     ?...........
    00006358h: 0C 00 04 C0 02 21 18 00 01 00 00 00 11 74 65 73 ; ...?.!.......tes
    00006368h: 74 69 6E 67 00 00 00 00 00 A0 28 E2 EB FF FF FF ; ting.....?(瞬
    00006378h: 67 31 63 68 61 72 20 20 20 20 20 20 20 20 20 20 ; g1char          
    00006388h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ;                 
    00006398h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ;                 
    000063a8h: 20 20 20                                        ;
    
    XLogRecord: tot_len xid prev info rmid crc
    XLogRecordDataHeaderShort: id data_len
    ```
    

### TEST_D

**WHERE PK**

```
Logdump 388 >n
TokenID x47 'G' Record Header    Info x01  Length  203
TokenID x48 'H' GHDR             Info x00  Length   36
 450c 0041 7700 0fff a8f4 2a02 5415 f302 f056 0005 | E..Aw.....*.T....V..
 0000 0000 0000 0000 0352 0000 0001 0000           | .........R......
TokenID x44 'D' Data             Info x00  Length  119
TokenID x54 'T' GGS Tokens       Info x00  Length   28
TokenID x5a 'Z' Record Trailer   Info x01  Length  203
___________________________________________________________________
Hdr-Ind    :     E  (x45)     Partition  :     .  (x0c)
UndoFlag   :     .  (x00)     BeforeAfter:     A  (x41)
RecLength  :   119  (x0077)   IO Time    : 2022/12/06 12:39:34.351.016
IOType     :    15  (x0f)     OrigNode   :   255  (xff)
TransInd   :     .  (x03)     FormatType :     R  (x52)
SyskeyLen  :     0  (x00)     Incomplete :     .  (x00)
AuditRBA   :          0       AuditPos   : 83908336
Continued  :     N  (x00)     RecCount   :     1  (x01)

2022/12/06 12:39:34.351.016 FieldComp            Len   119 RBA 5521
Name: test.test_d  (TDR Index: 2)
After  Image:                                             Partition x0c   G  s
 0000 0a00 0000 0000 0000 0000 0001 0100 0b00 0000 | ....................
 0700 7465 7374 696e 6702 001c 0000 0032 3030 302d | ..testing......2000-
 3031 2d30 313a 3030 3a30 303a 3030 2e30 3030 3030 | 01-01:00:00:00.00000
 3003 0036 0000 0032 0063 6861 7231 2020 2020 2020 | 0..6...2.char1
 2020 2020 2020 2020 2020 2020 2020 2020 2020 2020 |
 2020 2020 2020 2020 2020 2020 2020 2020 2020 20   |
Column 0 (0x0000), Length 10 (0x000a).
 0000 0000 0000 0000 0001                          | ..........
Column 1 (0x0001), Length 11 (0x000b).
 0000 0700 7465 7374 696e 67                       | ....testing
Column 2 (0x0002), Length 28 (0x001c).
 0000 3230 3030 2d30 312d 3031 3a30 303a 3030 3a30 | ..2000-01-01:00:00:0
 302e 3030 3030 3030                               | 0.000000
Column 3 (0x0003), Length 54 (0x0036).
 0000 3200 6368 6172 3120 2020 2020 2020 2020 2020 | ..2.char1
 2020 2020 2020 2020 2020 2020 2020 2020 2020 2020 |
 2020 2020 2020 2020 2020 2020 2020                |

GGS tokens:
TokenID x4c 'L' LOGCSN           Info x00  Length   17
 3030 3030 3030 3030 2f30 3530 3035 4337 30        | 00000000/05005C70
TokenID x36 '6' TRANID           Info x00  Length    3
 3732 30                                           | 720
```

- WAL
  
    ```
    000056f0h: 4E 05 00 00 D0 02 00 00 B8 56 00 05 00 00 00 00 ; N...?...퇦......
    00005700h: 40 0A 00 00 FF 7E E6 E4 00 30 51 00 BC 04 44 00 ; @...~輦.0Q.?.D.
    00005710h: 05 7F 06 00 00 00 40 00 00 43 40 00 00 00 00 00 ; .....@..C@.....
    00005720h: 00 FF 0E 00 00 00 00 60 4F 00 05 00 00 00 00 44 ; ......`O......D
    00005730h: 00 88 1B 00 20 04 20 D0 02 00 00 98 9F C6 00 30 ; .?.. . ?...삜?.0
    00005740h: 9F C6 00 C8 9E C6 00 60 9E C6 00 F8 9D C6 00 90 ; 읝.???.`왚.???.?
    00005750h: 9D C6 00 28 9D C6 00 C0 9C C6 00 58 9C C6 00 F0 ; 씶.(씶.핞?.X쑪.?
    00005760h: 9B C6 00 88 9B C6 00 D0 02 00 00 00 00 00 00 00 ; 쎟.닗?.?........
    00005770h: 00 00 00 00 00 00 00 0B 00 04 80 02 28 18 00 01 ; ...........(...
    00005780h: 00 00 00 11 74 65 73 74 69 6E 67 00 00 00 00 00 ; ....testing.....
    00005790h: 00 00 00 00 00 00 00 67 63 68 61 72 31 20 20 20 ; .......gchar1   
    000057a0h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ;                 
    000057b0h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ;                 
    000057c0h: 20 20 20 20 20 20 20 20 20 20 00 00 00 00 00 CE ;           .....?
    000057d0h: 02 00 00 00 00 00 00 09 00 00 00 00 00 00 00 0A ; ................
    000057e0h: 00 04 00 02 08 18 00 0A 00 00 00 15 76 61 72 63 ; ............varc
    000057f0h: 68 61 72 31 30 00 00 00 00 00 00 00 00 00 00 67 ; har10..........g
    00005800h: 63 68 61 72 31 30 20 20 20 20 20 20 20 20 20 20 ; char10          
    00005810h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ;                 
    00005820h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ;                 
    00005830h: 20 20 00 00 00 00 00 CE 02 00 00 00 00 00 00 08 ;   .....?........
    00005840h: 00 00 00 00 00 00 00 09 00 04 00 02 08 18 00 09 ; ................
    00005850h: 00 00 00 13 76 61 72 63 68 61 72 39 00 00 00 00 ; ....varchar9....
    00005860h: 00 00 00 00 00 00 00 67 63 68 61 72 39 20 20 20 ; .......gchar9   
    00005870h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ;                 
    00005880h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ;                 
    00005890h: 20 20 20 20 20 20 20 20 20 20 00 00 00 00 00 CE ;           .....?
    000058a0h: 02 00 00 00 00 00 00 07 00 00 00 00 00 00 00 08 ; ................
    000058b0h: 00 04 00 02 08 18 00 08 00 00 00 13 76 61 72 63 ; ............varc
    000058c0h: 68 61 72 38 00 00 00 00 00 00 00 00 00 00 00 67 ; har8...........g
    000058d0h: 63 68 61 72 38 20 20 20 20 20 20 20 20 20 20 20 ; char8           
    000058e0h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ;                 
    000058f0h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ;                 
    00005900h: 20 20 00 00 00 00 00 CE 02 00 00 00 00 00 00 06 ;   .....?........
    00005910h: 00 00 00 00 00 00 00 07 00 04 00 02 08 18 00 07 ; ................
    00005920h: 00 00 00 13 76 61 72 63 68 61 72 37 00 00 00 00 ; ....varchar7....
    00005930h: 00 00 00 00 00 00 00 67 63 68 61 72 37 20 20 20 ; .......gchar7   
    00005940h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ;                 
    00005950h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ;                 
    00005960h: 20 20 20 20 20 20 20 20 20 20 00 00 00 00 00 CE ;           .....?
    00005970h: 02 00 00 00 00 00 00 05 00 00 00 00 00 00 00 06 ; ................
    00005980h: 00 04 00 02 08 18 00 06 00 00 00 13 76 61 72 63 ; ............varc
    00005990h: 68 61 72 36 00 00 00 00 00 00 00 00 00 00 00 67 ; har6...........g
    000059a0h: 63 68 61 72 36 20 20 20 20 20 20 20 20 20 20 20 ; char6           
    000059b0h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ;                 
    000059c0h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ;                 
    000059d0h: 20 20 00 00 00 00 00 CE 02 00 00 00 00 00 00 04 ;   .....?........
    000059e0h: 00 00 00 00 00 00 00 05 00 04 00 02 08 18 00 05 ; ................
    000059f0h: 00 00 00 13 76 61 72 63 68 61 72 35 00 00 00 00 ; ....varchar5....
    00005a00h: 00 00 00 00 00 00 00 67 63 68 61 72 35 20 20 20 ; .......gchar5   
    00005a10h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ;                 
    00005a20h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ;                 
    00005a30h: 20 20 20 20 20 20 20 20 20 20 00 00 00 00 00 CE ;           .....?
    00005a40h: 02 00 00 00 00 00 00 03 00 00 00 00 00 00 00 04 ; ................
    00005a50h: 00 04 00 02 08 18 00 04 00 00 00 13 76 61 72 63 ; ............varc
    00005a60h: 68 61 72 34 00 00 00 00 00 00 00 00 00 00 00 67 ; har4...........g
    00005a70h: 63 68 61 72 34 20 20 20 20 20 20 20 20 20 20 20 ; char4           
    00005a80h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ;                 
    00005a90h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ;                 
    00005aa0h: 20 20 00 00 00 00 00 CE 02 00 00 00 00 00 00 02 ;   .....?........
    00005ab0h: 00 00 00 00 00 00 00 03 00 04 00 02 08 18 00 03 ; ................
    00005ac0h: 00 00 00 13 76 61 72 63 68 61 72 33 00 00 00 00 ; ....varchar3....
    00005ad0h: 00 00 00 00 00 00 00 67 63 68 61 72 33 20 20 20 ; .......gchar3   
    00005ae0h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ;                 
    00005af0h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ;                 
    00005b00h: 20 20 20 20 20 20 20 20 20 20 00 00 00 00 00 CE ;           .....?
    00005b10h: 02 00 00 00 00 00 00 01 00 00 00 00 00 00 00 02 ; ................
    00005b20h: 00 04 00 02 08 18 00 02 00 00 00 13 76 61 72 63 ; ............varc
    00005b30h: 68 61 72 32 00 00 00 00 00 00 00 00 00 00 00 67 ; har2...........g
    00005b40h: 63 68 61 72 32 20 20 20 20 20 20 20 20 20 20 20 ; char2           
    00005b50h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ;                 
    00005b60h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ;                 
    00005b70h: 20 20 00 00 00 00 00 CE 02 00 00 D0 02 00 00 00 ;   .....?...?....
    00005b80h: 00 00 00 00 00 00 00 0B 00 04 40 02 01 18 00 01 ; ..........@.....
    00005b90h: 00 00 00 13 76 61 72 63 68 61 72 31 00 00 00 00 ; ....varchar1....
    00005ba0h: 00 00 00 00 00 00 00 67 63 68 61 72 31 20 20 20 ; .......gchar1   
    00005bb0h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ;                 
    00005bc0h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ;                 
    00005bd0h: 20 20 20 20 20 20 20 20 20 20 00 00 00 00 00 04 ;           ......
    00005be0h: 80 02 28 18 00 01 00 00 00 11 74 65 73 74 69 6E ; .(.......testin
    00005bf0h: 67 00 00 00 00 00 00 00 00 00 00 00 00 67 63 68 ; g............gch
    00005c00h: 61 72 31 20 20 20 20 20 20 20 20 20 20 20 20 20 ; ar1             
    00005c10h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ;                 
    00005c20h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ;                 
    00005c30h: D0 02 00 00 01 00 00 10 00 00 00 00 0B 00       ; ?.............
    
    XLogRecord: tot_len xid prev info rmid crc
    XLogRecordDataHeaderShort: id data_len
    ```
    

**WHERE !PK**

```
Logdump 390 >n
TokenID x47 'G' Record Header    Info x01  Length  203
TokenID x48 'H' GHDR             Info x00  Length   36
 450c 0041 7700 0fff ce47 7708 5415 f302 1864 0005 | E..Aw....Gw.T....d..
 0000 0000 0000 0000 0352 0000 0001 0000           | .........R......
TokenID x44 'D' Data             Info x00  Length  119
TokenID x54 'T' GGS Tokens       Info x00  Length   28
TokenID x5a 'Z' Record Trailer   Info x01  Length  203
___________________________________________________________________
Hdr-Ind    :     E  (x45)     Partition  :     .  (x0c)
UndoFlag   :     .  (x00)     BeforeAfter:     A  (x41)
RecLength  :   119  (x0077)   IO Time    : 2022/12/06 12:41:20.016.334
IOType     :    15  (x0f)     OrigNode   :   255  (xff)
TransInd   :     .  (x03)     FormatType :     R  (x52)
SyskeyLen  :     0  (x00)     Incomplete :     .  (x00)
AuditRBA   :          0       AuditPos   : 83911704
Continued  :     N  (x00)     RecCount   :     1  (x01)

2022/12/06 12:41:20.016.334 FieldComp            Len   119 RBA 5880
Name: test.test_d  (TDR Index: 2)
After  Image:                                             Partition x0c   G  s
 0000 0a00 0000 0000 0000 0000 0001 0100 0b00 0000 | ....................
 0700 7465 7374 696e 6702 001c 0000 0032 3030 302d | ..testing......2000-
 3031 2d30 313a 3030 3a30 303a 3030 2e30 3030 3030 | 01-01:00:00:00.00000
 3003 0036 0000 0032 0021 7465 7374 2120 2020 2020 | 0..6...2.!test!
 2020 2020 2020 2020 2020 2020 2020 2020 2020 2020 |
 2020 2020 2020 2020 2020 2020 2020 2020 2020 20   |
Column 0 (0x0000), Length 10 (0x000a).
 0000 0000 0000 0000 0001                          | ..........
Column 1 (0x0001), Length 11 (0x000b).
 0000 0700 7465 7374 696e 67                       | ....testing
Column 2 (0x0002), Length 28 (0x001c).
 0000 3230 3030 2d30 312d 3031 3a30 303a 3030 3a30 | ..2000-01-01:00:00:0
 302e 3030 3030 3030                               | 0.000000
Column 3 (0x0003), Length 54 (0x0036).
 0000 3200 2174 6573 7421 2020 2020 2020 2020 2020 | ..2.!test!
 2020 2020 2020 2020 2020 2020 2020 2020 2020 2020 |
 2020 2020 2020 2020 2020 2020 2020                |

GGS tokens:
TokenID x4c 'L' LOGCSN           Info x00  Length   17
 3030 3030 3030 3030 2f30 3530 3036 4130 38        | 00000000/05006A08
TokenID x36 '6' TRANID           Info x00  Length    3
 3732 32                                           | 722
```

- WAL
  
    ```
    00006418h: BA 05 00 00 D2 02 00 00 E0 63 00 05 00 00 00 00 ; ?...?...??......
    00006428h: 40 0A 00 00 A4 20 72 38 00 30 51 00 28 05 48 00 ; @...? r8.0Q.(.H.
    00006438h: 05 7F 06 00 00 00 40 00 00 43 40 00 00 00 00 00 ; .....@..C@.....
    00006448h: 00 FF 0E 00 00 00 00 40 5C 00 05 00 00 00 00 48 ; ......@\......H
    00006458h: 00 20 1B 00 20 04 20 D0 02 00 00 98 9F C6 00 30 ; . .. . ?...삜?.0
    00006468h: 9F C6 00 C8 9E C6 00 60 9E C6 00 F8 9D C6 00 90 ; 읝.???.`왚.???.?
    00006478h: 9D C6 00 28 9D C6 00 C0 9C C6 00 58 9C C6 00 F0 ; 씶.(씶.핞?.X쑪.?
    00006488h: 9B C6 00 88 9B C6 00 20 9B C6 00 D2 02 00 00 00 ; 쎟.닗?. 쎟.?....
    00006498h: 00 00 00 00 00 00 00 00 00 00 00 0C 00 04 80 02 ; ...............
    000064a8h: 28 18 00 01 00 00 00 11 74 65 73 74 69 6E 67 00 ; (.......testing.
    000064b8h: 00 00 00 00 00 00 00 00 00 00 00 67 21 74 65 73 ; ...........g!tes
    000064c8h: 74 21 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ; t!              
    000064d8h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ;                 
    000064e8h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 00 00 ;               ..
    000064f8h: 00 00 00 D0 02 00 00 D2 02 00 00 00 00 00 00 00 ; ...?...?........
    00006508h: 00 00 00 0C 00 04 C0 02 21 18 00 01 00 00 00 11 ; ......?.!.......
    00006518h: 74 65 73 74 69 6E 67 00 00 00 00 00 00 00 00 00 ; testing.........
    00006528h: 00 00 00 67 63 68 61 72 31 20 20 20 20 20 20 20 ; ...gchar1       
    00006538h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ;                 
    00006548h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ;                 
    00006558h: 20 20 20 20 20 20 00 00 00 00 00 CE 02 00 00 00 ;       .....?....
    00006568h: 00 00 00 09 00 00 00 00 00 00 00 0A 00 04 00 02 ; ................
    00006578h: 09 18 00 0A 00 00 00 15 76 61 72 63 68 61 72 31 ; ........varchar1
    00006588h: 30 00 00 00 00 00 00 00 00 00 00 67 63 68 61 72 ; 0..........gchar
    00006598h: 31 30 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ; 10              
    000065a8h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ;                 
    000065b8h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 00 00 ;               ..
    000065c8h: 00 00 00 CE 02 00 00 00 00 00 00 08 00 00 00 00 ; ...?............
    000065d8h: 00 00 00 09 00 04 00 02 09 18 00 09 00 00 00 13 ; ................
    000065e8h: 76 61 72 63 68 61 72 39 00 00 00 00 00 00 00 00 ; varchar9........
    000065f8h: 00 00 00 67 63 68 61 72 39 20 20 20 20 20 20 20 ; ...gchar9       
    00006608h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ;                 
    00006618h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ;                 
    00006628h: 20 20 20 20 20 20 00 00 00 00 00 CE 02 00 00 00 ;       .....?....
    00006638h: 00 00 00 07 00 00 00 00 00 00 00 08 00 04 00 02 ; ................
    00006648h: 09 18 00 08 00 00 00 13 76 61 72 63 68 61 72 38 ; ........varchar8
    00006658h: 00 00 00 00 00 00 00 00 00 00 00 67 63 68 61 72 ; ...........gchar
    00006668h: 38 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ; 8               
    00006678h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ;                 
    00006688h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 00 00 ;               ..
    00006698h: 00 00 00 CE 02 00 00 00 00 00 00 06 00 00 00 00 ; ...?............
    000066a8h: 00 00 00 07 00 04 00 02 09 18 00 07 00 00 00 13 ; ................
    000066b8h: 76 61 72 63 68 61 72 37 00 00 00 00 00 00 00 00 ; varchar7........
    000066c8h: 00 00 00 67 63 68 61 72 37 20 20 20 20 20 20 20 ; ...gchar7       
    000066d8h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ;                 
    000066e8h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ;                 
    000066f8h: 20 20 20 20 20 20 00 00 00 00 00 CE 02 00 00 00 ;       .....?....
    00006708h: 00 00 00 05 00 00 00 00 00 00 00 06 00 04 00 02 ; ................
    00006718h: 09 18 00 06 00 00 00 13 76 61 72 63 68 61 72 36 ; ........varchar6
    00006728h: 00 00 00 00 00 00 00 00 00 00 00 67 63 68 61 72 ; ...........gchar
    00006738h: 36 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ; 6               
    00006748h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ;                 
    00006758h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 00 00 ;               ..
    00006768h: 00 00 00 CE 02 00 00 00 00 00 00 04 00 00 00 00 ; ...?............
    00006778h: 00 00 00 05 00 04 00 02 09 18 00 05 00 00 00 13 ; ................
    00006788h: 76 61 72 63 68 61 72 35 00 00 00 00 00 00 00 00 ; varchar5........
    00006798h: 00 00 00 67 63 68 61 72 35 20 20 20 20 20 20 20 ; ...gchar5       
    000067a8h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ;                 
    000067b8h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ;                 
    000067c8h: 20 20 20 20 20 20 00 00 00 00 00 CE 02 00 00 00 ;       .....?....
    000067d8h: 00 00 00 03 00 00 00 00 00 00 00 04 00 04 00 02 ; ................
    000067e8h: 09 18 00 04 00 00 00 13 76 61 72 63 68 61 72 34 ; ........varchar4
    000067f8h: 00 00 00 00 00 00 00 00 00 00 00 67 63 68 61 72 ; ...........gchar
    00006808h: 34 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ; 4               
    00006818h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ;                 
    00006828h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 00 00 ;               ..
    00006838h: 00 00 00 CE 02 00 00 00 00 00 00 02 00 00 00 00 ; ...?............
    00006848h: 00 00 00 03 00 04 00 02 09 18 00 03 00 00 00 13 ; ................
    00006858h: 76 61 72 63 68 61 72 33 00 00 00 00 00 00 00 00 ; varchar3........
    00006868h: 00 00 00 67 63 68 61 72 33 20 20 20 20 20 20 20 ; ...gchar3       
    00006878h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ;                 
    00006888h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ;                 
    00006898h: 20 20 20 20 20 20 00 00 00 00 00 CE 02 00 00 00 ;       .....?....
    000068a8h: 00 00 00 01 00 00 00 00 00 00 00 02 00 04 00 02 ; ................
    000068b8h: 09 18 00 02 00 00 00 13 76 61 72 63 68 61 72 32 ; ........varchar2
    000068c8h: 00 00 00 00 00 00 00 00 00 00 00 67 63 68 61 72 ; ...........gchar
    000068d8h: 32 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ; 2               
    000068e8h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ;                 
    000068f8h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 00 00 ;               ..
    00006908h: 00 00 00 CE 02 00 00 D0 02 00 00 00 00 00 00 00 ; ...?...?........
    00006918h: 00 00 00 0B 00 04 40 02 05 18 00 01 00 00 00 13 ; ......@.........
    00006928h: 76 61 72 63 68 61 72 31 00 00 00 00 00 00 00 00 ; varchar1........
    00006938h: 00 00 00 67 63 68 61 72 31 20 20 20 20 20 20 20 ; ...gchar1       
    00006948h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ;                 
    00006958h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ;                 
    00006968h: 20 20 20 20 20 20 00 00 00 00 00 04 80 02 28 18 ;       .......(.
    00006978h: 00 01 00 00 00 11 74 65 73 74 69 6E 67 00 00 00 ; ......testing...
    00006988h: 00 00 00 00 00 00 00 00 00 67 21 74 65 73 74 21 ; .........g!test!
    00006998h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ;                 
    000069a8h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ;                 
    000069b8h: 20 20 20 20 20 20 20 20 20 20 20 20 D2 02 00 00 ;             ?...
    000069c8h: 0B 00 00 10 00 00 00 00 0C 00                   ; ..........
    
    XLogRecord: tot_len xid prev info rmid crc
    XLogRecordDataHeaderShort: id data_len
    ```
    

## DELETE

### TEST_F

**WHERE PK**

```
Logdump 391 >n
TokenID x47 'G' Record Header    Info x01  Length   98
TokenID x48 'H' GHDR             Info x00  Length   36
 450c 0042 0e00 03ff cb9b d60f 5415 f302 406a 0005 | E..B........T...@j..
 0000 0000 0000 0000 0352 0000 0001 0000           | .........R......
TokenID x44 'D' Data             Info x00  Length   14
TokenID x54 'T' GGS Tokens       Info x00  Length   28
TokenID x5a 'Z' Record Trailer   Info x01  Length   98
___________________________________________________________________
Hdr-Ind    :     E  (x45)     Partition  :     .  (x0c)
UndoFlag   :     .  (x00)     BeforeAfter:     B  (x42)
RecLength  :    14  (x000e)   IO Time    : 2022/12/06 12:43:23.704.267
IOType     :     3  (x03)     OrigNode   :   255  (xff)
TransInd   :     .  (x03)     FormatType :     R  (x52)
SyskeyLen  :     0  (x00)     Incomplete :     .  (x00)
AuditRBA   :          0       AuditPos   : 83913280
Continued  :     N  (x00)     RecCount   :     1  (x01)

2022/12/06 12:43:23.704.267 Delete               Len    14 RBA 6083
Name: test.test_f  (TDR Index: 1)
Before Image:                                             Partition x0c   G  s
 0000 0a00 0000 0000 0000 0000 0002                | ..............
Column 0 (0x0000), Length 10 (0x000a).
 0000 0000 0000 0000 0002                          | ..........

GGS tokens:
TokenID x4c 'L' LOGCSN           Info x00  Length   17
 3030 3030 3030 3030 2f30 3530 3036 4146 38        | 00000000/05006AF8
TokenID x36 '6' TRANID           Info x00  Length    3
 3732 33                                           | 723
```

- WAL
  
    ```
    00006a40h: 87 00 00 00 D3 02 00 00 08 6A 00 05 00 00 00 00 ; ?...?....j......
    00006a50h: 10 0A 00 00 E4 E8 D5 72 00 00 00 00 7F 06 00 00 ; ....怏??.......
    00006a60h: 00 40 00 00 3E 40 00 00 00 00 00 00 FF 59 D3 02 ; .@..>@......Y?.
    00006a70h: 00 00 02 00 10 02 04 20 02 01 18 00 02 00 00 00 ; ....... ........
    00006a80h: 13 32 76 61 72 63 68 61 72 00 00 00 00 A0 28 E2 ; .2varchar....?(?
    00006a90h: EB FF FF FF 67 32 63 68 61 72 20 20 20 20 20 20 ; ?g2char      
    00006aa0h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ;                 
    00006ab0h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ;                 
    00006ac0h: 20 20 20 20 20 20 20                            ;
    
    XLogRecord: tot_len xid prev info rmid crc
    XLogRecordDataHeaderShort: id data_len
    ```
    

**WHERE !PK**

```
Logdump 392 >n
TokenID x47 'G' Record Header    Info x01  Length   98
TokenID x48 'H' GHDR             Info x00  Length   36
 450c 0042 0e00 03ff b4fb 4911 5415 f302 306b 0005 | E..B......I.T...0k..
 0000 0000 0000 0000 0352 0000 0001 0000           | .........R......
TokenID x44 'D' Data             Info x00  Length   14
TokenID x54 'T' GGS Tokens       Info x00  Length   28
TokenID x5a 'Z' Record Trailer   Info x01  Length   98
___________________________________________________________________
Hdr-Ind    :     E  (x45)     Partition  :     .  (x0c)
UndoFlag   :     .  (x00)     BeforeAfter:     B  (x42)
RecLength  :    14  (x000e)   IO Time    : 2022/12/06 12:43:48.042.676
IOType     :     3  (x03)     OrigNode   :   255  (xff)
TransInd   :     .  (x03)     FormatType :     R  (x52)
SyskeyLen  :     0  (x00)     Incomplete :     .  (x00)
AuditRBA   :          0       AuditPos   : 83913520
Continued  :     N  (x00)     RecCount   :     1  (x01)

2022/12/06 12:43:48.042.676 Delete               Len    14 RBA 6181
Name: test.test_f  (TDR Index: 1)
Before Image:                                             Partition x0c   G  s
 0000 0a00 0000 0000 0000 0000 0001                | ..............
Column 0 (0x0000), Length 10 (0x000a).
 0000 0000 0000 0000 0001                          | ..........

GGS tokens:
TokenID x4c 'L' LOGCSN           Info x00  Length   17
 3030 3030 3030 3030 2f30 3530 3036 4245 38        | 00000000/05006BE8
TokenID x36 '6' TRANID           Info x00  Length    3
 3732 34                                           | 724
```

- WAL
  
    ```
    00006b30h: 87 00 00 00 D4 02 00 00 F8 6A 00 05 00 00 00 00 ; ?...?...??......
    00006b40h: 10 0A 00 00 EC 65 F1 BE 00 00 00 00 7F 06 00 00 ; ....??湊.......
    00006b50h: 00 40 00 00 3E 40 00 00 00 00 00 00 FF 59 D4 02 ; .@..>@......Y?.
    00006b60h: 00 00 0C 00 10 02 04 A0 02 21 18 00 01 00 00 00 ; .......?.!......
    00006b70h: 11 74 65 73 74 69 6E 67 00 00 00 00 00 A0 28 E2 ; .testing.....?(?
    00006b80h: EB FF FF FF 67 21 74 65 73 74 21 20 20 20 20 20 ; ?g!test!
    00006b90h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ;
    00006ba0h: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 ;
    00006bb0h: 20 20 20 20 20 20 20                            ;
    
    XLogRecord: tot_len xid prev info rmid crc
    XLogRecordDataHeaderShort: id data_len
    ```
    

### TEST_D

**WHERE PK**

```
Logdump 393 >n
TokenID x47 'G' Record Header    Info x01  Length   98
TokenID x48 'H' GHDR             Info x00  Length   36
 450c 0042 0e00 03ff d79f d612 5415 f302 206c 0005 | E..B........T... l..
 0000 0000 0000 0000 0352 0000 0001 0000           | .........R......
TokenID x44 'D' Data             Info x00  Length   14
TokenID x54 'T' GGS Tokens       Info x00  Length   28
TokenID x5a 'Z' Record Trailer   Info x01  Length   98
___________________________________________________________________
Hdr-Ind    :     E  (x45)     Partition  :     .  (x0c)
UndoFlag   :     .  (x00)     BeforeAfter:     B  (x42)
RecLength  :    14  (x000e)   IO Time    : 2022/12/06 12:44:14.036.951
IOType     :     3  (x03)     OrigNode   :   255  (xff)
TransInd   :     .  (x03)     FormatType :     R  (x52)
SyskeyLen  :     0  (x00)     Incomplete :     .  (x00)
AuditRBA   :          0       AuditPos   : 83913760
Continued  :     N  (x00)     RecCount   :     1  (x01)

2022/12/06 12:44:14.036.951 Delete               Len    14 RBA 6279
Name: test.test_d  (TDR Index: 2)
Before Image:                                             Partition x0c   G  s
 0000 0a00 0000 0000 0000 0000 0002                | ..............
Column 0 (0x0000), Length 10 (0x000a).
 0000 0000 0000 0000 0002                          | ..........

GGS tokens:
TokenID x4c 'L' LOGCSN           Info x00  Length   17
 3030 3030 3030 3030 2f30 3530 3036 4339 30        | 00000000/05006C90
TokenID x36 '6' TRANID           Info x00  Length    3
 3732 35                                           | 725
```

- WAL
  
    ```
    00006c20h: 40 00 00 00 D5 02 00 00 E8 6B 00 05 00 00 00 00 ; @...?...??......
    00006c30h: 10 0A 00 00 A9 5A 14 05 00 00 00 00 7F 06 00 00 ; ....쯟.........
    00006c40h: 00 40 00 00 43 40 00 00 00 00 00 00 FF 12 D5 02 ; .@..C@.......?.
    00006c50h: 00 00 02 00 10 04 04 00 01 00 18 01 02 00 00 00 ; ................
    
    XLogRecord: tot_len xid prev info rmid crc
    XLogRecordDataHeaderShort: id data_len
    ```
    

**WHERE !PK**

```
Logdump 394 >n
TokenID x47 'G' Record Header    Info x01  Length   98
TokenID x48 'H' GHDR             Info x00  Length   36
 450c 0042 0e00 03ff a1f7 0814 5415 f302 c86c 0005 | E..B........T....l..
 0000 0000 0000 0000 0352 0000 0001 0000           | .........R......
TokenID x44 'D' Data             Info x00  Length   14
TokenID x54 'T' GGS Tokens       Info x00  Length   28
TokenID x5a 'Z' Record Trailer   Info x01  Length   98
___________________________________________________________________
Hdr-Ind    :     E  (x45)     Partition  :     .  (x0c)
UndoFlag   :     .  (x00)     BeforeAfter:     B  (x42)
RecLength  :    14  (x000e)   IO Time    : 2022/12/06 12:44:34.113.441
IOType     :     3  (x03)     OrigNode   :   255  (xff)
TransInd   :     .  (x03)     FormatType :     R  (x52)
SyskeyLen  :     0  (x00)     Incomplete :     .  (x00)
AuditRBA   :          0       AuditPos   : 83913928
Continued  :     N  (x00)     RecCount   :     1  (x01)

2022/12/06 12:44:34.113.441 Delete               Len    14 RBA 6377
Name: test.test_d  (TDR Index: 2)
Before Image:                                             Partition x0c   G  s
 0000 0a00 0000 0000 0000 0000 0001                | ..............
Column 0 (0x0000), Length 10 (0x000a).
 0000 0000 0000 0000 0001                          | ..........

GGS tokens:
TokenID x4c 'L' LOGCSN           Info x00  Length   17
 3030 3030 3030 3030 2f30 3530 3036 4433 38        | 00000000/05006D38
TokenID x36 '6' TRANID           Info x00  Length    3
 3732 36                                           | 726
```

- WAL
  
    ```
    00006cc8h: 40 00 00 00 D6 02 00 00 90 6C 00 05 00 00 00 00 ; @...?...릐......
    00006cd8h: 10 0A 00 00 89 E3 D9 C8 00 00 00 00 7F 06 00 00 ; ....됥謨.......
    00006ce8h: 00 40 00 00 43 40 00 00 00 00 00 00 FF 12 D6 02 ; .@..C@.......?.
    00006cf8h: 00 00 0C 00 10 04 04 00 01 00 18 01 01 00 00 00 ; ................
    
    XLogRecord: tot_len xid prev info rmid crc
    XLogRecordDataHeaderShort: id data_len
    ```
    

## TRUNCATE

### TEST_F

```
Logdump 396 >n
TokenID x47 'G' Record Header    Info x01  Length   80
TokenID x48 'H' GHDR             Info x00  Length   36
 450c 0041 0000 64ff a0e9 a815 5415 f302 b0b3 0005 | E..A..d.....T.......
 0000 0000 0000 0000 0352 0000 0001 0000           | .........R......
TokenID x54 'T' GGS Tokens       Info x00  Length   28
TokenID x5a 'Z' Record Trailer   Info x01  Length   80
___________________________________________________________________
Hdr-Ind    :     E  (x45)     Partition  :     .  (x0c)
UndoFlag   :     .  (x00)     BeforeAfter:     A  (x41)
RecLength  :     0  (x0000)   IO Time    : 2022/12/06 12:45:01.372.832
IOType     :   100  (x64)     OrigNode   :   255  (xff)
TransInd   :     .  (x03)     FormatType :     R  (x52)
SyskeyLen  :     0  (x00)     Incomplete :     .  (x00)
AuditRBA   :          0       AuditPos   : 83932080
Continued  :     N  (x00)     RecCount   :     1  (x01)

2022/12/06 12:45:01.372.832 GGSPurgedata         Len     0 RBA 6475
Name: test.test_f  (TDR Index: 1)
After  Image:                                             Partition x0c   G  s

GGS tokens:
TokenID x4c 'L' LOGCSN           Info x00  Length   17
 3030 3030 3030 3030 2f30 3530 3042 3444 30        | 00000000/0500B4D0
TokenID x36 '6' TRANID           Info x00  Length    3
 3732 37                                           | 727
```

- WAL
  
    ```
    0000b3b0h: 2A 00 00 00 D7 02 00 00 F0 B2 00 05 00 00 00 00 ; *...?...製......
    0000b3c0h: 30 0A 00 00 45 49 0F 78 FF 10 00 40 00 00 01 00 ; 0...EI.x..@....
    0000b3d0h: 00 00 00 40 7A 02 3E 40 00 00                   ; ...@z.>@..
    
    XLogRecord: tot_len xid prev info rmid crc
    XLogRecordDataHeaderShort: id data_len
    ```
    

### TEST_D

```
Logdump 398 >n
TokenID x47 'G' Record Header    Info x01  Length   80
TokenID x48 'H' GHDR             Info x00  Length   36
 450c 0041 0000 64ff 7750 a418 5415 f302 d8ba 0005 | E..A..d.wP..T.......
 0000 0000 0000 0000 0352 0000 0001 0000           | .........R......
TokenID x54 'T' GGS Tokens       Info x00  Length   28
TokenID x5a 'Z' Record Trailer   Info x01  Length   80
___________________________________________________________________
Hdr-Ind    :     E  (x45)     Partition  :     .  (x0c)
UndoFlag   :     .  (x00)     BeforeAfter:     A  (x41)
RecLength  :     0  (x0000)   IO Time    : 2022/12/06 12:45:51.403.127
IOType     :   100  (x64)     OrigNode   :   255  (xff)
TransInd   :     .  (x03)     FormatType :     R  (x52)
SyskeyLen  :     0  (x00)     Incomplete :     .  (x00)
AuditRBA   :          0       AuditPos   : 83933912
Continued  :     N  (x00)     RecCount   :     1  (x01)

2022/12/06 12:45:51.403.127 GGSPurgedata         Len     0 RBA 6555
Name: test.test_d  (TDR Index: 2)
After  Image:                                             Partition x0c   G  s

GGS tokens:
TokenID x4c 'L' LOGCSN           Info x00  Length   17
 3030 3030 3030 3030 2f30 3530 3042 4246 38        | 00000000/0500BBF8
TokenID x36 '6' TRANID           Info x00  Length    3
 3733 30                                           | 730
```

- WAL
  
    ```
    0000bad8h: 2A 00 00 00 DA 02 00 00 18 BA 00 05 00 00 00 00 ; *...?....?......
    0000bae8h: 30 0A 00 00 A3 E6 40 D4 FF 10 00 40 00 00 01 00 ; 0...ｆ@?..@....
    0000baf8h: 00 00 00 8F 7F 02 43 40 00 00                   ; ...?.C@..
    
    XLogRecord: tot_len xid prev info rmid crc
    XLogRecordDataHeaderShort: id data_len
    ```