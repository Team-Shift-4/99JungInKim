# Tracing Utility

# Trcdump

## Command Summary

| Command | Desc |
| --- | --- |
| LOAD | tracing file 로드 |
| DETAIL | recode 출력 옵션 설정 |
| NEXT | N | 다음 record 출력 |
| PREV | P | 이전 record 출력 |
| SKIP | S | 지정된 수의 record 건너 뜀 |
| GOTO | G | record 및 file을 이동 |
| FIND | F | 특정 조건에 해당하는 record로 이동하여 출력 |
| SCAN | 특정 조건에 해당하는 record의 위치를 출력 |
| CD | tracing file이 위치한 디렉터리를 설정 |
| STATS | tracing file 내 record 통계 정보를 출력 |
| SHOW | 현재 trcdump 설정 및 tracing file 정보를 표시 |
| POSITION | POS | 현재 위치를 출력 |
| HELP | trcdump 사용 도움말 출력 |

## LOAD

- 모듈 ALIAS 또는 파읾명으로 특정 traicing file을 조회할 수 있도록 함
    - 모듈 alias 사용 시
        - 동일한 alias를 가지는 모든 tracing file이 조회 범위로 설정
    - 파일명 사용 시
        - 입력된 tracing file만 조회 범위로 설정

```bash
trcdump load module <module_alias> [file sequence]
						 file <file_name>
```

- 📷
    
    ![trcdump load module <module_alias>](Tracing%20Utility%20fab47b0308f6412cb5791f58fa5e4028/Untitled.png)
    
    trcdump load module <module_alias>
    

## DETAIL

- 레코드 출력 옵션 설정
- Header, Transaction, 상세 데이터, Large 데이터 등 상세 정보 출력

```bash
trcdump detail [ option ] [ value ]
													[ on | off ]
							 header     [ on | off ]
							 [ transaction | tx ] [ on | off ]
							 data       [ on | off ]
							 large      [ on | off ]
								
```

- 📷
    
    ![trcdump detail, trcdump detail on](Tracing%20Utility%20fab47b0308f6412cb5791f58fa5e4028/Untitled%201.png)
    
    trcdump detail, trcdump detail on
    
    ![detail on](Tracing%20Utility%20fab47b0308f6412cb5791f58fa5e4028/Untitled%202.png)
    
    detail on
    
    ![detail off](Tracing%20Utility%20fab47b0308f6412cb5791f58fa5e4028/Untitled%203.png)
    
    detail off
    

## NEXT

- 현재 레코드 기준 입력된 값 만큼 다음 레코드를 출력하고 이동하는 명령어
- 이동 단위는 레코드, 입력이 없을 시 1개의 레코드씩 이동
- 최소 1개 부터 최대 100000개 까지 지원

```bash
next [ n ]
n    [ n ]
```

- 제약
    - Detail Data 설정이 off이고 레코드 데이터 타입이 Binary 또는 LOB일 경우 실제 데이터는 생략되며 데이터 타입 정보만 출력
- 예외
    
    ### 마지막 파일의 마지막 레코드일 때 사용한 경우
    
    - 마지막 파일의 마지막 레코드임을 출력, 파일 명 또한 출력
- 📷
    
    ![trcdump next](Tracing%20Utility%20fab47b0308f6412cb5791f58fa5e4028/Untitled%204.png)
    
    trcdump next
    

## PREV

- 현재 레코드를 기준으로 입력된 값 만큼 이전 레코드를 출력하고 해당 레코드로 이동
- 이동단위는 레코드, 입력이 없을 시 1개의 레코드씩 이동
- 최소 1개부터 최대 100000개 까지 지원

```bash
prev [ n ]
p    [ n ]
```

- 제약
    - Detail Data 설정이 off이고 레코드 데이터 타입이 Binary 또는 LOB일 경우 실제 데이터는 생략되며 데이터 타입 정보만 출력
- 예외
    
    ### 마지막 파일의 마지막 레코드일 때 사용한 경우
    
    - 마지막 파일의 마지막 레코드임을 출력, 파일 명 또한 출력
- 📷
    
    ![trcdump prev [n]](Tracing%20Utility%20fab47b0308f6412cb5791f58fa5e4028/Untitled%205.png)
    
    trcdump prev [n]
    

## SKIP

- 현재 레코드를 기준으로 입력된 값 만큼 특정 위치로 이동
- 사용 가능한 값은 특정 Row, 레코드, SCN, 트랜잭션 또는 파일

```bash
skip [ record | transaction ] [ n ]
s    [ record | transaction ] [ n ]
```

- 📷
    
    ![trcdump skip](Tracing%20Utility%20fab47b0308f6412cb5791f58fa5e4028/Untitled%206.png)
    
    trcdump skip
    

## GOTO

- 특정 값에 해당하는 레코드 또는 파일로 이동
- 이동단위는 레코드나 트랜잭션, 입력이 없을 시 1개의 레코드씩 이동
- 최소 1개부터 최대 100000개 까지 지원, 음수도 지원

