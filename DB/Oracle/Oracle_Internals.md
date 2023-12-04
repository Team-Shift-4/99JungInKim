해당 문서는 [juliandyke.com](juliandyke.com)을 기반으로 작성되었다.
Juliandyke의 경우 Oracle 10i 기준으로 작성이 되어 차후 다른점을 Confluence에 숨김 문서로 작성할 예정이다.

# Redo Operations

## Redo

DB에 대한 모든 변경 사항은 Redo에 의해 기록된다.
Redo에는 데이터 파일에 대한 모든 변경 사항이 포함되나 컨트롤 파일이나 파라미터 파일에 대한 변경 사항은 포함되지 않는다.

Redo는 초기에 Online Redo Log에 기록된다.
Redo Log File의 내용은 Oracle 버전이나 OS, 서버 아키텍처의 조합에 따라 달라지게 된다.
일반적으로 한 아키텍처에 작성된 Redo Log는 다른 아키텍처에서 읽을 수 없다.
위 예외는 Oracle 10.2의 Linux에서 작성된 Redo Log를 Windows DB에서 읽을 수 있는 사례가 있다.

### Redo Threads

각 Online Redo Log에는 Thread Number와 Sequence Number가 있다.
Thread Number는 주로 여러 Thread가 있는 RAC DB와 관련이 있다.
Thread Number는 Instance Number와 반드시 동일할 필요는 없다.
Single Instance DB의 경우 항상 하나의 Redo Log Thread만 있다.

### Redo Log Groups

Redo Thread는 두 개 이상의 Redo Log Group으로 구성된다.

각 Redo Log Group에는 Member라고 하는 하나 이상의 물리적 Redo Log File이 포함되어 있다.
Mirroring을 하기 위해 여러 Member가 제공된다(미디어 오류에 대한 보호를 위해).
Redo Log Group 내의 모든 Member는 항상 동일해야 한다.

각 Redo Log Group에는 상태가 있다.
가능한 상태는 `UNUSED`, `CURRENT`, `ACTIVE`, `INACTIVE`가 포함된다.
처음에는 Redo Log Group이 `UNUSED` 상태이다.
`CURRENT` 상태인 Redo Log Group은 항상 하나여야 한다.
Log Switch 이후 Redo Log Group은 Checkpoint가 완료될 때 까지 항상 `ACTIVE` 상태를 유지한다.
Checkpoint 완료 후 Redo Log Group은 LGWR Background Process(이하 LGWR)에서 재사용될 때 까지 `INACTIVE` 상태가 된다.

### Log Switches

Online Redo Log가 가득 차면 Log Switch가 발생한다.
아래의 명령을 사용해 Log Switch를 외부에서 발생시킬 수 있다.

```sql
ALTER SYSTEM SWITCH LOGFILE;
```

Log Switch가 발생하면 Sequence Number가 증가하고 Sequence의 다음 파일에서 계속해서 Redo가 기록된다.
Archive Logging이 활성화된 경우 Log Switch가 완료된 Online Redo Log는 구성에 따라 ARCH Background Process(이하 ARCH) 또는 LNSn Background Process(이하 LNSn)에 의해 Archive Log 대상에 복사된다.

### Redo Log Files

Redo Log File은 고정된 크기의 Block으로 구성된다.
Redo Log File의 전체 크기는 Log Group 생성 시 지정된다.
Redo Log Block 크기는 Linux와 Solaris를 포함한 대부분의 플랫폼에서는 512 Byte이며 HP/UX 등의 몇몇 플랫폼에서는 1024이다.

각 Redo Log File에는 고정된 Header가 있다.
Oracle 8.0 이상에서는 이 Header가 두 개의 Block이다.
Header의 두 번째 Block에는 아래 정보를 포함하는 표준 Oracle File Header가 포함되어 있다.

-   DB Name
-   Thread
-   Compatibility Version
-   Start Time
-   End Time
-   Start SCN
-   End SCN

다른 Data들은 Header에 저장된다.
End SCN은 실제 다음 Redo Log File의 Start SCN이다.

### Redo Blocks

Redo Log File의 본문은 Redo Block을 저장하는 데 사용된다.
각 Redo Block에는 16 Byte Header가 있다.
각 Redo Block의 나머지 부분은 Redo Record를 저장하는 데 사용된다.

### Redo Records

