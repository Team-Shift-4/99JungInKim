# Extract

- 📄
    
    [BEGINNER-84774734-220922-1708-32.pdf](Extract%208e5e0cdeae944d11bdf134c16013c4ec/BEGINNER-84774734-220922-1708-32.pdf)
    

# 개인적으로 생각했을 때 중요한 것들 정리 및 이해

## 추출 대상 객체 지정

- 추출 또는 추출에서 제외할 객체를 지정하는 기능

### 목적

- 추출 대상을 all, 스키마 단위 또는 테이블 단위로 지정할 수 있도록 하기 위함
- Wildcard를 사용해 객체 명 패턴으로 추출할 경우 특정 객체는 제외되도록 할 때 사용 가능

### 추출 대상 객체 지정 기능

- Extract Config의 `TABLE`과 `SEQUENCE` Config를 통해 설정 가능
- Source 데이터베이스에서 추출할 객체 명을 지정시 해당 객체가 Post Config에 지정된 적용 대상 객체와 매핑
- 매핑은 동일한 명 기반으로 수행
- 객체 명이 다를 경우 Post Mapper 파일에서 직접 매핑을 수행

```bash
TABLE="[container.]schema(*).object(*)";
SEQUENCE="[container.]schema(*).object(*)";
```

- `TABLE` & `SEQUENCE`
    - 최대 지원 길이: 255자
    - 지원 키워드: 문자(`A-Z`, `a-z`), 숫자 (`0-9`), 특수 문자(`_`, `$`, `#`, `*`, `.`, `,`)
    - 세 부분(container 포함) 또는 두 부분(container 미포함)으로 지정 가능
    - Container의 경우 Wildcard(*)가 허용되지 않음
    - `,`를 통해 여러 객체 설정 가능
- 특정 객체를 추출에서 제외하려면 `EXCLUDE` 파라미터를 사용

```bash
TABLE="EXCLUDE <container>.<schema>.<object>";
```

- `TABLE`과 `SEQUENCE` Config는 여러 개 설정 가능

### 객체명 변환 추출

추출 대상 Source 객체 이 Target에서 다를 경우, Extract Mapper 파일에서 추출 되는 객체명을 변환 가능

```bash
MAP from_schema.from_object [ TARGET to_scheam.to_object ] { };
```

- 객체명 변환 시 DML과 메타데이터 레코드에 변환 된 객체명이 기록됨
- DDL은 변환 추출이 지원되지 않음

## Mapper 파일 규칙

```bash
MAP from_schema.from_object [ TARGET to_scheam.to_object ] {
		KEY_COLS (column_name, ...);
		EXCLUDE_DML (INSERT | UPDATE | DELETE, ...);
		EXCLUDE_COLS (column_name, ...);
		CONVERT_TYPE (Oracle datatype, ArkCDC datatype);
		CONVERT_DATA (Oracle datatype, value);
		COLMAP (
		column_name = @STRTONUM (column_name | value),
		column_name = @NUMTOSTR (column_name | value),
		column_name = @BINARY (column_name),
		column_name = @DATE (column_name)
	);
};
```

- 테이블 단위 매핑
    - 테이블 단위 매핑 키워드는 `;`으로 구분
    - 키워드 뒤에는 공백 필요
        - 지원 됨: KEY_COLS ( ... );
        - 지원 안됨: KEY_COLS( ... );
    - MAP문 내에 명시 된 옵션들은 해당 MAP문에만 유효
    - MAP문 내에서 동일한 옵션을 여러번 지정하여, 옵션이 충돌할 경우 가장 마지막 옵션이 다른 동일한 옵션들을 오버라이드함
- 컬럼 단위 매핑
    - COLMAP 내에 기능들은 `,`로 구분한다.
    - 키워드 뒤에는 공백 필요
        - 지원 됨: column_name = @STRTONUM ( ... ),
        - 지원 안됨: column_name = @STRTONUM( ... ),
    - COLMAP 내에 기능들은 '=' 앞 뒤로 공백 필요
        - 지원 됨: column_name = @STRTONUM ( ... ),
        - 지원 안됨: column_name=@STRTONUM ( ... ),
    - COLMAP문 내에 명시 된 옵션들은 해당 COLMAP문에만 유효
    - COLMAP 내에 동일한 컬럼이 여러 번 지정되고, 컬럼 매핑끼리 충돌할 경우 가장 마지막 컬럼 매핑이 다른 컬럼 매핑들을 오버라이드함

## DDL 추출 지정

- 추출할 DDL을 지정하기 위해 필요
- 특정 객체에 대한 DDL 또는 특정 DDL 타입을 추출에 포함 또는 제외 가능하도록 사용 가능

```bash
DDL = "INCLUDE | EXCLUDE <schema>.<object>; [OBJTYPE = ALL | <Object Type> ]; [OPERATION = ALL | CREATE | ALTER | DROP | TRUNCATE | RENAME]"
```

- `INCLUDE` | `EXCLUDE`
    - 특정 객체에 대한 DDL문을 추출 또는 추출에서 제외하도록 하는 옵션
