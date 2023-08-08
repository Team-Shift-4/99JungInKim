# PostgreSQL: Logical Decoding Output Plugin

변경 데이터 캡처(Change Data Capture, 이하 CDC)의 PostgreSQL 커넥터는 PostgreSQL DB의 스키마에서 행 수준 변경을 모니터링하고 기록할 수 있다.

PostgreSQL 서버/클러스터에 처음 연결할 때 모든 스키마의 일관된 스냅샷을 읽는다.
해당 스냅샷이 완료되면 커넥터는 PostgreSQL 9.6 이상에 커밋된 변경 사항을 지속적으로 스트리밍하고 해당 INSERT, UPDATE, DELETE 이벤트를 생성한다.

## 개요

PostgreSQL의 논리적 디코딩 기능은 9.4 버전에서 처음 도입되었다.
논리적 디코딩은 트랜잭션 로그에 커밋된 변경 사항을 추출하고 출력 플러그인의 도움을 통해 이런 변경 사항을 사용자 친화적인 방식으로 처리할 수 있는 매커니즘이다.
클라이언트가 변경 사항을 사용하기 위해 PostgreSQL 서버를 실행하기 전에 이 출력 플러그인을 설치하고 복제 슬롯과 함께 활성화해야 한다.

PostgreSQL 커넥터에는 서버 변경 사항을 읽고 처리할 수 있도록 함께 작동하는 두 가지 다른 부분이 포함되어 있다.

-   PostgreSQL 서버에 설치 및 구성해야 하는 논리적 디코딩 출력 플러그인
-   PostgreSQL JDBC 드라이버를 통해 PostgreSQL의 스트리밍 복제 프로토콜을 사용하여 플러그인에서 생성된 변경 사항을 읽는 JAVA 코드

그 다음 커넥터는 수신된 모든 행 수준 INSERT, UPDATE, DELETE에 대해 변경 이벤트를 생성한다.
클라이언트 애플리케이션은 관심있는 DB 테이블에 해당하는 모든 행 수준 이벤트에 반응한다.

PostgreSQL은 일반적으로 일정 시간이 지나면 WAL 세그먼트를 제거한다.
커넥터에는 DB에 대한 모든 변경 사항의 전체 기록이 없다.
따라서 PostgreSQL 커넥터가 특정 PostgreSQL DB에 처음 연결할 때 각 DB 스키마의 일관된 스냅샷을 수행하여 시작한다.
커넥터는 스냅샷을 완료한 후 스냅샷이 만들어진 정확한 지점에서 변경 사항을 계속 스트리밍한다.
이렇게 하면 모든 데이터에 대한 일관된 보기로 시작하나 스냅샷이 생성되는 동안 변경된 내용을 잃지 않고 계속 읽을 수 있다.
커넥터가 중지되었을 때 스냅샷이 완료되지 않은 경우 다시 시작하면 새 스냅샷이 시작된다.

## 논리적 디코딩 출력 플러그인

PostgreSQL 10+의 표준 논리적 디코딩 플러그인인 `pgoutput`은 Postgres 커뮤니티에서 유지 관리되며 논리적 복제를 위해 Postgres에서도 사용된다.
`pgoutput` 플러그인은 항상 존재한다.
추가적인 라이브러리를 설치하지 않아도 되며 원시 복제 이벤트 스트림을 변경 이벤트로 직접 해석한다.

`pgoutput`의 한계는 아래와 같다(발견 시 추가할 예정).

1.   논리적 디코딩은 DDL 변경을 지원하지 않는다.
2.   논리적 디코딩 복제 슬롯은 기본 서버(Primary Server)에서만 지원한다.
     즉 PostgreSQL 서버 클러스터가 있는 경우 활성 기본 서버에서만 실행할 수 있다.
     `hot`이나 `warm` 대기 복제본(Standby Replica)에서는 실행할 수 없다.
     기본 서버가 실패하거나 강등되면 커넥터가 중지된다.

## 논리적 디코딩을 위한 설정

먼저 복제 슬롯을 구성할 수 있어야 한다.
복제 슬롯을 구성하기 위해서는 `max_replication_slots`와 `max_wal_senders`가 둘 다 1 이상이여야 한다(기본 값: 10).
`wal_level`의 경우 WAL과 함께 사용하기에 `logical`로 설정해 준다

```bash
# vi postgresql.conf 3
wal_level=logical
max_wal_senders=1
max_replication_slots=1
```

복제 슬롯은 변경 데이터 캡처 중단 중에도 변경 데이터 캡처에 필요한 모든 WAL을 유지하도록 보장된다.
위와 같인 이유로 인해 복제 슬롯이 너무 오랫동안 사용되지 않은 상태로 유지되는 경우 카탈로그 팽창과 같이 발생할 수 있는 너무 많은 디스크 소비와 기타 조건을 방지하기 위해 복제 슬롯을 면밀히 모니터링 하는 것이 중요하다.

다음으로 권한을 설정해야 한다.
권한의 경우 복제를 수행할 수 있는 DB 사용자를 구성해야 한다.
복제는 적절한 권한이 있는 DB 사용자가 구성된 호스트에 대해서만 수행할 수 있다.
사용자에게 복제 권한을 부여하려면 최소한 `REPLICATION`과 `LOGIN` 권한이 있는 PostgreSQL 역할을 정의해야 한다(수퍼유저는 두 권한을 가지고 있다.).

```postgresql
CREATE ROLE <role_name> REPLICATION LOGIN;
```

PostgreSQL 커넥터가 실행 중인 호스트와 서버 시스템 간 복제가 발생할 수 있도록 PostgreSQL 서버를 구성한다.

```bash
# vi pg_hba.conf #
local	replication	<user>				trust
host	replication	<user>	0.0.0.0/0	trust
host	replication <user>	::1/128		trust
```

1.   <user>에 대한 로컬에 대해 복제를 허용하도록 서버에 지시한다.
2.   <user>에 대한 모든 호스트에 대해  IPv4를 사용하여 복제를 허용하도록 서버에 지시한다.
3.   <user>에 해단 localhost에 대해 IPv6를 사용하여 복제를 허용하도록 서버에 지시한다.

