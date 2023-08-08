# PostgreSQL: Compare CDC

위 문서에는 Oracle Goldengate, Red Hat Change Data Capture Connector, Debezium을 비교 할 예정이다.

## Setting

### Oracle Goldengate

#### [DB 사용자 및 권한 준비](https://docs.oracle.com/en/middleware/goldengate/core/21.3/coredoc/prepare-postgresql.html#GUID-9E2DFFA6-F647-4A59-B022-E01794A89268)

간단히 요약하여 접속하고, 복제하고, 생성할 수 있는 권한을 부여한다.

#### DB 연결 구성

DB 연결 구성의 경우 ODBC 드라이버를 사용해 PostgreSQL에 연결한다.

#### DB 구성

DB 구성의 경우 postgresql.conf와 pg_hba.conf에서 접속 및 복제가 가능하도록 WAL 수준을 변경하고 복제 슬롯을 생성하며 복제 가능한 호스트들을 설정해준다.

#### 추가 로깅 활성화(*)

추가 로깅 활성화의 경우 DML 작업의 변경 데이터 캡처를 지원하고 로깅 수준에 따라 이중 데이터와 같은 경우 필요할 수 있는 변경되지 않은 추가 열을 포함하도록 원본 DB 테이블 수준 추가 로깅을 설정하는 작업이다.

PostgreSQL에는 4가지 수준의 테이블 수준 로깅이 있다.
테이블의 REPLICA IDENTITY 설정과 동일하다.

REPLICA IDENTITY: 업데이트나 삭제된 행을 식별하기 위해 WAL에 기록되는 정보를 변경한다.
대부분의 경우 각 열의 이전 값은 새 값과 다른 경우에만 기록된다.
이전 값이 외부에 저장되어 있으면 변경 여부에 관계없이 항상 기록된다.
이 옵션은 논리적 복제가 사용 중인 경우를 제외하고는 효과가 없다.

-   DEFAULT: 기본 키 열의 이전 값을 기록(비 시스템 테이블의 기본 값)
-   NOTHING: 이전 행에 대한 정보를 기록하지 않음(시스템 테이블의 기본 값)
-   USING INDEX <index_name>: 명명된 인덱스가 포함하는 열의 이전 값을 기록
    이 값은 고유해야 하며 부분적이지 않고 연기할 수 없어야 하며 NOT NULL로 표시된 열만 포함
    인덱스가 삭제될 경우 NOTHING과 똑같이 동작
-   FULL: 행에 있는 모든 열의 이전 값을 기록

```POSTGRESQL
ALTER TABLE <table_name> REPLICA IDENTITY [ DEFAULT | USING INDEX <index_name> | FULL | NOTHING ]
```

### Red Hat Change Data Capture Connector

#### DB 사용자 및 권한 준비

최소 LOGIN과 REPLICATION을 실행할 수 있는 권한을 준다.

#### DB 연결 구성

카프카 커넥트에 해당 정보들을 등록하여 연결한다.
높은 확률로 JDBC로 연결하는 것 같다.

#### DB 구성

DB 구성의 경우 postgresql.conf와 pg_hba.conf에서 접속 및 복제가 가능하도록 WAL 수준을 변경하고 복제 슬롯을 생성하며 복제 가능한 호스트들을 설정해준다.

#### 논리적 디코딩 출력 플러그인

Red Hat CDC Connector는 기본 내장 논리적 디코딩 출력 플러그인인 pgoutput만 지원한다.
따라서 복제 슬롯을 사용해야 한다.
논리적 디코딩의 특성으로 인해 아래와 같은 제약 사항이 발생한다.

1.   논리적 디코딩은 DDL 변경을 지원하지 않는다.
2.   논리적 디코딩은 기본 서버(primary server)에서만 지원한다.

### Debezium

#### DB 사용자 및 권한 준비

최소 LOGIN과 REPLICATION을 실행할 수 있는 권한을 준다.

#### DB 연결 구성

JDBC를 사용해 카프카 커넥트에 해당 정보들을 등록하여 연결한다.

#### DB 구성

DB 구성의 경우 postgresql.conf와 pg_hba.conf에서 접속 및 복제가 가능하도록 WAL 수준을 변경하고 복제 슬롯을 생성하며 복제 가능한 호스트들을 설정해준다.

#### 논리적 디코딩 출력 플러그인

위 Red Hat CDC Connector와 동일하나 pgoutput, decoderbuffer를 지원한다.
1.9 버전 이하에서는 wal2json도 지원하였다.