- `OBJTYPE`
    - 특정 객체 타입에 대한 DDL만 추출 할 수 있도록 하는 옵션
    - 지원되는 객체
        - TABLE
        - INDEX
        - SEQUENCE
        - VIEW
        - MATERIALIZED VIEW
        - CLUSTER
        - PROCEDURE
        - FUNCTION
        - PACKAGE
    - ALL을 설정하면 지원되는 모든 객체에 대한 DDL이 추출됨
- `OPERATION`
    - 특정 DDL문을 추출 할 수 있도록 하는 옵션
- `<schema>.<object>`
    - 최대 지원 길이: 255자
    - 지원 키워드: 문자 (`A-Z` | `a-z`), 숫자 (`0-9`), 특수 문자(`_`, `$`, `#`, `*`, `.`, `,`)

## TRUNCATE 추출

- TRUNCATE의 경우 `GET_TRUNCATE` Config를 통해 별도로 추출 가능
- `GET_TRUNCATE`로 인해 추출 된 Truncate 레코드는 OP Type을 Truncate로 기록
- DDL로 인해 추출 된 Truncate와 구별 가능

```bash
GET_TRUNCATE="[ yes | no | y | n ]"
```

- `GET_TRUNCATE`
    - 기본 값: yes
- `GET_TRUNCATE` Config와 `DDL` Config 설정이 충돌할 경우 `GET_TRUNCATE`가 우선 순위

## 특정 컬럼 제외

- Extract Mapper 파일의 `EXCLUDE_COLS` Config를 통해 추출 대상 테이블에서 특정 컬럼을
추출에서 제외 가능

```bash
MAP from_schema.from_object [ TARGET to_scheam.to_object ] {
	exclude_cols (name),
};
```

- `EXCLUDE_COLS`로 제외 된 컬럼은 Tracing 파일에서 제외
- Key 컬럼은 제외하지 않음
- Key 컬럼이 추출에서 제외되어도 Extract는 정상 동작해야 함
- Post에서 적용 시 에러가 발생할 수 있기 때문에 Key 컬럼은 제외하지 않도록 권장
- 예외
    
    ### 존재하지 않는 컬럼 제외 시
    
    - 테이블에 존재하지 않는 컬럼이 EXCLUDE_COLS에 설정할 경우, 관련 된 Warning을 로그에 출력하고 해당 설정을 무시
    - EXCLUDE_COLS를 여러 개 설정하여 존재하는 컬럼과 존재하지 않는 컬럼의 조합이 사용된다면, 존재하는 컬럼만 추출에서 제외
    
    ```bash
    EXCLUDE_COLS (existing_col, non-existing_col)
    ```
    
    ### Definition
    
    - `EXCLUDE_COLS`로 인해 컬럼이 제외되어도 Definition에서는 제외되지 않아야 함
    
    ### 모든 컬럼 제외
    
    - 테이블의 모든 컬럼이 제외될 경우 Tracing 파일에 레코드가 기록되지 않아야 함 (Skip해야 함)
    
    ### Update 대상 컬럼이 제외 된 경우
    
    - Update문의 대상 컬럼(SET절)이 제외되어 레코드 After 데이터가 없을 경우 해당 레코드는 Tracing 파일에서 Skip되어야 함
    
    ### 키 컬럼이 제외 된 경우
    
    - `EXCLUDE_COLS`의 경우 키 컬럼은 제외하지 않도록 권장
    - Update 또는 Delete문에서 키 컬럼이 제외 될 경우 Extract가 중지되어야 함(Before 절이 비어있는 경우)
    - Composite Primary key의 경우 일부 컬럼만 추출 제외되고, 일부는 추출에 포함 된다면 정상 추출해야 함
    - Composite Primary key는 여러 컬럼 값의 조합으로 Row를 구별하기 때문에, 일부 컬럼이 제외 될 경우, 적용 시 올바른 Row가 Update 또는 Delete되지 않을 수 있음
    - Insert에서 키 컬럼이 추출 제외 될 경우 정상 추출 해야 함
    - Non-key 테이블의 경우 모든 컬럼이 추출에서 제외되지 않은 이상 정상 추출해야 함

## DML 필터링

- 특정 DML 타입을 제외
    - 추출 대상 객체 전부 적용: `EXCLUDE_DML_TYPE`(Extract Config)
    - 테이블 단위 적용: `EXCLUDE_DML`(Mapper Config)

### `EXCLUDE_DML_TYPE`

- `EXCLUDE_DML_TYPE`은 Extract Config 파일 Config
- 이 Config는 모든 추출 대상 객체에 대해 INSERT, UPDATE 또는 DELETE를 추출에서 제외(Truncate와 DDL은 `GET_TRUNCATE` 또는 `DDL Config`를 통해 필터링 가능)

```bash
EXCLUDE_DML_TYPE="[ NONE | INSERT | UPDATE | DELETE ]"
```

- `EXCLUDE_DML_TYPE`
    - 기본 값: NONE (제외 DML 타입 없음)
    - 여러 개를 설정 가능, `,`를 통해 구분

### `EXCLUDE_DML`

- Extract의 Mapper 파일에서 사용되며, 테이블 단위로 DML 필터링 가능

```bash
EXCLUDE_DML ([ INSERT(I) | UPDATE(U) | DELETE(D) ])
```

