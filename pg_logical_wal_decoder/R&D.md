길이(4) txid(4) 이전 위치(8) 플래그(1) RmgrID(1) 패딩(2) CRC32(4)

RMGR과 Flag의 조합으로 어떤 이벤트인지 나타낸다.



| RMGR ID Value | Description |
| ------------- | ----------- |
| 08            | Standby     |
| 00            | XLOG        |
| 02            | Storage     |
| 09            | Heap2       |
| 0a            | Heap        |
| 0b            | Btree       |
| 01            | Transaction |
|               |             |

| xl_info | rmgr == standby  Description |
| ------- | ---------------------------- |
| 00      | XLOG_STANDBY_LOCK            |
| 10      | XLOG_RUNNING_XACTS           |
| 20      | XLOG_INVALIDATIONS           |

| xl_info | rmgr == xlog Description  |
| ------- | ------------------------- |
| 00      | XLOG_CHECKPOINT_SHUTDOWN  |
| 10      | XLOG_CHECKPOINT_ONLINE    |
| 20      | XLOG_NOOP                 |
| 30      | XLOG_NEXTOID              |
| 40      | XLOG_SWITCH               |
| 50      | XLOG_BACKUP_END           |
| 60      | XLOG_PARAMETER_CHANGE     |
| 70      | XLOG_RESTORE_POINT        |
| 80      | XLOG_FPW_CHANGE           |
| 90      | XLOG_END_OF_RECOVERY      |
| A0      | XLOG_FPI_FOR_HINT         |
| B0      | XLOG_FPI                  |
| D0      | XLOG_OVERWIRTE_CONTRECORD |

| xl_info | rmgr == heap Description |
| ------- | ------------------------ |
| 00      | XLOG_HEAP_INSERT         |
| 10      | XLOG_HEAP_DELETE         |
| 20      | XLOG_HEAP_UPDATE         |
| 30      | XLOG_HEAP_TRUNCATE       |
| 40      | XLOG_HEAP_HOT_UPDATE     |
| 50      | XLOG_HEAP_CONFIRM        |
| 60      | XLOG_HEAP_LOCK           |
| 70      | XLOG_HEAP_INPLACE        |

| xl_info | rmgr == heap2 Description |
| ------- | ------------------------- |
| 00      | XLOG_HEAP2_REWRITE        |
| 10      | XLOG_HEAP2_PRUNE          |
| 20      | XLOG_HEAP2_VACUUM         |
| 30      | XLOG_HEAP2_FREEZE_PAGE    |
| 40      | XLOG_HEAP2_VISIBLE        |
| 50      | XLOG_HEAP2_MULTI_INSERT   |
| 60      | XLOG_HEAP2_LOCK_UPDATE    |
| 70      | XLOG_HEAP2_NEW_CID        |

| xl_info | rmgr == transaction Description  |
| ------- | -------------------------------- |
| 00      | TRANSACTION_STATUS_IN_PROGRESS   |
| 01      | TRANSACTION_STATUS_COMMITTED     |
| 02      | TRANSACTION_STATUS_ABORTED       |
| 03      | TRANSACTION_STATUS_SUB_COMMITTED |
