# Agent/Pmon

# Agent Config

| 이름 | 설명 |
| --- | --- |
| IP | IP 정보 |
| PORT | Agent 용 Port 번호 |
| PROTOCOL_TYPE | Agent간 구간 암호화 여부 설정 |
| RECV_PORTRANGE | 데이터 수신 Port 범위 수정 |
| DATA_PORTRANGE | Row Compare를 위한 Port 범위 수정 |
| LOG_LEVEL | 로그 레벨 설정 |
| LOG_BACKUP | 로그 백업 정책 설정 |
| LOG_PATH | 로그 파일 경로 지정 |
| SEND_EMAIL_ALERT | Email Alert 여부 설정 |
| EMAIL_SEND_ADDRESS | 전송할 Email 주소 |
| EMAIL_RECV_ADDRESS | 전송 받을 Email 주소 |
| SMTP_TYPE | SMTP / SMTPS
(SMTP_PORT가 465일 경우 SMTPS) |
| SMTP_SERVER | SMTP Server 주소 |
| SMTP_PORT | SMTP Server Port 번호 |
| SMTP_ID | SMTP Server ID |
| SMTP_PASSWORD | mgr의 getpwd 명령(-e)을 이용하여 암호화 한 값을 저장 |
| MONITORING_RESET_TIME | 모듈 정상 작동 여부를 판단하는 시간 설정 |

# Agent 정보 설정

- Agent IP와 Port를 지정할 수 있음

```bash
IP="<IP Address>";
PORT="<Port>";
```

- `IP`
    - IPv4
- `PORT`
    - well-known port 영역 제외, 기본 값: 11811
        - 등록된 포트 (registered port): 1024 ~ 49151
        - 동적 포트 (dynamic port): 49152 ~ 65535
            - 해당 범위의 값을 설정할 경우 경고 메세지가 출력

# 암호화 통신

- 통신 프로토콜을 암호화하여 사용할 수 있도록 함

```bash
PROTOCOL_TYPE="[ http | https ]";
```

- `PROTOCOL_TYPE`
    - 기본 값: http
    - https 설정 시 $ARKCDC_HOME/conf에 특정 파일 필요
        1. cdc_server.key - Server Private Key
        2. cdc_server.pem - Server Private Key로 만든 인증서
        
        ```bash
        openssl genrsa -out cdc_server.key 1024
        openssl req -dats 365 -out cdc_server.pem -new -x509 -key cdc_server.key
        ```
        
- 예외
    - 연결된 peer 간 `PROTOCOL_TYPE` 옵션이 동일해야 한다.
        - 동일하지 않은 경우 Send-Recv 연결에 실패한다.
    - 설정이 올바르지 않은 경우 관련 내용이 로깅되고 agent가 종료된다.
        - 키/인증서 파일이 존재하지 않는 경우
        - 키/인증서 파일이 유효하지 않은 경우
        - 키 사이즈가 지정된 범위를 벗어나는 경우
    - cdc_server.key 파일 생성 시, 키 사이즈 범위는 최소 512 bit, 최대 4096 bit이어야 한다.
    범위에 속하지 않을 경우 관련 내용이 로깅되고 Agent가 종료된다.

# 수신 Port 범위 설정

- Target Server에서 데이터를 수신할 Port 범위를 설정하는 기능

```bash
RECV_PORTRANGE="[ [port]:[port] ]";
```

- `RECV_PORTRANGE`: 최대 개수 255
    - well-known port 영역 제외
    - 동적 포트 사용 시 경고 메세지 출력

# Compare 데이터 Port 범위 설정

- Manager가 Row Compare를 요청할 때 Agent에 접근하기 위한 Port 범위를 설정하는 기능
- Source와 Target Agent 설정 파일에 `DATA_PORTRANGE` Config를 통해 설정 가능

```bash
DATA_PORTRANGE="[ [port]:[port] ]";
```

- `DATA_PORTRANGE`
    - well-known port 영역 제외
    - 동적 포트 사용 시 경고 메세지 출력