- `EXCLUDE_DML`
    - 여러 개를 설정 할 수 있으며, `,`를 통해 구분
    - 약자를 통해서도 지정이 가능하다.
- 예외
    - DELETE 타입 제외 시, 동일한 Key를 이용한 Insert 또는 Update로 인해 Target에서 중복 키 에러가 발생 가능
    - 제외 된 DML 타입 레코드는 Tracing 파일에 기록 불가
    - 모든 DML 타입이 제외 될 경우 로그와 콘솔 화면에 "Ignoring all DML type record. If not intended, confirm configuration file." 출력

## 추출 지원 데이터 타입

### Redo supported datatypes

- Extract Redo Log로부터 추출하는 데이터 타입
- Numeric Data Types
    - `NUMBER`, `DECIMAL`, `BINARY_FLOAT`, `BINARY_DOUBLE`, `FLOAT`
- Character Data Types
    - `CHAR`, `VARCHAR`, `VARCHAR2`, `NCHAR`, `NVARCHAR2`
- Binary Data Types
    - `RAW`
- Date and Timestamp Data Types
    - `DATE`, `TIMESTAMP`, `INTERVAL YEAR TO MONTH`, `DATEINTERVAL DAY TO SECOND`
- Large Object Data Types
    - BASICFILE
        - `CLOB`(inline), `NCLOB`(inline), `BLOB`(inline), `BFILE`, `CFILE`
    - SECUREFILE
        - SECUREFILE에 옵션이 없을 경우 Redo
        - 있을 경우 Fetch(옵션: De-duplication, Compression, Encryption)
- User Defined or Abstract Types
    - `ROWID`, `UROWID`
- Spatial Data types
    - `SDO_GEOMETRY`
- BFILE, CFILE
    - 외부 파일은 복제하지 않고, 저장된 경로만 저장

### Database fetch supported datatypes

- Extract가 Source 데이터베이스로부터 직접 Fetch하는 데이터 타입
    - Character Data Types
        - `LONG`
    - Binary Data Types
        - `LONG RAW`
    - Date and Timestamp Data Types
        - `TIMEZONE`, `TIMESTAMP WITH TIME ZONE`, `TIMESTAMP WITH LOCAL TIMEZONE`
    - Large Object Data Types
        - BASICFILE
            - `CLOB`(outline), `NCLOB`(outline), `BLOB`(outline)
        - SECUREFILE
            - 옵션이 있는 SECUREFILE LOB (De-duplication, Compression, Encryption)

## 추출 지원 기능

- Conventional Path와 Direct Path로 로드 된 데이터 둘 다 추출을 지원

## 프로세스 메모리 제한

- Extract 모듈의 메모리 과다 점유를 방지하기위해 최대 메모리 사용량 제한 필요
    - `IN_MEMORY_SIZE`: Extract가 Malloc한 메모리 총 사이즈 제한
    - `IN_MEMORY_TX_SIZE`: 트랜잭션 데이터 메모리 사이즈 제한
- Extract가 malloc한 사이즈가 위에 설정 된 값을 초과할 경우, 해당 내용은 Cache 파일에 기록

### `IN_MEMORY_SIZE`

- Extract가 Malloc한 메모리의 최대 사이즈를 설정하는 Config이다.

```bash
IN_MEMORY_SIZE="n[ k | K | m | M | g | G ]"
```

- `IN_MEMORY_SIZE`
    - 기본 값: 0
    - 지원 범위: 0 또는 1 이상의 정수
        - 0으로 설정할 경우 메모리 제한 없음
        - 1 이상의 정수로 설정할 경우 설정 된 값만큼 메모리를 제한
    - 지원 포맷: 정수에 이은 문자 k, K, m, M, g, G의 조합
    - 위 표기에 따른 정수 변환 값이 536,870,912-17,179,869,184 이하 (512MB ~ 16GB)
    - 이 Config 값은 `IN_MEMORY_TX_SIZE`보다 크게 설정하도록 해야한다.

### `IN_MEMORY_TX_SIZE`

- IN_MEMORY_TX_SIZE Config는 트랜잭션 데이터의 최대 메모리 사이즈를 설정한다.

```bash
IN_MEMORY_TX_SIZE="n [ k | K | m | M | g | G ]"
```

- `IN_MEMORY_TX_SIZE`
    - 기본 값: 1G
    - 지원 범위: 0 또는 1 이상의 정수
        - 0으로 설정할 경우 메모리 제한 없음
        - 1 이상의 정수로 설정할 경우 설정 된 값만큼 메모리를 제한
    - 지원 포맷: 정수에 이은 문자 k, K, m, M, g, G의 조합
    - 위 표기에 따른 정수 변환 값이 536,870,912-4,294,965,096 이하 (512MB ~ 4GB)

## 대용량 트랜잭션 관리

- 대용량 트랜잭션으로 인한 메모리 과다 점유를 방지를 위해 대용량 트랜잭션 캐싱 기능 지원
- 초과 된 레코드는 Cache 파일로 옮겨 쓰여짐
- 해당 트랜잭션 데이터가 더 들어올 경우 Cache 파일에 이어서 작성

