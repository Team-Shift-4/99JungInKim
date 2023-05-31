# 5. Serializable Snapshot Isolation(SSI)

# SSI 시행을 위한 기본 전략

- 생성된 Cycle이 우선순위 그래프가 충돌이 생기면 Serialization 이상이 발생
    - `Write-Skew`등

![Write-Skew Schedule 및 우선 순위 그래프](./5 Serializable Snapshot Isolation(SSI)/Untitled.png)

Write-Skew Schedule 및 우선 순위 그래프

- 개념적으로 충돌에는 세 유형이 있음
    - `wr-conflicts`(Dirty Reads) → PostgreSQL 자체 방지
    - `ww-conflicts`(`UPDATE` 손실) → PostgreSQL 자체 방지
    - `rw-conflicts` → SSI 구현으로 방지 고려
- PostgreSQL은 SSI 구현을 위해 세 전략을 취함
    - Tx이 Access하는 모든 Object(Tuple, Page, Relation)을 `SIREAD LOCK`으로 기록
    - Heap 또는 Index Tuple이 작성될 때마다 `SIREAD LOCK`을 사용해 `rw-conflicts` 감지
    - 감지된 `rw-conflict`를 확인해 Serialization 이상이 발생하면 Tx `ABORT`

# PostgreSQL에서의 SSI 구현

<aside>
ℹ️ 충돌이 감지되는 기법은 [predicate.c](https://github.com/postgres/postgres/blob/master/src/backend/storage/lmgr/predicate.c) 참고

</aside>

- `SIREAD LOCK`
    - 내부적으로 `predicate lock`이라 함
    - Object와 누가 어떤 Object에 Access 했는지에 대한 정보를 저장하는 (virtual) txid 쌍
        - 설명 단순화를 위해 virtual txid 대신 txid 사용
    - `SERIALIZABLE` Mode에서 하나의 DML Command가 실행될 때마다 `CheckTargetForConflictsOut()` 함수에 의해 생성
        - ex) txid 100이 Table의 `Tuple_1`을 읽으면 `SIREAD LOCK` `{Tuple_1, {100}}` 생성
        다른 Tx(txid 101)이 `Tuple_1`을 읽으면 `SIREAD LOCK` `{Tuple_1, {100, 101}}`로 `UPDATE`
    - `SIREAD LOCK`은 Tuple, Page, Relation의 세 가지 Level이 있음
    - 단일 Page 내 모든 Tuple이 `SIREAD LOCK`이 되면 해당 Page에 단일 `SIREAD LOCK`으로
      생성되고 연결된 Tuple의 모든 `SIREAD LOCK`이 해제되어 Memory 공간이 줄어듬
        - Page도 동일함
    - Index에 대한 `SIREAD LOCK`을 생성할 때 Page Level의 `SIREAD LOCK` 생성
    - Sequential Scan할 때에도 조건에 상관없이 Relation Level의 `SIREAD LOCK` 생성
- `rw-conflict`
    - SIREAD LOCK과 SIREAD LOCK을 읽고 쓰는 두 txid의 삼중항(Triplet)
    - 함수 `CheckTargetForConflictsIn()`은 `SERIALIZABLE` Mode에서 `INSERT`, `UPDATE`, `DELETE` Command가 실행때마다 호출되며 `SIREAD LOCK`을 확인해 충돌 감지 시 `rw-conflict` 생성
        - ex) txid 100이 `Tuple_1`을 읽은 후 txid 101을 `Tuple_1`을 `UPDATE`
        txid 101의 `UPDATE` Command에 의해 호출된 `CheckTargetForConflictsIn()`은 txid 100과 txid 101에서 `Tuple_1`의 `rw-conflict`를 감지해
        `rw-conflict` `{r=100, w=101, {Tuple_1}}`을 생성
