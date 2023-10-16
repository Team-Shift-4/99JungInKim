# Shrink?

Shrink는 데이터의 저장된 구조를 변경하는 것이다.

블럭에 적재된 데이터의 양이 들쑥날쑥하고, Row-Chaining등이 많다면 동일한 데이터라도 Table을 읽을 때 시간이 많이 걸리는데 이를 Trigger로 인한 추가적인 DB 변경은 발생하지 않으나 실제 Row를 DELETE/INSERT 작업을 통해 재정렬하는 것이기에 Archive Log File이 대량으로 생성될 수 있다.

어떤 세그먼트를 위해 공간이 크게 할당된 경우 HWM 이후 공간은 사용되지 않은 채로 남아 있게 될 수 있다.
또 HWM 이전의 영역에서도 누적된 DELETE 연산의 결과로 빈 공간이 많이 존재할 수 있다.
위와 같은 경우에 아래와 같은 문제점이 발생할 수 있다.

-   데이터보다 많은 블록에 걸쳐 흩어져서 스캔 시 많은 I/O 발생
-   내부 단편화로 인해 Row-Chaining / Row Migration이 일어날 가능성이 높다.
-   전체적으로 공간 낭비가 발생한다.

Oracle 9i까지는 이런 문제점들을 해결하기 위해 해당 오브젝트를 이동하거나 재생성하는 것이였으나 10g 이후로 Segment Shrink 기능을 제공한다.

## Segment Shrink의 원리

Segment Shrink는 아래 두 단계에 걸쳐 이뤄진다.

-   Data Compact
    -   실제 데이터가 바뀌는 것은 아니기에 DML Trigger가 정의되어 있어도 발생하지 않는다.
    -   Segment Shrink가 Row-Chaining을 완전히 제거하는 것을 보장하진 않는다.
    -   DML과 같은 방식으로 이뤄지므로 Index Dependency는 자동으로 처리된다.
        -   다만 IOT에 대한 2차 Index는 Shrink 직후 재생성하는 것을 권장한다.
    -   Data Compact는 HWM 아래 영역의 Hole들을 채우는 작업이며 내부적으로는 INSERT/DELETE 연산으로 이뤄진다.
        -   HWM에 가까이 있는 행을 안쪽 빈 공간에 INSERT하고 해당 행을 DELETE하여 행을 옮기는 것이다.
-   Push Down HWM
    -   Data Compact로 인해 HWM에서 먼 쪽은 데이터가 촘촘히 채워지고 HWM 가까이는 비어있는 상태가 된다.
    -   HWM를 내리고 새롭게 설정된 HWM 이후 공간을 해당 Tablespace에 반납함으로써 Segment Shrink가 완료된다.

Segment Shrink는 Online이자 In-Space 연산이다.
다만 1단계에서 통상의 Row-Level Lock을 획득애햐 할 뿐 다른 세션의 DML을 불허하진 않는다(Object 가용성이 제한되지 않는다).
2단계에서 HWM를 내리는 데 필요한 Exclusive Table Lock의 경우 매우 짧은 시간 동안만 필요하다.

## Segment Shrink의 조건

1.   오직 Automatic Segment Space Management를 사용하는 Tablespace 내의 Segment만이 Shrink 가능하다.
     데이터의 Compaction 정보는 Segment Header의 Bitmap Block을 이용하기 때문이다.
     하지만 아래 세그먼트들은 ASSM Tablespace 내에 있더라도 Shrink 될 수 없다.
     -   Temp Segment, Undo Segment
     -   Cluster 내의 Table
     -   LONG Column을 가진 Table
     -   ROWID 기반의 Materialized View가 정의된 Table
     -   LOB Index
     -   IOT Mapping Table
     -   IOT Overflow Segment
     -   Shared LOB Segment
2.   Data Compaction 단계에서 RowID가 변경되므로 해당 Segment에 대해 미리 ROW MOVEMENT가 Enable 되어야 한다.

## SHRINK SPACE COMMAND

```sql
ALTER TABLE <table_name> SHRINK SPACE [COMPACT] [CASCADE];
```

-   Table 말고도  Segment Shrink를 지원하는 모든 Object들에 대해 위와 같은 명령을 사용할 수 있다.
-   COMPACT 옵션이 사용될 경우 Data Compaction까지 수행한다.
-   CASCADE 옵션이 사용될 경우 Segment Shrink는 Dependent한 Object들에 대해서도 자동으로 수행되게 된다.