```bash
LARGE_TRANSACTION_SIZE="n[ k | K | m | M | g | G ]";
CACHE_FILE_DEST="<cache_file>";
```

- `LARGE_TRANSACTION_SIZE`
    - 기본 값: 128MB
    - 지원 범위: 0 또는 1 이상의 정수
        - 0으로 설정할 경우 Large 트랜잭션이 바로 Tracing 파일에 기록
        - 1이상의 정수로 설정할 경우 Cache 파일에 기록된다.
    - 지원 포맷: 1 이상의 정수에 이은 문자 k, K, m, M, g, G의 조합
    - 위 표기에 따른 정수 변환 값이 134,217,728-4,294,965,096이하 (128MB ~ 4GB)
- `CACHE_FILE_DEST`
    - 캐시 파일 경로 지정

### Cache 파일

- 대용량 트랜잭션 레코드를 저장하는 파일
- 대용량 트랜잭션에 대한 정보는 CTS 파일에 저장
- Extract는 CTS 파일을 통해 대용량 트랜잭션 레코드 추출 지점을 알 수 있음
- 캐시 파일의 구조는 Tracing 파일과 동일

```bash
{writer alias}*{transactionID}*{tracing sequence#}.trc
```

- 동작
    1. Extract 메모리에 있는 Commit되지 않은 transaction의 누적 사이즈가 `LARGE_TRANSACTION_SIZE` 설정 값을 초과
    2. Large 트랜잭션을 cache file에 모두 내려씀
    3. 해당 트랜잭션이 Commit 되면 Cache 파일의 내용을 모두 Tracing 파일에 옮겨씀
    4. cache file에는 definition record가 작성되지 않음

### CTS 파일

- cache file과 함께 동작하며, cache된 transaction의 상태를 기록하는 파일
- Cache 파일을 Tracing 파일에 옮겨 쓰는 과정에서 Extract가 종료 될 경우, 재시작 시 CTS 파일을 통해 이어서 추출할 지점을 알 수 있음

```bash
{alias}_{transactionID}.cts
```

- CTS 파일
    - Cache 파일에 내려쓴 레코드의 추출 지점 (RBA)
    - Cache 파일 Sequence
    - Cache 파일 내 Position
    - 캐시 된 레코드 개수
- 동작
    - Cache된 트랜잭션이 존재하고, Log switch가 발생한 경우 마지막으로 cache된 레코드 정보 및 cache file 정보를 저장
- 재시작 시 동작:
캐시 된 트랜잭션이 있는지 조회한 뒤, 있을 경우 CTS 파일이 존재하는지 확인하고 이를 로드
    - CTS 파일이 있는 경우 : CTS 파일 내용을 참조하여, cache file의 기준지점(pos) 이후 내용을 삭제 후 transaction list에 추가, 재시작 지점부터 다시 캐싱
    - CTS 파일이 없는 경우 : 캐시된 트랜잭션 삭제 후 다시 캐싱

## 데이터, 데이터 타입 변환 추출

- 데이터 변환
    - `LOB` 변환
        - `LOB`를 `NULL` 또는 `Char`로 변환
        - `LOB` 추출 실패 시 `Empty`로 변환
    - 데이터 변환
        - 특정 컬럼 또는 특정 데이터 타입의 데이터를 변환
- 데이터 타입 변환
    - 특정 데이터 타입을 다른 데이터 타입으로 변환

### `LOB` 변환

- Extract가 데이터를 추출할 때 `LOB` 데이터에 대해 변환하여 추출할지 지정하는 기능
- `LOB` 변환 추출 Config
    - `CONVERT_LOB_TO_CHAR`
    - `LOB_TO_NULL`
    - `FAILED_FETCH_LOB_TO_EMPTY`

```bash
CONVERT_LOB_TO_CHAR="<char_value>";
LOB_TO_NULL="[ yes | no | y | n ]";
FAILED_FETCH_LOB_TO_EMPTY="[ yes | no | y | n ]";
```

- `CONVERT_LOB_TO_CHAR`
    - `LOB` 데이터를 대체하여 추출 할 문자열을 지정하는 Config
    - 설정될 경우 `LOB_TO_NULL`과 `FAILED_FETCH_LOB_TO_EMPTY` Config는 무시
    - 최대 255 byte까지 설정이 가능
- `LOB_TO_NULL`
    - `LOB` 데이터를 `NULL`로 추출할지 여부를 지정하는 Config
    - yes 또는 y로 설정될 경우 `FAILED_FETCH_LOB_TO_EMPTY` Config는 무시
    - 기본 값: no
- `FAILED_FETCH_LOB_TO_EMPTY`
    - `LOB` 데이터에 대한 Fetch가 실패할 경우 `Empty`로 추출할지 여부를 지정하는 Config
    - 기본 값: no

### 데이터 변환 추출

- 특정 컬럼 또는 특정 데이터 타입의 데이터를 `NULL`, 특정 숫자 또는 문자열로 치환하여 추출하는 기능
- 이 설정은 Extract Mapper 파일에서 수행 가능

```bash
MAP from_schema.from_object [ TARGET to_scheam.to_object ] {
	convert_data (oracle_datatype, value)
};
```