# Log 관리

- 로그 레벨 설정과 로그 백업 설정 기능

```bash
LOG_LEVEL="[ TRACE | DEBUG | INFO | WARN | ERROR | FATAL ]";
LOG_BACKUP="[ NONE | ONE | ALL ]";
LOG_PATH="<PATH>";
```

- `LOG_LEVEL`
    - Agent와 Pmon 프로세스의 로그 레벨을 설정
    - 기본 값: `INFO`
- `LOG_BACKUP`
    - 기본 값: `ALL`
    - log 파일 백업 여부를 설정
        - `NONE`: 로그 파일을 백업하지 않음
        - `ONE`: 1개의 로그 파일만 백업 후 기존 파일을 덮어씀
        - `ALL`: 모든 로그 파일을 백업
- `LOG_PATH`
    - 기본 값: $ARKCDC_HOME/logs/
    - 로그 파일 경로를 설정

# Agentwd

- Agent의 Job 처리 담당
- Agentwd 작업
    - Job 상태 및 결과를 확인할 수 있는 API를 제공
    - Job 중지를 요청하는 API를 제공

## Agentwd Arguments

| 이름 | 타입 | 설명 |
| --- | --- | --- |
| job_type | int | Job 종류 |
| job_code | string | Agent에서 관리하는 Job의 고유 Code |

## Job Type

| Job | 값 | 설명 |
| --- | --- | --- |
| TABLEHASH | 11 | table의 row count와 데이터의 분산 값 구함
total compare 시 활용 |
| ROWHASH | 12 | 각 row의 hash 값을 구하고 이 내용을 결과 파일에 기록
row compare 시 활용 |
| ROWHASH_ANALYSIS | 13 | row hash 결과 파일을 분석 |
| TABLEHASH_TOTAL | 14 | source agent / target agent에 TABLEHASH job을 각각 요청하고 그 결과를 취합해 비교 결과 정리 |
| FILE_TRANSFER | 15 | 타 Agent에게 파일 요청 |
| TABLESCAN | 21 | table 전체를 읽어 요청에 따라 key / hash를 구분해 파일에 기록 |

## `job_code`

- 1 ~ 10000 순환해 1씩 증가하는 sequence와 start_time 문자열에 MD5 암호화 함수를 적용한 해쉬 값을 job code로 사용

## Job 관리

- Job은 최대 100개까지 동시에 수행 가능하며 100개를 초과하는 요청은 거부
- Job 관련 데이터는 Agent의 공유 메모리에서 관리하며 Agentwd는 수행 경과를 실시간으로 기록
    - `job_code`를 key로 하는 job_item 리스트를 관리
    - Agent는 작업 완료 후 10분간 job_item 리스트를 관리
- 작업 시작 시 start_time을 기록하고, 작업 종료 시 end_time을 기록

# 인증

- Peer간 통신에 사용자가 허가하지 않은 연결을 배제하기 위해 Agent 인증 기능이 제공
- 인증 기능은 $ARKCDC_HOME/conf 하위에 agent.pwd 파일을 통해 수행
- 인증은 Open API를 위한 인증과 내부 용도 API를 위한 인증 두 가지 있어야 함
- 예외
    - Agent 시작 시 agent.pwd의 내용이 유효하지 않을 경우 해당 내용이 로깅되고 Agent가 종료

## 인증 방식

- 개선된 Digest Authentication
    - 알고리즘: MD5, Bcrypt
    - OpenAPI를 제외한 모든 API
- Basic Authentication
    - 알고리즘: PBKDF2, BASE6
    - Open API

| Type | URI | Method | Desc |
| --- | --- | --- | --- |
| auth | /afc/auth/init | POST | 사용자 인증 |
| module | /afc/module/state | GET | module 정보 |
| info | /afc/info/state | GET | 단말 정보 |
|  | /afc/info/peer | GET | 현재 동작 중인 모듈 목록 |
|  | /afc/info/df | GET | 디스크 사용량 |
|  | /afc/info/statistics | GET | 통계 정보 |
|  | /afc/info/schemas | GET | 특정 extract config의 추출 대상 schema 리스트 |
|  | /afc/info/tables | GET | 특정 유저 소유의 테이블 목록 |
| config | /afc/config | GET | config 가져오기 |
|  | /afc/config/list | GET | config file 리스트 |

