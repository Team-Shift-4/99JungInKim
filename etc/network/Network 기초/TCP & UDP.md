# TCP & UDP

: 전송 계층에서 데이터를 보내기 위해 사용하는 프로토콜들

![Untitled](./TCP & UDP/Untitled.png)

# TCP

: Transmission Control Protocol

<aside>
<img src="https://www.notion.so/icons/cursor_gray.svg" alt="https://www.notion.so/icons/cursor_gray.svg" width="40px" /> 인터넷상에서 데이터를 메세지의 형태로 보내기 위해 IP와 함께 사용하는 프로토콜

</aside>

- 일반적으로 TCP와 IP를 함께 사용
    - IP는 데이터의 배달을 처리
    - TCP는 패킷을 추적 및 관리
- 인터넷 환경에서 기본으로 사용

![가상 회선 패킷 교환 방식](./TCP & UDP/Untitled%201.png)

가상 회선 패킷 교환 방식

## TCP의 특징

- 연결헝 서비스로 가상 회선 방식을 제공
- 3-way handshaking 과정을 통해 연결을 설정함
- 4-way handshaking 과정을 통해 연결을 해제함
- 흐름 제어 및 혼잡 제어
- 높은 신뢰성을 보장
- UDP보다 속도가 느림
- 전이중(Full-Duplex), 점대점(Point to Point) 방식

<aside>
<img src="https://www.notion.so/icons/exclamation-mark_gray.svg" alt="https://www.notion.so/icons/exclamation-mark_gray.svg" width="40px" /> TCP가 가상 회선 방식을 제공한다는 것은 발신지와 수진지를 연결해 패킷을 전송하기 위한 논리적 경로를 배정한다는 뜻

3-way handshaking 과정은 목적지와 수진지를 확실히 해 정확한 전송을 보장하기 위해 세션을 수립하는 과정을 의미

TCP는 신뢰성을 보장하기에 데이터 흐름 제어나 혼잡 제어를 하나 이러한 특징들 때문에 UDP보다 속도가 느림

**TCP는 연속성보다 신뢰성이 중요할 때 사용하는 프로토콜**

ex) 파일전송

</aside>

## TCP 서버의 특징

- 서버 소켓은 연결만 담당
- 연결 과정에서 반환된 클라이언트 소켓은 데이터의 송수신에 사용된다면 서비스로 가상 회선 방식을 제공
- 서버와 클라이언트는 1:1 관계로 연결
- 스트림 전송으로 전송 데이터의 크기가 무제한
- 패킷에 대한 응답을 해서 성능이 낮다
- Streaming 서비스에 불리

<aside>
<img src="https://www.notion.so/icons/question-mark_gray.svg" alt="https://www.notion.so/icons/question-mark_gray.svg" width="40px" /> **Packet?**

인터넷 내에서 데이터를 보내기 위한 경로 배정(라우팅)을 효율적으로 하기 위해 데이터를 여러 개의 조각들로 나누어 전송할 때의 조각

</aside>

# UDP

: User Datagram Protocol

<aside>
<img src="https://www.notion.so/icons/cursor_gray.svg" alt="https://www.notion.so/icons/cursor_gray.svg" width="40px" /> 데이터를 데이터그램 단위로 처리하는 프로토콜

</aside>

- 데이터그램: 독립적인 관계를 지는 패킷
- 비연결형 프로토콜
- 연결을 위해 할당된 논리적인 경로가 없음
- 각각의 패킷은 다른 경로로 전송되고 독립적인 관계를 지니게 되어 독립적으로 처리하게 됨

![Untitled](./TCP & UDP/Untitled%202.png)

## UDP의 특징

- 비연결형 서비스로 데이터그램 방식 제공
- 정보를 주고 받을 때 정보를 보내거나 받는다는 신호 절차를 거치지 않음
- UDP 헤더의 CheckSum 필드를 통해 최소한의 오류만 검출
- 신뢰성이 낮으나 TCP보다 속도가 빠르다
- Streaming 서비스에 유리

<aside>
<img src="https://www.notion.so/icons/exclamation-mark_gray.svg" alt="https://www.notion.so/icons/exclamation-mark_gray.svg" width="40px" /> UDP는 비연결형 서비스이기에 연결 설정 및 해제하는 과정이 없음

서로 다른 경로로 독립적으로 처리하며 패킷에 순서를 부여하여 재조립하거나 흐름 제어 및 혼잡 제어 기능도 처리하지 않아 TCP보다 빠르고 부하가 적다는 장점이 있음

신뢰성 있는 데이터 전송을 보장하지 못함

**UDP는 신뢰성보다 연속성이 중요할 때 사용하는 프로토콜**

ex) Streaming 서비스

</aside>

## UDP 서버의 특징

- UDP에는 연결 자체가 없어 서버 소켓과 클라이언트 소켓의 구분이 없음
- 소켓 대신 IP를 기반으로 데이터 전송
- 서버와 클라이언트는 1:1, 1:N, N:M의 관계 등으로 연결될 수 있음
- 데이터그램 단위로 전송되며 65535바이트의 크기로 전송되며 초과시 잘라서 보냄
- 흐름 제어가 없어 패킷이 제대로 전송되었는지, 오류가 없는지 확인 불가능
- 파일 전송과 같은 신뢰성이 필요한 서비스보다 성능이 중요시 될 때 사용

<aside>
<img src="https://www.notion.so/icons/question-mark_gray.svg" alt="https://www.notion.so/icons/question-mark_gray.svg" width="40px" /> **흐름 제어(Flow Control)와 혼잡 제어(Congestion Control)?**

흐름 제어는 데이터를 송신하는 곳과 수신하는 곳의 데이터 처리 속도를 조절해 수신자의 버퍼 오버플로우를 방지하는 것
수신자가 데이터를 빠르게 많이 받다가 문제가 발생하기 때문

혼잡 제어는 네트워크 내 패킷 수가 넘치게 증가하지 않도록 방지하는 것
정보의 소통량이 과다할 때 패킷을 조금 전송해 혼잡 붕괴 현상이 일어나는 것을 막음

</aside>

# TCP와 UDP의 비교

| 프로토콜 종류 | TCP | UDP |
| --- | --- | --- |
| 연결 방식 | 연결형 서비스 | 비연결형 서비스 |
|  패킷 교환 방식 | 가상 회선 방식 | 데이터그램 방식 |
| 전송 순서 | 전송 순서 보장 | 전송 순서가 바뀔 수 있음 |
| 수신 여부 확인 | 수신 여부 확인 | 수신 여부 확인 안함 |
| 통신 방식 | 1:1 통신 | 1:1 or 1:N or N:M 통신 |
| 신뢰성 | 높다 | 낮다 |
| 속도 | 느리다 | 빠르다 |
- 추가 자료
  
    ![교환 방식](./TCP & UDP/Untitled%203.png)
    
    교환 방식
    
    ![TCP Flow](./TCP & UDP/Untitled%204.png)
    
    TCP Flow
    
    ![UDP Flow](./TCP & UDP/Untitled%205.png)
    
    UDP Flow
    

TCP는 전화기

UDP는 편지