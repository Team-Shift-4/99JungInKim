# Virtual Box Network

### 간단 정리 표

| 방식 | 게스트 → 호스트 | 게스트 ← 호스트 | 게스트1 ↔ 게스트2 | 게스트 → 인터넷 | 게스트 ← 인터넷 |
| --- | --- | --- | --- | --- | --- |
| 호스트 전용 어댑터 | O | O | O | X | X |
| 내부 네트워크 | X | X | O | X | X |
| 브릿지 네트워크 | O | O | O | O | O |
| NAT | X | Port forwading | X | O | Port forwading |
| NAT 네트워크 | X | Port forwading | O | O | Port forwading |

# 용어 정리

- Host: 자신의 메인 PC
- Guest: 모든 가상 서버
- 공인 IP: 외부 세계와 연결할 때 쓰는 통신사에 결제 해 얻은 고유의 IP(1개)

![Untitled](./Virtual Box Network/Untitled.png)

- 사설 IP: 유무선공유기를 통해 집 내부 기기들에 할당되는 모든 IP(여러개)
    - A class: 0.0.0.0 ~ 127.255.255.255
        - 네트워크 부분: 첫 옥테드
        - 호스트 부분: 나머지 옥테드
    - B class: 128.0.0.0 ~ 191.255.255.255
        - 네트워크 부분: 앞 두 옥테드
        - 호스트 부분: 나머지 옥테드
    - C class: 192.0.0.0 ~ 223.255.255.255
        - 네트워크 부분: 앞 세 옥테드
        - 호스트 부분: 마지막 옥테드

# 네트워크 방식 설명

## NAT 방식

![Untitled](./Virtual Box Network/Untitled%201.png)

- NAT 박스 안 가상 서버 3대가 같은 IP가 할당되어 있음
- 외부로 인터넷 통신이 되나 자기들 끼리 통신이 되지 않음
- Gateway가 같음
- 호스트와 게스트 간 통신을 위해 별도로 포트포워딩 해줘야 함

## Bridge 방식

![Untitled](./Virtual Box Network/Untitled%202.png)

- Bridge 방식을 사용하면 IP를 AP에서 직접 받아옴
- 하나의 네트워크로 묶여있기때문에 상호 통신이 가능

### 세팅 방법

![Untitled](./Virtual Box Network/Untitled%203.png)

## Host only

![Untitled](./Virtual Box Network/Untitled%204.png)

- Host ↔ Guest 통신은 되나 외부 인터넷이 안됨

## 내부 네트워크

![Untitled](./Virtual Box Network/Untitled%205.png)

- Host ↔ Guest 통신이 안되고 인터넷도 안됨
- 내부 네트워크로 설정한 가상머신간 통신은 가능

## Port Forwarding

- Host OS에서 putty 등으로 가상머신에 접속하기 위해 해당 기능이 활성화 되어야 함
- NAT와 NAT network 방식만 포트 포워딩 기능 사용이 가능하며 브릿지 방식은 상호 통신이 되니 해당 기능이 필요 없음

### 세팅 방법

- 가상서버 설정 → 네트워크 → 고급 → 포트 포워딩

![Untitled](./Virtual Box Network/Untitled%206.png)

- Host IP + Host port는 본인 메인 PC 주소
- Guest IP + Guest port는 해당 가상서버 주소
- SSH 원격 터미널로 접속할 때 가상 서버 포트 번호는 22번이 기본

### 원리

![Host의 IP와 Port를 Guest의 IP와 Port로 넘겨주는 것](./Virtual Box Network/Untitled%207.png)

Host의 IP와 Port를 Guest의 IP와 Port로 넘겨주는 것

- putty로 접속 시도할 때 입력해야 하는 IP와 Port 값은  Virtual Box 포트 포워딩 규칙에 설정한 Host IP + Host Port 번호 입력
- ssh로 접속하기 위한 Linux 설정
  
    ```bash
    vi /etc/ssh/sshd_config
    
    # PermitRootLogin yes ## <= 추가
    
    Systemctl restart ssh
    ```
    

### 실습용 세팅

- 위 세팅과 다르게 별도의 DHCP 서버가 있어서 각각 IP를 할당 받아 게스트간 통신이 가능

### 세팅 방법

![Untitled](./Virtual Box Network/Untitled%208.png)

1. 파일 → 환경설정 → 네트워크 → 맨 우측 아래 세번째 설정 누름
2. 원하는 네트워크 이름과 대역 설정
   
    ![Untitled](./Virtual Box Network/Untitled%209.png)
    
3. 반영하고 싶은 가상 서버의 설정에 들어가 네트워크 → 네트워크 방식을 ‘NAT 네트워크 선택’
   위에 설정한 네트워크 이름 선택
   
    ![Untitled](./Virtual Box Network/Untitled%2010.png)
   
4. 모두 이런식으로 설정한 후 ip를 확인하면 설정한 대역의 IP로 설정됨