- `oracle_datatype`
    - Oracle 고유 데이터 타입만 사용 가능
    - 지원 타입
        - `CHAR`, `NCHAR`, `VARCHAR2`, `NVARCHAR2`, `NUMBER`, `BINARY_FLOAT`, `BINARY_DOUBLE`, `LONG`, `DATE`, `CLOB`, `NCLOB`, `BLOB`
- `value`
    - 치환 가능한 데이터
        - `NULL`, 숫자 ,문자, `EMPTY()` (`oracle_datatype`이 `LOB`가 아닐 경우, `NULL`로 변환), 공백 (`' '`)
    - 허용되지 않는 데이터
        - 공백 없는 작은 따옴표 (`''`)
- 데이터 변환 주의 사항
    - 지정한 데이터 타입에 올바른 데이터를 입력해야 함
    - 올바르지 않는 형식의 데이터를 지정하면 에러 발생

### 데이터 타입 변환 추출

- 특정 데이터 타입을 다른 데이터 타입으로 치환하여 추출하는 기능
- 이 설정은 Extract Mapper 파일에서 수행 가능

```bash
MAP from_schema.from_object [ TARGET to_scheam.to_object ] {
	convert_type (oracle_datatype, convert_type)
};
```

- `oracle_datatype`
    - 지원 타입
        - `CHAR`, `NCHAR`, `VARCHAR2`, `NVARCHAR2`, `NUMBER`, `BINARY_FLOAT`, `BINARY_DOUBLE`, `LONG`, `DATE`
- `convert_type`
    - CDC 지원 타입
        - `NUMERIC`, `STRING`, `DATE`
    - 지원되는 데이터 타입 변환
        - `CHAR`, `NCHAR`, `VARCHAR2`, `NVARCHAR2` → `NUMERIC`
        - `NUMBER`, `BINARY_FLOAT`, `BINARY_DOUBLE`, `LONG`, `DATE` → `STRING`
        - `CHAR`, `NCHAR`, `VARCHAR2`, `NVARCHAR2` → `DATE`
- 데이터타입 변환 주의 사항
    - 지원되는 데이터 타입 변환 이외의 데이터 타입이 명시 될 경우 에러가 발생
    - Definition에 변경된 데이터타입이 반영되지 않음
    - DDL은 변환 추출이 지원되지 않음
    - 치환하려는 datatype에 유효한 데이터만 추출
        - ex) CONVERT_TYPE(varchar2, numeric); / 실데이터: '123ABC' => 추출데이터: 123

### 컬럼 단위 데이터 변환

- 컬럼 단위로 특정 컬럼 또는 특정 값을 변환하여 추출하는 기능

```bash
MAP from_schema.from_object [ TARGET to_scheam.to_object ] {
	COLMAP (
		column_name = @STRTONUM (column_name | value),
		column_name = @NUMTOSTR (column_name | value),
		column_name = @BINARY (column_name),
		column_name = @DATE (column_name)
	);
};
```

- `@STRTONUM`
    - 문자 데이터를 숫자로 변환
- `@NUMTOSTR`
    - 숫자 데이터를 문자로 변환
- `@BINARY`
- 특정 컬럼 데이터를 `Binary` 형식으로 변환
- `@DATE`
    - `String` 타입 컬럼 데이터를 `DATE`로 변환
    - `String` 타입 컬럼만 사용 가능
    - 지원 포맷
        - YYYY-DD-MM 24HH:mm:SS
        - YYYY-DD-MM (날짜만 지정될 경우 시간은 0으로 추출)

## TDE/TSE 추출

- 암호화 데이터를 추출하기 위해 필요

### TDE 추출 기능

- TDE는 암호화 컬럼의 데이터를 그대로 추출하고 Tracing 파일에 작성할 때 복호화를 수행
- TSE는 Vector의 모든 컬럼 데이터들을 암호화하는 기능
- ObjectID, 컬럼 정보, 트랜잭션 ID 등 추출에 필요한 데이터들이 모두 암호화 되어있어 레코드에서 데이터를 추출하기 전에 복호화 수행
- TDE 데이터는 컬럼 단위 암호화 및 테이블스페이스 단위 암호화 데이터 추출이 지원

```bash
ARK_TDE_FILENAME="<wallet_key_file>"
```

- `ARK_TDE_FILENAME`
    - 최대 255자까지 가능

## 테이블 정의 데이터 추출

- 테이블의 생성/정의 값을 수집하여 Tracing 파일에 저장하는 기능
- Tracing 파일에서 Definition 레코드로 기록됨

## DDL History 관리

- DDL이 발생 할 경우 테이블의 메타정보가 변경될 수 있음
- 레코드 수행 시점 기준 메타정보가 필요할 경우 DDL History 테이블을 통해 이를 알 수 있음

### DDL History 관리 기능

DDL History는 두 개의 테이블로 관리된다.

- Marker Table
    - Marker table에는 다음과 같은 정보가 저장
        - DDL 발생 시간
        - DDL Event (CREATE, ALTER, DROP)
        - DDL Object Type (TABLE, USER, SEQUENCE...)
        - DDL Object Owner
        - DDL Object name
        - DB version
        - DDL statement
        - NLS session parameter
    - BEFORE DDL Trigger는 아직 DDL이 실행되지 않아 DDL의 SCN이 없음
    Marker Table에 위 데이터 저장으로 생성된 SCN을 History Table의 DDL SCN 값 활용
