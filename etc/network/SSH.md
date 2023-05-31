# SSH

# SSH란

- Secure SHell의 약자
- 원격지 호스트 컴퓨터에 접속하기 위해 사용되는 인터넷 프로토콜 중 하나
- 컴퓨터와 다른 컴퓨터가 공공 네트워크를 통해 로그인하거나 원격 시스템에서 명령을 실행하고 다른 시스템으로 파일을 복사할 수 있도록 해주는 응용 프로그램, 프로토콜을 말함
- 암호화 기법을 사용해 보안에 좋음
- 기본적으로 22번 포트를 사용

# SSH key

- 서버 접속 시 비밀번호 대신 Key를 제출하는 방식
- 비밀번호보다 높은 수준의 보안방식
- Public key와 Private key로 이뤄짐
- Private key는 로컬에 Public key는 원격지에 위치해 로컬과 원격의 Private key를 비교해 일치하는지 비교
    - Public key: 공개키, 공개되어도 안전한 키, 복호화 불가
    - Private key: 비공개키, 노출 되면 안되는 키, 로컬 컴퓨터 내부 저장, 암호화 정보 복호화

# 접속 방법([참고](https://www.lainyzine.com/ko/article/how-to-connect-to-linux-server-with-ssh-on-windows-10/))

<aside>
<img src="https://www.notion.so/icons/exclamation-mark_gray.svg" alt="https://www.notion.so/icons/exclamation-mark_gray.svg" width="40px" /> OpenSSH로 접속하는 기본 명령어

```bash
ssh [USER]@[HOSTNAME] -p [PORT]
```

- [USER]: 접속할 리눅스 사용자를 입력
- [HOSTNAME]: 네트워크 상 접근 가능한 호스트네임이나 IP를 지정
- [PORT]: 리눅스 서버의 SSH 포트이며 22번을 사용시 `-p` 옵션 생략 가능
</aside>

# Telnet vs SSH

## Telnet

- 원격지의 컴퓨터를 인터넷을 통해 접속해 자신의 컴퓨터처럼 사용할 수 있는 원격 접속 서비스
- 이용을 위해 원격 컴퓨터를 이용할 수 있는 사용자 계정이 필요
- TCP 포트는 23번 사용

## SSH

- 네트워크 상의 다른 컴퓨터에 로그인 하거나 원격 시스템에서 명령을 실행하고 다른 시스템으로 파일을 복사할 수 있도록 해주는 응용 프로그램 / 프로토콜
- TCP 포트는 22번을 사용
- 다른 컴퓨터 혹은 장비와 통신 시 암호화 기법을 사용해 노출 되어도 자기 자신만 알 수 있는 문자로 보이게 함

## 공통점

- OSI 7계층인 응용계층에서 동작하는 프로토콜
- 원격으로 제어 할 수 있음

## 차이점

- Telnet은 통신 시 데이터가 평문이기에 해킹 당할 시 정보가 그대로 노출되나 SSH는 암호화 통신을 하기에 안전함