# File Discriptor

- Unix OS에서 **Network Socket**과 같은 **File**이나 기타 **I/O Resource**에 Access하는 데
사용되는 **추상표현 →** System으로 부터 할당받은 **File이나 Socket을 대표하는 정수**
- FD는 **음이 아닌 정수(Non-negative Integer)**
- 일반적으로 형식 **int**로 C 프로그래밍 언어로 표현
(음수 값은 "무값" 또는 오류 조건을 나타내기 위해 예약됨)
(Window에서는 file handle이라고 부르고 값은 랜덤하게 할당)
- FD의 **0번에서 2번까지는 고정**되어 있음(unistd.h 헤더파일에 명시)
- 각 Unix Process는 세 가지 **standard streams**에 해당하는 고정된 standard POSIX **file descriptors**를 가짐
- Standard I/O도 FD로 표현이 되는데 이들은 Program이 시작되면 기본적으로 열리고,
종료 시 자동으로 닫힘

| Integer Value | Name | <unistd.h> Symbolic Constant | <stdio.h> File Stream |
| --- | --- | --- | --- |
| 0 | Standard Input | STDIN_FILENO | stdin |
| 1 | Standard Output | STDOUT_FILENO | stdout |
| 2 | Standard Error | STDERR_FILENO | stderr |
- FD가 단순히 숫자인 이유는 Process가 유지하고 있는 **FD Table의 Index**이기 때문
- **File Open or Create Socket시** 부여되는 FD는 **3부터 시작함**
- Process가 실행 중에 File을 Open 하면 kernel은 해당 Process의 FD 숫자 중에 사용하지 않는
**가장 작은 값을 할당**해 줌
- 그 다음 Process가 열려있는 File에 System Call을 이용해서 접근할 때 **FD Value을 이용해 
File을 지칭 가능**

![제목 없음.png](./File Discriptor/%25EC%25A0%259C%25EB%25AA%25A9_%25EC%2597%2586%25EC%259D%258C.png)

- FD Table의 각 항목은 **FD Flag**와 **File Table로의 Pointer**를 가짐
- File Talbe로의 Pointor를 이용하여 FD 를 통해 System의 File을 참조 가능
- Process는 이런 FD Table과 File Table의 정보를 직접 고칠 수 없으며, **Kernel**을 통해 수정 해야함

```c
#include <unistd.h>
#include <stdio.h>
int	main(void) {
	int	max;
	max = sysconf(_SC_OPEN_MAX);
	printf("%d\n", max);
	return(0);
}
```

```bash
getconf OPEN_MAX
```

- FD의 최대값은 `OPEN_MAX`
- Process 하나 당 최대 `OPEN_MAX`개의 File을 열 수 있음
- `OPEN_MAX`값은 Platform마다 다름