```bash
goto [ OPTION ] [ value ]
g    [ OPTION ] [ value ]
		 record     [ row number ]
		 trn        [ record number ]
		 scn        [ scn ]
     [ transaction | trans | tx ] [ transaction id ]
     file       [ filename ]
```

- 제한
    - File 단위 사용 시 File 이동 기능은 사용 할 수 없다.
    - row, record 단위 이동 시, 현재 로드된 tracing file 내에서만 가능하다.
    - row 단위 이동 시, definition record는 제외된다.
    - file 이동 시, 현재 alias와 다른 파일로 이동할 수 없다.
- 예외
    
    ### 존재하지 않는 record number를 입력한 경우
    
    - 레코드가 옳지 않다는 메시지를 출력한다.
    
    ### 전체 tracing file에 존재하는 scn보다 큰 scn을 입력한 경우
    
    - 존재하지 않는 SCN임을 출력한다. 해당 파일의 마지막 SCN 또한 출력한다.
    
    ### 존재하지 않는 transaction id을 입력한 경우
    
    - 존재하지 않는 트랜잭션 ID임을 출력한다.
    
    ### 존재하지 않는 file sequence를 입력한 경우
    
    - 존재하지 않는 파일임을 출력한다.
- 📷
    
    ![goto](Tracing%20Utility%20fab47b0308f6412cb5791f58fa5e4028/Untitled%207.png)
    
    goto
    

## FIND

- 현재 레코드 기준으로, 파일 끝까지 탐색해 지정한 검색 조건과 일치하는 레코드로 이동 후 출력
- 검색 가능 정보
    - 데이터
    - 트랜잭션 ID
    - Row ID
    - Definition
- 특정 데이터로 검색할 경우 조회할 컬럼 개수 함께 입력
- find 명령어 뒤 옵션을 사용하지 않을 시 이전 조회 조건으로 검색 수행

```bash
find [ option ] [ value ]
		 data       [ schema_name.object_name ] -c [ column count ]
     tx         [ transaction id ]
		 row        [ row id ]
		 def        [ schema_name.object_name ]
```

- 제약
    - 현재 record 위치를 기준으로 동작하며, 이전 record는 검색 범위에 포함되지 않는다.
    - definition record는 해당 검색조건으로만 검색이 가능하며, 그 외 다른 조건들의 검색 범위에는포함되지 않는다.
    - data를 검색하는 경우, 옵션 사용하지 않으면 기본 1개 컬럼을 입력 받아야 한다.
    - data를 검색하는 경우, 검색 data는 record data와 완전히 일치해야 한다.
    - data를 검색하는 경우, 공백이 포함된 데이터도 검색이 가능해야 한다.
    - data를 검색하는 경우, schema_name과 object_name에 * 사용이 가능해야 한다. (부분 문자열은 불가)
    - 검색 data는 다음 기준을 따른다.
        - 공백포함: O
        - 대소문자 구분: X
        - 최소 길이 (byte): 1
        - 최대 길이 (byte): 5000
    - 직전에 조회했던 조건이 없는 상태에서 command만 입력하면 관련 내용 출력
- 예외 처리
    
    ### 조건 결과가 존재하지 않는 경우
    
    - 존재하지 않음을 출력한다.
- 📷
    
    ![trcdump find](Tracing%20Utility%20fab47b0308f6412cb5791f58fa5e4028/Untitled%208.png)
    
    trcdump find
    

## SCAN

- 📷
    
    

## CD

- 📷
    
    

## STATS

- 📷
    
    ![trcdump stat](Tracing%20Utility%20fab47b0308f6412cb5791f58fa5e4028/Untitled%209.png)
    
    trcdump stat
    
    ![trcdump stats detail](Tracing%20Utility%20fab47b0308f6412cb5791f58fa5e4028/Untitled%2010.png)
    
    trcdump stats detail
    

## SHOW

- 📷
    
    ![trcdump show files](Tracing%20Utility%20fab47b0308f6412cb5791f58fa5e4028/Untitled%2011.png)
    
    trcdump show files
    
    ![trcdump show info](Tracing%20Utility%20fab47b0308f6412cb5791f58fa5e4028/Untitled%2012.png)
    
    trcdump show info
    
    ![trcdump show fileheader](Tracing%20Utility%20fab47b0308f6412cb5791f58fa5e4028/Untitled%2013.png)
    
    trcdump show fileheader
    

## POSITION

- 📷
    
    ![trcdump position](Tracing%20Utility%20fab47b0308f6412cb5791f58fa5e4028/Untitled%2014.png)
    
    trcdump position
    

## HELP

- 📷
    
    ![trcdump help](Tracing%20Utility%20fab47b0308f6412cb5791f58fa5e4028/Untitled%2015.png)
    
    trcdump help
    

# trccomplete

- 📷
    
    ![trccomplete <module_alias>](Tracing%20Utility%20fab47b0308f6412cb5791f58fa5e4028/Untitled%2016.png)
    
    trccomplete <module_alias>