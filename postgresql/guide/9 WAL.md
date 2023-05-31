# 9. WAL에 대한 개요

# Write Ahead Logging(WAL)

- Tx Log는 DB의 필수적인 부분
- 모든 DBMS는 System 장애가 발생하더라도 Data 손실이 일어나면 안됨
- Tx Log에는 이미 실행된 각 Tx에 대한 충분한 정보가 포함되어 있어 DB Server는 Server 충돌 시 Tx Log의 변경 사항과 작업을 재생하여 DB Cluster를 복구 할 수 있어야 함
- 컴퓨터 과학 분야의 WAL은 Write Ahead Logging의 약자로 변경 사항과 작업을 모두 Tx Log에 기록하는 Protocol 또는 규칙인 반면 PostgreSQL에서는 Write Ahead Log의 약자
- PostgreSQL의 WAL은 Tx Log의 동의어로 사용됨
- WAL 메커니즘에 대한 이해는 PostgreSQL을 사용한 시스템 통합 및 관리에 필수적

## WAL을 사용하지 않는 INSERT

- 관계된 Page에 대한 효율적인 Access를 제공하기 위해 모든 DBMS는 Shared Buffer Pool을 구현

![WAL 기능을 사용하지 않는 PostgreSQL의 TABLE_A에 일부 데이터 Row를 `INSERT`한다고 가정](./9 WAL/Untitled.png)

WAL 기능을 사용하지 않는 PostgreSQL의 TABLE_A에 일부 데이터 Row를 `INSERT`한다고 가정

1. 첫 번째 `INSERT` 문을 실행하면 PostgreSQL은 DB Cluster에서 TABLE_A의 Page를 Memory 내 Shared Buffer Pool로 로드하고 Row를 Page에 삽입
(이 Page는 DB Cluster에 즉시 기록되지 않음, Dirty Page)
2. 두 번째 `INSERT` 문을 실행하면 PostgreSQL이 Buffer Pool의 Page에 새 Row를 삽입
(이 Page 역시 Storage에 기록되지 않음)
3. 정전등의 장애로 OS 또는 PostgreSQL Server에 장애 발생 시 `INSERT`된 모든 Data가 손실이 남
- WAL이 없는 DB는 System 장애에 취약함

## INSERT 작업 및 DB Recovery

- 성능 저하 없이 위같은 System 장애를 처리하기 위해 PostgreSQL은 WAL 지원
- PostgreSQL은 오류에 대비하기 위해 모든 수정 사항을 기록 데이터로 영구 저장소에 기록
- PostgreSQL에서 History Data는 XLOG Record 또는 WAL Data로 알려져 있음
- XLOG Record는 `INSERT`, `DELETE`, `COMMIT`같은 변경 작업에 의해 Memory 내 WAL Buffer에 기록
- Tx가 `COMMIT`/중단 될 때 Storage의 WAL Segment File에 즉시 기록됨
    - XLOG Record의 쓰기가 다른 경우에 발생할 수도 있음
- XLOG Record의 LSN(Log Sequence Number)은 해당 Row가 Tx Log에 기록되는 위치를 나타냄
- Row의 LSN은 XLOG Record의 고유한 ID
- PostgreSQL은 RECO POINT 시점으로부터 Recovery함
- 마지막 Checkpoint가 시작된 시점에 XLOG Record를 기록할 위치
- DB Recovery 처리는 Checkpoint 처리와 밀접하게 연결되어 있음

![WAL을 사용한 `INSERT`](./9 WAL/Untitled%201.png)

WAL을 사용한 `INSERT`

1. Background Process인 Checkpointer는 주기적으로 Checkpoint를 수행
Checkpointer가 시작될 때 마다 Checkpoint Record라는 XLOG Record를 현재 WAL Segement에 작성(REDO Pont의 위치를 포함함)
2. 첫 `INSERT`문을 실행하면 PostgreSQL은 TABLE_A의 Page를 Shard Buffer Pool에 로드하고 Row를 Page에 `INSERT`하고 이 Command의 XLOG Record를 생성해 LSN_1의 WAL Buffer에 쓰고 TABLE_A의 LSN을 `UPDATE`함(LSN_0→LSN_1)
3. 이 Tx가 `COMMIT`되면 PostgreSQL은 `COMMIT`동작의 XLOG Record를 생성해 WAL Buffer에 쓴 다음 WAL Buffer의 모든 XLOG Record를 LSN_1에서 WAL Segment File로 쓰고 `FLUSH`
4. 두 번째 `INSERT`문을 실행하면 PostgreSQL은 Page에 새 Row를 삽입하고 이 Row의 XLOG Record를 생성해 LSN_2의 WAL Buffer에 쓰고 TABLE_A의 LSN을 LSN_1에서 LSN_2로 `UPDATE`
5. 이 Tx이 `COMMIT`되면 PostgreSQL은 3단계와 같은 방식으로 동작
6. 장애로 Shared Buffer Pool의 모든 Data가 손실되어도 Page의 모든 수정 사항은 WAL Segment File에 저장됨

