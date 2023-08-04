위 문서는 PostgreSQL 11버전을 기반으로 작성되었다.

# Debezium Connector PostgreSQL

## README.md

### PostgreSQL 변경 이벤트 수집

이 모듈은 PostgreSQL DB에서 변경 이벤트를 수집하는 커넥터를 정의한다.

#### Kafka Connect에서 PostgreSQL 커넥터 사용

PostgreSQL 커넥터는 Kafka Connect와 함께 작동하고 Kafka Connect 런타임 서비스에 배포되도록 설계되었다.
ㅂ배포된 커넥터는 DB 서버 내에서 하나 이상의 스키마를 모니터링하고 하나 이상의 클라이언트에서 독립적으로 사용할 수 있는 Kafka 항목에 모든 변경 이벤트를 기록한다.
Kafka Connect는 내결함성을 제공하여 커넥터가 실행 중이고 DB의 변경 사항을 지속적으로 따라갈 수 있도록 배포할 수 있다.

Kafka Connect는 단일 프로세스로 독립 실행형으로 실행될 수도 있지만 실패를 허용하지는 않는다.

#### PostgreSQL 커넥터 내장

PostgreSQL 커넥터는 Kafka나 Kafka Connect 없이도 라이브러리로 사용될 수 있으므로 애플리케이션과 서비스가 PostgreSQL 데이터베이스에 직접 연결하고 순서가 지정된 변경 이벤트를 얻을 수 있다.
이 방법을 사용하려면 애플리케이션이 커넥터의 진행 상황을 기록해야 다시 시작할 때 연결이 중단된 위치에서 계속될 수 있다.
따라서 이는 덜 중요한 사용 사례에 유용한 접근 방식일 수 있다.
프로덕션 사용 사례의 경우 Kafka와 Kafka Connect와 함께 이 커넥터를 사용하는 것이 좋다.

#### 테스트 실행

이 모듈에는 단위 테스트와 통합 테스트가 모두 포함되어 있다.

단위 테스트는 파일 시스템을 사용할 수 있고 JVM 프로세스 내에서 모든 구성 요소를 실행할 수 있지만 외부 서비스를 필요로 하거나 사용하지 않는 `*Test.java`나 `Test*.java`라는 JUnit 테스트 클래스이다.
위 JUnit 테스트 클래스들은 매우 빠르게 실행되고, 독립적이며, 스스로 정리한다.

통합 테스트는 Debezium 팀에서 유지 관리하는 quay.io/debezium/postgres:10 Docker 이미지를 기반으로 사용자 지정 Docker 컨테이너에서 실행되는 PostgreSQL DB 서버를 사용하는 `*IT.java`나 `IT*.java`라는 JUnit 테스트 클래스이다.
이 Docker 이미지는 DB 이벤트를 수신하는 데 필요한 Debezium Logical Decoding 플러그인을 설치하는 기본 PostgreSQL 10 이미지를 사용한다.
빌드는 통합 테스트가 실행되기 전 자동으로 PostgreSQL 컨테이너를 시작하고 모든 통합 테스트가 완료된 후 자동으로 중지하고 제거한다.

mvn install을 실행하면 모든 코드가 컴파일되고 단위 및 통합 테스트가 실행된다.
컴파일 문제나 단위 테스트가 실패하면 빌드가 즉시 중단된다.
그렇지 않을 경우 이 명령은 계속해서 모듈의 아티팩트를 생성하고 PostgreSQL 및 사용자 지정 스크립트를 사용해 Docker 이미지를 생성, Docker 컨테이너 시작, 통합 테스트 실행, 컨테이너 중지, 코드에서 checkstyle을 실행한다.
여전히 문제가 없을 경우 빌드는 모듈의 아티팩트를 로컬 Maven Repository에 설치한다.

