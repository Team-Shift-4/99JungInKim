# FTP vs SFTP

# 공통점

- 네트워크와 호스트 간 파일 / 데이터 / 정보를 전송함(파일 전송 프로토콜)

# FTP(File Transfer Protocol)

- 한 호스트에서 다른 호스트로 파일을 복사하는 TCP / IP의 프로토콜
- 파일 이름의 규칙이 다르거나 디렉터리 구조가 달라도 가능
    - 두개의 연결을 통해 해결
        - 데이터 전송: TCP 포트 20번
        - 제어 정보: TCP 포트 21번
- 제어 연결로 호스트와의 연결을 설정한 다음 파일 전송을 위한 데이터 연결 설정
    - 데이터 연결은 파일이 전송 된 뒤 열리고 닫힘
    - 제어 연결은 전체 FTP 세션에 대해 연결 상태를 유지

# SFTP(Secure File Transfer Protocol)

- SSH 프로토콜의 일부이며 네트워크를 통해 파일을 전송하기 위한 보안 채널을 도입
- SSH 프로토콜은 클라이언트와 서버 사이의 보안 연결을 설정하고 SSH에 의해 생성된 보안 채널에서 파일을 전송

# 차이점

- FTP는 호스트간 파일을 전송하기 위한 보안 채널을 제공하지 않으나 SFTP는 보안채널을 제공
- FTP는 TCP / IP에서 제공하는 서비스이나 SFTP는 SSH 프로토콜의 일부
- FTP는 TCP 포트 21번에서 제어 연결을 사용하여 연결하나 SFTP는 클라이언트와 서버 간 SSH 프로토콜에 의해 설정된 보안 연결로 파일을 전송
- FTP는 암호와 데이터를 일반 텍스트 형식으로 전송하나 SFTP는 데이터를 다른 호스트로 보내기 전 암호화함