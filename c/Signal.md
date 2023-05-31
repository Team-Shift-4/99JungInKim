# Signal

# Signal

- 예기치 않은 사건 발생 시 이를 알리는 SW Interrupt
    - `SIGFPE`: 부동소수점 오류
    - `SIGPWR`: 정전
    - `SIGALARM`: 알람시계 울림
    - `SIGCHLD`: 자식프로세스 종료
    - `SIGINT`: 키보드로부터 종료 요청(`Ctrl` + `C`)
    - `SIGSTP`: 키보드로부터 정지 요청(`Ctrl` + `Z`)

## Create Signal

- Terminal
    - `Ctrl` + `C`: `SIGINT`
    - `Ctrl` + `Z`: `SIGSTP`
- Hardware Exception
    - 0으로 나누기: `SIGFPE`
    - 유효하지 않은 Memory 참조: `SEGSEGV`
- `kill()` System Call
    - Process(Group)에 Signal 보내는 System Call
    - Process의 Owner거나 Superuser여야 함
- Software Term
    - 알람: `SIGALRM`
    - 끊어진 PIPE: `SIGPIPE`
    - Child Process가 끝났을 때 Parent Process에게 전달되는 Signal: `SIGCHLD`

## Main Signal

| Name | Mean | Default Processing |
| --- | --- | --- |
| SIGABRT | abort()에서 발생되는 종료 Signal | 종료(코어 덤프) |
| SIGALRM | alarm() 울림 때 발생하는 알람 Signal | 종료 |
| SIGCHLD | Process의 종료 혹은 중지를 Parent에게 알리는 Signal | 무시 |
| SIGCONT | 중지된 Process를 계속시키는 Signal | 무시 |
| SIGFPE | 0으로 나누기와 같은 심각한 산술 오류 | 종료(코어 덤프) |
| SIGHUP | 연결 끊김 | 종료 |
| SIGILL | 잘못된 HW Command 수행 | 종료(코어 덤프) |
| SIGIO | 비동기와  I/O Event 알림 | 종료 |
| SIGINT | Terminal에서 Ctrl + C할 때 발생하는 Interrupt Signal | 종료 |
| SIGKILL | 잡을 수 없는 Process를 종료시키는 Signal | 종료 |
| SIGPIPE | PIPE에 Write 할 때 Reader가 없을 때 | 종료 |
| SIGPIPE | PIPE가 끊어졌을 때 | 종료 |
| SIGPWR | Power 고장 | 종료 |
| SIGSEGV | 유효하지 않은 Memory 종료 | 종료(코어 덤프) |
| SIGSTOP | Process 중지 Signal | 중지 |
| SIGSTP | Terminal에서 Ctrl + Z할 때 발생하는 중지 Signal | 중지 |
| SIGSYS | 유효하지 않은 System Call | 종료(코어 덤프) |
| SIGTERM | 잡을 수 있는 Process 종료 Signal | 종료 |
| SIGTTIN | 후면 Process가 Control Terminal에 Read | 중지 |
| SIGTTOU | 후면 Process가 Control Terminal에 Write | 중지 |
| SIGUSR1 | 사용자 정의 Signal | 종료 |
| SIGUSR2 | 사용자 정의 Signal | 종료 |

## Signal Processing

- 기본 처리 동작
1. Process Terminate(종료)
2. Signal Ignore(무시)
3. Process Suspend(중지)
4. Process Resume(계속)

## `alarm()`

```c
#include <unistd.h>
unsigned int alarm(unsigned int sec)
// sec초 이후 Process에 SIGALRM Signal 발생
```

- 한 Process 당 하나의 `alarm()` 가능
    - 이전에 설정된 `alarm()`이 있다면 취소되고 남은 초를 return
    - 이전에 설정된 알람이 없다면 0 return
- `alarm(0)`: 이전에 설정한 `alarm()` 취소

# S**ignal** Handling

## `signal()`

```c
#include <signal.h>
signal(int signo, void (*func))
// signo에 대한 처리 function을 func로 지정 후 기존 처리 function return
```

- `signal()` System Call: 이 Signal이 발생하면 이 function으로 처리
- Signal 처리 Function func
    1. `SIG_IGN`: Signal Ignore
    2. `SIG_DFL`: Defualt 처리
    3. 사용자 정의 함수 이름
- `pause()`: Signal을 받을 때까지 해당 Process Sleep

### `sigaction()`

- `signal()`보다 정교하게 Signal 처리기를 등록하기 위한 function

```c
#include <signal.h>
int sigaction(int sgnum, const struct sigaction *act, struct sigaction *oldact);
// signum Signal(SIGKILL, SIGSTOP 제외) 수신 시 Process가 취할 Action 변경에 사용

struct sigaction {
	void (*sa_handler)(int); // Signal 처리기
	void (*sa_sigaction)(int, siginfo_t *, void *);
	sigset_t sa_mask; // Signal 처리하는 동안 차단할 Signal 집합
	int sa_flags;
};
```

```c
#include <stdio.h>
#include <signal.h>
struct sigaction newact;
struct sigaction oldact;
void sigint_handler(int signo) {
	printf("No. %d Signal Handling\n", signo);
	printf("If you press again, it will be Suspend");
	sigaction(SIGINT, &oldact, NULL); // 기존 처리 Action으로 변경
}
int main() {
	newact.sa_handler = signint_handler; // Signal Handler 지정
	sigfillset(&newact.sa_mask); // 모든 Signal 차단하도록 Mask
	sigaction(SIGINT, &newact, &oldact); // SIGINT의 처리 Action을 새로 지정, Old에 Backup
	while(1) {
		printf("Press Ctrl+C\n");
		sleep(1);
	}
	return 0;
}
```

# Send Signal

## `kill()`

- Kill Command
    - 다른 Process를 Control 하기 위해 특정 Process에 임의의 Signal을 강제적으로 전송
- `kill()` System Call
    - 특정 Process pid에 원하는 임의의 Signal signo를 전송
    - 보내는 Process의 Owner가 Process pid의 Owner와 같거나 SuperUser여야 함

```c
#include <sys/types.h>
#include <signal.h>

int kill(int pid, int signo);
// Process pid에 Signal signo를 보냄 성공 시 0, 실패 시 -1 return
```

- `pid > 0`: Process ID가 pid인 Process에 신호
- `pid == 0`: 보내는 Process의 Process Group ID와 동일한 Group ID를 가진 Process들에게 신호
- `pid < 0`: Process Group ID가 -pid인 Process들에게 신호

## Signal을 이용한 Process Control

- `SIGCONT`: Process 재개
- `SIGSTOP`: Process 중지
- `SIGKILL`: Process 종료
- `SIGTSTP`: `Ctrl` + `Z`에서 발생
- `SIGCHLD`: Child Process 중지 or 종료 시 Parent Process에게 전달