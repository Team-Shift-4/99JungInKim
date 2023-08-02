# 5. Commit Log(clog)

# Clog

- PostgreSQL은 clog에 Tx Status를 저장
- 종종 clog라고 하는 Commit Log는 Shared Memory에 할당되며 Tx Processing 전반에 걸쳐 사용

## Transaction Status

- PostgreSQL은 `IN_PROGRESS`, `COMMITTED`, `ABORTED`, `SUB_COMMITTED`의 Tx Status를 정의함
    - `SUB_COMMITTED`는 Sub Tx를 위한 Status

## Clog의 성능

- Clog는 Shared Memory에 하나 이상의 Page로 구성(8KB)
- 논리적으로 Array를 형성함
    - Array의 Index는 각 txid에 해당하고 Array의 각 항목은 해당 Tx의 상태

![Clog의 동작 방식의 예](./5 Commit Log(clog)/Untitled.png)

Clog의 동작 방식의 예

- `T1`: txid 200 `COMMIT`; txid 200의 Status가 `IN_PROGRESS` → `COMMITTED`
- `T2`: txid 201 `ABORT`; txid 201의 Status가 `IN_PROGRESS` → `ABORTED`
- 현재 txid가 진행되고 있으며 clog가 더 이상 저장할 수 없으면 새 Page가 추가
- Tx의 Status가 필요할 때 내장 함수가 호출
    - 이 내장 함수는 clog를 읽고 요청된 Tx의 Status를 반환

## Clog의 유지 관리

- PostgreSQL이 종료되거나 Checkpoint Process가 실행될 때 clog의 Data는 `pg_xact` 하위 디렉터리에 저장된 File에 기록(Ver 9.6 이하는 `pg_clog`)
    - 위 File의 이름은 `0000`, `0001`, …
    - 최대 File 크기는 256KB
        - ex) 37Page를 사용하는 경우 해당 Data는 `0000`(256KB), `0001`(40KB)로 변환
    - PostgreSQL이 시작되면 `pg_xact`의 File에 저장된 Data가 로드되어 clog를 초기화
    - clog가 채워질 때 새 Page가 추가되어 clog의 크기가 계속 증가
        - `VACUUM` Processing으로 Dirty Page와 File 모두를 정기적으로 제거