Redo Record는 논리적 구조이다.
크기 상한은 아마도 65536 Byte 일 것이다(확인 필요).
Redo Record는 여러 물리적 Redo Block에 걸쳐 있을 수 있다.
물리적 Redo Block에는 여러 Redo Record가 포함될 수 있다.

각 Redo Record에는 Header가 있다.
Redo Record Header의 VLD Field는 Redo Record의 타입을 지정한다.
Redo Record Header의 크기는 유형에 따라 다르다.

Oracle 9.2에서 Redo Record Header는 일반적으로 12 Byte이나 때때로 크기가 28 Byte로 늘어날 수 있다.
Oracle 10.2에서 Redo Record Header는 일반적으로 24 Byte이나 일부 상황에서 68 Byte까지 늘어날 수 있다.

아래는 Oracle 10.2의 Redo Record Header의 예시이다.

```
REDO RECORD - Thread:1 RBA: 0x000092.00000193.0088 LEN: 0x0050 VLD: 0x01
SCN: 0x0000.00181068 SUBSCN:  1 05/07/2009 21:53:48
```

Redo Record Header는 아래의 Field들이 포함된다.

-   Thread: Redo Log Thread 숫자
-   RBA: Redo Byte Address, Redo Log 내의 Redo Record 주소(`<sequence>.<block_number>.<offset>`)
-   LEN: Header를 포함한 Redo Record의 Byte 길이
-   VLD: 아래 참조
-   SCN: Redo Record의 System Change Number
-   SUBSCN: 알 수 없음
-   Timestamp: 시간 값

VLD Field는 Redo Record Header의 크기를 결정한다.
Oracle 9i에 대해 알려진 값은 아래와 같다(Release마다 다를 수 있다).

| Mnemonic | Value | Description                                                  |
| -------- | ----- | ------------------------------------------------------------ |
| KCRVOID  | 0     | 내용이 올바르지 않음                                         |
| KCRVALID | 1     | Change Vactor 포함                                           |
| KCRCOMIT | 2     | Commit SCN 포함                                              |
| KCRDEPND | 4     | Dependent SCN 포함                                           |
| KCRNMARK | 8     | New SCN Mark Record<br />이 Instance에 의해 Redo Log의 이 시점에 정확히 할당된 SCN |
| KCROMARK | 16    | Old SCN Mark Record<br />SCN은 Redo의 이 시점이나 그 이전에 할당됨<br />다른 Instance에 의해 할당될 수 있음 |
| KCRORDER | 32    | SCN 별로 Redo를 정렬할 때 일부 Block에 대한 Redo가 Inc/seq# 별로 정렬되도록 새 SCN이 할당됨 |

### Change Vectors

Redo Record는 Change Vector라고 불리는 하나 이상의 Change Record로 구성된다.
각 Change Vector는 아래의 내용들로 구성된다.

-   Change Header
-   Element 길이 목록
-   Element 목록

Change Header의 크기는 Oracle 9.2와 10.2 모두 28 Byte이다.

Element 길이 목록에는 Element 길이를 Byte 단위로 지정하는 2 Byte Header가 있다.
각 요소의 길이는 2 Byte Field에 저장된다.
마지막으로 구조가 4 Byte 경계에 정렬되지 않을 경우 추가로 2 Byte Field가 추가된다.

Element 목록은 4 Byte 경계에 정렬된 하나 이상의 Element로 구성된다.
Element의 크기는 4 Byte부터 32 KB까지 가능하다.

Update Operation에 대해 Supplemental Logging이 활성화된 경우 Row의 PK, UK나 Column 값들을 포함하는 Change Vector가 Element 목록에 추가된다.

### Operation Codes

각 Change Vector에는 Operation Code가 있다.
Oracle 9.2에는 150개 이상의 Redo Log Operation이 있다.
이 숫자는 Oracle 10.2에서 크게 증가하였으나 정확한 수치는 알려져 있지 않다.
Operation Code는 Major와 Minor Number로 구성된다.

Major Number는 Redo가 생성되는 Kernel의 Level을 나타낸다.
아래 표에 일반적인 Level이 나와 있다.