특히 Git에 변경 사항을 커밋하기 전 항상 기본적으로 mvn install을 사용해야 한다.
그러나 다른 Maven 명령을 실행해야 하는 몇 가지 상황이 있다.

##### 일부 테스트 실행

단일 통합 테스트 클래스의 테스트 메서드를 통과하려고 하고 모든 통합 테스트를 실행하지 않으려는 경우, 하나의 통합 테스트 클래스만 실행하고 나머지는 모두 건너뛰도록 Maven에 지시할 수 있다.
예시로 다음 명령을 사용해 `ConnectionIT.java` 클래스에서 테스트를 실행한다.

```bash
$ mvn -Dit.test=ConnectionIT install
$ mvn -Dit.test=Connection*IT install
```

이러한 명령은 PostgreSQL Docker 컨테이너를 자동으로 관리한다.

##### 디버깅 테스트

IDE에서 단계별로 통합 테스트를 디버깅하려는 경우 mvn install 명령을 사용하면 IDE의 중단점을 기다리지 않으므로 문제가 된다.
이를 수행하는 방법이 있으나 일반적으로 Docker 컨테이너를 시작하고 통합 테스트를 실행할 때 사용할 수 있도록 실행 상태로 두는 것이 쉽다.

```bash
$ mvn docker:start
```

기본 PostgreSQL 컨테이너를 시작하고 데이터베이스 서버를 실행한다.
이제 IDE를 사용해 하나 이상의 통합 테스트를 실행하고 디버그 할 수 있다.
통합 테스트가 각 테스트 전후에 데이터베이스를 정리하고다음을 포함해 필수 시스템 속성을 정의하는 VM 인수로 테스트를 실행하는지 확인해야 한다.

-   `database.dbname` - 통합 테스트에서 사용할 DB의 이름.
    기본 값은 postgres이다.

-   `database.hostname` - Docker 컨테이너가 실행 중인 호스트의 IP 주소나 이름.
    Linux의 경우 localhost가 기본 설정되나 OS X나 Windows Docker에서는 Docker를 실행하는 VM의 IP 주소로 설정해야 한다.

-   `database.port` - PostgreSQL이 수신 대기 중인 포트.
    기본 값은 5432이며 이 모듈의 Docker 컨테이너가 사용하는 값이다.

-   `database.user` - DB 사용자의 이름.
    기본 값은 postgres이며 다른 DB 스크립트를 사용하지 않는 한 정확하다.

-   `database.password` - DB 사용자의 비밀번호.
    기본 값은 postgres이며 다른 DB 스크립트를 사용하지 않는 한 정확하다.

예시로 다음 인수를 JVM에 전달해 이런 속성을 정의할 수 있다.

```bash
-Ddatabase.dbname=<DATABASE_NAME> -Ddatabase.hostname=<DOCKER_HOST> -Ddatabase.port=5432 -Ddatabase.user=postgres -Ddatabase.password=postgres
```

IDE에서 통합 테스트 실행을 완료하면 다음 빌드를 실행하기 전 Docker 컨테이너를 중지하고 제거해야 한다.

```bash
$ mvn docker:stop
```

#### DB 분석

종종 하나 이상의 통합 테스트가 실행된 후 DB의 상태를 검사해야 할 수 있다.
mvn install 명령은 테스트를 실행하지만 통합 테스트가 완료된 후 컨테이너를 종료하고 제거한다.
통합 테스트가 완료된 후 컨테이너를 계속 실행하려면 다음 Maven 명령을 사용해야 한다.

```bash
$ mvn integration-test
```

#### Docker 컨테이너 중지

Maven이 통합 테스트를 통해 정상적인 Maven 수명 주기를 실행하고 Docker 컨테이너가 정상적으로 종료되고 제거될 때 사후 통합 테스트 단계 전에 중지하도록 지시한다.
빌드를 다시 실행하기 전 컨테이너를 수동으로 중지하고 제거해야 한다.

```bash
$ mvn docker:stop
```