![WAL을 사용한 DB Recovery](./9 WAL/Untitled%202.png)

WAL을 사용한 DB Recovery

1. PostgreSQL은 적절한 WAL Segment File에서 첫 번째 `INSERT`문의 XLOG Record를 읽고 TABLE_A의 Page를 DB Cluster에서 Shared Buffer Pool로 로드
2. PostgreSQL은 XLOG Record의 재생을 시도하기 전 XLOG Record의 LSN과 해당 Page의 LSN을 비교
    1. XLOG Record의 LSN이 Page의 LSN보다 크면 XLOG Record의 Data 부분이 Page에 `INSERT`되고 Page의 LSN이 XLOG Record의 LSN으로 `UPDATE`
    2. XLOG Record의 LSN이 Page의 LSN보다 작으면 다음 WAL Date를 읽음
3. PostgreSQL은 나머지 XLOG Record를 같은 방식으로 재생
- WAL Segment File에 작성된 XLOG Record를 시간 순서대로 재생해 자체적으로 복구함
    - XLOG Record = REDO Log
    - PostgreSQL은 UNDO Log를 지원하지 않음

## Full-Page Write

- Background-Writer Process가 Dirty Page를 쓰는 동안 OS가 실패하여 저장소에 있는 TABLE_A가 손상되었다고 가정했을 시 XLOG Record는 손상된 Page에서 재상할 수 없음
- PostgreSQL은 위 상황을 처리하기 위해 Full-Page Write지원함
- Full-Page Write를 설정할 경우 PostgreSQL은 모든 Checkpoint 이후 각 Page의 첫 번째 변경 동안 Header Data쌍과 Full-Page를 XLOG Record로 작성
    - Default: Full-Page Write True
- PostgreSQL에서 전체 Page를 포함하는 XLOG Record를 Backup Block(Full-Page Image)라 함

![Full-Page Write가 활성화된 상태에서의 Row `INSERT`](./9 WAL/Untitled%203.png)

Full-Page Write가 활성화된 상태에서의 Row `INSERT`

1. Checkpointer는 Checkpoint Process를 싲가
2. 첫 `INSERT`문 실행 시 PostgreSQL은 이전과 동일한 방식으로 동작하나 XLOG Record는 이 Page의 Backup Block이 됨, 최신 Checkpoint 이후 이 Page를 처음 작성함
3. Tx이 `COMMIT`되면 PostgreSQL은 이전과 동일하게 동작
4. 두 분째 `INSERT`문을 실행할 때 PostgreSQL은 이 XLOG Record가 Backup Block이 아니므로 이전과 동일하게 동작
5. 이전과 동일하게 동작
6. Full-Page Write의 효율성을 보여주기 위해 Background Write가 저장소에 쓰기 작업을 수행하는 동안 OS 오류로 Storage의 TABLE_A Page가 손상된 경우를 고려

![Backup Block을 사용한 DB Recovery](./9 WAL/Untitled%204.png)

Backup Block을 사용한 DB Recovery

1. PostgreSQL은 첫 INSERT문의 XLOG Record를 읽고 손상된 TABLE_A Page를 DB Cluster에 Shared Buffer Pool로 로드함
이 XLOG Record는 Backup Block(각 Page의 첫 번째 XLOG Record는 Full-Page Wrire의 규칙에 따라 항상 Backup Block)임
2. XLOG Record가 Backup Block인 경우 다른 재생 규칙이 적용됨
Row의 Data 부분(Page)는 두 LSN 값에 관계없이 Page에 덮어쓰이고 Page의 LSN이 XLOG Record의 LSN으로 `UPDATE`됨
PostgreSQL은 Record의 Data 부분을 손상된 Page에 덮어쓰고 TABLE_A의 LSN을 LSN_1으로 UPDATE함
손상된 Page는 Backup Block에 의해 복원됨
3. 두 번째 XLOG Record는 Backup되지 않은 Block이므로 이전과 동일한 방식으로 동작

### WAL, Backup 및 Recovery

- WAL은 Process 또는 OS Down으로 인한 Data 손실을 방지할 수 있음
- File System이나 Media 오류가 발생할 시 Data는 손실됨
- Data 손실을 처리하기 위해 PostgreSQL은 Online Backup과 Replication을 지원함
- Online Backup을 정기적으로 할 시 Media 오류가 발생해도 최근 Backup에서 DB를 Recovery할 수 있음(마지막 Backup 이후 변경 사항은 복원 불가능)
- 동기식 Replication은 다른 Storage나 Host에 대한 모든 변경 사항을 실시간으로 저장 가능

![Postgresql_elephant.svg.png](./9 WAL/Postgresql_elephant.svg.png)