| Level | Description                     |
| ----- | ------------------------------- |
| 4     | Block Cleanout                  |
| 5     | Transaction Layer (Undo)        |
| 10    | Index Operation                 |
| 11    | Table Operation (DML)           |
| 13    | Block Allocation                |
| 14    | Extent Allocation               |
| 17    | Backup Management               |
| 18    | Online Backup                   |
| 19    | Direct Load                     |
| 20    | Transaction Metadata (LogMiner) |
| 22    | Space Management (ASSM)         |
| 23    | Physical I/O Block Operation    |
| 24    | DDL Statement                   |

각 Level에는 하나 이상의 Subcode가 존재한다.

#### Level 4

##### 4.1 Block Cleanout

이 Redo가 생성되고 Block Cleanout을 수행한다.
Block Cleanout은 Block의 Transaction Header에 있는 정보가 더 이상 Undo Header의 Transaction 정보와 일치하지 않을 때 발생한다.

예시

```
REDO RECORD - Thread:1 RBA: 0x0000ac.00000134.0080 LEN: 0x0048 VLD: 0x01
SCN: 0x0000.003ddf71 SUBSCN:  1 08/27/2015 03:33:09
CHANGE #1 TYP:0 CLS:1 AFN:1 DBA:0x004138ac OBJ:458 SCN:0x0000.003c92b9 SEQ:1 OP:4.1 ENC:0 RBL:0
Block cleanout record, scn:  0x0000.003ddf71 ver: 0x01 opt: 0x02, entries follow...
  itli: 2  flg: 2  scn: 0x0000.003c92b9
```

위 예시에서 Redo Record는 72 Byte이다.
Redo Record Header는 24 Byte이다.
Chnage Header는 28 Byte이다.
하나의 Redo Element가 있으므로 Redo Vector는 2 Byte이다 (+ 2 Byte 정렬)
첫 번째 Element는 20 Byte이다.

아래는 Element의 Hex이다.

```
00010102 003DDF71 00000000 00000202 003C92B9
```

##### 4.6 Commit Time Block Cleanout Change

이 Redo는 Commit 시 Block Cleanout이 필요하므로 생성된다.

이 작업은 `db_lost_write_protect` Parameter가 `TYPICAL`로 설정된 경우 Update된 Block에 대해 관찰되었다.

아래는 Indexing 되지 않은 Column의 단일 Row Update Operation에 대해 다음 Redo가 생성된 예시이다.

```
REDO RECORD - Thread:1 RBA: 0x00009b.00000125.0010 LEN: 0x0078 VLD: 0x05
SCN: 0x0000.003b85b3 SUBSCN:  1 08/26/2015 22:43:37
(LWN RBA: 0x00009b.00000125.0010 LEN: 0001 NST: 0001 SCN: 0x0000.003b85b3)
CHANGE #1 TYP:0 CLS:1 AFN:1 DBA:0x00415ceb OBJ:75819 SCN:0x0000.003b85b2 SEQ:1 OP:4.6 ENC:0 RBL:0
 ktbcc redo -  Commit Time Block Cleanout Change
xid:  0x0008.01e.00000761  scn:  0x0000.003b85b2  itli: 1
```

위 예시에서 Redo Record Header는 LWN 구조를 포함하므로 68 Byte이다.

아래는 동일한 Row의 다른 예시이다.

```
REDO RECORD - Thread:1 RBA: 0x0000a0.00000170.0120 LEN: 0x004c VLD: 0x01
SCN: 0x0000.003c7e61 SUBSCN:  1 08/26/2015 23:01:06
CHANGE #1 TYP:0 CLS:1 AFN:1 DBA:0x00415ceb OBJ:75819 SCN:0x0000.003c7e61 SEQ:1 OP:4.6 ENC:0 RBL:0
 ktbcc redo -  Commit Time Block Cleanout Change
xid:  0x0004.01f.000006b4  scn:  0x0000.003c7e61  itli: 1
```

Redo Record 길이는 76 Byte이다.
Redo Record Header는 LWN 구조를 포함하지 않으므로 24 Byte이다.
Change Header는 28 Byte이다.
Element Vector는 4 Byte이다.(각 요소 당 2 Byte, 정렬 없음)
첫 번째 Element Vector는 16 Byte이다.
첫 번째 Vector에는 SCN과 xid가 포함되어 있다.
두 번째 Element Vector는 4 Byte이다.
두 번째 Vector는 1 Byte를 4 Byte로 올림 한 것이다.

아래는 첫 Element의 Hex이다.

```
003C7E61 00000000 001F0004 000006B4
```

아래는 두 번째 Element의 Hex이다.

```
00000001
```