- 함수 `CheckTargetForConflictOut()`, `CheckTargetForConflictIn()`와 `COMMIT` Command가 `SERIALIZABLE` Mode에서 실행될 때 호출되는 `ProCommit_CheckForSerializationFailure()` 함수는 생성된 `rw-conflict`를 사용해 Serialization 이상을 확인
    - 이상을 감지하면 첫 `COMMIT`된 Tx만 `COMMIT`되고 다른 Tx는 `ABORT`(`first-committer-win`)

# SSI 수행 방식

```sql
CREATE TABLE tbl (id INT primary key, flag bool DEFAULT false);
INSERT INTO tbl (id) SELECT generate_series(1,2000);
ANALYZE tbl;
```

![`Write-Skew` Scenario](./5 Serializable Snapshot Isolation(SSI)/Untitled%201.png)

`Write-Skew` Scenario

![`Write-Skew` Scenario의 Index와 Table의 Relation](./5 Serializable Snapshot Isolation(SSI)/Untitled%202.png)

`Write-Skew` Scenario의 Index와 Table의 Relation

- 모든 Command가 Index-Scan을 사용한다고 가정
    - Command가 실행될 때 해당 Heap Tuple을 가리키는 Index Tuple을 각각 포함하는 Heap Tuple과 Index Page를 모두 읽음
- `T1`: `Tx_A`는 `SELECT` Command 실행, Heap Tuple(`Tuple_2000`)과 PK(`Pkey_2`)의 한 Page 읽음
- `T2`: `Tx_B`는 `SELECT` Command 실행, Heap Tuple(`Tuple_1`)과 PK(`Pkey_1`)의 한 Page 읽음
- `T3`: `Tx_A`는 `UPDATE` Command 실행해 `Tuple_1` `UPDATE`
- `T4`: `Tx_B`는 `UPDATE` Command실행해 `Tuple_2000` `UPDATE`
- `T5`: `Tx_A`가 `COMMIT`
- `T6`: `Tx_B` `COMMIT` 하나 `Write-Skew` 이상으로 인해 `ABORT`

![SIREAD LOCK 및 rw-conflict, `Write-Skew` Scenario의 Schedule](./5 Serializable Snapshot Isolation(SSI)/Untitled%203.png)

SIREAD LOCK 및 rw-conflict, `Write-Skew` Scenario의 Schedule

- `T1`: `Tx_A`의 `SELECT` Command 실행할 때 `CheckTargetForConflictsOut()`은 `SIREAD LOCK`생성
이 Scenario에서 `CheckTargetForConflictsOut()`는 두  `SIREAD LOCK`(`L1` 및 `L2`) 생성
`L1` 및 `L2`는 각각 `Pkey_2` 및 `Tuple_2000`과 연결
- `T2`: `Tx_B`의 `SELECT` Command 실행할 때 `CheckTargetForConflictsOut()`은
두 `SIREAD LOCK`(`L3` 및 `L4`) 생성, `L3` 및 `L4`는 각각 `Pkey_1` 및 `Tuple_1`과 연결
- `T3`: `Tx_A`의 `UPDATE` Command 실행할 때 `ExecUpdate()` 전후 `CheckTargetForConflictsOut()`, `CheckTargetForConflictsIN()` 모두 호출
이 Scenario에서 `CheckTargetForConflictsOut()`은 아무 작업도 수행하지 않음
`CheckTargetForConflictsIn()`은 `Pkey_1`, `Tuple_1`이 모두 `Tx_B`에서 읽고 `Tx_A`에서 쓰기 때문
`Tx_B`와 `Tx_A` 사이에서 `Pkey_1`과 `Tuple_1`의 `rw-conflict` `C1` 생성
- `T4`: `Tx_B`의 `UPDATE` Command 실행할 때 `CheckTargetForConflictsIn()`은 `Tx_A`와 `Tx_B`
사이의 `Pkey_2`와 `Tuple_2000`의 `rw-conflict` `C2` 생성
이 Scenario에서 `C1`과 `C2`는 우선 순위 그래프에서 Cycle 만듬
`Tx_A` 및 `Tx_B`는 Serialization 할 수 없는 상태
`Tx_A` 및 `Tx_B` Tx 둘 다 `COMMIT`하지 않아 `CheckTargetForConflictsIn()`은 `Tx_B`를 `ABORT`안함
PostgreSQL의 SSI 구현이 `first-committer-win`방식 기반이기에 발생
- `T5`: `Tx_A`가 `COMMIT`시도 시 `PreCommit_CheckForSerializationFailure()` 호출
이 함수는 Serialization 이상을 감지하고 가능한 경우 `COMMIT` 실행 가능
이 Scenario에서 `Tx_B`가 `IN_PROGRESS`이므로 `Tx_A` `COMMIT`
- `T6`: `Tx_B`가 `COMMIT`시도 시 `PreCommit_CheckForSerializationFailure()`가
Serialization 이상 감지 
`Tx_A`가 이미 `COMMIT` 되어 `Tx_B`는 `ABORT`
- 그림 (1): `Tx_A`가 `COMMIT`된 후(`T5`) `Tx_B`에 의해 `UPDATE` Command가 실행되면 `Tx_B`의 `UPDATE` COMMAND에 의해 호출된 `CheckTargetForConflictsIn()`이 Serialization 이상 감지
    - `Tx_B` `ABORT`
