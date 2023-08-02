Apache Kafka는 운영 단에서 사용하기 힘듬

조금 더 쉽게 사용할 수 있을까 라는 고민으로 부터 시작

SPITHA Kafka Package Relice Premium Service by SPITHA Care Pack

Apache Kafka File이 사용자 친화적이지 않음
쿠버네티스의 경우 직접 말아서 사용

배포판을 추가하며 기술 지원 서비스를 제공

다른 배포판을 사용하고 있었을 경우 서비스 중단 없이 마이그레이션 기능을 지원

Web UI 대다수의 기능을 단순화(클릭으로만)

솔루션을 개발하고 공급하는 것 이외에도 지원(Care Pack)

Apache Kafka Hot Fix등을 지원

Felice는 웹 유아이 기반으로 멀티 클러스터 관리 기능

클러스터에 대한 전체 대시보드를 보여줌(모니터링 당연히 포함)

전체에 대한 모니터링 기능

해당 브로커에 대한 모니터링도 가능

물리 노드에 대한 Health Check 가능

Apache Kafka가 정상이라도 물리 노드의 장애도 확인 가능

Apache Kafka는 어렵지만 좋은 솔루션이므로 제작

Topic 생성 값과 항목같은 것들이 뜸

이런 부분에 대해서 공부할 필요 없이 도움말을 통해 쉽게 파악 가능

토글로 꺼서 확인하지 않게도 작성

설정 구성 템플릿을 제공(반복 활동 단순화)

알림 기능 지원

사용자 별로 지라나 슬랙 웹훅등으로 가능

권한으로 관리 가능

Smart Rebalancing을 통한 효율적인 Broker 활용 가능
Broker의 Disk 사용 불균형을 해소하는 기능

Broker에 대한 리소스가 초기에는 자동으로 들어가나 시간이 지난 후 밸런스가 맞지 않아짐

Apache Kafka를 CLI환경에서 사용할 때 노가다성 작업으로 파티션을 옮겨야 하나 대부분 불가능

알고리즘을 통해 자동으로 추천해주고 ok시 활용됨

파티션 복제본 개수 변경 가능

사용자 실수 가능성이 높은 작업

수치 입력만으로도 쉽게 가능

Connect Connector 가능

DB SW등과 같이 관리 기능 제공

대부분 오픈소스 Connector를 미리 올려놓았음

따로 CLI 없이 UI를 통해 설치와 사용 가능

자체적 Connector를 만들었거나 Platform을 추가 시 쉽게 가능

CMPS: Consuming Messages per Second

고객사 중 각각의 비즈니스 환경에서 최적, 최악의 성능을 파악

한번에 볼 수 없는가 해서 생긴 기능

실제로 Application의 최대 성능, 현재 성능을 확인

잘 작동하는지 확인

초당 확인을 하나 집계에서 확인 가능

저런 통계수치가 초당 얼마나 생산하니? 같은 질문을 받음, 이 값이 질문의 답이 됨
생산되고 나가고를 확인할 수 있음 유효한 성능 지표일 것 같음
Felice는 Infra를 가리지 않음

Conector 적용에서 이 안에서 데베지움을 써서 사용을 해봤다 고객사에서 Debezium을 사용해 사용 중
Debezium의 MySQL Connector를 사용
GUI에서 설치 가능
![image-20230502112142100](C:/Users/Ark053/AppData/Roaming/Typora/typora-user-images/image-20230502112142100.png)

국내환경 친화적인 솔루션은 Felice

KSQL은 오픈소스인가요?(Community 라이센스)
SASS Service는 하지 않음
KSQL은 Apache에 준하는 라이센스

Apache Kafka에대한 컨설팅도 함

고객사 환경에 따라 차이가 있으나 

![image-20230502112446993](C:/Users/Ark053/AppData/Roaming/Typora/typora-user-images/image-20230502112446993.png)

MSK에서 할 수 없었는 기능까지 추가로 사용 가능

정리

![image-20230502113447623](C:/Users/Ark053/AppData/Roaming/Typora/typora-user-images/image-20230502113447623.png)

Apache Kafka를 위한 기술지원, 컨설팅

스파크앤어소시에이츠

서드파티 제품을 사용하는 데 필요한 요구사항

Plugin으로 제공

Broker 별 Message 확인 가능

Message In / Out

Topic 하나를 어디로 가는가?

토픽 세부 별 통계가 있음

내부 Message

Connector 설정을 할 수 있음

Task List

Connector 추가 시 Open Source Connector들을 미리 설정해 놓음

Confluent의 AutoReblance와 비슷

가격은 노드당 천만원대
Broker 당
년 단위 Subscription
Connector 빼고 칠천?
DB를 사용한 프로젝은 없는가?(SI는 없고 Solution만 함, 직접 하진 않으나 모아놓으면 솔루션을 개선)

따로 구축해 배포도 해줌
Consuming할 때 Back단 문제가 생길 경우 같이 추적은 해줌

