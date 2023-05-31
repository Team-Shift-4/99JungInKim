# RPM & YUM

# RPM(Redhat Package Manager)

- 레드햇 계열의 리눅스 배포판에서 사용하는 프로그램(패키지) 설치 관리 도구
- 현재는 RPM Package Manager의 재구적 약자로 사용

## 등장 배경

- 초기 리눅스는 모든 패키지를 tar와 gzip으로 묶인 소스 파일을 가지고 직접 컴파일 한 후 수동으로 설치해야 했음
- 패키지 설치에 너무 많은 시간과 노력이 투자되어 편하게 사용하고자 개발
- 의존하고 있는 패키지까지는 자동 설치 하지 않음

## RPM 패키지 구성

- 컴파일되어 설치한 실행파일, 설정파일, 라이브러리 등을 묶은 것
- 설치 전후로 스크립트를 사용해 필요한 작업들이 수행되며 삭제도 마찬가지
- 설정 파일의 경우 설정하고 싶은 설정 파일이 있을 때 설정파일명 .RPMNEW 파일을 생성하고 패키지를 삭제하려는 경우 설정파일은 .RPMSAVE 확장자로 백업됨

## SRPM

- RPM 패키지 제작 과정에서 소스파일을 유지하며 원본 소스에 패치를 적용하여 수정 이력을 관리하며 RPM 제작을 위해 사용되는 소스와 패치 파일 제작 과정에 대한 명세파일(*.spec)을 묶어 ~.src.rpm 형태로 배포

## RPM 패키지 파일의 이름 규칙

- RPM 파일은 *.rpm 식의 파일 이름을 갖고 패키지의 버전과 실행 환경에 따라 규칙성 있는 패키지 명을 가짐

<aside>
<img src="https://www.notion.so/icons/question-mark_gray.svg" alt="https://www.notion.so/icons/question-mark_gray.svg" width="40px" /> mysql DB와 Java를 연결해주는 jdbc 패키지 명

**mysql-connector-java-5.1.25-3.el7.noarch.rpm**

</aside>

| 패키지 이름 | - | 소스 버전 | - | 릴리즈 버전 | . | 배포판(OS) 버전 | . | 아키텍처 | . | rpm |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| mysql-connector-java | - | 5.1.25 | - | 3 | . | el7 | . | noarch | . | rpm |
- **패키지 이름**
    - 어떤 패키지인지 구분할 수 있는 가장 중요한 항목
- **소스 버전**
    - 보통 세 레벨로 구성되며 major버전.minor버전.patch버전 순으로 구성
- **릴리즈 버전**
    - 문제점을 개선할 때마다 붙여지는 버전
- **배포판(OS) 버전**
    - CentOS를 포함한 RHEL(RedHat Enterprise Linux)의 경우 배포판 버전을 rpm 패키지 파일명에 사용
    - el7은 RHEL 7을 의미
- **아키텍처**
    - 패키지가 컴파일된 아키텍처(CPU)를 의미
    - 이 패키지를 설치할 수 있는 CPU를 의미
        
        
        | 아키텍처 | 설명 |
        | --- | --- |
        | i386, i486, i586, i686 | 인텔 또는 AMD 계열 32비트 CPU |
        | x86_64 | 인텔 또는 AMD 계열 64비트 CPU |
        | alpha / sparc / ia64 | 미국 dec사의 알파, 썬 마이크로 시스템즈의 스팍, 인텔 아이테니엄 프로세서로 CPU 명령어를 줄여 하드웨어 구조를 심플하게 만드는 RISC 설계 방식의 CPU를 의미하나 잘 사용되지는 않음 |
        | src | 소스 파일 패키지로 설치 이후 별도로 컴파일 |
        | noarch | No Architecture로 모든 CPU에 설치 가능 |
- **.rpm**
    - rpm 확장자로 rpm 패키지임을 알림

## RPM 명령어 사용

<aside>
<img src="https://www.notion.so/icons/exclamation-mark_gray.svg" alt="https://www.notion.so/icons/exclamation-mark_gray.svg" width="40px" /> **rpm 명령어 사용 방법**

