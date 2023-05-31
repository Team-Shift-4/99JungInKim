# Logdump 명령어

# Logdump 실행

```bash
./Logdump
```

| 명령어 | 설명 |
| --- | --- |
| open ./dirdat/<fullfilename> | trail file 열기 |
| nexttrail | 다음 trail file 열기 |
| fileheader on | Trail File Header 출력 |
| ghdr on | Record Header 출력 |
| detail on | Column Infomation 추가 출력 |
| detail data | Hex값과 ASCII 값 추가 출력 |
| reclen <value> | value만큼 recode data가 화면에 출력 |
| pos 0 | 시작점으로 이동 |
| n(next) <value> | 1 record 출력, value 있을 시 value만큼 출력 |
| count | Trail File의 정보 출력 |
| usertoken detail |  |
| ggstoken detail |  |
| headertoken detail |  |
| filter rectype <type> | type인 Record만 표시 |

```
Logdump 227 >n

___________________________________________________________________
Hdr-Ind    :     E  (x45)     Partition  :     .  (x0c)
UndoFlag   :     .  (x00)     BeforeAfter:     A  (x41)
RecLength  :    29  (x001d)   IO Time    : 2022/12/06 06:58:06.893.315
IOType     :     5  (x05)     OrigNode   :   255  (xff)
TransInd   :     .  (x03)     FormatType :     R  (x52)
SyskeyLen  :     0  (x00)     Incomplete :     .  (x00)
AuditRBA   :          0       AuditPos   : 24897368
Continued  :     N  (x00)     RecCount   :     1  (x01)

2022/12/06 06:58:06.893.315 Insert               Len    29 RBA 82867
Name: test.test_f  (TDR Index: 2)
After  Image:                                             Partition x0c   G  s
0000 0a00 0000 0000 0000 0000 0001 0100 0b00 0000 | ....................
0700 7465 7374 696e 67                            | ..testing
Column 0 (0x0000), Length 10 (0x000a).
Column 1 (0x0001), Length 11 (0x000b).

GGS tokens:
TokenID x4c 'L' LOGCSN           Info x00  Length   17
3030 3030 3030 3030 2f30 3137 4245 3837 30        | 00000000/017BE870
TokenID x36 '6' TRANID           Info x00  Length    3
3634 35                                           | 645
```

Transaction을 포함한 Record Header Infomation

I/O Type

Operation Type

Image Type(Before / After)

Source Table Name

Record 작성 시각

Record Data의 Hex

Record Data의 ASCII

```
fileheader on
ghdr on
detail on
detail data
usertoken detail
ggstoken detail
headertoken detail

```