# IPC

# Inter Process Communication

![Untitled](./IPC/Untitled.png)

- Process는 독립된 실행 객체
- 서로 독립되어 있다는 뜻은 다른 Process의 영향을 받지 않는다는 뜻
- 별도의 설비 없이 서로간 통신이 어려움
- Linux Kernel 영역에서는 IPC 설비를 이용해 Process간 통신을 함

# System V IPC & POSIX IPC

## System V IPC

- 오랜 역사를 가져 이기종간 코드 호환성이 확실히 보장됨
- API가 오래되었음
- 함수명이 명확하지 않음

## POSIX IPC

- 비교적 최근 개발된 표준
- 직관적으로 API가 구성되어 있어 상대적으로 조금 더 사용하기 쉬움

# IPC 설비

- 내부 Process 간 통신에도 상황에 맞는 IPC 설비를 선택할 필요가 있음
- fork()를 이용해 만들어진 Multi Process Program에 있어 중요함
- 잘못된 IPC 설비 선택은 코딩을 어렵게 하거나 작동이 효율적이지 못함

## PIPE (익명 PIPE)

![Untitled](./IPC/Untitled%201.png)

- 두개의 Process를 연결하고 하나의 Process는 Write, 반대쪽은 Read만 가능
- 통신 할 Process를 명확히 알 수 있는 경우 사용함
    - 자식 Process ↔ 부모 Process
- 같은 PPID를 가지는 프로세스들 사이에서 통신이 가능
- 단방향 통신이 가능한 PIPE 특징 때문에 Half-Duplex 통신아고 부르기도 함
- 송수신을 위해 두 개의 PIPE를 만들어야 함
- 매우 간단히 사용할 수 있다는 장점이 있음
- 전이중 통신을 고려 시 좋지 않은 선택

## Named PIPE(FIFO)

![Untitled](./IPC/Untitled%202.png)

- 통신 할 Process들을 명확히 알지 못하는 경우 사용, PIPE의 확장
- 부모 Process와 무관하게 전혀 다른 모든 Process들 사이에서 통신이 가능
    - Process 통신을 위해 이름이 있는 파일을 사용함
- mkfifo를 통해 이뤄짐
- read-only, write-only만 가능
    - 통신 선로가 파일로 존재해 하나를 Read용, 또 하나를 Write용으로 열어 해결 가능
- 전이중 통신시 PIPE와 같이 두개의 FIFO파일이 필요

## Message Queue

![Untitled](./IPC/Untitled%203.png)

- 입출력 방식은 Named PIPE와 동일
- Message Queue는 Memory 공간
- Message Queue에 쓸 데이터에 번호를 붙여 여러 Process가 동시에 Data를 쉽게 다룰 수 있음

## Shared Memory

![Untitled](./IPC/Untitled%204.png)

- 데이터 자체를 공유하도록 지원
- 원래 Process는 자신만의 Memory 영역을 가지고 있으나 Shared Memory에서는 Process 간 Memory 영역을 공유해 사용할 수 있도록 허용함
- IPC들 중 가장 빠르게 작동할 수 있음

## Memory Map

![Untitled](./IPC/Untitled%205.png)

- Shared Memory와 마찬가지로 Memory를 공유함
- 열린 파일을 Memory에 Mapping시켜 공유한다는 점이 차이점
- 파일은 System의 Global 자원이므로 서로 다른 Process끼리 데이터 공유하는 데 문제가 없음

## Socket

![Untitled](./IPC/Untitled%206.png)

- Process와 System의 기초적인 부분이며 Process들 사이의 통신을 가능하게 함
- sys/shoket.h라는 Header를 이용해 사용 가능
- 같은 Domain에서 연결 가능
- 생성하고 이름을 지정해 사용 가능
- domain, type, Protocol을 지정해 주어야 함
- Server단에서 bind, listen, accept해 Socket 연결을 준비해야 함
- Client단에서 connect를 통해 Server에 요청하며 연결이 수립된 후 Socket을 Send함으로 데이터를 주고 받음
- 연결이 끝난 이후 반드시 Socket을 close()해주어야 함

## Semaphore

![Untitled](./IPC/Untitled%207.png)

- PIPE, Named PIPE, Message Queue와 달리 Process 간 데이터 동기화 및 보호하는데 중점
- Process 간 메세지 전송, Shared Memory를 통해 특정 데이터를 공유하게 될 경우 공유된 자원에 여러 Process가 동시 접근이 불가해 한 번에 하나의 Process만 접근 가능하도록 만들어 줌