# 5. UPDATE 손실 방지

# `UPDATE` 손실 방지

- `ww-confict`(`UPDATE` 손실)은 동시에 Tx이 같은 Tuple을 `UPDATE`할 때 발생하는 현상
- `REPEATABLE READ`, `SERIALIZABLE` Level에서 모두 방지되어야 함
    - `READ COMMITTED` Level은 방지할 필요가 없음

## 동시 `UPDATE` Command의 동작

- UPDATE 명령이 실행되면 내부적으로 `ExecUpdate()`가 호출됨

```sql
(1)  FOR each row that will be updated by this UPDATE command
(2)       WHILE true

               /* The First Block */
(3)            IF the target row is being updated THEN
(4)	              WAIT for the termination of the transaction that updated the target row

(5)	              IF (the status of the terminated transaction is COMMITTED)
   	                   AND (the isolation level of this transaction is REPEATABLE READ or SERIALIZABLE) THEN
(6)	                       ABORT this transaction  /* First-Updater-Win */
	              ELSE 
(7)                           GOTO step (2)
	              END IF

               /* The Second Block */
(8)            ELSE IF the target row has been updated by another concurrent transaction THEN
(9)	              IF (the isolation level of this transaction is READ COMMITTED THEN
(10)	                       UPDATE the target row
	              ELSE
(11)	                       ABORT this transaction  /* First-Updater-Win */
	              END IF

               /* The Third Block */
                ELSE  /* The target row is not yet modified or has been updated by a terminated transaction. */
(12)	              UPDATE the target row
                END IF
           END WHILE 
      END FOR
```

1. `UPDATE`될 각 Tuple을 가져옴
2. 대상 Tuple이 `UPDATE`될 때까지(Tx가 `ABORT`될 때 까지) 반복
3. 대상 Tuple이 `UPDATE`중인 경우(`ELSE IF`는 8)
4. PostgreSQL은 SI에서 `first-update-win`방식을 사용
    - 대상 Tuple을 `UPDATE`한 Tx가 `ABORT` 될 때까지 대기
5. 대상 Tuple을 `UPDATE`한 Tx의 Status가 `COMMITTED`이고 
Tx의 독립성 Level이 `REPEATABLE READ`(또는 `SERIALIZABLE`)인 경우(`ELSE`는 7)
6. `UPDATE` 손실을 방지하기 위해 해당 Tx `ABORT`
7. (2)로 이동, 해당 Tuple `UPDATE` 다시 시도
8. 대상 Tuple이 다른 동시 Tx에 의해 `UPDATE`된 경우(`ELSE`는 12)
9. 이 Tx의 독립성 Level이 `READ COMMITTED`인 경우(`ELSE`는 11)
10. 대상 Tuple을 `UPDATE`하고 (1)로 이동
11. `UPDATE` 손실을 방지하기 위해 해당 Tx `ABORT`
12. 대상 Tuple을 `UPDATE`한 후 수정되지 않았거나 ABORT된 Tx에 의해 `UPDATE`되어 (1)로 이동
    - `UPDATE` 손실 발생
- 위 함수는 각 대상 Tuple에 대해 `UPDATE`작업을 수행

![`ExecUpdate()`의 내부 Block 3개](./5 UPDATE 손실 방지/Untitled.png)

`ExecUpdate()`의 내부 Block 3개

- 그림 (1)
    - `being updated`는 Tuple이 다른 동시 Tx에 의해 `UPDATE`되고
      해당 Tx가 `ABORT`되지 않았음을 의미
        - PostgreSQL은 `first-update-win` 방식을 사용해 현 Tx는 대상 Tuple을 `UPDAET`한 Tx의 `ABORT` 를 대기
        - 현재 Tx가 `READ COMMITTED` Level일 경우 대기 후 Tuple을 `UPDATE`, 
          아닐 경우 `UPDATE` 손실 방지를 위해 Tx `ABORT`
- 그림 (2)
    - `has been updated by the concurrent transaction`은 현재 Tx이 대상 Tuple에 대해 `UPDATE`를 시도하나 다른 동시 Tx가 이미 대상 Tuple을 `UPDATE`한 후 `COMMIT`한 상황
        - 현재 Tx가 `READ COMMITED` Level일 경우 Tuple `UPDATE`,
        아닐 경우 `UPDATE` 손실 방지를 위해 Tx `ABORT`
- 그림 (3)
    - `There si no conflict`는 충돌이 없다는 뜻으로 대상 Tuple `UPDATE`

<aside>
ℹ️ PostgreSQL의 SI 기반 CC는 `UPDATE` 손실을 방지하기 위해 `first-updater-win` 방식 사용
PostgreSQL의 SSI는 serialization(직렬화) 이상 방지를 위해 `first-committer-win` 방식 사용

</aside>