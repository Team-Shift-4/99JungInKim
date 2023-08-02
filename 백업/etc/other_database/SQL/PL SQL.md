# PL/SQL

# 특징

- SQL을 확장한 절차적 언어
- 관계형 데이터베이스에서 사용되는 Oracle의 표준 데이터 엑세스 언어로 프로시저 생성자를 SQL과 완벽하게 통합함
- 유저 프로세스가 PL/SQL 블록을 보내면 서버 프로세서는 PL/SQL Engine에서 해당 블록을 받고 SQL과  Procedural를 나눠서 SQL은 SQL Statement Executer로 보냄
- 종류는 크게 Procedure, Function, Trigger로 나뉨
- Oracle에서 지원하는 프로그래밍 언어의 특성을 수용해 SQL에서는 사용할 수 없는 절차적 프로그래밍 기능을 가지고 있음
- 블록 단위의 실행을 제공
- 변수, 상수 등을 선언해 SQL과 절차형 언어에서 사용
- 변수의 선언은 DECLARE절에서만 가능
- BEGIN 섹션에서 새 값이 할당될 수 없음
- IF문을 사용해 조건에 따라 문장 분기가 가능
- LOOP문을 사용해 문장 반복 가능
- 커서를 사용해 여러 행을 검색 및 처리 가능
- 사용 가능한 SQL은 Query, DML, TCL
- PL/SQL의 SELECT문은 해당 SELECT의 결과를 PL/SQL Engine으로 보냄
    - 이를 캐치하기 위한 변수를 DECLARE해야 하며 INTO절을 꼭 선언하여 넣을 변수를 꼭 표현해 주어야 함
    - SELECT 문장은 반드시 한 개의 행이 검색되어야 함, 검색되는 행이 없으면 문제가 발생

# 장점

- 프로시저 생성자와 SQL의 통합
- 모듈식 프로그램 개발 가능
- 이식성이 좋음
- 예외 처리 가능
- 변수가 없고 제어문이 없는 SQL의 단점을 해결
- 여러 명령문을 사용하기에 원래의 SQL과 달리 상대적으로 트래픽이 감소

# 구조

| 영역 | 설명 | 옵션/필수 |
| --- | --- | --- |
| DECLARE(선언부) | 변수, 상수, 커서등을 선언하는 부분 | 옵션 |
| BEGIN(실행부) | 절차적 형식으로 SQL문을 실행할 수 있도록 기술하는 부분 | 필수 |
| EXCEPTION(예외 처리부) | PL/SQL문이 에러 발생 시 해결할 문장을 기술하는 부분 | 옵션 |
| END(실행문 종료) |  | 필수 |

# Block의 종류

- 익명 블록: 이름이 없는 PL/SQL Block을 의미
- 이름 있는 블록: DB의 객체로 저장되는 블록
    - 프로시저: 리턴 값을 하나 이상 가질 수 있는 프로그램
    - 함수: 리턴 값을 반드시 반환해야 하는 프로그램
    - 패키지: 하나 이상의 프로시저, 함수, 변수, 예외 등의 묶음
    - 트리거: 지정된 이벤트가 발생하면 자동으로 실행되는 PL/SQL 블록

# 작성 요령

- 한 문장이 종료할 때마다 `;` 사용해 한 문장이 끝났다는 것을 명시
- END 뒤 `;`을 사용해 하나의 블록이 끝났다는 것을 명시
- 단일 주석은 `--`, 다중 주석은 `/* */`
- 쿼리문을 수행하기 위해 반드시 `/`가 입력되어야 함
- 행에 `/`가 있으면 종결된 것으로 간주
- Oralcle에서 화면 출력을 위해 `PUT_LINE`이란 프로시저 이용
    - ex) DBMS_OUTPUT.PUT_LINE(’내용’);
    - 위 프로시저를 사용해 화면에 출력하기 위해 환경 변수 SERVEROUTPUT을 ON으로 변경
    
    ```sql
    SET serveroutput ON
    BEGIN
    	DBMS_OUTPUT.PUT_LINE('Print');
    END;
    ```
    