```bash
rpm [option] [rpm package file or package name]
```

</aside>

<aside>
<img src="https://www.notion.so/icons/exclamation-mark_gray.svg" alt="https://www.notion.so/icons/exclamation-mark_gray.svg" width="40px" /> **패키지가 설치 되어 있는지 조회**

```bash
rpm -qa
rpm -qa [package name]
rpm -qa | grep [package name]
```

</aside>

<aside>
<img src="https://www.notion.so/icons/exclamation-mark_gray.svg" alt="https://www.notion.so/icons/exclamation-mark_gray.svg" width="40px" /> **주로 패키지 설치 시 쓰는 옵션 예시**

```bash
rpm -Uvh [package file]
```

****U: 패키지를 설치하되 이미 설치된 경우 업그레이드 하라는 뜻
v: 패키지 설치 시 설치 과정을 출력하라는 뜻
h: 설치 진행률을 `#` 기호로 화면에 출력하라는 뜻

</aside>

<aside>
<img src="https://www.notion.so/icons/exclamation-mark_gray.svg" alt="https://www.notion.so/icons/exclamation-mark_gray.svg" width="40px" /> **패키지 삭제 시**

```bash
rpm -e [package name]
```

</aside>

### RPM 명령어의 동작별 실행 옵션

| 동작 | 옵션 | 사용법 |
| --- | --- | --- |
| 설치 | -i | rpm -i [option] [package name] |
| 업그레이드 | -U | rpm -U [option] [package name] |
|  | -F | rpm -F [option] [package name] |
| 질의 | -q | rpm -q [option] [package name] |
| 검증 | -v | rpm -v [option] [package name] |
| 서명 확인 | --checksig | rpm --checksig [package name] |
| 삭제 | -e | rpm -e [option] [package name] |
| 데이터베이스 다시 제작 | --rebuilddb | rpm --rebuilddb |

위 동작 옵션과 같이 사용되는 옵션

| 옵션 | 설명 |
| --- | --- |
| -v | 상세 정보를 출력 |
| -vv | 아주 상세한 디버깅 정보를 출력 |
| --quiet | 최대한 불필요한 출력을 줄임(에러 메세지만 출력) |
| --version | 사용중인 rpm 버전을 출력 |
| --root <dir> | 모든 동작을 <dir>을 기준으로 최상위 디렉터리로 인식하고 작업 |
| --help | 사용 설명을 출력 |

### 설치 및 업그레이드시의 옵션

- 주요 기능인 패키지 설치 및 업그레이드 옵션은 i와 U 옵션이 존재
- 원칙적으로 이미 설치된 패키지를 재설치 불가능하나 U옵션을 사용해 이미 설치된 패키지의 경우 업그레이드로 진행

추가적으로 설치 명령과 같이 사용되는 옵션

| 옵션 | 설명 |
| --- | --- |
| --nodeps | 패키지 설치 시 현재 설치하는 패키지가 필요로 하는 의존 패키지 설치 여부를 검사하지 않음 |
| --force | 설치중 발생하는 에러를 무시하고 강제로 설치 |
| --oldpackage | 새로운 패키지를 지우고 구 버전의 패키지를 설치할 때 사용 |
| --replacepkgs | 이미 같은 패키지가 있으면 재설치 |
| --root <dir> | https://www.notion.so/07b7f36df79e4f8aa973e0daaf8c1460 |
| --test | 가상으로 설치해본 뒤 오류나 충돌이 있는지 검사 |
| --noscript | 설치 전후로 실행하는 preinstall, postinstall 스크립트를 실행하지 않음 |
| --excludedocs | 문서파일을 제외하고 설치 |
| -h --hash | #를 사용해 현재 진행상태 표시 |
| --percent | %를 사용해 현재 진행상태 표시 |

### 질의 기능 옵션

RPM 패키지에 대한 정보를 질의할 때

