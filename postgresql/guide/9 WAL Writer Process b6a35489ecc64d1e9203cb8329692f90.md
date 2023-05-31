# 9. WAL Writer Process

# WAL Writer Process

- WAL Writer는 WAL Buffer를 주기적으로 확인하고 기록되지 않은 모든 XLOG Record를 WAL Segment에 쓰는 Background Process
- XLOG Record의 쓰기가 터지는 것을 방지하는게 목적
- WAL Writer는 필수 Process이며 비활성화 불가능
- 확인 간격은 구성 매개변수 `wal_writer_delay`로 설정함
    - Default: 200ms