- History Table
    - `ALTER`, `DROP` DDL 이벤트가 발생 했을 때 다음과 같은 정보를 테이블에 저장
        - DDL SCN
        - Object ID, Data Object ID
        - Object Name
        - Object Owner
        - Object Type
        - DDL Type
        - Column 메타 정보 (JSON)

## Presist 파일 관리

- 오랫동안 Commit되지 않은 트랜잭션이 존재할 때, 재시작 시, redo/archive의 보관 주기 문제와 너무 오래 전 시점부터 추출을 시작해야 하는 문제를 해소하기 위해 Persist 파일을 활용

### Persist 파일 관리 기능

- 특정 조건 발생 시, `COMMIT` 또는 `ROLLBACK`이 수행되지 않은 트랜잭션의 데이터를 Persist 파일에 저장
- Persist 파일이 생성 되는 특정 조건은 `PERSISTENCE_MODE` Config를 통해 설정 가능
- Persist 파일은 아래와 같은 포맷으로 `CACHE_FILE_DEST` 경로에 저장

```bash
{alias}*persist*{thread#}*{log sequence#}*{tracing sequence#}.trc
```

- 기본 동작 (Log Switch 기준)
    - Log Switch가 일어난 시점에, 현재 가지고 있는 Transaction list를 돌면서 Persist 파일에 모두 내려씀
    - 가장 최근 Persist 파일이 최초 시작 이후 `Commit`되지 않은 transaction들을 모두 가지고 있어야 함
    - Current redo sequence 보다 2 미만인 persist 파일은 삭제
    - transaction list가 비어있는 경우에는 persist 파일 작성하지 않음
    - 이미 Caching 된 Transaction인 경우에는 persist 파일 작성하지 않고, cts 파일만 작성
    - Persist 파일은 가장 최근의 Redo Log에 포함되는 Long Transaction 데이터만을 저장하며, Thread 당 최대 2개까지 유지
- 재시작 시 동작
    - persist transaction이 있는지 검색한 뒤, persist transaction을 transaction list에 추가
    - RAC 환경에서 노드별로 persist 파일이 존재하는 경우, checkpoint의 persist timestamp를 비교하여 가장 최근의 persist 파일 하나만 로드

### Config

- Persist File을 작성하는 기준은 `PERSISTENCE_MODE` Config를 통해 설정 가능

```bash
PERSISTENCE_MODE="[ LOGSWITCH | INTERVAL | OFF ]"
PERSISTENCE_INTERVAL="[ { n } H ]"
```

- `PERSISTENCE_MODE`
    - 기본 값: `LOGSWITCH`
    - `LOGSWITCH`: 로그 스위치 발생 기준으로 Persist 파일을 작성한다.
    - `INTERVAL`: 특정 시간 간격으로 Persist 파일을 작성한다.
    - `OFF`: Persist 파일 작성을 비활성화 한다.
- `PERSISTENCE_INTERVAL`
    - `PERSISTENCE_MODE` 값이 `INTERVAL` 일 때만 유효하다.
    - 0 설정 시 사용 안함을 의미한다.
    - 기본 값: 6
    - 최솟 값: 0
    - 최댓 값: 2400
    - 지원 포맷: 정수에 이은 H 문자의 조합

## Extract 체크포인트

- Extract가 재시작 시 마지막 추출 지점부터 이어서 추출 가능하도록 추출 및 Tracing 파일 기록 시점을 기록
- 프로세스의 상태 및 진행 상황 파악 가능

### 체크포인트 기능

- Extract 체크포인트는 크게 `Read`와 `Write` 체크포인트로 나뉨
`Read` 체크포인트는 Extract가 Redo Log에서 읽은 위치, `Write`는 Tracing 파일에서 기록하는 위치
- Read Checkpoint
    - Startup Checkpoint
        - Extract가 최초 실행 된 위치
        Write가 발생하기 전에 Extract가 재시작 될 경우 추출의 시작점이 되기도 함
    - Persistent Checkpoint
        - Extract가 재시작 되기까지 길어 지거나 Long 트랜잭션으로 인해 Persistent Caching 기능이 실행 될 경우, 마지막 저장 위치
    - Recovery Checkpoint
        - 메모리에 로드 되어있는 `Commit`되지 않은 트랜잭션 중 가장 오래 된 트랜잭션
        - Extract 재기동 시, 이전에 추출하지 못한 트랜잭션의 시작 지점인 Recovery로 이동하여 추출을 수행
    - Current Checkpoint
        - Extract가 Redo Log에서 가장 최근에 읽은 리두 블럭.
- Write Checkpoint
    - Write Checkpoint는 Extract가 Tracing 파일에서 성공적으로 기록한 것을 확인한 위치

### 작성 및 갱신 시점

- 작성하는 시점
    1. 모듈 start ( header, startup & current - thread, scn )
    2. redo open 직후 ( startup & current - rba, log path )
- 갱신 시점
    1. 10초마다 갱신. ( current )
    2. tracing file write ( write, current )
    3. log switch 발생 ( persist & current )
    4. 모듈 stop ( current )