# 장애 메일 발송

- 모듈 장애 시 경고 메일을 발송
- 발송 여부는 Agent 설정 파일의 `SEND_EMAIL_ALERT` Config를 통해 설정 가능

```bash
SEND_EMAIL_ALERT="[ yes | no | y | n ]";
EMAIL_SEND_ADDRESS="<email_address>";
EMAIL_RECV_ADDRESS="<email_address>";
SMTP_TYPE="[ SMTP | SMTPS ]";
SMTP_SERVER="<ip_address>";
SMTP_PORT="<port_number>";
SMTP_ID="<ID>";
SMTP_PASSWORD="<password>";
```

- `SEND_EMAIL_ALERT`
    - 모듈 장애 시 경고 메일 발송 여부
- `EMAIL_SEND_ADDRESS`
    - 전송할 Email 주소
- `EMAIL_RECV_ADDRESS`
    - 전송 받을 Email 주소
- `SMTP_TYPE`
    - 기본 값: SMTP
- `SMTP_SERVER`
    - SMTP Server 주소
- `SMTP_PORT`
    - `SMTP_TYPE`= SMTP일 때 기본 값: 25
    - `SMTP_TYPE`= SMTPS일 때 기본 값: 465
- `SMTP_ID`
    - SMTP ID
- `SMTP_PASSWORD`
    - SMTP 비밀번호

# 모니터링

- Pmon 프로세스는 Agent의 모듈과 프로세스 상태를 모니터링 및 관리
- Pmon 프로세스는 모듈 상태 파일인 module.alias.mpc를 통해 모듈을 모니터링
- 모듈이 비정상 종료 될 경우 모듈을 재시작

# 모듈 재실행

- Extract가 비정상적인 블록을 읽고 종료될 경우
- 프로세스가 사용자 요청이 아닌 외부 요인으로 Kill 될 경우
- 5회차 재시작 될 경우 Emergency Mode로 기동
    - 비정상 종료 횟수가 5회인 경우 해당 프로세스를 `-emergency` 옵션을 사용해 실행
        1. Extract인 경우 dump 디렉터리에 현재 읽고 있는 로그 파일 정보 기록
        ($ARKCDC)HOME/dump/extract_alias_thread count)
        2. 프로세스 재실행
    - 비정상 종료 횟수가 5회 미만인 경우
        1. 최초 비정상 종료 시, email alert 설정 된 경우 경고 메일 발송
        2. 프로세스 재실행
- 모듈 재실행 이후 모듈이 정상 작동 할 경우 비정상 종료 횟수와 이메일 알림이 초기화
- 모듈 정상 작동 판단 기준은 `MONTORING_RESET_TIME` Config를 통해 설정 가능

```bash
MONITORING_RESET_TIME="n[ s | S | m | M ]";
```

- `MONITORING_RESET_TIME`
    - 기본 값: 5m
    - 최소 값: 1s
    - 최대 값: 60m

# Recv 디스크 사용량

- Recv 모듈이 사용할 최대 디스크 사용률을 관리하려면 `DISK_USAGE_CAPACITY` Config를 사용
단위: %

```bash
DISK_USAGE_CAPACITY="[ n ]";
```

- `DISK_USAGE_CAPACITY`
    - 기본 값: 95
    - 최소 값: 0
        - 0 설정 시 디스크 사용률을 확인하지 않음
    - 최대 값: 99

# 제약사항 & 예외처리

- mpc 파일이 정상적으로 작성되고 프로세스가 hang 상태인 경우 프로세스 재시작 불가
- 비정상 종료된 모듈의 재시작은 5회로 제한
- mpc 파일에 대한 정상적인 접근이 불가능할 경우 프로세스 모니터링 불가