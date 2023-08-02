# 최성훈 대리님이 알려주신 내용

툴 설명과 툴 실행 시 어떻게 결과가 나오는지 위주로 설명해 주심

리버스 엔지니어링

- 이미 만들어진 시스템이나 장치에 대한 해체나 분석을 거쳐 구조와 기능들을 알아내는 일련의 과정
- 소스코드가 없는 상태에서 컴파일 된 소프트웨어의 구조와 동작 원리를 여러 가지 방법으로 분석
- 학습 및 연구 용으로 많이 이용, 각종 악성 코드 분석 혹은 취약점 분석
- 소스 코드를 비롯한 전체적인 작동 원리를 알 수 있음

활용

- 각종 프로그램의 보안성 평가
- 악성 코드 분석
- 불법 프로그램 생성(Crack)
- 게임 핵

분석 툴

컴퓨터는 2진수로 파일을 읽으나 사람은 16진수로 읽음

- Hex Editor
- UltraEdit

또한, 디스어셈블러, 디버깅 툴을 이용해 파일을 분석

- Ollydbg
- IDA
- Ghidra
- GDB
- Pin

정적 분석

프로그램을 실행시키지 않고 분석하는 방법

- 파일 구조 분석
- 디스 어셈블러를 이용한 내부 코드, 구조 분석

동적 분석

동적 분석만으로 **레지스터**의 값을 추론해내는 것은 어려움
프로그램을 실행시켜 입출력과 내부 동작 단계를 살피며 분석

## Endian

메모리를 어떻게 저장하는가 Byte order

## Data Alignment

### Align

32Bit 프로세스 컴퓨터에 메모리에 데이터를 쓰거나 읽을 때 4Byte 단위로 접근해 명령을 수행

로드되는 메모리 주소는 4의 배수인 곳이 선택

컴파일러 옵션을 추가할 시 정렬해주나 기본적으로는 사람이 정렬하는것이 좋다

Padding = Alignment 규칙을 맞춤

## Assemble / Disassemble

### Compile

Source code: 사람이 이해 가능한 프로그래밍 코드

Binary Code: 컴퓨터가 이해 가능한 이진법 코드

Compile: Source Code를 Binary Code로 변환하는 과정

Source Code -> Intermediate Code -> **Assembly Code** -> Binary Code

Register 처리중인 데이터, 처리 결과를 임시적으로 보관

## 분석하기 전

메타 정보를 관리할 수 있는 테이블을 가지고 있을 것

DDL에서 힌트가 있을 수 있음

## GDB

```
gcc -0 -g test test.c

gdb adextract
run

gdb <execute file> core
```

### GDB Command

|                 |      |      |
| --------------- | ---- | ---- |
| run             |      |      |
| list            |      |      |
| info locals     |      |      |
| info variables  |      |      |
| info registers  |      |      |
| break           |      |      |
| info break      |      |      |
| Clear \| delete |      |      |
| step            |      |      |
| stepin          |      |      |
| stepover        |      |      |
| stepout         |      |      |
| finish          |      |      |
| return          |      |      |
| continue        |      |      |
| disass          |      |      |
| display         |      |      |
| print           |      |      |
| backtrace       |      |      |
| kill            |      |      |
| x/              |      |      |
| quit            |      |      |

### Core File 분석하기

프로그램 동작 중 비정상적인 종료가 발생할 때 운영 체계는 프로세스의 메모리 이미지를 덤프한 책ㄷ 파일을 생성

```
ulimit -c unlimited
gdb ./test core
```

