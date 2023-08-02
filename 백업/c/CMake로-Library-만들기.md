# CMake로 Library 만들기

# 생성

```c
#include <stdio.h>
void PrintHelloWorld(void) {
	printf("Hello World!\n");
}
```

```c
void PrintHelloWorld(void);
```

```bash
add_library(hello [ STATIC | SHARED ] hello.c)
```

- `add_library`: library를 build하는 command
- `hello`: library name, 최종 library file은 library 앞 lib라는 prefix가 추가된 file name을 가짐
- `[ STATIC | SHARED ]`: `STATIC`은 `*.a`로 file이 생성되며 static library로 build된다는 뜻이며
`SHARED`는 `*.so`로 file이 생성되며 dynamic library(shared object)로 build됨을 의미
- `hello.c`: Build할 fileㅇ르 의미, 두 개 이상의 file을 build할 때 각 file명을 연속적으로 추가, 사이  ``추가

```bash
cmake .
make
```

# 사용

```c
#include "hello.h"
int main(int argc, char *argv[]) {
	PrintHelloWorld();
}
```

```bash
cmake_minimum_required(VERSION 3.14)
set(TARGET_APP app)
add_executable(${TARGET_APP} app.c)
target_include_directories(${TARGET_APP} PRIVATE ${CMAKE_CURRENT_LIST})
target_link_directories(${TARGET_APP} PRIVATE ${CMAKE_CURRENT_LIST})
target_link_libraries(${TARGET_APP} PRIVATE hello)
```

- `cmake_minimum_required`: 필요한 CMake의 최소 버전 명시
- `add_executable`: `app.c`를 build하여 `app`(`TARGET_APP`)이라는 executable file을 생성하도록 명령
- `target_include_directories`: application이 include하는 header file들이 위치한 경로를 지정
    - gcc compile command 중 `-l`option에 해당
- `target_link_directories`: application이 link하는 library file들이 위치한 경로를 지정
    - gcc compile command 중 `-L`option에 해당
    - 위 예제에서는 `libhello.a`가 위치한 경로 지정
- `target_link_libraries`: application이 link 하는 library name을 지정
    - gcc compile command 중 `-l`option에 해당

```bash
cmake .
make
./app
```

# ETC

```bash
cmake_minimum_required(VERSION 3.14)

add_library(hello STATIC hello.c)

set(TARGET_APP app)
add_executable(${TARGET_APP} app.c)
target_include_directories(${TARGET_APP} PRIVATE ${CMAKE_CURRENT_LIST})
target_link_directories(${TARGET_APP} PRIVATE ${CMAKE_CURRENT_LIST})
target_link_libraries(${TARGET_APP} PRIVATE hello)
```

- Libarary 생성과 application 생성을 하나의 CMakeLists.txt로 가능
