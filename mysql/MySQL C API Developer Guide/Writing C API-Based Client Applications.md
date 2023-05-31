[toc]

# C API Client Program Build

## Unix에서 MySQL Client Compile

예제 컴파일러 **gcc**

Compiler가 MySQL Header File을 사용하는 Client Program을 Compile할 때 `-I` Option을 지정해야 할 수 있음
ex) Header File이 `/usr/local/mysql/include`에 있음

```bash
-I/usr/local/mysql/include
```

코드를 Dynamic이나 Static MySQL C Client Libary와 연결할 수 있음

MySQL Client는 `-lmysqlclient` Link Command Option을 사용해 연결해야 함
`-L<library_path>`형식으로 Linker에게 지정해주는 Option을 사용할 수도 있음
ex) Library가 `/usr/local/mysql/lib`에 있음

```bash
-L/usr/local/mysql/lib -lmysqlclient
```

경로는 System에 따라 다를 수 있음, 상황에 맞게 `-I`, `-L` Option 조정

> [Unix에서 MySQL Program을 간단하게 Compile하기 위해 `mysql_config` script 사용](https://dev.mysql.com/doc/refman/8.0/en/mysql-config.html)

`mysql_config`는 Compile 또는 Link에 아래와 같은 필요한 Option을 표시함

```bash
mysql_config --cflags
mysql_config --libs
```

Command Line에서 해당 Command를 호출해 적절한 Option을 사용하고 Compile 또는 Link 명령에 수동으로 추가할 수 있음
`백틱`을 이용해 Command Line 내에 직접 `mysql_config`의 출력을 직접 포함

```bash
gcc -c `mysql_config --cflags` progname.c
gcc -o progname progname.o `mysql_config --libs`
```

Unix에서 Link는 기본적으로 Dynamic Library를 사용
Link를 통해 Static Client Libary를 연결하기 위해 Link Command에 경로 이름을 추가
ex) Library가 `/usr/local/mysql/lib`에 있음

```bash
gcc -o progname progname.o /usr/local/mysql/lib/libmysqlclient.a
```

`mysql_config`를 사용해 Library에 대한 경로를 제공할 수 있음

```bash
gcc -o progname progname.o `mysql_config --variable=pkglibdir`/libmysqlclient.a
```

`mysql_config`는 Static Linking에 필요한 모든 Library를 나열하는 방법을 현재 제공하지 않으므로 Link Command에 추가 Library명을 지정해야 할 수도 있음
추가할 Library를 알기 위해 `mysql_config --libs`와 `ldd libmysqlclient.so`(MacOS의 경우 `otool -Llibsqlclient.dylib`) 사용

`pkg_config`는 MySQL Application을 Compile하는 데 필요한 Compiler Flag나 Link Library와 같은 정보를 얻기 위한 `mysql_config` 대안으로 사용 가능

