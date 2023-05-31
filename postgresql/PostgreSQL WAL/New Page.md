# New Page

[wal2extract](./New Page/wal2extract.md)

```c
/* When record crosses page boundary, set this flag in new page's header */
#define XLP_FIRST_IS_CONTRECORD		        0x0001
/* This flag indicates a "long" page header */
#define XLP_LONG_HEADER				            0x0002
/* This flag indicates backup blocks starting in this page are optional */
#define XLP_BKP_REMOVABLE			            0x0004
/* Replaces a missing contrecord; see CreateOverwriteContrecordRecord */
#define XLP_FIRST_IS_OVERWRITE_CONTRECORD 0x0008
/* All defined flag bits in xlp_info (used for validity checking of header) */
#define XLP_ALL_FLAGS                     0x000F
```

```c
// xlog_info Value
#define XLOG_HEAP_INSERT		0x00
#define XLOG_HEAP_DELETE		0x10
#define XLOG_HEAP_UPDATE		0x20
#define XLOG_HEAP_TRUNCATE		0x30
#define XLOG_HEAP_HOT_UPDATE	0x40
#define XLOG_HEAP_CONFIRM		0x50
#define XLOG_HEAP_LOCK			0x60
#define XLOG_HEAP_INPLACE		0x70

#define XLOG_HEAP_OPMASK		0x70
/*
 * When we insert 1st item on new page in INSERT, UPDATE, HOT_UPDATE,
 * or MULTI_INSERT, we can (and we do) restore entire page in redo
 */
#define XLOG_HEAP_INIT_PAGE		0x80
```

```c
#define BKPBLOCK_FORK_MASK	0x0F
#define BKPBLOCK_FLAG_MASK	0xF0
#define BKPBLOCK_HAS_IMAGE	0x10	/* block data is an XLogRecordBlockImage */
#define BKPBLOCK_HAS_DATA	  0x20
#define BKPBLOCK_WILL_INIT	0x40	/* redo will re-init the page */
#define BKPBLOCK_SAME_REL	  0x80	/* RelFileLocator omitted, same as previous */
```

```c
typedef struct xl_running_xacts
{
	int			xcnt;			/* # of xact ids in xids[] */
	int			subxcnt;		/* # of subxact ids in xids[] */
	bool		subxid_overflow;	/* snapshot overflowed, subxids missing */
	TransactionId nextXid;		/* xid from ShmemVariableCache->nextXid */
	TransactionId oldestRunningXid; /* *not* oldestXmin */
	TransactionId latestCompletedXid;	/* so we can set xmax */

	TransactionId xids[FLEXIBLE_ARRAY_MEMBER];
} xl_running_xacts;
```

![Untitled](../WAL%E1%84%8B%E1%85%B4%20%E1%84%80%E1%85%AE%E1%84%8C%E1%85%A9%20%E1%84%86%E1%85%B5%E1%86%BE%20%E1%84%80%E1%85%AE%E1%84%89%E1%85%A5%E1%86%BC%E1%84%8B%E1%85%AD%E1%84%89%E1%85%A9%2004465cfdb6a34201a0252f8ef5fd37a6/WAL%20Segment%E1%84%8B%E1%85%B4%20%E1%84%82%E1%85%A2%E1%84%87%E1%85%AE%20%E1%84%85%E1%85%A6%E1%84%8B%E1%85%B5%E1%84%8B%E1%85%A1%E1%84%8B%E1%85%AE%E1%86%BA%200e6b6c099561467cb46f36376425ec5b/Untitled.png)

# PageHeaderData

98 D0 06 00(magic) 01 00 00 00(info) 00 00 00 0E(timeline) 00 00 00 00 00 00 00 00(pageaddr) 00 00 00 00 (rem_len) 3D 25 B1 BD 78 4D 74 63(sysid) 00 00 00 01(seg_size) 00 20 00 00 (blck_size)

# 1. XLogRecord

32 00 00 00(tot_len) 00 00 00 00(xid) 68 50 01 0D 00 00 00 00(prev) 10(info) 08(rmid) 00 00(padding) 3F 20 FD 76(crc)

## XLogRecordDataHeaderShort

FF(id) 18(data_len:xl_running_xacts length.)

### xl_running_xacts

00 00 00 00(xcnt) 00 00 00 00(subxcnt) 00 B6 73 00(bool:subxid_overflow) 54 02 00 00(nextxid) 54 02 00 00(oldestXid) 53 02 00 00(latestXid)