재시작 후 시작 지점 설정

Extract가 재시작했을 때 Checkpoint 기록 여부 및 시점에 따라 추출 시작 시점이 다르게 설정됨

이미 추출했던 데이터들은 재추출하지 않도록 스킵해야 함

Large Transaction의 경우, 이미 캐싱 된 데이터들을 다시 캐싱하지 않도록 해야 함

| Checkpoint 상태 | 시작 시점 |
| --- | --- |
| persist, recovery 모두 기록 | persist와 recovery를 비교해 가장 최근 지점부터 시작 |
| persist가 최근 | persist 파일을 로드 한 뒤, persist 지점부터 시작 |
| recovery가 최근 | recovery 지점부터 시작 |
| 동일 정보 | persist 지점부터 시작 |
| persist만 기록 | persist 파일을 로드 한 뒤, persist 지점부터 시작 |
| recovery만 기록 | recovery 지점부터 시작 |
| persist, recovery 모두 없음 | startup 지점부터 시작 |
- 예외
    - 체크포인트 파일이 없을 경우:
        - 파일을 새로 생성하여, 현재 확인할 수 있는 정보로 체크포인트를 작성한다.
    - 체크포인트 파일 권한이 없을 경우:
        - Extract 프로세스 시작 시:
            - 체크포인트 파일에 권한이 없다는 메시지를 로그에 남긴다.
            - Extract 프로세스가 시작되지 않아야 한다.
        - Extract 프로세스 실행 중 발생 시:
            - 체크포인트 갱신 시점에 권한이 없을 경우, 체크포인트 파일에 권한이 없다는 메시지를 로그에 남긴다.
            - 프로세스를 중단 시킨다.

### Extract Lag

- Extract 프로세스 Lag는 레코드가 발생한 시간과 Extract가 레코드를 Tracing 파일에 기록한 시간 간 간격
- Extract Lag는 Extract 체크포인트 파일에 기록, 체크포인트 파일이 갱신 될 때마다 같이 갱신

```bash
admgr getlag
admgr getlag all
admgr getlag extract
admgr getlag extract all
```

### Checkpoint Thread

- Checkpoint 용 별도 스레드가 필요하며, 해당 스레드는 Monitoring API와 통신

### Checkpoint 갱신 간격 설정

- Checkpoint 파일의 갱신 간격은 `CHECKPOINT_SECONDS` Config로 설정 가능

```bash
CHECKPOINT_SECONDS="n"
```

- `CHECKPOINT_SECONDS`
    - 기본 값: 10
    - 최소 값: 2
    - 최대 값: 30

## 시점 추출

- Extract가 특정 SCN 또는 Timestamp에서 시작하도록 설정하는 기능

```bash
--start-dsn

--start-time
```

## 초기 복제

- 기존에 있는 데이터를 복제해 Source와 Target DB를 동기화 시키기 위해 필요한 기능

```bash
INITIAL_COPY_THREADS="n"
INITIAL_COPY_SPLIT_TRANSACTION="n"
INITIAL_COPY_SPLIT_SIZE="n"
INITIAL_COPY_PARALLELISM_DEGREE="n"
INITIAL_COPY_SCN_ASCENDING="[ on | off ]"
```

- `INITIAL_COPY_THREADS`
    - 초기 복제 시 사용할 Capture Thread 개수
    - 기본 값: 4
    - 최소 값: 1
    - 최대 값: 10
- `INITIAL_COPY_SPLIT_TRANSACTION`
    - 초기 복제 트랜잭션의 최대 레코드 개수
    - 기본 값: 100,000
    - 최솟 값: 10,000
    - 최댓 값: 1,000,000
- `INITIAL_COPY_SPLIT_SIZE`
    - 초기 복제 트랜잭션의 최대 크기
    - 기본 값: `LARGE_TRANSACTION_SIZE` 값
    - 최소 값: 1
    - 지원 포맷: 정수에 이은문자 k, K, m, M, g, G의 조합
    - 지원 범위: 정수 변환 값 134,217,728-4,294,965,096이하 (128MB ~ 4GB)
- `INITIAL_COPY_PARALLELISM_DEGREE`
    - 초기 복제 시 쿼리 수행 병렬도
    - 기본 값: 4
    - 최소 값: 0
    - 최대 값: 128
- `INITIAL_COPY_SCN_ASCENDING`
    - 초기 복제 쿼리 scn_ascending 힌트 사용 여부
    - 기본 값: on
    - --start-dsn 옵션 사용시, 해당 config 무시

### 초기 복제 수행

Source 데이터베이스에서 테이블의 구조와 데이터를 복제하는 기능

- 옵션 리스트
    - `-copy`
        - 초기 복제 필수 옵션
    - `--copy-data`
        - 데이터만 추출 (기본 값)
    - `--copy-table`
        - 테이블 구조만 추출
    - `--copy-all`
        - 데이터와 테이블 구조 둘 다 추출
    - `--script`
        - ddl script로 생성
    - `--copy-sample`
        - 입력한 값만큼 sample 추출 (default 1000)

## 통계

- Extract 추출 데이터를 모니터링하기 위해 통계를 기록