<aside>
<img src="https://www.notion.so/icons/exclamation-mark_gray.svg" alt="https://www.notion.so/icons/exclamation-mark_gray.svg" width="40px" /> **이미 설치되어 있는 패키지**

```bash
rpm -qa [package name]  #시스템에 해당 패키지가 설치되어 있는지 확인
rpm -qf [package file]  #이미 설치 된 파일이 어느 패키지에 포함된 것인지 확인
rpm -ql [package name]  #특정 패키지에 어떤 파일들이 포함되어 있는지 확인
rpm -qi [package name]  #설치된 패키지의 상세 정보를 확인
```

**아직 설치되지 않은 패키지 파일**

```bash
rpm -qlp [package file]  #패키지 파일에 어떤 파일들이 포함되어 있는지 확인
rpm -qip [package file]  #패키지 파일의 상세 정보를 출력
```

</aside>

### 검증 기능 옵션

<aside>
<img src="https://www.notion.so/icons/exclamation-mark_gray.svg" alt="https://www.notion.so/icons/exclamation-mark_gray.svg" width="40px" /> **원본과 다른점을 검사 MD5, 타입, 퍼미션, 소유자, 그룹 등 8개 항목 검사
오류 시 오류에 해당하는 문자 출력**

```bash
rpm -Va
rpm -ya
rpm -a --verify
```

**출력값**

| 문자 | 설명 |
| --- | --- |
| . | 이상이 없음 |
| 5 | MD5 체크섬 불일치 |
| D | 사용자 불일치 |
| G | 그룹 불일치 |
| S | 파일 크기 불일치 |
| L | 심볼릭 링크 경로 불일치 |
| M | 퍼미션 및 파일 타입 불일치 |
| P | 기능 불일치 |
| T | 갱신일 불일치 |
| U | 디바이스의 Major/Minor 넘버 불일치 |
</aside>

추가적으로 질의 명령과 같이 사용되는 옵션

질의 대상 지정에 대한 옵션

어떤 정보를 얻을 것인지에 대한 옵션

| 옵션 | 설명 |
| --- | --- |
| -a | 모든 패키지에 대해 질의 실행 |
| -f <file name> | 특정 패키지 파일에 대해 질의 실행 |
| -F | 파일명을 표준 입력을 통해 받은 후 그 패키지 파일에 대해 질의 실행 |
| -p <file name> | 설치 되거나 되지 않은 패키지 파일에 대해 질의 수행 |
| -P | 파일명을 표준 입력을 통해 받은 후 설치 되거나 되지 않은 패키지 파일에 대해 질의 수행 |
| -i | 패키지에 관한 정보들을 보여줌 |
| -R | 패키지가 의존하고 있는 패키지들의 목록을 보여줌 |
| --provides | 패키지가 제공하는 기능을 보여줌 |
| -l | 패키지 안의 파일들을 보여줌 |
| -s | 패키지 안의 파일의 상태를 보여줌 |
| -d | 문서 파일만 보여주며 -l과 함께 사용 |
| -c | 설정 파일만 보여줌 |
| -scripts | 패키지 설치 또는 제거에 실행되는 쉘 스크립트를 확인 |
| --dump | MD5 체크섬, 소유자, 그룹, 설정 파일 여부, 심볼릭 링크 여부등의 정보를 dump함 |

### RPM 제거 기능

<aside>
<img src="https://www.notion.so/icons/exclamation-mark_gray.svg" alt="https://www.notion.so/icons/exclamation-mark_gray.svg" width="40px" /> **패키지 삭제 시**

```bash
rpm -e [package name]
```

</aside>

### 서명 기능

<aside>
<img src="https://www.notion.so/icons/exclamation-mark_gray.svg" alt="https://www.notion.so/icons/exclamation-mark_gray.svg" width="40px" /> **출처를 알아볼 때 사용**

```bash
rpm --checksig [package name]
```

</aside>

### 데이터베이스 리빌드 기능