두 번째 Vector에는 ITL Index(itli)가 포함되어 있다.
다음 표는 LWN이 있거나 없는 단일 변경 Record의 크기(Byte)를 보여준다.

|             | Structure          | With LWN | Without LWN |
| ----------- | ------------------ | -------- | ----------- |
| REDO RECORD | Redo Record Header | 24       | 24          |
| CHANGE #1   | Change Header      | 28       | 28          |
|             | Element Vector     | 4        | 4           |
|             | Element 1          | 16       | 16          |
|             | Element 2          | 4        | 4           |
| Total       |                    | 120      | 76          |

Redo Record에는 여러 4.6 Commit Time Block Cleanout Change를 포함할 수 있다.

아래는 예시이다.

```
REDO RECORD - Thread:1 RBA: 0x0000a0.0000001e.0010 LEN: 0x00ac VLD: 0x05
SCN: 0x0000.003c7db3 SUBSCN:  1 08/26/2015 23:00:59
(LWN RBA: 0x0000a0.0000001e.0010 LEN: 0005 NST: 0001 SCN: 0x0000.003c7db3)
CHANGE #1 TYP:0 CLS:1 AFN:2 DBA:0x00800fdb OBJ:6176 SCN:0x0000.003c7db0 SEQ:1 OP:4.6 ENC:0 RBL:0
 ktbcc redo -  Commit Time Block Cleanout Change
xid:  0x0008.006.00000765  scn:  0x0000.003c7db2  itli: 2
CHANGE #2 TYP:0 CLS:1 AFN:2 DBA:0x00800fd3 OBJ:6175 SCN:0x0000.003c7db0 SEQ:1 OP:4.6 ENC:0 RBL:0
 ktbcc redo -  Commit Time Block Cleanout Change
xid:  0x0008.006.00000765  scn:  0x0000.003c7db2  itli: 2
```

위의 예시에서 Redo Record Header에는 LWN 구조가 있다.
Redo Record에는 두 가지 변경 사항이 있다.
다음 표는 LWN이 있거나 없는 두 Change Record의 크기(Byte)를 보여준다.

|             | Structure          | With LWN | Without LWN |
| ----------- | ------------------ | -------- | ----------- |
| REDO RECORD | Redo record header | 68       | 24          |
| CHANGE #1   | Change header      | 28       | 28          |
|             | Element vector     | 4        | 4           |
|             | Element 1          | 16       | 16          |
|             | Element 2          | 4        | 4           |
| CHANGE #2   | Change header      | 28       | 28          |
|             | Element vector     | 4        | 4           |
|             | Element 1          | 16       | 16          |
|             | Element 2          | 4        | 4           |
| Total       |                    | 172      | 128         |

#### Level 10

##### 10.2 Insert Index Row

##### 10.4 Delete Index Row

##### 10.5 Restore Leaf Row

##### 10.6 Lock Index Block

##### 10.7 Clear Block Opcode during Commit

##### 10.8 Initialize New Leaf Block

##### 10.9 Save Current Leaf Block

##### 10.10 Set Pointer to next Leaf Block

##### 10.11 Set Pointer to previous Leaf Block

##### 10.12 Initialize Root Block After Split

##### 10.13 Make Index Leaf Block Empty

##### 10.14 Restored Block Before Image

##### 10.15 Insert Branch Block Row

##### 10.16 Purge Branch Block Row

##### 10.17 Initialize Branch Block

##### 10.18 Update Keydata

##### 10.35 Update Non-Key Value

#### Level 11

##### 11.1 Undo table operation

##### 11.2 Insert Row Piece(IRP)

##### 11.3 Delete Row Piece(DRP)

##### 11.4 Select for Update

##### 11.5 Update Row Piece(URP)

##### 11.11 Array Insert

##### 11.12 Array Delete(Undo Only)

##### 11.19 Array Update

#### Level 23

##### 23.1 Block Write Operation

이 Redo는 DBWn이 DB에 Physical Block Write를 수행할 때 생성된다.

##### 23.2 Block Read Operation

이 Operation은 `db_lost_write_protect`가 `TYPICAL`이나 `FULL`(확실하지 않음)로 설정된 경우 관찰되었다.

