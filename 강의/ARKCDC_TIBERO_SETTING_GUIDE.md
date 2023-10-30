# 요약

```bash
adctl start

admgr supplog add <SCHEMA>

tbsql arkmgr/arkmgr

select * from ark_supp_tables;

admgr start extract <EXT_MODULE> 
```

# 개괄

저희 ArkCDC의 Extract의 경우 Redo / Archive Log를 읽어 추출하기에 Supplemental Logging이 되어있어야 추출이 가능합니다.
Supplemental Logging이 되어있지 않은 상태에서 적용이 된 데이터들은 추출되지 않습니다.

ArkCDC for Tibero는 DDL을 지원하지 않습니다.
테이블이 추가될 경우 Supplemental Logging을 걸어주어야 데이터 추출이 가능해집니다.

아래는 Supplemental Logging 적용 유무 확인 방법입니다. 

```sql
tbsql arkmgr/arkmgr

select * from ark_supp_tables;
-- 추출 대상에 Supplemental Logging이 적용되어 있는 지 확인하는 쿼리입니다.

-- 아래는 확인의 예시입니다.
+------------+---------------+-----------+----+-----------+--------+
|SCHEMA      |TABLE_NAME     |LOGGRP_NAME|COL#|COLUMN_NAME|KEY_TYPE|
+------------+---------------+-----------+----+-----------+--------+
|BENCHMARKSQL|BMSQL_CONFIG   |ARKCDC_3129|0   |CFG_NAME   |PK      |
|BENCHMARKSQL|BMSQL_CUSTOMER |ARKCDC_3133|0   |C_W_ID     |PK      |
|BENCHMARKSQL|BMSQL_CUSTOMER |ARKCDC_3133|1   |C_D_ID     |PK      |
|BENCHMARKSQL|BMSQL_CUSTOMER |ARKCDC_3133|2   |C_ID       |PK      |
|BENCHMARKSQL|BMSQL_DISTRICT |ARKCDC_3132|0   |D_W_ID     |PK      |
|BENCHMARKSQL|BMSQL_DISTRICT |ARKCDC_3132|1   |D_ID       |PK      |
|BENCHMARKSQL|BMSQL_HISTORY  |ARKCDC_3135|0   |HIST_ID    |PK      |
|BENCHMARKSQL|BMSQL_ITEM     |ARKCDC_3139|0   |I_ID       |PK      |
|BENCHMARKSQL|BMSQL_NEW_ORDER|ARKCDC_3136|0   |NO_W_ID    |PK      |
|BENCHMARKSQL|BMSQL_NEW_ORDER|ARKCDC_3136|1   |NO_D_ID    |PK      |
+------------+---------------+-----------+----+-----------+--------+
```

만약 위 예시와 같이 추출 대상이 나와있지 않을 경우 해결 방법입니다.

```bash
adctl start
# admgr을 실행시키기 위해 에이전트를 가동시킵니다.

admgr supplog add <SCHEMA>
# 스키마에 포함된 테이블들의 Supplemental Logging을 설정합니다.

tbsql arkmgr/arkmgr

select * from ark_supp_tables;
```

혹시 추가로 더 필요한 내용이 있으시면 정리하여 보내 드리겠습니다!
이런 지원이 처음이라 대응이 미흡했던 점 사과드립니다.

아크데이타 김정인 사원 드림