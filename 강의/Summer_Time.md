# Summer Time

Summer Time(ST)이란 일광 절약 시간제의 다른 말이다.
하절기에 국가의 표준시를 원래 시간보다 앞당겨 사용하는 것을 말한다.

한 시간 정도를 당기기 때문에 ST가 실시되면 8시는 9시로, 2시를 3시로 늦춰 표기하게 된다.

미국과 캐나다는 대부분의 지역에서 ST를 실시한다.
시간이 바뀌는 날과 시간은 3월 두 번째 일요일 오전 2시, 종료일은 11월 첫 번째 일요일 오전 2시 이다.

3월 두 번째 일요일에 오전 2시가 3시가 된다고 생각하면 편하다.
유지되던 ST는 11월 첫 번째 일요일에는 오전 2시 이후 다시 오전 1시로 돌아와 한번 더 반복된다.

```bash
# Newyork Time Zone

Sun Mar 12 01:58:01 EST 2023
Sun Mar 12 01:59:01 EST 2023
Sun Mar 12 03:00:01 EDT 2023
Sun Mar 12 03:01:01 EDT 2023
...
Sun Nov  5 01:58:01 EDT 2023
Sun Nov  5 01:59:01 EDT 2023
Sun Nov  5 01:00:01 EST 2023
Sun Nov  5 01:01:01 EST 2023
```

EST(Eastern Standard Time)는 표준시(가을/겨울)가 UTC-05:00일 때를 의미한다.
EDT(Eastern Daylight Time)는 일광 절약 시간 DST(봄/여름)로서 UTC-4:00일 때를 말한다.

Timestamp는(UNIX TIMESTAMP) Epoch 시간을 사용하기 때문에 ST에 영향을 받지 않는다.

ST 테스트 과정(SCN / SYSDATETIME / SYSTIMESTAMP)(가동 중 / 종료 후 재가동)

1.   ST로 인해 시간이 밀렸을 때 DB와 ARKCDC의 상태 확인
2.   ST로 인해 시간이 반복될 때 DB와 ARKCDC의 상태 확인
3.   유저의 설정으로 인해 시간이 밀렸을 때 DB와 ARKCDC의 상태 확인
4.   유저의 설정으로 인해 시간이 반복될 때 DB와 ARKCDC의 상태 확인

| CASE                    | SCN  | SYSDATE | SYSTIMESTAMP | MEMO |
| ----------------------- | ---- | ------- | ------------ | ---- |
| ST START / DB OPEN      |      |         |              |      |
| ST START / DB STARTUP   |      |         |              |      |
| ST END / DB OPEN        |      |         |              |      |
| ST END / DB STARTUP     |      |         |              |      |
| TIME FORTH / DB OPEN    |      |         |              |      |
| TIME FORTH / DB STARTUP |      |         |              |      |
| TIME BACK / DB OPEN     |      |         |              |      |
| TIME BACK / DB STARTUP  |      |         |              |      |