기본 DB에 `db_lost_write_protect` Parameter가 설정된 경우 Session이 Buffer Cache에 대한 Physical Read를 수행할 때 추가 Redo가 생성된다.
Physical Read는 Sequential(Single-Blcok) Read나 Scattered(Multi-Block) Read일 수 있다.
Redo에는 Block에 대한 DBA와 Last Write의 SCN이 포함된다.

`db_lost_write_protect` Parameter가 Standby에 설정된 경우 Lost Write가 감지되면 자세한 오류 메세지와 함께 Recovery가 중지된다.
아마 Lost Write는 Standby Disk에서 Physical Write를 수행하고 이를 23.2 Block Read Operation의 SCN과 비교하여 감지된다.

이 Operation은 Buffer Cache에 대한 Read에 대해서만 생성된 것으로 보인다.
Read가 PGA에 대한 Direct Read인 경우 23.2 Block Read Operation Redo가 생성되지 않는다.
이 주장은 `_serial_direct_reads` Parameter를 `NEVER`로 설정하고 `db_lost_write_protect`를 `TYPICAL`로 설정하여 확인되었다.
`db_lost_write_protect`가 `_serial_direct_reads`의 다른 값에 대해 Bufferd Read를 강제하는 것이 가능하다(가능성이 낮음).

이 Redo는 Process가 DB에서 Physical Block Read를 수행할 때 생성된다.

Single Block Read의 경우 두 가지 구조가 있는 것으로 보인다.

아래 예시는 LWN 구조를 포함한다.

```
REDO RECORD - Thread:1 RBA: 0x000095.00000002.0010 LEN: 0x0060 VLD: 0x14
SCN: 0x0000.003a7c59 SUBSCN:  1 08/26/2015 18:42:22
(LWN RBA: 0x000095.00000002.0010 LEN: 0009 NST: 0001 SCN: 0x0000.003a7c59)
CHANGE #1 TYP:2 CLS:6 AFN:1 DBA:0x0040015a OBJ:37 SCN:0x0000.0007ceeb SEQ:1 OP:23.2 ENC:0 RBL:0
 Block Read - afn: 1 rdba: 0x0040015a BFT:(1024,4194650) non-BFT:(1,346)
              scn: 0x0000.0007ceeb seq: 0x01
              flags: 0x00000006 ( dlog ckval )
```

아래 예시는 LWN 구조를 포함하지 않는다.

```
REDO RECORD - Thread:1 RBA: 0x000095.00000002.0070 LEN: 0x0034 VLD: 0x10
SCN: 0x0000.003a7c59 SUBSCN:  1 08/26/2015 18:42:22
CHANGE #1 TYP:2 CLS:6 AFN:1 DBA:0x004048a7 OBJ:228 SCN:0x0000.00024710 SEQ:1 OP:23.2 ENC:0 RBL:0
 Block Read - afn: 1 rdba: 0x004048a7 BFT:(1024,4212903) non-BFT:(1,18599)
              scn: 0x0000.00024710 seq: 0x01
              flags: 0x00000006 ( dlog ckval )
```

LWN 구조는 Redo Record에 포함되므로 LWN이 없으면 Redo Record Header는 24 Byte, 있다면 68 Byte이다.
VLD Flag는 LWN 구조가 존재하는 지 여부를 지정한다.(VLD % 0x4가 0이 아닌 경우 LWN 구조가 존재한다)
위 두 예시 모두 Change Header가 있으나 Change Vector나 Change Element가 없다.
Redo Record Header와 Change Header에 충분한 정보가 있기 때문이다.
Multi-Block Read의 경우 Redo Record에 여러 변경 사항이 포함될 수 있다.

아래는 여러 병경사항이 포함된 Redo Record의 예시이다.