```bash
extract_[alias]_[timestamp].stat
```

## 트랜잭션 필터링 (나중에 작성)

## Emergency 모드

- 프로세스가 5번 이상 재시작 될 경우 해당 프로세스의 로그와 덤프를 남기기 위해 프로세스를 임시로 시작하는 기능
- Extract 시작 옵션인 `--emergency`를 통해서도 수행 가능

```bash
admgr start --emergency [module_alias]
```

- EMERGENCY 모드로 실행한 프로세스가 종료될 경우, 이 프로세스는 재시작되지 않음
- Emergency 모드가 수행된 후, 로그 레벨과 상관없이 중단되기 직전 로그 1000개를 로그 파일에 덤프 형태로 남김

## 캐릭터셋 변환 실패

- Extract는 추출한 데이터를 전부 UTF-8로 변환
- 변환이 실패할 경우 (iconv error) `FAILED_CONVERT_TO_UTF8` Config를 통해 동작 설정

```bash
FAILED_CONVERT_TO_UTF8="[ STOP | NULL | RAW | FETCH]";
```

- `FAILED_CONVERT_TO_UTF8`
    - `STOP` (Default): Extract 중단
    - `NULL`: 데이터를 `NULL`로 추출
    - `RAW`: UTF-8로 변환하기 전 캐릭터셋으로 추출
    - `FETCH`: 데이터를 `Select`를 통해 추출

## Extract 모듈 상태

- `Running`
    - Extract가 동작 중인 상태
- `Stopped`
    - Extract가 정상 중지된 상태.
- `Error`
    - 에러가 발생하여 Extract가 중지 된 상태
- Extract는 위 모듈 상태를 admgr, Checkpoint 파일, Manager 및 미들웨어에 제공
- 필요에 따라 모듈 상태를 추가해서 사용 가능

## Multi-write Extract

- 하나의 Extract가 여러 Tracing 파일에 기록 할 수 있도록 하는 기능
- 구성하기 위해 `TRACINGALIAS` Config를 여러 개 설정

```bash
TRACINGALIAS="ext01_wrt1";
TABLE="CDCTEST.TEST";
SEQUENCE="";
DDL="";
TRACINGFILE_SIZE="";
TRACINGFILE_DEST="";
MAP="map1";
FAILED_FETCH_LOB_TO_EMPTY=""
GET_TRUNCATE="no"
##-------------------------##
TRACINGALIAS="ext01_wrt2";
TABLE="CDCTEST.TEST2";
SEQUENCE="";
DDL="";
TRACINGFILE_SIZE="";
TRACINGFILE_DEST="";
MAP="map2";
FAILED_FETCH_LOB_TO_EMPTY=""
GET_TRUNCATE=""
```

- `TRACINGALIAS` Config부터 `GET_TRUNCATE` Config는 하나의 Tracing Alias 단위 설정
- 이 Config들이 하나의 세트이며, 최대 10개까지 설정 가능
- Tracing Alias 설정은 다른 Tracing Alias 설정에게 영향 받지 않으며, 설정되지 않은 Config는 Default 값이 사용
- Config가 중복 될 경우, 가장 마지막 Config 설정이 사용

## 레코드 기록 단위

- Extract가 추출한 레코드를 Tracing 파일에 기록하는 단위
- 단위 설정은 `WRITE_FLUSH_RECORD_COUNT`와 `WRITE_FLUSH_BUFFER_SIZE` Config를 통해 설정

```bash
WRITE_FLUSH_RECORD_COUNT = "[ n ]"
WRITE_FLUSH_BUFFER_SIZE = "[ n ] [ k | k | m | M ]"
```

- `WRITE_FLUSH_RECORD_COUNT`
    - Extract가 한번에 기록 할 레코드 개수 경계점
    - 이 값만큼 레코드 개수가 채워지면 해당 레코드들이 Tracing 파일에 기록
    - `WRITE_FLUSH_RECORD_COUNT` Config에 설정 개수만큼 레코드가 채워지지 않아도, `WRITE_FLUSH_BUFFER_SIZE` Config에 설정 크기에 도달할 경우, 레코드가 파일에 쓰여짐
        - 기본 값: 1000
        - 최소 값: 1
        - 최대 값: 10,000,000
- `WRITE_FLUSH_BUFFER_SIZE`
    - Extract가 한번에 기록 할 레코드 사이즈 경계점
    - 이 값만큼 레코드 사이즈가 채워지면 해당 레코드들이 Tracing 파일에 기록
    - `WRITE_FLUSH_BUFFER_SIZE` Config에 설정 크기만큼 레코드가 채워지지 않아도, `WRITE_FLUSH_RECORD_COUNT` Config에 설정 개수에 도달할 경우, 레코드가 파일에 쓰여짐
        - 기본 값: 64k
        - 최솟 값: 1k
        - 최댓 값: 100mb
- 레코드가 채워지지 않아도 더 이상 추출할 레코드가 없다면 Tracing 파일에 기록 수행

## 추출 예외 사항

- 이미 `NULL`인 데이터를 `NULL`로 `Update`할 때, 해당 컬럼 이후 모든 컬럼 데이터가 `NULL`일 경우, 해당 `Update`문은 추출되지 않음