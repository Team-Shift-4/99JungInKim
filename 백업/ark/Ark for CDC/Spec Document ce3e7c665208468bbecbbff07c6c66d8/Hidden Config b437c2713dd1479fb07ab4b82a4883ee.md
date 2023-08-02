# Hidden Config

# Agent Hidden Config

| 항목 | 기본 값 | 설명 |
| --- | --- | --- |
| h_TIMEOUT_MODULE_RESPONSE | 3s | 모듈 인터페이스 응답 대기 최대 시간 |
| h_RESTART_ERROR_MODULE | no | pmon 에러로 종료된 모듈 재시작 여부 설정 |

# Extract Hidden Config

| 항목 | 기본 값 | 설명 |
| --- | --- | --- |
| h_CHARSET_ENCODING | - | 캐릭터셋 변환 |
| h_XML_ALLOW_LOB_CONFIG | no | xml 타입이 LOB 관련 설정을 따를지 여부 |
| h_INVALID_COLUMN_FETCH | no | 추출이 올바르지 않을 경우 FETCH로 추출할 지 여부 |
| h_INVALID_FETCH_FLASHBACK_SCN | 1 | Delete 추출이 올바르지 않을 경우 FETCH로 추출할 지 여부
Fetch시, Commit SCN을 기준으로 Fetch하기 때문에 Delete문의 경우 Before Image가 존재하는 SCN까지 앞당겨야 함
이 Config를 설정하면 설정된 값 만큼 Delete Commit SCN에서 빼서 해당 SCN값을 기준으로 Delete값 조회 |
| h_CHECK_NUM_MANTISSA | 40 | 숫자 데이터 타입 NUMBER의 mantissa 사이즈 설정 |
| h_SKIP_OVER_NUM_MANTISSA | no | NUMBER의 mantissa 사이즈 초과 시 Extract 동작 결정
(yes: 추출 진행, no: Extract 중단) |

# Send Hidden Config

| 항목 | 기본 값 | 설명 |
| --- | --- | --- |
| h_DISCONNECT_STATUS | RUNNING | 네트워크 단절 시 저장할 상태 지정
RUNNING: alert mail + 재시작
ERROR: alert mail
STOPPED: No Action |

# Post Hidden Config

| 항목 | 기본 값 | 설명 |
| --- | --- | --- |
| h_USE_DEF_FROM_SEQ | 0 | 프로세스 실행 시 Definition record 일기를 시도할 Tracing file sequence |
| h_WRITE_DISCARD_TRC | yes | 데이터베이스 에러를 무시할 경우 Discard Tracing 작성 유무 |
| h_ADJUST_COLLISION_IGNORE_DB_ERROR_CODE | - | Adjust collision으로 적용 시 특정 데이터베이스 에러 코드 무시
지원 포맷: error_code |
| h_MAX_LOADED_TRACING_QUEUE | 10 | Loader에서 로드한 레코드 큐 개수 제한 |
| h_MAX_MANIPULATED_RECORD_QUEUE | 20 | Manipulation에서 변환한 레코드 큐 개수 제한 |
| h_MAX_ON_MEMORY_PLAIN_WORKSET | 20 | Record Workset에서 생성한 Workset 개수 제한 |
| h_MAX_ON_MEMORY_BATCHED_WORKSET | 20 | Batch Creation에서 배치작업이 완료된 Workset 개수 제한 |
| h_MAX_ON_MEMORY_ALLOCATED_WORKSET | 20 | Parallelism split에서 배치한 Workset 개수 제한 |
| h_MAX_ON_MEMORY_WAIT_TIME | 50 (ms) | 후속 스레드 작업 지연으로 대기하는 최대 시간 |
| h_LOADER_WAIT_TIME | 10 (ms) | Tracing 레코드 대기 시간 |
| h_DDL_EXECUTE_WAIT_TIME | 10 (ms) | DDL 레코드 적용 대기 시간 |
| h_MANIPULATION_WAIT_TIME | 10 (ms) | Load된 tracing 레코드 대기 시간 |
| h_RECORDWORKSET_WAIT_TIME | 10 (ms) | 변환된 레코드 큐 대기 시간 |
| h_BATCHCREATION_WAIT_TIME | 10 (ms) | Workset list 대기 시간 |
| h_PARALLELISMSPLIT_WAIT_TIME | 10 (ms) | 배치작업이 완료된 Workset list 대기 시간 |
| h_APPLIER_WAIT_TIME | 10 (ms) | 적용할 Workset list 대기시간 |
| h_REMOVE_DELETED_DATA | error code | 지정한 에러 코드 발생 시 op_type이 Delete 또는 Truncate인 Row를 삭제 후 에러를 발생시킨 Alter를 재수행 |
| h_V14STATS_SUPPORT | no | v1.4 버전의 통계 파일을 작성하는 기능 제공 여부 |
| h_DEADLOCK_WAIT_TIME | 500 (ms) | Deadlock 에러 발생 시 재시도 대기시간 |
| h_DEADLOCK_RETRY_COUNT | 10 | Deadlock 에러 발생 시 재시도 횟수 |
| h_IGNORE_BLANK_UPDATE | all | UPDATE 레코드 변환 시 SET절에 포함된 컬럼이 없는 경우 해당 레코드를 무시하고 적용을 진행
지원 포맷: [ all | collisions | off ] |
| h_IGNORE_CHANGED_ROW_ZERO_UPDATE | no | UPDATE 구문이 Changed Row 0로 실패하는 경우
yes: 해당 레코드 적용 무시
no: 오류로 모듈 종료 |