- 그림 (2): `T6`에서 `COMMIT`대신 `SELECT` Command가 실행되면 `Tx_B`의 `SELECT` Command에
  의해 호출된 `CheckTargetForConflictsOut()`이 Serialization 이상 감지
    - `Tx_B` `ABORT`

![다른 `Write-Skew` Scenario](./5 Serializable Snapshot Isolation(SSI)/Untitled%204.png)

다른 `Write-Skew` Scenario

# **False-Positive Serialization 이상 현상**

![false-positive serialization anomaly 발생 Scenario](./5 Serializable Snapshot Isolation(SSI)/Untitled%205.png)

false-positive serialization anomaly 발생 Scenario

- `SERIALIZABLE` Mode에서는 false-negative Serialization 이상 현상이 감지되지 않음
    - 동시 Tx의 Serialization 완전 보장
    - false-positive anomalies가 감지될 수 있음
    - SERIALIZABLE Mode를 사용할 때 염두

![False-positive anomaly - Sequential Scan 사용 Scenario](./5 Serializable Snapshot Isolation(SSI)/Untitled%206.png)

False-positive anomaly - Sequential Scan 사용 Scenario

- Sequential Scan을 사용하는 경우 `SIREAD LOCK`을 생성
- 위 그림은 PostgreSQL이 Sequential Scan을 사용할 때 `SIREAD LOCK` 및 `rw-conflicts` 발생
    - tbl의 `SIREAD LOCK`과 관련된 `rw-conflicts` `C1`, `C2`가 생성되고 순환 발생
        - False-positive `Write-Skew` Anomaly 감지(충돌 없어도 `Tx_A` 또는 `Tx_B`가 `ABORT`)

![False-positive anomaly - 같은 Index Page에서의 Index Scan 사용 Scenario](./5 Serializable Snapshot Isolation(SSI)/Untitled%207.png)

False-positive anomaly - 같은 Index Page에서의 Index Scan 사용 Scenario

- Index Scan을 사용하는 경우 `Tx_A`와 `Tx_B` 모두 동일한 Index `SIREAD LOCK`을 받으면 이상 감지
    - Index Page의 `Tx_A`와 `Tx_B` 각각 `SELECT`, `UPDATE` 명령 실행할 때 `Pkey_1`에서 읽고 씀
    - `Pkey_1`과 관련된 `rw-conflicts` `C1`, `C2`가 생성되고 순환 발생
        - False-positive `Write-Skew` Anomaly 감지
        (`Tx_A`와 `Tx_B`가 다른 Index Page의 `SIREAD LOCK`을 얻으면 모두 `COMMIT`가능)