> [`pkg-config` 추가 설명](#`pkg-config`를 사용해 C API Client Program Build)

## Windows에서 MySQL Client Compile

Header와 Libary File 위치를 지정하기 위해 개발 환경에서 제공하는 기능을 사용해야 함

Windows에서 C API Client를 구축하기 위해 C Client Library와 Windows ws2_32 sockets Library와 Secur32 Security Library와 Link해야 함

코드를 Dynamic 또는 Static하게 MySQL C Client와 연결할 수 있음

* Dynamic Library = `libmysql.dll`, `libmysql.dll`사용 시 Static Library가 필요
* Static Library = `mysqlclient.lib`, Static C Client와 연결하기 위해 C Client Library(Oracle에서 Build한 Static C Client Library용 Visual Studio 2015)를 Compile하는 데 사용된 것과 동일한 버전의 Visual Studio로 Client Application을 Compile

Oracle에서 구축한 MySQL C Client Library를 사용하는 경우 Client Application에 대한 C Runtaime을 연결할 때 따를 규칙

* Community Distribution of MySQL의 MySQL C Client Library의 경우
    * Static, Dynamic C Client Library와 관계 없이 항상 C Runtime의 경우 Dynamic으로 연결(`/MD` Compiler Option 사용)
    * Client Application을 실행하는 대상 Host에는 Visual C++ Redistributable for Visual Studio 2015가 설치되어야 함
* Commercial Distribution of MySQL의 MySQL C Client Library의 경우
    * Static C Client Library에 연결하는 경우 C Runtime에 Static으로 연결(`/DT` Compiler Option 사용)
    * Dynamic C Client Library에 연결하는 경우 Static이나 Dynamic으로 C Runtime에 연결(`/MT`, `/MD` Compiler Option 사용)

일반적으로 Static MySQL C Client Library에 Linking 할 때 Client Library와 Client Application은 C Runtime을 Linking 할 때와 동일한 Compiler Option을 사용해야 함
Client Library가 `/MT` Option으로 Compile되면 Client Application도 `/MT` Option으로 Compile해야 함

> [the MSDN page describing the C library linking options](http://msdn.microsoft.com/en-us/library/2kzt1wy3.aspx)

## MySQL Client Library에 Connection 문제 해결

MySQL Client Library에는 SSL 지원이 내장되어 있음
Link 시 `-lssl` 또는 `-lcrypto`를 지정할 필요 없음
`-lssl` 또는 `-lcrypto`를 지정할 시 문제가 발생할 수 있음

Linker가 MySQL Client Library를 찾을 수 없는 경우 `mysql_`로 시작하는 Symbol들에 대해 정의되지 않은 Reference 오류가 발생할 수 있음

```bash
/tmp/ccFKsdPa.o: In function `main':
/tmp/ccFKsdPa.o(.text+0xb): undefined reference to `mysql_init'
/tmp/ccFKsdPa.o(.text+0x31): undefined reference to `mysql_real_connect'
/tmp/ccFKsdPa.o(.text+0x69): undefined reference to `mysql_error'
/tmp/ccFKsdPa.o(.text+0x9a): undefined reference to `mysql_close'
```

Link Command 끝에 `-L<dir_path> -lmysqlclient`를 추가해 이 문제를 해결할 수 있음
`<dir_path>`의 경우 Client Library가 있는 Directory의 경로 이름을 나타냄
ex) 경로를 확인하는 명령

```bash
mysql_config --libs
```

`mysql_config`의 출력은 Link Command에 지정해야 하는 다른 Library도 나타낼 수 있음
`백틱`을 사용하여 `mysql_config` 출력을 Compile 또는 Link Command에 직접 포함할 수 있음
ex) `백틱` 사용 예시

```bash
gcc -o <progname> <progname>.o `mysql_config --libs`
```

Floor Symbol 이 정의되지 않은 Link 시 오류 발생때 Compile/Link 줄 맨 끝에 `-lm`을 추가해 Math Library에 연결함
`connect()`와 같이 System에 존재해야 하는 다른 Function에 대해 정의되지 않은 Reference 오류가 발생하는 경우 해당 Function의 Manual Page를 확인해 Link Command에 추가할 Library를 결정

System에 존재하지 않는 Fucntion에 대해 다음과 같은 정의되지 않은 Reference 오류가 발생하면 일반적으로 MySQL Client Library가 System과 100% 호환되지 않는 System에서 Compile되었음을 의미

```bash
mf_format.o(.text+0x201): undefined reference to `__lxstat'
```

위와 같은 경우 최신 버전의 MySQL Source 배포판을 다운받고 MySQL Client Library를 직접 Compile해야 함

> [Installing MySQL from Source](https://dev.mysql.com/doc/refman/8.0/en/source-installation.html)

# `pkg-config`를 사용해 C API Client Program Build

MySQL 배포판에서는 `pkg-config` Command에서 사용할 MySQL 구성에 대한 정보를 제공하는 `mysqlclient.pc` File이 포함
MySQL Application을 Compile하는데 필요한 Compiler Flag 또는 Link Library와 같은 정보를 얻기 위해 `pkg-config`를 `mysql_config`대신 사용할 수 있음
ex) 다음 쌍은 동일

```bash
mysql_config --cflags
pkg-config --cflags mysqlclient

mysql_config --libs
pkg-config --libs mysqlclient
```

Static Linking을 위해 Flag를 생성하기 위한 명령어

```bash
pkg-config --static --libs mysqlclient
```

일부 Platform에서는 출력이 `--static`이 있는 경우와 없는 경우가 동일할 수 있음

`pkg-config`가 MySQL 정보를 찾지 못하면 `PKG_CONFIG_PATH` Environment Variable를  `mysqlclient.pc`File이 있는 Directory로 설정해야 할 수 있음(기본적으로 MySQL Library Directory 아래의 `pkgconfig` Directory)

```bash
# For sh, bash, ...
export PKG_CONFIG_PATH=/usr/local/mysql/lib/pkgconfig
# For csh, tcsh, ...
setenv PKG_CONFIG_PATH /usr/local/mysql/lib/pkgconfig
```

`mysqlconfig.pc` 설치 위치는 `INSTALL_PKGCONFIGDIR` CMake Option을 통해 제어할 수 있음

> [MySQL Source-Configuration Options](https://dev.mysql.com/doc/refman/8.0/en/source-configuration-options.html)

`--variable` Option은 구성 Variable 이름을 사용하고 Variable 값을 표시

```bash
# installation prefix directory
pkg-config --variable=prefix mysqlclient
# header file directory
pkg-config --variable=includedir mysqlclient
# library directory
pkg-config --variable=libdir mysqlclient
```

ex) `--variable` Option을 사용하여 `pkg-config`가 표시할 수 있는 변수값을 확인하는 예제

```bash
pkg-config --print-variables mysqlclient
```

Command Line에서 `백틱`을 사용하여 `pkg-config`를 사용해 특정 Option에 대해 생성되는 출력을 포함할 수 있음
ex) MySQL Client Program을 Compile하고 Link할 때 `pkg-config` 사용 예시

```bash
gcc -c `pkg-config --cflags mysqlclient` progname.c
gcc -o progname progname.o `pkg-config --libs mysqlclient`
```

# C API Thread Client Program 작성

> [Section 8.2, “C API Threaded Function Descriptions”](https://dev.mysql.com/doc/c-api/8.0/en/c-api-thread-function-descriptions.html)

사용하는 Source Code의 예시는 [MySQL Source 배포판의 `client` Directory](https://github.com/mysql/mysql-server/tree/8.0/client)를 참조

* `mysqlimport`의 Source는 `--use-threads` Option과 관련된 코드에서 Threading을 사용
* `mysqlslap`의 Source는 Thread를 사용해 동시 Workload를 설정하고 고부하 상태에서 Server 작동을 테스트 함

Thread Programming의 대안으로 Application들은 Asynchronous(Non-Blocking) C API Function들이 유용
이러한 기능을 통해 Application은 여러 개의 Outstanding Request들을 Server에 제출하고 각 Request들이 언제 Polling을 완료했는지 확인할 수 있음

> [Chapter 7, C API Asynchronous Interface(참조)](https://dev.mysql.com/doc/c-api/8.0/en/c-api-asynchronous-interface.html)

MySQL Client Library에 Thread Program을 연결할 때 정의되지 않은 Reference 문제가 발생하는 경우 높은 확률로 사용자가 Compile/Link Command에 Thread Library를 포함하지 않아서 발생

Client Library는 거의 Thread-Safe 상태
최대 문제는 Socket에서 읽는 `sql/net_serv.cc`의 subroutine이 Interrupt에 안전하지 않다는 것
이 작업은 Server에 대한 긴(큰) 읽기를 중단할 수 있는 자체 알람을 사용할 수 있다는 것에서 발생
`SIGPIPE` Interrupt에 대한 Interrupt Handler를 설치하는 경우 Socket Handling은 Thread-Safe여야 함

연결이 종료될 때 Program이 중단되는 것을 방지하기 위해 MySQL은 `mysql_library_init()`, `mysql_init()`, `mysql_connect()`에 첫 번째 호출에서 `SIGPIPE`를 차단
자신의 `SIGPIPE` Handeler를 사용하기 위해 `mysql_library_init()`을 호출한 뒤 Handler 설치

Client Library는 Connection 당 Thread-Safe
두 Thread는 다음과 같은 주의 사항과 함께 연결을 공유할 수 있음

- Asynchronous C API Function을 사용하지 않는 한 여러 Thread가 동일한 Connection에서 MySQL Server에 동시에 Query를 전송할 수 없음
    특히 한 Thread에서 `mysql_real_query()`(또는 `mysql_query()`)와 `mysql_store_result()`에 대한 호출 사이에 다른 Thread가 동일한 Connection을 사용하지 않도록 주의해야 함
    다른 Thread가 동일한 Connection을 사용하지 않도록 하기 위해 `mysql_real_query()`(또는 `mysql_query()`)와 `mysql_store_result()` 호출 쌍 주위에 Mutex Lock을 사용
    `mysql_store_result()`가 반환된 후 Lock을 해제하고 다른 Thread가 동일한 Connection을 Query할 수 있음
    POSIX Thread를 사용하는 경우 `pthread_mutex_lock()`과 `pthread_mutex_unlock()`을 사용해 Mutex Lock을 설정과 해제할 수 있음
- MySQL Source 배포판에서 Program을 검사하면 `pthread_mutex_lock()`과 `pthread_mutex_unlock()` 호출 대신 `native_mutex_lock()`과 `native_mutex_unlock()`에 대한 호출이 표시
    후자의 Function은 `thr_mutex.h` Header File에 정의되며 Platform 별 Mutex Function에 Mapping됨
- `mysql_store_result()`로 검색된 서로 다른 Result Set에 여러 Thread가 Access할 수 있음
- `mysql_use_result()`를 사용하려면 Result Set이 닫힐 때까지 다른 Thread가 동일한 Connection을 사용하지 않도록 해야함
    동일한 연결을 공유하는 Thread Client에서는 `mysql_store_result()`를 사용하는 것을 권장

Thread가 MySQL DB에 대한 Connection을 만들지 않지만 MySQL Function을 호출하는 경우 고려해야 할 사항:

`mysql_init()`을 호출하면 MySQL은 Thread에 특정한 Variable을 생성하는데 이 Variable은 Debug Library에서 사용됨
Thread가 `mysql_init()`을 호출하기 전 MySQL Function을 호출하면 Thread에 필요한 Thread별 Variable이 없기 때문에 Core Dump가 발생할 수 있음

문제 방지를 위해 수행:

1. 다른 MySQL Function보다 먼저 `mysql_library_init()`을 호출
    Thread에 안전하지 않으므로 Thread가 생성되기 전 호출하거나 Mutex로 호출을 보호
2. MySQL Function을 호출하기 전 Thread Handler에서 `mysql_thread_init()`을 호출하도록 정렬
    (`mysql_init()`을 호출하면 `mysql_thread_init()`을 호출)
3. Thread에서 `pthread_exit()`를 호출하기 전 `mysql_thread_end()`를 후출
    MySQL Thread별 Variable에 사용되는 Memory를 확보할 수 있음

`mysql_init()`에 대한 위 설명은 `mysql_init()`을 호출하는 `mysql_connect()`에도 동일하게 적용

# C API Client Program 실행

업그레이드 후 Command가 동기화되지 않거나 예기치 않은 Core Dump와 같은 Compile된 Client Program에 문제가 발생하는 경우 Program이 이전 Header 또는 Library File을 사용하여 Compile되었을 수 있음
이 경우 Compile에 사용되는 `mysql.h` Header File과 `libmysqlclient.a` Library의 날짜를 확인해 새 MySQL 배포판 버전의 것인지 확인
그렇지 않다면 새 Header와 Library로 Program을 다시 Compile
Library Major Version 번호가 변경된 경우 Shared Client Library에 대해 Compile된 Program에 대해서 재구성이 필요할 수 있음
ex) `libmysqlclient.so.17`에서 `libmysqlclient.so.18`

Major Shared Client Library Version에 따라 호환성이 결정됨
ex) `libmysqlclient.so.18.1.0`의 경우 Major = 18
새 버전의 MySQL과 함께 제공되는 Library는 동일한 Major Version을 가진 이전 Major Version의 대체
Major Library Version이 같은 경우 Library를 업그레이드 할 수 있으며 이전 Application은 계속 사용 가능

MySQL Program을 실행할 때 Runtime에 정의되지 않은 Reference 오류가 발생할 수 있음
만약 이런 오류가 `mysql_`로 시작하는 Symbol을 지정하거나 `libmysqlclient` Library를 찾을 수 없음을 나타내는 경우 System이 Shared Library인 `libmysqlclient.so` Library를 찾을 수 없음을 의미
문제 해결 방법은 해당 Library가 있는 Directory에서 Shared Library를 검색하도록 System에게 지시하는 방법

* `libmysqlclient.so`가 위치한 Directory의 경로를 `LD_LIBRARY_PATH`또는 `LD_LIBRARY` Environment Variable에 추가
* MacOS에서 `libmysqlclient.dylib`가 있는 Directory의 경로를 `DYLD_LIBRARY_PATH` Environment Variable에 추가
* Shared Library File(ex: `libmysqlclient.so`)을 System에서 검색하는 일부 Directory(ex: `/lib`)에 복사하고 `ldconfig`를 실행해 Shared Library 정보 업데이트(모든 관련 File을 복사해야 함)
    Shared Library는 Symbolic Link를 사용해 다른 이름을 제공하는 여러 이름으로 존재할 수 있음

# C API 기능 사용

## 암호화 연결 지원

기본적으로 MySQL Program은 Server가 암호화된 연결을 지원하는 경우 암호화를 사용하여 Connection
그렇지 않은 경우 암호화되지 않게 Connection
암호화된 Connection이 설정되는 방식에 대한 기본 동작 이상의 제어가 필요한 Application의 경우 C API는 다음을 제공

- `mysql_options()` 기능을 사용해 Application이 `mysql_real_connect()`를 호출하기 전 적절한 SSL/TLS Option 설정 가능
- `mysql_get_ssl_cipher()` 기능을 사용해 Application이 Connection이 설정된 후 암호화 사용 여부를 결정 가능
    `NULL`은 암호화 사용하지 않음 Non-`NULL`은 암호화 사용

### 암호화된 연결 Option

`mysql_options()`는 암호화된 Connection 사용을 제어하기 위해 다음의 Option 제공

- `MYSQL_OPT_SSL_CA`: CA Certificate File의 경로, Option 사용 시 Server에서 사용하는 것과 동일한 CA Certificate File 지정
- `MYSQL_OPT_SSL_CAPATH`: 신뢰할 수 있는 SSL CA certificate File의 Directory 경로
- `MYSQL_OPT_SSL_CERT`: Client Public Key Certificate File의 경로 
- `MYSQL_OPT_SSL_CIPHER`: TLSv1.2까지의 TLS Protocol을 사용하는 Connection에 대해 Client가 허용하는 암호화 암호 목록
- `MYSQL_OPT_SSL_CRL`: Certificate Revocation 목록이 포함된 File의 경로
- `MYSQL_OPT_SSL_CRLPATH`: Certificate Revocation 목록이 포함된 Directory의 경로
- `MYSQL_OPT_SSL_KEY`: Client Private Key File의 경로
- `MYSQL_OPT_SSL_MODE`: 연결 보안 상태
- `MYSQL_OPT_SSL_SESSION_DATA`: Connection이 활성화인 상태 동안 `mysql_get_ssl_session_data()` 호출에 의해 반환된 암호화된 Connection에서 직렬화된 Session Data
- `MYSQL_OPT_TLS_CIPHERSUITES`: TLSv1.3을 사용하는 Connection에 대해 Client가 허용하는 암호화 암호 그룹 목록 
- `MYSQL_OPT_TLS_VERSION`: Client가 허용하는 암호화 Protocol

`mysql_ssl_set()`은 Certificate, Key File, 암호화 암호등을 지정하는 `mysql_options()`와 같이 사용할 수 있음

### 암호화된 연결 적용

SSL Certificate File이나 Key File과 같은 정보에 대한 `mysql_options()` Option은 이런 Connection을 사용할 수 있는 경우 암호화된 Connection을 설정하는 데 사용되나 얻은 Copnnection을 암호화해야 한다는 요구사항은 적용하지 않음
암호화된 Connection을 적용하기 위한 방법:

1. 필요에 따라 `mysql_options()`를 호출해 적절한 SSL Parameter(Certificate File, Key File, 암호화 암호 등)를 제공
2. 값이 `SSL_MODE_REQ`인 `MYSQL_OPT_SSL_MODE` Option을 전달하기 위해 `mysql_options()`를 호출
3. `mysql_real_connect()`를 호출해 Server에 Connection
    암호화된 연결을 얻을 수 없을 시 호출 실패
    오류 발생시 종료

### 암호화된 연결의 보안 향상

기본 암호화에 제공하는 것과 관련된 추가 보안을 위해 Client는 Server에서 사용하는 것과 일치하는 CA Certificate File을 제공하고 Host Name Identity Verfication을 사용 가능
이런 방식으로 Server와 Client는 동일한 CA Certificate File를 신뢰하고 Client는 연결된 Host가 의도한 Host인지 확인

- CA Certificate File을 지정하기 위해 `mysql_options()`를 호출해 `MYSQH_OPT_SSL_CA`나 `MYSQL_OPT_SSL_CAPATH` Option을 전달하고 `mysql_options()`를 호출해 `SSL_MODE_VERIFY_CA` 값을 가진 `MYSQL_OPT_SSL_MODE` Option을 전달 받음
- Host NAme Identified Verification을 사용하기 위해 `mysql_options()`을 호출해 값이 `SSL_MODE_VERIFY_CA`가 아닌 `SSL_MODE_VERIFY_IDENTITY` 값인 `MYSQL_OPT_SSL_MODE` Option을 전달

## SSL Session 재사용

MySQL 8.0.29부터 Server는 기본적으로 SSL Session 재사용을 지원하나 사용자가 기능을 활성화한 후 구성 가능한 제한시간 내에서만 가능
모든 MySQL Client Application은 Session 재사용을 지원함

SSL Session 재사용은 다음과 같이 작동

1. 활성 SSL Connection이 진행중인 상태에서 Application은 `mysql_get_ssl_session_data()`를 호출해 현재 SSL Session Data를 요청 가능
    이 호출은 현재 Session의 PEM 직렬화인 Memory 내 개체에 대한 Pointer를 ASCII 문자열로 반환
2. Application은 구축 중인 새 Connection에 사용할 `MYSQL_OPT_SSL_SESSION_DATA` Option을 `mysql_options()`으로 Pointer 전달
3. Runtime시 Application은 정상적으로 연결, 이 시점에서 이전 Session을 재사용 할 수 있어야 함
    Application은 `mysql_get_ssl_session_reused()`를 호출해 Session이 새 Connection에 재사용되는지 결정 가능
    `True`일 시 Session이 있고 재사용 된 경우
4. Application에 Pointer가 더 이상 필요하지 않을 시 `mysql_free_ssl_session_data()` 호출

MySQL은 Session 재사용에도 적용되는 임의의 TLS Context ID 사용
TLS 1.3에서는 호출 시퀀스가 발생할 때 OpenSSL이 Session 재사용을 위해 사전 공유 키를 사용
TLS 1.2에서는 Open SSL이 Session Ticket

## Multiple Statement 실행 지원

기본적으로 Statement 문자열 인수를 실행할 단일 Statement인 `mysql_real_query()`또는 `mysql_query()`로 해석하고 Statement가 Result Set을 생성하는지 와 영향 받는 행 수를 반환

MySQL은 `;`으로 구분된 여러 Statement를 포함하는 문자열 실행을 지원 이 기능은 `mysql_real_connect()`를 호출해 서버에 Connection을 생성할 때나 생성한 후 `mysql_set_server_option()`으로 지정되는 특수 Option에 의해 활성화

Multiple Statement를 실행하면 여러 Result Set 또는 Row 수 표시기가 생성될 수 있음
이런 결과를 처리하는 것은 단일 Statement와는 다른 접근 방식
첫 Statement의 Result Set을 처리한 후 더 많은 Result Set이 있는지 확인하고 차례대로 처리해야 함
Multiple Statement를 지원하기 위해 MySQL C API에서 `mysql_more_results()`와 `mysql_next_result()`함수가 포함
`mysql_more_results()`와 `mysql_next_result()`는 다음 Result Set이 있는 경우 Loop의 끝에서 사용
이 방법으로 처리 못할 시 Server Connection이 끊어질 수 있음

Store Procedure에 대해 `CALL` 문을 실행하는 경우에도 Multiple-result Processing이 필요함
Store Procedure의 결과는 다음과 같은 특성이 있음

- Procedure 내의 Statement는 Result Set을 생성할 수 있음
    Result Set은 Procedure가 실행될 때 생성되는 순서대로 반환
    일반적으로 호출자는 Procedure가 반환한 Result Set 수를 알 수 없음
    Procedure 실행은 실행 경로가 한 호출에서 다음 호출로 달라지도록 하는 Loop 또는 조건문에 따라 달라짐
- Procedure의 최종 Result는 Result Set을 포함하지 않는 상태 결과
    상태 결과는 성공 또는 오류 발생을 나타냄

Multiple Statmement 및 Result 기능은 `mysql_real_query()`나 `mysql_query()`와 함께만 사용 가능
Prepared Statement Interface와 함께 사용할 수 없음
Prepared Statement Handler는 단일 Statement를 포함하는 문자열에서만 작동하도록 정의됨

Multiple Statement 및 Result 처리를 활성화하기 위해 다음 Option 사용 가능

- `mysql_real_connect()` 함수에는 `flags` 인수와 관련된 두 Option 값이 있음
    - `CLIENT_MULTI_RESULTS`를 사용하면 Client Program이 Multiple Result를 처리할 수 있음
        Result Set을 생성하는 Stored Procedure에 대해 `CALL` Statement를 실행하는 경우 이 Option을 사용해야 함
        그렇지 않은 경우 `Error 1312 (0A000)`발생
        `Error 1312 (0A000)`: Procedure `<proc_name>`이 지정된 Context의 Result Set을 반환할 수 없음
        `CLIENT_MULTI_RESULTS`는 기본적으로 사용하도록 설정되어 있음(Default)
    - `CLIENT_MULTI_STATEMENTS`를 사용할 경우 `mysql_real_query()`와 `mysql_query()`에서 `;`으로 구분된 여러 Statement들이 포함된 Statement 문자열을 실행할 수 있음
        이 Option을 사용할 경우 암묵적으로 `CLIENT_MULTI_RESULTS`를 사용할 수 있으므로 `CLIENT_MULTI_STATEMENTS`의 `flags` 인수를 `mysql_real_connect()`로 지정하면 `CLIENT_MULTI_RESULTS`의 인수와 동일
        `CLIENT_MULTI_STATEMENTS`는 Multiple Statement 실행과 모든 Multi Result를 처리 가능하게 하기에 충분함
- Server에 Connection이 설정된 후 `MYSQL_OPTION_MULTI_STATEMENTS_ON`이나 `MYSQL_OPTION_MULTI_STATEMENTS_OFF` 인수를 전달하여 `mysql_set_server_option()` 함수를 사용하거나 사용하지 않도록 설정 가능
    이 함수를 사용해 Multiple Statement 실행을 활성화하면 각 Statement가 단일 Result를 생성하는 Multiple Statement 문자열에 대한 **단순한** 결과 처리를 가능하게 하나 Result Set을 생성하는 Stored Procedure의 처리를 허용하기엔 충분하지 않음

다음 Procedure는 Multiple Statement를 처리하기 위해 제안된 전략을 개략적으로 설명

1. `CLIENT_MULTI_STATEMENTS`를 `mysql_real_connect()`에 전달해 Multiple Statement 실행과 Multiple Result 처리를 완전히 사용하게 설정
2. `mysql_real_query()`또는 `mysql_query()`를 호출해 성공 여부를 확인한 후 Statemente Result를 처리할 Loop 입력
3. Loop의 각 Iteration에 대해 Result Set 또는 영향 받은 Row 수를 검색해 현재 Statement 결과를 처리
    오류 발생 시 Loop 종료
4. Loop가 끝나면 `mysql_next_result()`를 호출해 다른 Result가 존재하는지 확인하고 존재할 경우 검색 시작
    더 이상 다른 Result가 없을 경우 Loop 종료

선행 전략의 한가지 가능한 구현은 Loop의 마지막 부분에 `mysql_next_result()`가 0이 아닌 다른 값을 반환하는지 여부에 대한 테스트로 축소
작성된 코드는 더 이상 Result가 없는 것과 오류를 구분하므로 오류가 발생할 경우 메세지를 출력 가능

```c
/* connect to server with the CLIENT_MULTI_STATEMENTS option */
if (mysql_real_connect (mysql, host_name, user_name, password, db_name, port_num, socket_name, CLIENT_MULTI_STATEMENTS) == NULL) {
  printf("mysql_real_connect() failed\n");
  mysql_close(mysql);
  exit(1);
}

/* execute multiple statements */
status = mysql_query(mysql, "DROP TABLE IF EXISTS test_table;\
                      CREATE TABLE test_table(id INT);\
                      INSERT INTO test_table VALUES(10);\
                      UPDATE test_table SET id=20 WHERE id=10;\
                      SELECT * FROM test_table;\
                      DROP TABLE test_table");
if (status) {
  printf("Could not execute statement(s)");
  mysql_close(mysql);
  exit(0);
}

/* process each statement result */
do {
  /* did current statement return data? */
  result = mysql_store_result(mysql);
  if (result) {
    /* yes; process rows and free the result set */
    process_result_set(mysql, result);
    mysql_free_result(result);
  } else {         /* no result set or error */
    if (mysql_field_count(mysql) == 0) {
      printf("%lld rows affected\n", mysql_affected_rows(mysql));
    } else { /* some error occurred */
      printf("Could not retrieve result set\n");
      break;
    }
  }
  /* more results? -1 = no, >0 = error, 0 = yes (keep looping) */
  if ((status = mysql_next_result(mysql)) > 0) {
    printf("Could not execute statement\n");
  }
} while (status == 0);

mysql_close(mysql);
```

## 날짜와 시간값에 Prepared Statement Handling

Binary(Prepared Statement) Protocol을 사용해 `MYSQL_TIME` 구조를 사용해 날짜와 시간 값(`DATE`, `TIME`, `DATETIME`, `TIMESTAMP`) 송수신 가능
이 구조의 Member는 이후 설명

임시 데이터 값을 보내려면 `mysql_stmt_prepare()`를 사용해 Prepared Statement를 만듬
그 이후 Statement를 실행하기 위해 `mysql_stmt_execute()` 호출 전 다음 절차를 사용해 임시 Parameter를 설정

1. 데이처 값과 연관된 `MYSQL_BIND` 구조에서 `buffer_type` Member를 전송할 시간 값의 종류를 나타내는 유형으로 설정
    `DATE`, `TIME`, `DATETIME`, `TIMESTAMP` 값의 경우 `buffer_type`을 Type 앞에 `MYSQL_TYPE_`을 붙여 설정
2. `MYSQL_BIND` 구조의 Buffer MEmber를 시간 값을 전달하는 `MYSQL_TIME` 구조의 주소로 설정
3. 전달된 시간 값 유형에 적합한 `MYSQL_TIME` 구조의 Member를 입력

`mysql_stmt_bind_param()`을 사용해 Statemente에 Parameter Variable을 Binding하는 데 사용
Binding 한 이후 `mysql_stmt_execute()`를 호출 가능

임시 값을 검색하기 위한 절차는 비슷하나 받을 것으로 예상되는 값의 유형으로 `buffer_type` Member를 설정하고 반환된 값이 배치되어야 하는 `MYSQL_TIME` 구조의 주소로 Member를 설정하는 점만 다르고 나머지는 유사
`mysql_stmt_bind_result()`호출 후 Result를 가져오기 전 Buffer를 Statemente에 Binding하는데 `mysql_stmt_execute()` 사용

`DATE`, `TIME`, `TIMESTAMP` 데이터를 INSERT하는 간단한 예시(`mysql` Variable은 유효한 Connection Handler라고 가정)

```c
  MYSQL_TIME  ts;
  MYSQL_BIND  bind[3];
  MYSQL_STMT  *stmt;

  strmov(query, "INSERT INTO test_table(date_field, time_field, timestamp_field) VALUES(?,?,?");

  stmt = mysql_stmt_init(mysql);
  if (!stmt) {
    fprintf(stderr, " mysql_stmt_init(), out of memory\n");
    exit(0);
  }
  if (mysql_stmt_prepare(mysql, query, strlen(query))) {
    fprintf(stderr, "\n mysql_stmt_prepare(), INSERT failed");
    fprintf(stderr, "\n %s", mysql_stmt_error(stmt));
    exit(0);
  }
  /* set up input buffers for all 3 parameters */
  bind[0].buffer_type= MYSQL_TYPE_DATE;
  bind[0].buffer= (char *)&ts;
  bind[0].is_null= 0;
  bind[0].length= 0;
  ...
  bind[1]= bind[2]= bind[0];
  ...

  mysql_stmt_bind_param(stmt, bind);

  /* supply the data to be sent in the ts structure */
  ts.year= 2002;
  ts.month= 02;
  ts.day= 03;

  ts.hour= 10;
  ts.minute= 45;
  ts.second= 20;

  mysql_stmt_execute(stmt);
  ..
```

## Prepared `CALL` Statement 지원

Prepared `CALL` Statement를 사용해 실행하는 Stored Proceduer 사용하는 방법:

- Stored Proceduer는 원하는 수의 Result Set을 생성할 수 있음
    Row의 수와 Row의 Data Type이 모든 Result Set에 대해 동일할 필요 없음
- `OUT`과 `INOUT` 매개변수의 최종 값은 Proceduer가 반환된 후 호출 Application에서 사용할 수 있음
    이런 Parameter는 Proceduer 자체에서 생성도니 Result Set 뒤 추가 단일 Row Result Set으로 반환
    Row에는 Proceduer Parameter 목록에서 선언된 순서대로 `OUT`과 `INOUT` Paremeter 값이 포함

다음 설명에서 Prepared `CALL` Statement에 대해 C API를 통해 기능을 사용하는 방법을 나열함

> [`PREPAREEXECUTE`와 `CALL` Statement를 통해 Prepared Statement를 사용하는 방법](https://dev.mysql.com/doc/refman/8.0/en/call.html)

Prepared `CALL` Statement를 실행하는 Application은 Result를 가져온 다음 추가 Result가 있는지 확인하기 위해 `mysql_stmt_next_result()`를 호출하는 Loop를 사용해야 함
결과는 Proceduer가 성공적으로 종료되었는지 여부를 나타내는 최종 상태 값이 뒤에 오는 Stored Proceduer에 의해 생성된 모든 Result Set으로 구성

Proceduer에 `OUT` 또는 `INOUT` Parameter가 있으면 최종 상태 앞 Result Set에 해당 값이 포함
Result Set에 Parameter값이 포함되어 있는지 확인하기 위해 `MYSQL` Connection Handler의 `server_status` Member에 `SERVER_PS_OUT_PARAMS`Bit가 설정되어 있는지 테스트:

```c
mysql->server_status & SERVER_PS_OUT_PARAMS
```

다음 예제이서 Prepared `CALL` Statement를 사용해 여러 Result Set을 생성하고 `OUT`과 `INOUT` Parameter를 통해 호출자에게 Parameter 값을 다시 제공하는 Stored Procedure를 실행
이 절체는 세가지 유형(`IN`, `OUT`, `INOUT`)의 Parameter를 모두 사용해 초기 값을 표시하고 새 값을 할당하고 업데이트 된 값을 표시한 후 반환
Proceduer에서 예상되는 반환 정보는 여러 Result Set과 최종 상태로 구성:

- 초기 Parameter Value를 표시하는 SELECT의 Result Set: `10`, `NULL`, `30`
    (`OUT` Parameter는 호출자에 의해 값이 할당되나 이 할당은 유효하지 않을것으로 예상
    `OUT` Parameter는 Procedure 내에서 값이 할당될 때까지 Proceduer 내에서 `NULL`로 간주)
- 수정된 Parameter Value를 표시하는 SELECT의 Result Set: `100`, `200`, `300`
- 최종 `OUT`과 `INOUT` Parameter Value를 포함하는 Result Set: `200`, `300`
- 최종 상태 Packet

Proceduer 실행 코드:

```c
MYSQL_STMT *stmt;
MYSQL_BIND ps_params[3];  /* input parameter buffers */
int        int_data[3];   /* input/output values */
bool       is_null[3];    /* output value nullability */
int        status;

/* set up stored procedure */
status = mysql_query(mysql, "DROP PROCEDURE IF EXISTS p1");
test_error(mysql, status);

status = mysql_query(mysql,
  "CREATE PROCEDURE p1("
  "  IN p_in INT, "
  "  OUT p_out INT, "
  "  INOUT p_inout INT) "
  "BEGIN "
  "  SELECT p_in, p_out, p_inout; "
  "  SET p_in = 100, p_out = 200, p_inout = 300; "
  "  SELECT p_in, p_out, p_inout; "
  "END");
test_error(mysql, status);

/* initialize and prepare CALL statement with parameter placeholders */
stmt = mysql_stmt_init(mysql);
if (!stmt) {
  printf("Could not initialize statement\n");
  exit(1);
}
status = mysql_stmt_prepare(stmt, "CALL p1(?, ?, ?)", 16);
test_stmt_error(stmt, status);

/* initialize parameters: p_in, p_out, p_inout (all INT) */
memset(ps_params, 0, sizeof (ps_params));

ps_params[0].buffer_type = MYSQL_TYPE_LONG;
ps_params[0].buffer = (char *) &int_data[0];
ps_params[0].length = 0;
ps_params[0].is_null = 0;

ps_params[1].buffer_type = MYSQL_TYPE_LONG;
ps_params[1].buffer = (char *) &int_data[1];
ps_params[1].length = 0;
ps_params[1].is_null = 0;

ps_params[2].buffer_type = MYSQL_TYPE_LONG;
ps_params[2].buffer = (char *) &int_data[2];
ps_params[2].length = 0;
ps_params[2].is_null = 0;

/* bind parameters */
status = mysql_stmt_bind_param(stmt, ps_params);
test_stmt_error(stmt, status);

/* assign values to parameters and execute statement */
int_data[0]= 10;  /* p_in */
int_data[1]= 20;  /* p_out */
int_data[2]= 30;  /* p_inout */

status = mysql_stmt_execute(stmt);
test_stmt_error(stmt, status);

/* process results until there are no more */
do {
  int i;
  int num_fields;       /* number of columns in result */
  MYSQL_FIELD *fields;  /* for result set metadata */
  MYSQL_BIND *rs_bind;  /* for output buffers */

  /* the column count is > 0 if there is a result set */
  /* 0 if the result is only the final status packet */
  num_fields = mysql_stmt_field_count(stmt);

  if (num_fields > 0)
  {
    /* there is a result set to fetch */
    printf("Number of columns in result: %d\n", (int) num_fields);

    /* what kind of result set is this? */
    printf("Data: ");
    if(mysql->server_status & SERVER_PS_OUT_PARAMS) {
      printf("this result set contains OUT/INOUT parameters\n");
    } else {
      printf("this result set is produced by the procedure\n");
    }
      
    MYSQL_RES *rs_metadata = mysql_stmt_result_metadata(stmt);
    test_stmt_error(stmt, rs_metadata == NULL);

    fields = mysql_fetch_fields(rs_metadata);

    rs_bind = (MYSQL_BIND *) malloc(sizeof (MYSQL_BIND) * num_fields);
    if (!rs_bind) {
      printf("Cannot allocate output buffers\n");
      exit(1);
    }
    memset(rs_bind, 0, sizeof (MYSQL_BIND) * num_fields);

    /* set up and bind result set output buffers */
    for (i = 0; i < num_fields; ++i) {
      rs_bind[i].buffer_type = fields[i].type;
      rs_bind[i].is_null = &is_null[i];

      switch (fields[i].type) {
        case MYSQL_TYPE_LONG:
          rs_bind[i].buffer = (char *) &(int_data[i]);
          rs_bind[i].buffer_length = sizeof (int_data);
          break;

        default:
          fprintf(stderr, "ERROR: unexpected type: %d.\n", fields[i].type);
          exit(1);
      }
    }

    status = mysql_stmt_bind_result(stmt, rs_bind);
    test_stmt_error(stmt, status);

    /* fetch and display result set rows */
    while (1) {
      status = mysql_stmt_fetch(stmt);

      if (status == 1 || status == MYSQL_NO_DATA) {
        break;
      }
        
      for (i = 0; i < num_fields; ++i) {
        switch (rs_bind[i].buffer_type) {
          case MYSQL_TYPE_LONG:
            if (*rs_bind[i].is_null) {
              printf(" val[%d] = NULL;", i);
            }
            else {
              printf(" val[%d] = %ld;", i, (long) *((int *) rs_bind[i].buffer));
            }
            break;

          default:
            printf("  unexpected type (%d)\n", rs_bind[i].buffer_type);
        }
      }
      printf("\n");
    }

    mysql_free_result(rs_metadata); /* free metadata */
    free(rs_bind);                  /* free output buffers */
  } else {
    /* no columns = final status packet */
    printf("End of procedure output\n");
  }

  /* more results? -1 = no, >0 = error, 0 = yes (keep looking) */
  status = mysql_stmt_next_result(stmt);
  if (status > 0) {
    test_stmt_error(stmt, status);
  }
} while (status == 0);

mysql_stmt_close(stmt);
```

Proceduer를 실행하면 다음과 같은 출력이 생성:

```c
Number of columns in result: 3
Data: this result set is produced by the procedure
 val[0] = 10; val[1] = NULL; val[2] = 30;
Number of columns in result: 3
Data: this result set is produced by the procedure
 val[0] = 100; val[1] = 200; val[2] = 300;
Number of columns in result: 2
Data: this result set contains OUT/INOUT parameters
 val[0] = 200; val[1] = 300;
End of procedure output
```

`test_error()`와 `test_stmt_error()`라는 두 Utility Routine을 사용해 오류를 확인하고 오류가 발생한 경우 진단 정보를 출력 후 종료:

```c
static void test_error(MYSQL *mysql, int status) {
  if (status) {
    fprintf(stderr, "Error: %s (errno: %d)\n", mysql_error(mysql), mysql_errno(mysql));
    exit(1);
  }
}

static void test_stmt_error(MYSQL_STMT *stmt, int status) {
  if (status) {
    fprintf(stderr, "Error: %s (errno: %d)\n", mysql_stmt_error(stmt), mysql_stmt_errno(stmt));
    exit(1);
  }
}
```

## Prepared Statement 문제

현재(MySQL 8.0.31, `23.01.02) 알려진 Prepared Statement 문제 목록

- `TIME`, `TIMESTAMP`, `DATETIME` 초(sec) 부분 지원 불가(ex: from `DATE_FORMAT()`)
- 정수를 문자열로 변환할 때 MySQL Server가 선행 0을 출력하지 않는 경우(ex: `MIN(number-with-zerofill)`)에 `ZEROFILL`이 Prepared Statement로 표시
- Client에서 부동소수점 실수를 문자열로 변환할 때 변환된 값의 맨 오른쪽 자리가 원래 값의 자리와 약간 다를 수 있음
- Prepared Statemente는 Multiple Statement를 지원하지 않음

## Optional Result Set Metadata

Client가 Result Set을 생성하는 Statement를 실행하면 MySQL은 Result Set에 포함된 데이터와 기본적으로 Result Set Data에 대한 정보를 제공하는 Result Set Metadata를 사용할 수 있음
Metadata는 `MYSQL_FIELD` 구조에 포함되어 있음
이 구조는 `mysql_fetch_field()`, `mysql_fetch_field_direct()`, `mysql_fetch_fields()` 함수에 의해 반환

Client는 Result Set Metadata가 Optional임을 Connection별로 표시할 수 있음
Client는 Result Set Metadata를 Server에 반환할 지 여부를 표시할 수 있음
Client에 의한 Metadata 전송을 억제하면 성능을 향상시킬 수 있음

Client가 Result Set Metadata가 Connection에 대해 Optional임을 나타내는 방법은 두 가지(둘 다 동일해 택일하면 됨):

- Connect 전 `MYSQL_OPT_OPTIONAL_RESULTSET_METADATA` Option을 `mysql_options()`에 설정
- Connect 시 `mysql_real_connect()`의 `client_flag` 인수에 `CLIENT_OPTIONAL_RESULTSET_MATADATA` flag를 사용해 설정

Metadata-Optional Connection의 경우 Client는 `resultset_metadata` System Variable을 설정해 Server가 Result Set Metadata 반환 여부를 제어
허용되는 값은 `FULL`(모든 Metadata 반환), `NONE`(Metadata 반환 없음)이고 기본값은 `FULL`이므로 Metadata-Optional Connection의 경우 Server는 기본적으로 Metadata 반환

Metadata-Optional Connection의 경우 `resultset_metadata`가 `NONE`일 경우 `mysql_fetch_field()`, `mysql_fetch_fields()`가 `NULL` 반환

Metadata-Optional Connection이 아닌 경우 `resultseet_metadata`를 `NONE`으로 설정하면 오류 발생

Result Set에 Metadata가 있는지 확인을 위해 Client는 `mysql_result_metadata()`함수 호출
이 함수는 `RESULTSET_METADATA_FULL`이나 `RESULTSET_METADATA_NONE`을 반환

`mysql_result_messages()`는 Result Set에 Metadata가 있는지 Client가 미리 알지 못하는 경우에 유용
예시로 Client가 여러 Result Set을 반환하는 Stored Procedure를 실행하고 `resultset_metadata` System Variable을 변경할 수 있는 경우 Client는 각 Result Set에 대해 `mysql_result_metadata()`를 호출해 Metadata가 있는지 확인할 수 있음

## Automatic Reconnection 제어

MySQL Client Library는 실행할 Server에 Statement를 보내려고 할 때 Connection이 중단된 것을 반결할 시 Server에 대한 Automatic Reconnection을 수행할 수 있음
Automatic Reconnection이 사용가능한 경우 Library는 Server에 다시 연결하고 Statement를 다시 보냄

Automatic Reconnection은 기본적으로 비활성화되어 있음

Application이 Connection이 끊겼다는 것을 아는 것이 중요한 경우(상태 정보 손실을 조정하기 위해 종료하거나 조치를 취할 수 있음) Automatic Reconnection이 비활성화되어 있는지 확인
이를 확인하기 위해 `MYSQL_OPT_RECONNECT` Option을 사용해 `mysql_options()`를 호출: 

```c
bool reconnect = 0;
mysql_option(&mysql, MYSQL_OPT_RECONNECT, &reconnect);
```

Connection이 중단된 경우 `mysql_ping()`의 결과는 auto-reconnect를 사용하도록 설정한 경우 `mysql_ping()`을 다시 수행
그렇지 않은 경우 오류 반환

일부 Client Program은 Autiomatic Reconnection을 제어하는 기능을 제공할 수 있음
예시로 `mysql`은 기본적으로 다시 연결되나 `--skip-reconnect` Option을 사용해 이 동작을 막을 수 있음

Automatic Reconnection이 발생하는 경우 명시적인 표시가 없음
다시 연결되었는지 확인하기 위해 `mysql_thread_id()`를 호출해 `mysql_ping()`을 호출하기 전 원래 Connection Identifier를 얻은 후 `mysql_thread_id()`를 다시 호출해 Identifier가 변경되었는지 확인해야 함

Automatic Reconnection은 사용자 고유의 Reconnect Code를 구현할 필요가 없어 편리하나 Reconnection이 발생할 경우 Connection 상태의 여러 측면이 Server측에서 재설정되고 Application에 알림이 표시되지 않음

Reconnection할 경우 다음에 Connection 관련 상태에 영향을 끼침:

- Active Transaction을 Rollback하고 Autocommit Mode를 재설정

- 모든 Table Lock을 해제

- 모든 `TEMPORARY` Table을 닫거나 삭제

- `SET NAMES`와 같은 Statement에 의해 암시적으로 설정된 System Variable을 포함해 Session System Variable를 해당 Global System Variable의 값으로 초기화

- 사용자 정의 Variable 설정 손실

- Prepared Statement를 Release

- `HANDLER` Variable 닫음

- `LAST_INSERT_ID()`를 0으로 재설정

- `GET_LOCK()`으로 획득한 잠금 해제

- Connection Thread 계측을 결정하는 성능 Schema Thread Table Row와 Client의 Connection 손실
    Connection이 끊긴 후 Client가 다시 Connect되면 Session이 Thread Table의 새 Row와 Connect되고 Thread Monitoring 상태가 다를 수 있음

    > [Thread Table 참조](https://dev.mysql.com/doc/refman/8.0/en/performance-schema-threads-table.html)

다시 연결될 경우 `MYSQL_INIT_COMMAND` Option으로 `mysql_options()`를 호출해 지정된 SQL Statement가 다시 실행

Connection이 끊어질 경우 Server가 Client가 더 이상 연결되어 있지 않음을 감지하지 못한 경우 Server측의 Connection과 관련된 Session이 계속 실행 중일 수 있음
이 경우 원래 Connection에 의해 유지된 Lock은 여전히 해당 Session에 속하므로 `mysql_kill()`을 호출해 해당 Session을 종료할 수 있음

## `mysql_query()` 성공 후 `NULL` `mysql_store_result()` 반환

`mysql_real_query()`나 `mysql_query`를 사용해 Server에 성공적으로 호출한 후 `mysql_store_result()`가 `NULL`을 반환할 수 있음:

- `malloc()` 오류가 발생(ex: Result Set이 너무 큰 경우)
- 데이터를 읽을 수 없음(Connection에서 오류 발생)
- Query가 데이터를 반환하지 않음(ex: INSERT, UPDATE, DELETE)

`mysql_field_count()`를 호출해 Statement가 비어있지 않은 Result Set을 생성했는지 여부를 확인할 수 있음
`mysql_field_count()`가 0을 반환하는 경우 Result Set은 비어 있으며 마지막 Query는 값을 반환하지 않는 Statement가 0이 아닌 다른 값을 반환하면 Statement가 비어 있지 않은 결과를 생성해야 함

`mysql_error()` 또는 `mysql_errno()`를 호출해 오류를 테스트 할 수 있음

## Query에서 사용 가능한 Result

Querty에 의해 반환되는 Result Set 외에도 얻을 수 있는 정보:

- `mysql_affected_rows()`는 INSERT, UPDATE, DELETE를 수행할 때 마지막 Query의 영향을 받은 Row 수 반환
    빠른 재생성을 위해 `TRUNCATE TABLE` 사용
- `mysql_num_rows()`는 Result_set의 Row 수 반환
    `mysql_store_result()`를 사용하면 `mysql_store_result()`가 반환되는 즉시 `mysql_num_rows()`를 호출할 수 있음
    `mysql_use_result()`의 경우 `mysql_fetch_row()`로 모든 Row를 가져온 후에만 `mysql_num_rows()` 호출 가능
- `mysql_insert_id()`는 `AUTO_INCREMENT` index가 있는 Table에 Row를 삽입한 마지막 Query에 의해 생성된 ID 값 반환
- 일부 Query(`LOAD DATA`, `INSERT INTO ... SELECT`, UPDATE)는 추가 정보를 반환
    Result는 `mysql_info()`로 반환
    반환되는 `mysql_info`는 추가 정보가 없을 시 `NULL` Pointer 반환

## 마지막 Inserted Row의 Unique ID 얻기

`AUTO_INCREMENT` Row가 포함된 Table에 Record를 삽입 하면 `mysql_insert_id()` 함수를 호출해 해당 Row에 저장된 값 얻을 수 있음

C Application에서 다음 코드를 실행해 값이 `AUTO_INCREMENT` Row에 저장됐는지 확인할 수 있음(성공했다고 가정 시):

```c
if ((result = mysql_store_result(&mysql)) == 0 && mysql_field_count(&mysql) == 0 && mysql_insert_id(&mysql) != 0) {
    used_id = mysql_insert_id(&mysql);
}
```

새 `AUTO_INCREMENT` 값이 생성되면 `mysql_real_query()` 또는 `mysql_query()`로 `SELECT LAST_INSERT_ID()` Statement를 실행하고 반환된 Result Set에서 Value를 검색해 이 값을 얻을 수 있음

Multiple Value를 삽입하면 마지막 `AUTO_INCREMENT` 값이 반환

`LAST_INSERT_ID()`의 경우 가장 최근에 생성된 ID가 Connection 별로 Server에 유지됨
다른 Client에 의해 변경되지 않음
Non-magic Value(`NULL`과 0이 아닌 값)으로 다른 `AUTO_INCREMENT` Row를 업데이트해도 변경되지 않음
여러 Client에서 `LAST_INSERT_ID()` Row와 `AUTO_INCREMENT` Row를 동시에 사용하는 것은 가능
각 Client는 Client가 실행한 마지막 Statement에 대해 마지막으로 삽입된 ID르 ㄹ받음

한 Table에 대해 생성된 ID를 사용해 두 번째 Table에 삽입하려면 다음과 같은 SQL문 사용:

```sql
INSERT INTO foo (auto,text) VALUES(NULL,'text');             -- generate ID by inserting NULL
INSERT INTO foo2 (id,text) VALUES(LAST_INSERT_ID(),'text');  -- use ID in second table
```

 `mysql_insert_id()`는 `AUTO_INCREMENT` Row에 저장된 값을 반환
해당 값이 `NULL` 또는 0을 저장해 자동으로 생성되는지, 명시적 값으로 지정되었는지 여부를 확인할 수 있음
`LAST_INSERT_ID()`는 자동 생성된 `AUTO_INCREMENT` 값만 반환
`NULL` 또는 0 이외의 명시적 값을 저장하는 경우 `LAST_INSERT_ID()`에서 반환하는 값에 영향주지 않음

`AUTO_INCREMENT` Row에서 마지막 ID값을 얻는 방법에 대한 자세한 내용:

> [SQL Statement 내에서 사용할 수 있는 `LAST_INSERT_ID()`](https://dev.mysql.com/doc/refman/8.0/en/information-functions.html)
>
> [JDBC를 통해 `AUTO_INCREMENT` Row 값 검색](https://dev.mysql.com/doc/connector-j/8.0/en/connector-j-usagenotes-last-insert-id.html)
>
> [Connector/ODBC를 사용해 `AUTO_INCREMENT` Row 값 검색](https://dev.mysql.com/doc/connector-odbc/en/connector-odbc-usagenotes-functionality-last-insert-id.html)

## Server Version and Client Library Version 얻기 

MySQL Server Version의 문자열 및 숫자 형식은 Compile 시 `MYSQL_SERVER_VERSION`과 `MYSQL_VERSION_ID` Macro의 값으로 사용할 수 있음
실행 시 `mysql_get_server_info()`와 `mysql_get_server_version()` 함수의 값으로 사용 가능

Client Library Version은 MySQL Version
이 Version의 문자열 및 숫자 형식은 Compile 시 `MYSQL_SERVER_VERSION`과 `MYSQL_VERSION_ID` Macro의 값으로 사용할 수 있음
Runtime에는 `mysql_get_client_info()`와 `mysql_client_version()` 함수의 값으로 사용 가능
