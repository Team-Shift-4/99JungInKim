# 5. Visibility Check Rules

# Visibility Check Rules

- Visibility Check Rules(가시성 확인 규칙)은 Tuple의 `t_xmin`, `t_xmax`, clog, 획득한 Tx Snapshot을 모두 사용해 각 Tuple이 표시되는지(보이는지)의 여부를 결정하는 Rule 집합

## `t_xmin` Status == `ABORTED`

```sql
Rule 1: IF t_xmin status is 'ABORTED' THEN
				RETURN 'Invisible'
								END IF
```

1. `t_xmin`의 Status가 `ABORTED`인 Tuple은 Tuple을 `INSERT`한 Tx가 `ABORT`되어 항상 보이지 않음

## `t_xmin` Status == `IN_PROGRESS`

- `t_xmin`의 Status가 `IN_PROGRESS`인 Tuple은 한 조건을 제외하고 본질적으로 보이지 않음

```sql
IF t_xmin status is 'IN_PROGRESS' THEN
				IF t_xmin = current_txid THEN
Rule 2:         IF t_xmax = INVALID THEN
												RETURN 'Visible'
Rule 3:         ELSE  /* this tuple has been deleted or updated by the current transaction itself. */
												RETURN 'Invisible'
								END IF
Rule 4: ELSE   /* t_xmin ≠ current_txid */
								RETURN 'Invisible'
				END IF
END IF
```

1. 현재 Tx에 의해 `INSERT`되고 `t_xmax`가 `INVALID`인 경우 보임(Tx 자체에 의해 `INSERT`된 Tuple)
2. 현재 Tx에 의해 `INSERT`되고 `t_xmax`가 `INVALID`가 아닌 경우 보이지 않음(`UPDATE`, `DELETE`)
3. 다른 Tx에 의해 `INSERT`되고 `t_xmin`의 Status가 `IN_PROGRESS`면 보이지 않음

## `t_xmin` Status == `COMMITTED`

- `t_xmin`의 Status가 `COMMITTED`인 경우 세 조건을 제외하고 볼 수 있음
    - visible (6, 8, 9), invisible (5, 7, 10)

```sql
IF t_xmin status is 'COMMITTED' THEN
Rule 5: IF t_xmin is active in the obtained transaction snapshot THEN
								RETURN 'Invisible'
Rule 6: ELSE IF t_xmax = INVALID OR status of t_xmax is 'ABORTED' THEN
								RETURN 'Visible'
				ELSE IF t_xmax status is 'IN_PROGRESS' THEN
Rule 7:         IF t_xmax =  current_txid THEN
												RETURN 'Invisible'
Rule 8:         ELSE  /* t_xmax ≠ current_txid */
												RETURN 'Visible'
								END IF
				ELSE IF t_xmax status is 'COMMITTED' THEN
Rule 9:         IF t_xmax is active in the obtained transaction snapshot THEN
												RETURN 'Visible'
Rule 10:        ELSE
												RETURN 'Invisible'
								END IF
				END IF
END IF
```

1. `t_xmin`이 획득한 Tx Snapshot에서 `active`(활성화)되어 보임
2. `t_xmax`가 `INVALID` or `ABORTED`일 때 보이지 않음
3. `t_xmax`가 현재 txid일 때 보이지 않음(`UPDATE`, `DELETE`)
4. `t_xmax`가 `IN_PROGRESS` & `t_xmax`가 현재 txid가 아닐 때 보임(`DELETE`되지 않음)
5. `t_xmax`가 `COMMITTED`이고 `t_xmax`가 획득한 Tx Snapshot에서`active`인 경우 보임
6. `t_xmax`가 `COMMITTED`이고 `t_xmax`가 획득한 Tx Snapshot에서 `active`가 아닌 경우 보이지 않음