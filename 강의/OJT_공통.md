# OJT

## 목차

-   **[Unix / Linux 구조 및 파일 시스템](#Unix--Linux-구조-및-파일-시스템)**
    -   [OS](#OS)
    -   [Virtual Machine](#Virtual-Machine)
    -   [VIM](#VIM)
    -   [Shell Script](#Shell-Script)
-   **[Oracle](#Oracle)**
    -   [RDBMS의 특징](#RDBMS의-특징)
    -   [Oracle Standalone 설치](#Oracle-Standalone-설치)
    -   [Oracle Admin](#Oracle-Admin)
    -   [Oracle Architecture](#Oracle-Architecture)
    -   [Backup & Recovery](#Backup--Recovery)
    -   [ASM](#ASM)
    -   [RAC](#RAC)
    -   [Multitenant](#Multitenant)
-   **[Other Database](#Other-Database)**
    -   [MySQL / MariaDB](#MySQL--MariaDB)
    -   [PostgreSQL](#PostgreSQL)
    -   [Tibero](#Tibero)
-   **[Ark Product](#Ark-Product)**
    -   [Ark for FR](#Ark-for-FR)
    -   [Ark for Oracle](#Ark-for-Oracle)
    -   [Ark for CDC](#Ark-for-CDC)

# Unix / Linux 구조 및 파일 시스템

## OS

OS란 Operating System의 줄임말이다.
OS는 한국어로 운영체제라고 한다.

### 개요

운영체제를 정리하면 하드웨어와 시스템 리소스를 제어하고 프로그램에 대한 일반적 서비스를 지원하는 시스템 소프트웨어이다.
시스템 하드웨어를 관리할 뿐 아니라 응용 스포트웨어를 실행하기 위해 하드웨어 추상화 플랫폼과 공통 시스템 서비스를 제공한다.

운영체제는 입출력과 메모리 할당 같은 하드웨어 기능의 경우 응용 프로그램과 컴퓨터 하드웨어 사이의 중재 역할을 한다.
응용 프로그램 코드는 일반적으로 하드웨어에서 직접 실행된다.

운영체제는 실행되는 응용 프로그램들이 메모리와 CPU, 입출력 장치 등의 자원을 사용할 수 있도록 만들어 준다.
위 자원들을 추상화하여 파일 시스템 등의 서비스를 제공한다.
멀티태스킹을 지원하는 경우 여러 개의 응용 프로그램을 실행하고 있는 동안 운영체제는 모든 프로세스들을 스케줄링하여 동시에 수행되는 것 처럼 보여주는 효과를 한다.

운영체제는 대표적으로 네 가지 역할을 수행한다.

| 역할            | 설명                                                         |
| --------------- | ------------------------------------------------------------ |
| 자원 관리       | 컴퓨터의 한정적인 자원을 효율적으로 관리한다.                |
| 보안            | 소프트웨어나 외부 사용자가 데이터를 삭제하거나, 중요한 파일에 접근하는 것을 막거나, Read Only로 보호한다. |
| 인터페이스 제공 | GUI, CLI 등 사용자가 편리하게 커널의 자원을 사용할 수 있도록 한다. |
| 프로세스 관리   | 컴퓨터가 여러 작업을 동시에 효율적으로 처리할 수 있게 한다.  |

### 종류

#### 싱글태스킹 / 멀티태스킹

-   싱글태스킹 운영체제
    -   한번에 오직 하나의 프로그램만 실행할 수 있다.
-   멀티태스킹 운영체제
    -   시분할을 통해 하나 이상의 프로그램이 동시에 실행할 수 있다.
    -   선점형과 비선점형(협동형)이 있다.
        -   선점형 멀티태스킹의 경우 CPU 시간을 쪼개 프로그램들 각각에 슬롯을 할당한다.
            -   Solaris, Linux 등의 Unix 계열 운영체제
        -   비선점형 멀티태스킹의 경우 정해진 방식에 따라 다른 프로세스들에 시간을 제공하기 위해 각 프로세스에 의존한다.
            -   16bit 버전의 Microsoft Windows

#### 단일 사용자 / 다중 사용자

-   단일 사용자 운영체제
    -   사용자 구별이 없으나 여러 프로그램이 나란히 실행하는 것은 가능하다.
-   다중 사용자 운영체제
    -   디스크 공간과 같은 리소스와 프로세스를 식별하는 기능을 갖춘 멀티태스킹의 기본개념을 확장한 것이다.
    -   여러 사용자에 속해 있으며 여러 사용자가 동시에 시스템과 상호 작용할 수 있게 한다.
    -   시분할 운영체제들은 시스템의 효율적인 이용을 위해 태스크를 스케줄링한다.

#### 분산 운영체제

-   구별된 컴퓨터 그룹을 관리해 하나의 컴퓨터인 것처럼 보이게 만든다.
-   서로 통신하는 네트워크화된 컴퓨터들이 개발되며 분산 컴퓨팅이 활성화되었다.
-   분산되는 연산들은 하나 이상의 컴퓨터에서 수행된다.
-   하나의 그룹에 속하는 컴퓨터들이 협업할 때 분산 시스템을 형성한다.

#### 판형 운영체제

-   배포 형식이나 클라우드 컴퓨팅 환경에서 하나의 가상 머신 이미지를 게스트 운영체제로 만드는 것을 가리킨다.
-   실행 중인 여러 개의 가상 머신을 위한 도구로 이를 저장한다.
    -   가상화와 클라우드 컴퓨팅 관리 둘 다에 사용된다.
        -   대형 서버 웨어하우스 환경에서 흔히 볼 수 있다.

#### 임베디드 운영체제

-   임베디드 컴퓨터 시스템에서 사용할 수 있게 설계된 운영체제이다.
    -   임베디드 컴퓨터 시스템: 내장형 시스템, 기계나 기타 제어가 필요한 시스템에 대해 제어를 위한 특정 기능을 수행하는 컴퓨터 시스템
-   조그마한 기계에 동작하도록 설계되어 있다.
-   제한된 수와 자원으로 동작한다.
    -   매우 크기가 작고 효율적으로 설계되어 있다.

#### 실시간 운영체제

-   특정한 짧은 시간 내 이벤트나 데이터의 처리를 보증하는 운영체제이다.
-   실시간 운영체제는 싱글태스킹일 수도 있고, 멀티태스킹일 수도 있다.

#### 라이브러리 운영체제

-   네트워크 등 일반적인 운영체제가 제공하는 서비스들이 라이브러리 형태로 제공되는 운영체제를 의미한다.

### Unix / Linux

#### Unix

-   벨 연구소에서 1970년대 C와 함께 탄생했다.
-   교육, 연구 기관에서 주로 사용하는 다중 사용자, 대화식, 시분할처리 시스템용 운영체제이다.
-   많은 OS의 본보기가 되었다.
-   하드웨어와 같이 배포되는게 일반화되었다.
    -   지원되는 하드웨어와의 높은 호환성과 신뢰성을 기대할 수 있다.

##### 배포판 요약

-   Minix
    -   교육용으로 개발된 Unix, Linux에 영감을 주었다.
-   MacOS
    -   최초 GUI 환경인 Mac Classic의 후속작이며 개인 컴퓨터 시장에서 Unix 중 가장 점유율이 높다.
-   BSD
    -   캘리포니아 대학의 CSRG에서 개발한 범용 OS, 과거에는 Linux 보다 높은 안정성으로 인기가 있었다.
-   AIX
    -   IBM사의 Power 제품군에 올라가는 OS로 주로 대기업과 금융권 등의 대형 서버로 이용된다.
    -   System-V 계열 Unix 중 유일하게 지속적으로 개발 중이다.
-   HP-UX
    -   HP 사에서 개발한 HP Server용 OS이며 2021년부터 업데이트를 하지 않는다.

#### Linux

-   Linux Is Not UniX로 재귀약자로 설명하기도 한다.

##### 기술적인 특징

| 특징                 | 설명                                                         |
| -------------------- | ------------------------------------------------------------ |
| 계층적인 파일 구조   | /를 기준으로 그 하위 디렉터리에 다시 디렉터리가 존재하는 구조이다.<br />이런 구조를 계층적 파일 구조라 한다.(Tree 구조) |
| 장치의 파일화        | Device를 파일화하여 사용한다.<br />특정 하드웨어에 명령을 수행하려면 해당 장치 파일에 명령을 내리는 형식이다. |
| 가상 메모리 사용     | Virtual Memory는 Hard Disk의 일부를 메모리처럼 사용하는 것을 말한다.<br />이런 영역을 SWAP이라고 부른다. |
| 동적 라이브러리 지원 | 프로그램에서 특정 기능을 실행하기 위한 명령어인 Routine들을 모아 놓은 것을 Library라 한다.<br />프로그램 개발 시 Library 중 필요한 Routine들을 받아 Link 시킨다.<br />이런 Routine들을 공유하는 것을 Shared Library라 한다.<br />Dynamic Shared Library는 실행 파일 내부에 넣지 않고 프로그램을 실행할 때 가져다 사용하므로 메모리 효율성이 높다. |
| 가상 콘솔            | Virtual Console은 말 그래도 가상 콘솔을 제공하는 기능이다.<br />리눅스는 기본적으로 6개의 가상 콘솔을 제공한다.<br />`ctrl` + `alt` + `F1` ~ `f6` |
| 파이프               | Pipe는 Process의 통신을 위해 도입된 것이다.<br />어떤 Process의 표준 출력이 다른 프로세스의 표준 입력으로 쓰는 것을 말한다.<br />`|` |
| Redirection          | Process의 I/O를 Standard I/O가 아닌 다른 I/O로 변경할 때 사용한다.<br />출력 결과를 파일로 저장하거나 파일의 내용을 Process의 입력으로 사용하는 기법이다. |

##### 배포판 요약

-   Redhat 계열
    -   Redhat Linux와 커뮤니티 버전인 Fedora에서 파생된 배포판들이다.
    -   패키지 형식은 .rpm이며 패키지 관리자로 yum을 사용한다.
    -   CentOS, Oracle Linux 등이 있다.
-   Debian 계열
    -   데비안에서 파생된 배포판들이다.
    -   패키지 형식은 .deb이며 패키지 관리자로 apt를 사용한다.
    -   Chrome OS, TmaxOS 등이 있다. 
-   Ubuntu 계열
    -   Kubuntu, Vanilla OS 등이 있다.
-   Arch 계열
    -   아치 리눅스에서 파생된 배포판들이다.
    -   패키지 관리자는 pacman이며 형식은 특정 확장자 없이 tar.gz나 tar.xz이나 관례적으로 압축용 확장자 앞에 .pkg가 붙는다.
    -   Steam OS 등이 있다.
-   SUSE 계열
    -   슬랙웨어 기반으로 시작했으나 현재는 관계가 멀어지고 .rpm을 사용하여 독자적 계열로 취급한다.
    -   openSUSE 등이 있다.

#### 기본 구조 및 구성

Hardware <-> Kernel <-> Shell <-> Application <-> User

| 구조        | 설명                                                         |
| ----------- | ------------------------------------------------------------ |
| Hardware    | 컴퓨터의 하드웨어이다.<br />CPU, 모니터, 키보드, RAM, GPU, Sound Card, 메인보드와 같은 물리적 부품을 의미한다. |
| Kernel      | OS의 다른 부분이나 Application 수행에 필요한 여러 서비스를 제공한다.<br />프로그램 실행 과정에서 가장 핵심적인 연산이 이루어지는 부분이다.<br />Core라고도 부른다.<br />Hardware를 직접 제어하고, Process 관리, Memory 관리, File System 관리 등을 수행하는 OS의 핵심이다.<br />Application과 Hardware 사이의 관리자 역할을 수행하며 Shell과 연관되어 실행하는 명령을 수행하고 수행 결과를 Shell로 보내는 역할을 한다. |
| Shell       | OS 상 다양한 OS 기능과 서비스를 구현하는 Interface를 제공한다.<br />사용자의 명령을 해석해 Kernel로 전달하는 프로그램이다.<br />OS의 내부를 감싸는 층이여서 Shell이라고 부른다. |
| Application | OS에서 실행되는 모든 Software                                |



#### Group / User

리눅스는 다중 사용자 운영체제이다.
사용자는 별도의 권한을 가지고 있으며 권한에 따라 파일을 읽고 쓰고 실행할 수 있다.

유저를 확인하는 방법은 `/etc/passwd`를 조회하면 된다.

```bash
cat /etc/passwd

root:x:0:0:root:/root:/bin/bash
...
ark:x:1000:1000:ark:/home/ark:/bin/bash
...
```

`/etc/passwd` 파일의 뜻은 다음과 같다.

```bash
root	:x			:0	:0	:root		:/root			:/bin/bash
Username:Password	:UID:GID:Description:Home Directory	:Shell Information
```

위 Password의 x는 

리눅스에는 Group이라는 개념이 있다.
어떤 파일이나 디렉터리를 특정 권한의 사용자들만 사용할 수 있게 하는 데에 사용한다.

그룹을 확인하는 방법은 `/etc/group`을 조회하면 된다.

```bash
cat /etc/group

root:x:0:
...
ark:x:1000:
...
```

기본적으로 Group의 경우 그냥 생성했을 때 1000번 부터 생성되는 것을 확인할 수 있다.

따로 옵션을 주어 해당하는 그룹을 만들 수도 있다.

```bash
groupadd -g 54321 oinstall
```

생성한 그룹은 사용자에게 부여할 수 있다.

```bash
usermod -G oinstall ark

id ark

uid=1000(ark) gid=1000(ark) groups=1000(ark),54321(oinstall)
```



##### 권한

#### File System

## Virtual Machine

### Linux 설치

### Network

### SSH

### TCP 통신

### SCP

### X Window

### Disk Mount

### LVM

## VIM

## Shell Script

# Oracle

## RDBMS의 특징

## Oracle Standalone 설치

## Oracle Admin

### Startup

### Shutdown

### Oracle 논리적 구조

### 오라클 물리적 구조

### 유저 생성 / 삭제 / 권한 부여 / 권한 강탈

#### 유저 생성

#### 유저 삭제

#### 유저 권한 부여

#### 유저 권한 강탈

### 테이블 생성 / 삭제

#### 테이블 생성

#### 테이블 삭제

### 데이터 조회 / 생성 / 변경 / 삭제

#### 데이터 조회

#### 데이터 생성

#### 데이터 변경

#### 데이터 삭제

### Procedure

#### PL/SQL

#### Procedure 생성

#### Procedure 실행

## Oracle Architecture

### Oracle Server

### Oracle Instance

### Oracle Database

## Backup & Recovery

### Backup

### Recovery

## ASM

## RAC

## Multitenant

# Other Database

## MySQL / MariaDB

## PostgreSQL

## Tibero

# Ark Product

## Ark for FR

## Ark for ORacle

## Ark for CDC