```
REDO RECORD - Thread:1 RBA: 0x000095.00000017.00c4 LEN: 0x00dc VLD: 0x10
SCN: 0x0000.003a7c5d SUBSCN:  1 08/26/2015 18:42:26
CHANGE #1 TYP:0 CLS:4 AFN:1 DBA:0x00415ce1 OBJ:75819 SCN:0x0000.003a2c74 SEQ:1 OP:23.2 ENC:0 RBL:0
 Block Read - afn: 1 rdba: 0x00415ce1 BFT:(1024,4283617) non-BFT:(1,89313)
              scn: 0x0000.003a2c74 seq: 0x01
              flags: 0x00000004 ( ckval )
CHANGE #2 TYP:0 CLS:4 AFN:1 DBA:0x00415ce2 OBJ:75819 SCN:0x0000.003a2c74 SEQ:1 OP:23.2 ENC:0 RBL:0
 Block Read - afn: 1 rdba: 0x00415ce2 BFT:(1024,4283618) non-BFT:(1,89314)
              scn: 0x0000.003a2c74 seq: 0x01
              flags: 0x00000004 ( ckval )
CHANGE #3 TYP:0 CLS:4 AFN:1 DBA:0x00415ce3 OBJ:75819 SCN:0x0000.003a2c74 SEQ:1 OP:23.2 ENC:0 RBL:0
 Block Read - afn: 1 rdba: 0x00415ce3 BFT:(1024,4283619) non-BFT:(1,89315)
              scn: 0x0000.003a2c74 seq: 0x01
              flags: 0x00000004 ( ckval )
CHANGE #4 TYP:0 CLS:4 AFN:1 DBA:0x00415ce4 OBJ:75819 SCN:0x0000.003a2c74 SEQ:1 OP:23.2 ENC:0 RBL:0
 Block Read - afn: 1 rdba: 0x00415ce4 BFT:(1024,4283620) non-BFT:(1,89316)
              scn: 0x0000.003a2c74 seq: 0x01
CHANGE #5 TYP:0 CLS:4 AFN:1 DBA:0x00415ce5 OBJ:75819 SCN:0x0000.003a2c74 SEQ:1 OP:23.2 ENC:0 RBL:0
 Block Read - afn: 1 rdba: 0x00415ce5 BFT:(1024,4283621) non-BFT:(1,89317)
              scn: 0x0000.003a2c74 seq: 0x01
              flags: 0x00000004 ( ckval )
CHANGE #6 TYP:0 CLS:4 AFN:1 DBA:0x00415ce6 OBJ:75819 SCN:0x0000.003a2c74 SEQ:1 OP:23.2 ENC:0 RBL:0
 Block Read - afn: 1 rdba: 0x00415ce6 BFT:(1024,4283622) non-BFT:(1,89318)
              scn: 0x0000.003a2c74 seq: 0x01
              flags: 0x00000004 ( ckval )
CHANGE #7 TYP:0 CLS:4 AFN:1 DBA:0x00415ce7 OBJ:75819 SCN:0x0000.003a2c74 SEQ:1 OP:23.2 ENC:0 RBL:0
 Block Read - afn: 1 rdba: 0x00415ce7 BFT:(1024,4283623) non-BFT:(1,89319)
              scn: 0x0000.003a2c74 seq: 0x01
              flags: 0x00000004 ( ckval )
```

위 예시는 7개의 Block Read에 대해 생성된 Redo를 보여준다.
이 경우 생성된 Redo 길이는 220 Byte이다.
이는 24 Byte Redo Record Header와 7 * 28 Byte Change Header로 구성된다.

Redo Record에 포함될 수 있는 최대 변경 수는 20개로 나타난다.
변경 사항이 20개를 초과할 경우 추가 Redo Record가 생성된다.

Flag는 Change Header(2, 3 Byte)에 저장된다.
아래는 알려진 값이다.

-   2: dlog
-   4: ckval

Single-Block Read의 경우 Redo Record Header에는 Redo Header의 크기는 LWN 구조가 포함되면 68 Byte이고 아닐 경우 24 Byte이다.
Change Header의 크기는 28 Byte이다.
따라서 Single-Block Read에 대한 23.2 Block Read Operation Redo Record의 총 크기는 96 혹은 52 Byte이다.(SCN Header 유/무)

Multi-Block Read의 경우 새 SCN이 생성되면 Redo Header의 크기는 68이나 24 Byte이며 Change Header의 크기는 28 Byte이다.
Operation이 8개인 것을 예로 들었을 때 292나 248 Byte이다(SCN Header 유/무).

#### Level 24

##### 24.1 DDL Operation

### Log File Dumps

아래 구문을 사용해 Online Redo Log와 Archived Redo Log에 대해 Symbolic Dump를 생성할 수 있다.

```sql
ALTER SYSTEM DUMP LOGFILE '<file>'
```

Online Redo Log의 경우 Current Redo Log의 파일명은 아래 SQL문을 이용하여 얻을 수 있다.

```sql
SELECT member FROM V$LOGFILE
WHERE group# = (
	SELECT group# FROM V$LOG
	WHERE status = 'CURRENT'
);
```