# 2. XLogRecord

B8 00 00 00(tot_len) 54 02 00 00(xid) 28 00 00 0E 00 00 00 00(prev) 00(info) 0A(rmid) 00 00(padding) 8A E6 F0 8F(crc)

## XLogRecordDataHeaderShort

00(id) 30(data_len:xl_running_xacts length.)

### ??

12 00 70 00 20 00 05 7F 06 00 00(spc) 39 36 00 00(db) 2E 40 00 00(rel) 00 00 00 00 FF 03 00 00 00 00 20 4F 01 0D 00 00 00 00 20 00 B0 1F 00 20 04 20

00 00 00 00 D8 9F 48 00 B0 9F 48 00 54 02 00 00(t_xvac) 00 00 00 00 00 00 00 00 00 00 00 00 02 00 02 00 02 08 18 00 0B 74 65 73 74 00 00 00(”test”) 01 00 00 00(”1”) 00 00 00 00 53 02 00 00 00

00 00 00 00 00 00 00 00 00 00 00 01 00 02

00 02 08 18 00 0B 74 65 73 74(”test”) 00 00 00 10 00 00 00 00 00 00 00 02 00 02 08 18 00 0B 74 65 73 74 00 00 00(”test”) 01 00 00 00(”1”) 

02 00(Offset) 08(Flag)

# 3. XLogRecord

2E 00 00 00(tot_len) 54 02 00 00(xid) 60 00 00 0E 00 00 00 00(prev) 80(info) 01(rmid) 00 00(padding) FB 0B 62 71(crc)

## XLogRecordDataShort

FF(id) 14(data_len)

### ??

40 4C 29 88 95 90 02 00 01 00 00 00 39 36 00 00 7F 06 00 00

# 4. XLogRecord

32 00 00 00(tot_len) 00 00 00 00(xid) 18 01 00 0E 00 00 00 00(prev) 10(info) 08(rmid) 00 00(padding) 71 1B FE E4(crc)

## XLogRecordDataHeaderShort

FF(id) 18(data_len)

### xl_running_xacts

00 00 00 00(xcnt) 00 00 00 00(subxcnt) 00 B6 73 00(bool:subxid_overflow) 55 02 00 00(nextXid) 55 02 00 00(oldestXid) 54 02 00 00(latestXid)

# 5. XLogRecord

AD 00 00 00(tot_len) 55 02 00 00(xid) 48 01 00 0E 00 00 00 00(prev) 00(info) 0A(rmid) 00 00(padding) BB A8 DC AF(crc)

## XLogRecordDataHeaderShort

00 30

0F 00 68 00 20 00 05 7F 06 00 00 39 36 00 00 2B 40 00 00 00 00 00 00 FF 03 00 00 00 00 A0

00 00 0D 00 00 00 00 20 00 B8 1F 00 20 04 20 00 00 00 00 E0 9F 3C 00 B8 9F 42 00 55 02 00 00 00 00 00 00 00 00 00 00 00 00 00 00 02 00 02 00 02 08 18 00 01 00 00 00 0B 

74 65 73 74 00 00 00 00 00 00 00 51 02 00 00 00 00 00 00 00 00 00 00 00 00 00 00 01 00 02 00 02 08 18 00 FF 00 00 00 05 76 00 00 02 00 02 08 18 00 01 00 00 00 0B 74 65 73 74 02 00 08

# 6. XLogRecord

2E 00 00 00(tot_len) 55 02 00 00(xid) 80 01 00 0E 00 00 00 00(prev) 80(info) 01(rmid) 00 00(padding) 00 9A 04 31(crc) 

## XLogRecordDataHeaderShort

FF 14

0B 5D 1D 89 95 90 02 00 01 00 00 00 39 36 00 00 7F 06 00 00

# 7. XLogRecord

32 00 00 00(tot_len) 00 00 00 00(xid) 30 02 00 0E 00 00 00 00(prev) 10(info) 08(rmid) 00 00(padding) EA 4A C7 FB(crc) 

## XLogRecordDataHeaderShort

FF 18 

### xl_running_xacts

00 00 00 00(xcnt) 00 00 00 00(subxcnt) 00 B6 73 00(bool:subxid_overflow) 56 02 00 00(nextXid) 56 02 00 00(oldestXid) 55 02 00 00(latestXid)

[00000001000000000000000Eeeee](./New Page/00000001000000000000000Eeeee.txt)