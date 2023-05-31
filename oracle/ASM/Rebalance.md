# Rebalance

디스크를 추가하면 자동적으로 데이터를 균등하게 만듬

[https://t1.daumcdn.net/cfile/tistory/240AF93B5132DCDE26](https://t1.daumcdn.net/cfile/tistory/240AF93B5132DCDE26)

디스크 생성시 rebalance power n 으로 구성할 수 있음

```sql
alter diskgroup testdb_dg1 add disk '/dev/sdf1' rebalance power 9 ;
```

n에는 10g -> 1~11 까지 가능 / 11g -> 1~1024 까지 가능

기본값은 1, 0을 쓰면 사용 안함

숫자가 클수록 rebalance 속도는 빨라짐(우선순위로 작업한다는 뜻)

단점으로는 CPU 부하가 많이 걸리므로 상황에 맞게 조정