# 변수 선언

- 블록내에서 변수를 사용하기 위해 DECLARE에서 선언
- 변수명 다음에 데이터 타입을 기술해야 함

<aside>
<img src="https://www.notion.so/icons/exclamation-mark_gray.svg" alt="https://www.notion.so/icons/exclamation-mark_gray.svg" width="40px" /> **문법**

```sql
identifier [CONSTANT] datatype [NOT NULL]
[:= |DEFAULT expression];
```

- `identifier`: 변수명(식별자)
- `CONSTANT`:  상수로 지정(초기값 반드시 할당)
- `datatype`: 자료형 기술
- `NOT NULL`: 값을 반드시 포함
- `expression`: Literal, 다른 변수, 연산자나 함수를 포함하는 표현식
</aside>

## %ROWTYPE

- 해당 테이블이나 뷰의 컬럼 속성을 그대로 들고 오는 형태
- 변수명 테이블이름%ROWTYPE

```sql
-- ex)
DECLARE
	DATA EMP%ROWTYPE;
BEGIN
	SELECT * INTO DATA
	FROM EMP
	WHERE EMPNO = '1234';
	DBMS_OUTPUT.PUT_LINE(DATA.ENAME || ',' ||DATA.DEPTNO);
```

## %TYPE

- 해당 테이블의 컬럼 속성을 지정해 그대로 들고 오는 형태
- 변수명 테이블이름.컬럼명%TYPE

```sql
-- ex)
DECLARE
	V_ENAME  EMP.ENAME%TYPE;
	V_DEPTNO EMP.DEPTNO%TYPE;
BEGIN
	SELECT ENAME, DEPTNO INTO V_ENAME, V_DEPTNO
	FROM EMP
	WHERE EMPNO = '1234';
	DBMS_OUTPUT.PUT_LINE(V_ENAME ||','||V_DEPTNO);
END;
```

# 변수 대입 방법

## 명시적인 값 대입

- 변수값을 저장하기 위해 `:=`를 사용
- `:=` 좌측에는 변수, 우측에는 값 기술

## SELECT 문을 이용하여 값 대입

- 기존 SELECT문과 다르게 INTO절 추가
    - INTO절에는 조회 결과 값을 저장할 변수를 기술.
    - SELECT문은 INTO절에 의해 하나의 행만을 저장 가능

```sql
SELECT select_list
INTO {variable_name1[,variable_name2,..]|record_name}
FROM table_name
WHERE condition;
```

- SELECT 다음에 기술한 컬럼은 INTO절에 있는 변수와 1:1로 대응해야함
    - 데티어 타입, 개수 길이를 일치시켜야함

# 반복문

## FOR LOOP

```sql
FOR index in [REVERSE] 시작값 .. END값 LOOP
	STATEMENT 1
	STATEMENT 2
	...
END LOOP;
```

- `index`는 자동 선언되는 binary_integer형 변수이고 1씩 증가
- `REVERSE` 옵션이 사용될 경우 `index`는 upper_bound에서 lower_bound로 1씩 감소
- IN 다음에는 CURSOR나 SELECT문이 올 수 있음

```sql
-- ex)
SET serveroutput ON;
BEGIN
	FOR i in 1..4 LOOP
		if mod(i, 2) = 0 then
			dbms_output.put_line( i || 'IS EVEN');
		else
			dbms_output.put_line( i || 'IS ODD');
		end if;
	END LOOP;
END;
/
```

```sql
-- ex
SET serveroutput ON;
BEGIN
	FOR NUM_LIST IN
	(
		SELECT 1 AS NUM FROM DUAL
		UNION ALL
		SELECT 2 AS NUM FROM DUAL
		UNION ALL
		SELECT 3 AS NUM FROM DUAL
		UNION ALL
		SELECT 4 AS NUM FROM DUAL
	)
	LOOP
		if mod(NUM_LIST.NUM, 2) = 0 then
			dbms_output.put_line( NUM_LIST.NUM || '는 짝수!!');
		else
			dbms_output.put_line( NUM_LIST.NUM || '는 홀수!!');
		end if;
	END LOOP;
END;
```

