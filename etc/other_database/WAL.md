# WAL

# Write-Ahead Logging

- Transaction이 일어나기 전 Log를 미리 기록하여 Transaction Undo, Redo를 할 수 있도록 함

## Undo Recovery

- Transaction이 작업을 진행하기 전 데이터로 돌리는 것
    - 실행중인 Transaction이 어떤 이유든 비정상 종료되는 경우 Transaction이 변경한 데이터를 원래대로 복구하는 작업
- Transaction이 중간에 종료되었는데, 중간까지의 결과물이 Disk에 쓰여졌을 때 Undo Recovery를 하지 않으면 중간 결과물이 최종 결과물처럼 오해될 수 있음
- ACID의 A(Atomicity)

## Redo Recovery

- Transaction이 작업을 진행한 후 상태로 되돌리는 것
    - 이미 Commit한 Transaction의 수정을 재반영하는 Recovery
- Transaction이 제대로 진행되었고 그 결과가 Memory에 반영되었으나 Disk에 반영되지 않을 때 정전 등의 이유로 Transaction 결과도 사라지게 됨
- Transaction 결과를 다시 Recovery 하기 위해 Redo Recovery 진행