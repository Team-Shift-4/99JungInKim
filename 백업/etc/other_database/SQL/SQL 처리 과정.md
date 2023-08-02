# SQL 처리 과정

# Parsing(구문 분석)

- 해당 Query가 문법적으로 틀리지 않은 지 확인
- 해당 구문을 SQL 서버가 이해할 수 있는 단위들로 분해
- 구문 부정확 시 여기서 처리 중단
- 이 문장이 Batch 내에 있다면 일괄 처리 전체를 중단
    - Batch Abort: Batch 중 하나라도 Syntax Error가 있다면 전체 Batch가 실행되지 않음

# Standardization(표준화)

- 실제 필요 없는 부분들이 제거
- Standard Query Tree가 만들어 짐

# Optimization(최적화)

- 통계나 조각 정보 등을 바탕으로 Execution Plan을 만들어 냄
- Query 처리에서 매우 중요한 단계
    1. Query 분석: SARG(검색 제한자)인지 Join 조건인지 판단
    2. Index 선택: 분포 통계 정보를 이용해 Index 검색이나 Table Scan 중 하나를 선택
    여러 Index 중 가장 효율적인 것을 선택
    3. Join 처리: JOIN, UNION, GROUP BY, ORDER BY절을 가진지 확인해 적절한 작업 순서 선택
    이 단계의 출력은 Execution Plan

# Compilation(컴파일)

- 컴파일을 하면 Binary Code가 생성
- 일반적인 경우 Compile 후 .exe, .dll등의 binary file이 만들어 지나 SQL Server에서는 메모리(프로시저 캐시)에만 올림 → 컴파일 속도가 빠름

# Execute(실행)

- Access Routine으로 가 실제 처리를 하고 결과를 돌려줌

# 문법 순서

1. `SELECT`
2. `FROM`
3. `WHERE`
4. `GROUP BY`
5. `HAVING`
6. `ORDER BY`

# 실행 순서

1. `FROM`: 해당 데이터를 찾음
2. `WHERE`: 조건에 맞는 데이터만 가져옴
3. `GROUP BY`: 원하는 데이터로 가공함
4. `HAVING`: 가공한 데이터에서 조건에 맞는 것만 가져옴
5. `SELECT`: 뽑아옴
6. `ORDER BY`: 정렬함