## LOOP문

```sql
LOOP
	PL/SQL STATEMENT 1
		다른 LOOP를 포함하여 중첩으로 사용 가능
	EXIT [WHEN CONDITION]
END LOOP;
```

- `EXIT`문이 사용되었을 때 무조건 LOOP문을 빠져나감
- `EXIT` `WHEN`조건이 사용될 경우 WHEN절에서 LOOP를 빠져나가는 조건을 제어할 수 있음

```sql
-- ex
SET serveroutput ON;
DECLARE
	v_num NUMBER := 6; -- 시작숫자
	v_tot_num NUMBER := 0; -- 총 loop수 반환 변수
BEGIN
	LOOP
		DBMS_OUTPUT.PUT_LINE('current number: ' || v_num);
		v_num := v_num + 1;
		v_tot_num := v_tot_num + 1;
		EXIT WHEN v_num > 10;
	END LOOP;
	DBMS_OUTPUT.PUT_LINE(v_tot_num || 'loops');
END;
```

```sql
-- ex
SET serveroutput ON;
DECLARE
	v_num NUMBER := 6; -- 시작숫자
	v_tot_num NUMBER := 0; -- 총 loop수 반환 변수
BEGIN
	WHILE v_num < 11 LOOP
		DBMS_OUTPUT.PUT_LINE('current number: ' || v_num);
		v_num := v_num + 1;
		v_tot_num := v_tot_num + 1;
		-- EXIT WHEN v_num > 10;
	END LOOP;
	DBMS_OUTPUT.PUT_LINE(v_tot_num || 'loops');
END;
```

# 제어문

## IF

```sql
IF 조건1 THEN
	처리문1
ELSIF 조건2 THEN
	처리문2
	...
ELSE
	처리문
END IF;
```

- 조건값이 참일때 해당 조건의 처리문장이 실행
- 조건 다음에 `THEN`삽입
- ELSIF 명령어 사용
- IF가 끝났을 때 END IF

```sql
-- ex
DECLARE v_score NUMBER :=79;
BEGIN
	IF v_score >= 90 THEN
		DBMS_OUTPUT.PUT_LINE('SCORE: ' || v_score || ', GRADE: A');
	ELSIF v_score >= 80 THEN
		DBMS_OUTPUT.PUT_LINE('SCORE: ' || v_score || ', GRADE: B');
	ELSIF v_score >= 70 THEN
		DBMS_OUTPUT.PUT_LINE('SCORE: ' || v_score || ', GRADE: C');
	ELSIF v_score >= 60 THEN
		DBMS_OUTPUT.PUT_LINE('SCORE: ' || v_score || ', GRADE: D');
	ELSE
		DBMS_OUTPUT.PUT_LINE('SCORE: ' || v_score || ', GRADE: F');
	END IF;
END;
```

```sql
-- ex
DECLARE v_score NUMBER; -- NULL의 비교는 항상 NULL -> ELSE 이하 문만 수행
BEGIN
	IF v_score >= 90 THEN
		DBMS_OUTPUT.PUT_LINE('SCORE: ' || v_score || ', GRADE: A');
	ELSIF v_score >= 80 THEN
		DBMS_OUTPUT.PUT_LINE('SCORE: ' || v_score || ', GRADE: B');
	ELSIF v_score >= 70 THEN
		DBMS_OUTPUT.PUT_LINE('SCORE: ' || v_score || ', GRADE: C');
	ELSIF v_score >= 60 THEN
		DBMS_OUTPUT.PUT_LINE('SCORE: ' || v_score || ', GRADE: D');
	ELSE
		DBMS_OUTPUT.PUT_LINE('SCORE: ' || v_score || ', GRADE: F');
	END IF;
END;
```

## CASE

