# 5. Concurrency Control(CC)

# CC

- CC는 DB에서 여러 Tx가 동시 실행될 때 ACID의 두 속성인 원자성과 독립성을 유지하는 매커니즘
- MVCC(Multi-Version CC), S2PL(Strict 2-Phase Locking), OCC(Optimistic CC)의 세 CC가 있음
    - MVCC에서 각 쓰기 작업은 이전 버전을 유지하며 데이터 항목의 새 버전을 생성
        - Tx이 Data 항목을 읽을 때 System은 개별 Tx의 독립성 보장을 위해 버전 중 하나 선택
        - 장점으로 Reader와 Writer가 서로를 차단하지 않은 점
    - S2PL 기반 System은 Writer가 항목에 대한 배타적 Lock을 획득해 작성할 때 차단
- PostgreSQL 및 일부 RDBMS는 SI(Snapshot Isolation)라고 하는 MVCC 변형을 사용
- SI를 구현하기 위해 Oracle등의 일부 RDBMS는 Rollback Segment를 사용
    - 새 Data 항목을 쓸 때 항목 이전 버전이 Rollback Segment에 기록된 후 덮어씀
    - PostgreSQL은 항목을 읽을 때 Visibility Check Rules을 적용해 개별 Tx에 대해 알맞은 버전을 제공해 줌
- SI는 ANSI SQL-92 표준에 정의된 세 가지 예외를 허용하지 않음
(Dirty Reads, Non-Repeatable Reads, Phantom Reads)
    - SI는 Write Skew 및 Read Only Tx Skew 같은 직렬화 이상을 허용
    - 위 문제(직렬화 이상 허용)를 해결하기 위해 SSI(Serializable SI)가 Ver 9.1에 추가됨

## PostgreSQL의 Tx 독립성 Level

| Isolation Level | Dirty Reads | Non-repeatable Read | Phantom Read | Serialization Anomaly |
| --- | --- | --- | --- | --- |
| READ COMMITTED | 불가 | 가능 | 가능 | 가능 |
| REPEATABLE READ | 불가 | 불가 | PG에서 불가,
ANSI SQL은 가능 | 가능 |
| SERIALIZABLE | 불가 | 불가 | 불가 | 불가 |
- `REPEATABLE READ`: Ver 9.0 이하에서는 `SERIALIZABLE`로 사용
Ver 9.1에서 SSI가 구현된 후 `REPEATABLE READ`로 변경되었음

<aside>
⚠️ PostgreSQL은 DML(`SELECT`, `UPDATE`, `INSERT`, `DELETE`)에 SSI 사용
DDL(`CREATE TABLE` 등)에 2PL 사용

</aside>