<aside>
<img src="https://www.notion.so/icons/exclamation-mark_gray.svg" alt="https://www.notion.so/icons/exclamation-mark_gray.svg" width="40px" /> **만약 설치된 패키지에 대한 정보가 저장되어 있는 RPM db에 문제가 생길 때 리빌드**

```bash
rpm --rebuilddb
```

</aside>

# YUM(Yellowdog Updater Modified)

- RPM의 단점인 의존성 문제를 해결하기 위해 제공
- 자동으로 의존성 처리를 해줌
- 인터넷이 연결되어 있어야 사용 가능

## 명령어 나열

```bash
yum check-update #현재 인스톨된 프로그램 중에 업데이트 된 것을 체크
yum clean all #캐시 되어 있는 것을 모두 지움
yum deplist #yum 패키지에 대한 의존성 테스트
yum downgrade [package] #yum을 통한 패키지 다운그레이드
yum erase [package] #yum을 통한 시스템에서 삭제
yum groupinfo [group] #그룹패키지의 정보를 보여줌
yum groupinstall [group] #그룹패키지를 설치
yum grouplist [group] #그룹리스트에 관한 정보를 확인
yum groupremove [group] #그룹리스트에 관해 삭제
yum help #yum의 도움말을 확인
yum info [group or package] #패키지 또는 그룹의 패키지를 자세하게 확인
yum install [package] #시스템으로 패키지의 설치 실행
yum list #서버에 있는 그룹 및 패키지의 리스트를 보여줌
yum localinstall [package] #로컬에 설치
yum makecache #캐시를 다시 올림
yum provides [file path name] #파일이 제공하는 패키지 정보 출력
yum reinstall [package] #패키지를 다시 설치
yum update [package] #패키지를 업데이트
yum upgrade [package] #패키지를 업그레이드
yum search [keyword] #키워드로 시작하는 패키지를 검색
```

## 옵션 나열

| 옵션 | 설명 |
| --- | --- |
| -h, --help | 해당 명령어의 도움말을 보여줌 |
| -t, --tolerant | 에러를 자동으로 잡아서 설치 |
| -C, --cacheonly | 캐시를 업데이트 하지 않고 전체 시스템 캐시 실행 |
| -c [config file], --config=[config file] | 파일 위치를 알려줌 |
| -R [minutes], --randomwait=[minutes]
-R [minutes], --randomwait=[minutes] | 최대치의 명령어 실행시 기다림 |
| -d [debug level], --debuglevel=[debug level] | 최종 결과를 디버깅 |
| --showduplicates | 중복 요소를 보여줌 |
| -e [error level], --errorlevel=[error level] | 결과 중 에러를 보여줌 |
| --rpmverbosity=[debug level name] | rpm에서 결과물을 디버깅 |
| --version | Yum 버전을 보여줌 |
| -y, --assumeyes | 모든 물음에 yes로 진행 |
| -q, --quiet | 모든 작업 종료 |
| -v, --verbose | 작업을 장황하게 함 |
| --installroot=[path] | root 권한으로 path 위치에 인스톨 진행 |
| --enablerepo=[repo] | 1개 이상의 저장소 위치에 저장 |
| --disablerepo=[repo] | 1개 이상의 저장소 위치에 저장 금지 |
| -x [package], --exclude=[package] | 패키지 이름을 제외 |
| --disableexcludes=[repo] | 이름으로 플러그인 ㅈ설치를 중단 |
| --obsoletes | 오래된 패키지는 업데이트 하는 동안 적절히 삭제 및 교체 |
| --noplugins | Yum plugin이 없도록 함 |
| --nogpgcheck | gpg signature를 불가능하게 함 |
| --skip-broken | 문제 있는 패키지는 자동으로 넘어감 |
| --color=[COLOR] | 컬러가 사용되었을 때 조정 |
| --releasever=[RELEASEVER] | $releasever의 값을 Yum config와 repo 파일에서 조정 |
| --setopt=[SETOPTS] | 임의로 config와 repo 옵션값을 지정 |
| --disablepresto | Presto 플러그인을 중단하고 deltarpm을 다운받지 않음 |