```sql
CASE WHEN 조건1 THEN
	처리문1
WHEN 조건2 THEN
	처리문2
	...
ELSE
	처리문
END CASE;
```

- ORACLE CASE문과 PL/SQL CASE문은 거의 동일

```sql
-- ex
DECLARE
	v_grade CHAR(1) := 'C';
	v_appraisal VARCHAR2(20);
BEGIN
	v_appraisal := CASE v_grade
		WHEN 'A' THEN 'Excellent'
		WHEN 'B' THEN 'Very Good'
		WHEN 'C' THEN 'Good'
		ELSE 'No such grade'
	END;
	DBMS_OUTPUT.PUT_LINE ('Grade : '|| v_grade);
	DBMS_OUTPUT.PUT_LINE ('Appraisal: '|| v_appraisal);
END;
```

- PL/SQL문을 실행시킬 때는 CASE 조건문을 사용해야 함
- CASE 조건문은 끝이 END CASE로 끝남

```sql
-- ex
DECLARE
	v_grade CHAR(1) := 'C';
	v_appraisal VARCHAR2(20);
BEGIN
	CASE v_grade
	WHEN 'A' THEN
		v_appraisal := 'Excellent';
	WHEN 'B' THEN
		v_appraisal := 'Very Good';
	WHEN 'C' THEN
		v_appraisal := 'Good';
	ELSE
		v_appraisal := 'No such grade';
	END CASE;
	DBMS_OUTPUT.PUT_LINE ('Grade : '|| v_grade) ;
	DBMS_OUTPUT.PUT_LINE ('Appraisal: '|| v_appraisal);
END;
```

# CURSOR

- SQL 커서는 Oracle 서버에서 할당한 전용 메모리 영역에 대한 포인터
- 질의의 결과로 얻어진 여러 행이 저장된 메모리상의 위치
- 커서는 SELECT문의 결과 집합을 처리하는데 사용

## Implicit Cursor(암시적 커서)

- Oracle DB에서 실행되는 모든 SQL문장은 암시적 커서가 생성되며 커서 속성을 사용 가능
- 모든 DML과 PL/SQL SELECT문에 대해 선언됨
- 암시적 커서는 오라클이나 PL/SQL실행 메커니즘에 의해 처리되는 SQL문장이 처리되는 곳에 대한 익명의 주소
- Oracle Server에서 SQL문을 처리하기 위해 내부적으로 생성 및 관리함
- 암시적 커서는 SQL문이 실행되는 순간 자동으로 OPEN과 CLOSE를 실행
- SQL커서 속성을 사용하면 SQL문의 결과를 테스트 할 수 있음

### 암시적 커서의 속성

- `SQL%FOUND`: 해당 SQL문에 의해 반환된 총 행수가 1개 이상일 경우 `TRUE`
- `SQL%NOTFOUND`: 해당 SQL문에 의해 반환된 총 행수가 1개 이상일 경우 `FALSE`
- `SQL%ISOPEN`: 항상 `FALSE`, 암시적 커서가 열려 있는지의 여부 검색
(PL/SQL은 실행 후 바로 묵시적 커서를 닫기에 항상 `FALSE`)
- `SQL%ROWCOUNT`: 해당 SQL문에 의해 반환된 총 행수, 가장 최근 수행된 SQL문에 의해 영향을 받은 행의 개수(정수)

### 예제

```sql
SET SERVEROUTPUT ON;
DECLARE
	BEGIN
	DELETE FROM emp WHERE DEPTNO = 10;
	DBMS_OUTPUT.PUT_LINE('처리 건수 : ' || TO_CHAR(SQL%ROWCOUNT)|| '건');
	END;
```

## Explict Cursor(명시적 커서)

- 프로그래머에 의해 선언되며 이름있는 커서

### 명시적 커서의 속성

- `%ROWCOUNT`: 현재까지 반환된 모든 행의 수를 출력
- `%FOUND`: `FETCH`한 데이터가 행을 반환하면 `TRUE`
- `%NOTFOUND`: `FETCH`한 데이터가 행을 반환하지 않으면 `TRUE`(LOOP를 종료할 시점 찾음)
- `%ISOPEN`: 커서가 `OPEN`되어 있으면 `TRUE`

### 문법

1. `DECLARE`를 통해 명명된 SQL영역을 생성
2. `OPEN`을 이용해 결과 행 집합을 식별
3. `FETCH`를 통해 현재 행을 변수에 로드(이를 현재 행이 없을 때까지 수행할 수 있음)
4. `CLOSE`를 통해 결과 행 집합을 해제

<aside>
<img src="https://www.notion.so/icons/exclamation-mark_gray.svg" alt="https://www.notion.so/icons/exclamation-mark_gray.svg" width="40px" /> **문법 예제**

```sql
DECLARE
	CURSOR [CURSORNAME] IS [SELECT문];
BEGIN
	OPEN [CURSORNAME];
	FETCH [CURSORNAME] INTO [LOCALVARIABLE];
	CLOSE [CURSORNAME];
END;
```

- `OPEN`
    - 커서 열기
    - 커서안의 검색이 실행되며 아무런 데이터행을 추출 못해도 에러가 발생하지 않음
- `FETCH`
    - 현재 데이터 행을 OUTPUT변수에 반환
    - 커서의 SELECT문의 컬럼 수와 OUTPUT변수의 수가 동일해야 함
    - 커서 컬럼의 변수타입과 OUTPUT변수의 데이터 타입이 동일해야 함
    - 커서는 한 라인씩 데이터를 FETCH함
    - 문법: FETCH cursorname INTO var1, var2;
- `CLOSE`
    - 사용 마친 커서를 반드시 닫아야 함
    - 필요시 커서를 다시 열 수 있음
    - 커서를 닫은 상태에서는 FETCH 불가능
    - 문법: CLOSE cursorname;
</aside>

```sql
-- ex
SET SERVEROUTPUT ON;
DECLARE
	CURSOR emp_cur -- 커서정의
	IS
	SELECT * FROM emp WHERE DEPTNO = 10;
	emp_rec emp%ROWTYPE; -- 변수정의
BEGIN
	OPEN emp_cur;
		LOOP -- 반복
	FETCH emp_cur INTO emp_rec; -- 하나씩 변수에 넣기
	EXIT WHEN emp_cur%NOTFOUND; -- 더이상 없으면 끝내기
		DMBS_OUTPUT.PUT_LINE(emp_rec.empno || ' ' || emp_rec.name); -- 출력
	END LOOP;
	CLOSE emp_cur;
END;
```

```sql
-- ex
SET SERVEROUTPUT ON;
DECLARE
	ID_LIST SYS_REFCURSOR; -- 커서정의
	I_ID VARCHAR2(100); -- 변수정의
BEGIN
	OPEN ID_LIST;
	FOR
		SELECT USER_ID FROM MY_USER WHERE 조건;
	LOOP -- 반복
	FETCH ID_LIST INTO I_ID; -- 하나씩 변수에 넣기
	EXIT WHEN ID_LIST%NOTFOUND; -- 더이상 없으면 끝내기
		DMBS_OUTPUT.PUT_LINE(I_ID); -- 출력
	END LOOP;
	CLOSE ID_LIST;
END;
```

```sql
-- ex
SET SERVEROUTPUT ON;
DECLARE
	CURSOR ID_LIST IS
	SELECT 'JIK' AS USER_ID FROM DUAL;
BEGIN
	FOR TEST_CURSOR IN ID_LIST
	LOOP
		DBMS_OUTPUT.PUT_LINE(TEST_CURSOR.USER_ID);
	END LOOP;
END;
```

```sql
-- Explict Cursor ex
SET SERVEROUTPUT ON;
DECLARE
	BEGIN
		FOR ID_LIST IN
		(
			SELECT 'JIK' AS USER_ID FROM DUAL
		)
		LOOP
			DBMS_OUTPUT.PUT_LINE(ID_LIST.USER_ID);
		END LOOP;
	END;
```