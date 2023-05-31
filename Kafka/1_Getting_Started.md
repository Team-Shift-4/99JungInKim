# Introduction

## Event Streaming이란?

Event Streaming은 사람으로 치자면 중추 신경계에 해당합니다.
비즈니스를 점점 Software로 정의해 자동화하고, 그 사용자 또한 Software인 경우가 많은 Always-on 세계의 기술적인 근간입니다.

기술적으로 Event Streaming은 Database, Sensor, Mobile Device, Cloud Service, Software Application과 같은 Event Source에서 Data를 실시간으로 Event Source에서 Data를 Real-Time으로 Event Stream 형식으로 잡아내는 관행입니다.
이런 Event Stream은 나중에 조회할 수 있게 안전한 곳에 저장하고, Real-Time Event Stream에 즉시 반응하거나 모아서 Processing할 수도 있습니다.
필요에 따라 Event Stream을 다른 기술로 Routing하기도 합니다.
Event Streaming은 Data의 지속적인 Flow를 이어주며, 덕분에 Data를 끊김 없이 해석해 적시에 적절한 정보를 필요한 곳에 제공할 수 있습니다.

## Event Streaming의 사용 사례

Event Streaming은 수 많은 산업과 조직에 걸쳐 활용되고 있습니다.

-   증권 거래소, 은행, 보험 등에서 실시간 지불 처리와 기타 금융 거래 처리
-   물류, 자동차 산업 등에서 자동차, 트럭, 차량, 화물을 실시간으로 추적하고 Monitoring
-   공장, 풍력 단지 등에서 IoT 기기나 기타 장비의 Sensor Data를 지속적으로 수집하고 분석
-   소매, 호텔 및 여행 산업, Mobile Application 등에서 고객 상호 작용과 주문 Event를 수집하고 즉각 대응
-   병원 진료 중 환자를 Monitoring하고 상태 변화를 예측해 응급 상황 발생 시 적시에 치료
-   사내 여러 부서에서 생산한 데이터를 연결, 저장, 사용 가능하도록 구성
-   Data Platform, Event-Based Architecture, Micro-Service의 기초 토대로 활용

## Apache Kafka의 핵심 기능

Apache Kafka는 Event Streaming Platform입니다.
세 가지 핵심 기능을 갖추고 있어 현장에서 금증된 단일 Solution을 통해 원하는 사례를 Event Streaming End-to-End로 구현할 수 있습니다.

1.   Event Stream을 Write(발행)하고 Read(구독)하며, 다른 System에 있는 Data를 끊임 없이 Import/Export할 수 있습니다.
2.   Event Stream을 원하는 기난동안 안전하고 신뢰할 수 있는 곳에 저장합니다.
3.   Event 발생 즉시 Stream을 처리하거나 모아서 처리합니다.

이 모든 기능은 Distributed Service(분산 서비스)가 가능하고 확장성이 뛰어나며 탄력적이고 내결함성이 있는 안전한 방식으로 제공됩니다.
Kafka는 Bare Metal Hardware, Virtual Machine, Container에 배포될 수 있으머 Cloud나 On-Premise 환경에서도 배포할 수 있습니다.
Kafka 환경을 직접 관리해도 되고, 다양한 Vendor가 제공하는 완전 관리형 Service를 사용해도 좋습니다.

## Kafka의 작동 핵심

Kafka는 고성능 TCP Network Protocol로 통신하는 Server와 Client로 구성된 Distributed System입니다.

Server: Kafka는 Server를 하나 이상 가진 Cluster로 실행하며 각 Server는 여러 Data Center나 Cloud Region에 걸쳐있을 수 있습니다.
일부 Server는 Broker라고 하는 Storage Layer를 구성합니다.
또 다른 Server는 Kafka Connect를 실행해 Data를 끊임 없이 Event Stream으로 Import/Export하는 식으로, Kafka를 다른 Kafka Cluster나 RDB 등의 기존 System과 통합힙니다.
Service 운영에 필수적인 Use Case를 구현할 수 있도록 Kafka Cluster는 뛰어난 확장성과 내결함성을 제공합니다.
Server 중 하나의 장애가 발생할 시 다른 Server에서 이어받아 Data Loss 없이 지속적인 운영을 보장합니다.

Client: Kafka Client로는 Network 문제나 장비 장애가 발생해도 내결함성을 유지하며 대규모 Event Stream을 Read/Write/Process하는 Distributed Application과 Micro Service를 만들 수 있습니다.
Kafka는 Kafka Community에서 제공하는 수십 개의 Client로 보강한 몇 가지 Client를 제공합니다.
Client는 Java, Scala에서 사용할 수 있으며, REST API, Go, Python, C/C++ 등 다양한 Programming Language 용 고수준 Kafka Streams Library도 제공합니다.

## Main Concept & Terminology

Event는 세상에서나 비즈니스 환경에서 "어떤 것이 발생했다"는 사실을 기록합니다.
이 문서에서는 Record 혹은 Message라고도 부릅니다.
Kafka에서 Data를 Read/Write할 때 Event 형식으로 진행합니다.
개념적으로 Event는 Key, Value, Timestamp를 가지고 있으며, Option으로 Metadata Header도 있을 수 있습니다.

예시

-   Event Key: "Jungin"
-   Event Value: "Study Kafka"
-   Event Timestamp: "Mar. 10, 2023 at 10:57 a.m."

Producer는 Kafka에 Event를 Write하는 Client Application을 뜻하며 Consumer는 이 Event를 Read & Process하는 Application을 뜻합니다.
Kafka에서 Producer와 Consumer는 분리되어 있으며 각자 서로 세부 구현을 알 필요 없이 독립적으로 동작합니다.
Producer와 Consumer를 분리한 것은 높은 확장성을 위해서 설계한 핵심 설계 요소입니다.
Producer는 Consumer를 기다릴 필요가 없고 Kafka는 Event를 정확히 한 번만 처리하는 등 여러 Semantic을 보장합니다.

Event는 Topic으로 구성되어 안전하게 저장됩니다.
단순히 설명해 Topic은 File System의 Folder와 유사하며 Event는 Folder 안의 File이라고 생각하시면 편합니다.
Kafka의 Topic은 언제나 Multi-Producer와 Multi-Consumer가 접간할 수 있습니다.
단일 Topic에 Event를 작성하는 Producer가 0~N개가 될 수 있으며 Event를 구독하는 Consumer도 0~N개가 될 수 있습니다.
Topic의 Event는 필요한 만큼 다시 읽어갈 수 있습니다.
기존의 Messaging System과 달리 Event를 Consume한 후 삭제하지 않습니다.
대신 Topic 별 설정으로 Kafka가 Event를 보존할 기간을 정의하고 오래된 Event를 폐기합니다.
사실상 Kafka의 성능은 Data Size가 커도 일정하므로 장기간의 Data를 저장해도 문제가 발생하지 않습니다.

Topic은 Partitioning됩니다.
즉 Topic은 서로 다른 Kafka Broker에 있는 여러 "Bucket"으로 Distribute됩니다.
이렇게 Data를 Distribute해 저장하는 것은 확장성을 위해서입니다.
덕분에 Client Application은 동시에 여러 Broker에서 Data를 Read/Write 할 수 있습니다.
Topic에 새 Event를 Write하면 실제로 Topic의 Partition 중 하나에 추가됩니다.
Event Key가 동일한 Event는 같은 Partition에 기록되며 Kafka에선 하나의 Topic-Partition을 Consume하는 모든 Consumer는 항상 기록한 순서와 정확히 같은 순서로 해당 Partition Event를 읽어간다는 걸 보장합니다.

![img](./1_Getting_Started.assets/streams-and-tables-p1_p4.png)

위 예제 사진의 Topic엔 4개의 Partition P1~P4가 있습니다.
서로 다른 두 Producer Client가 Network을 통해 이 Topic의 Partition에 Event를 작성해 독립적으로 Topic에 Event를 발행합니다.
Key가 동일한 Event는 같은 Partition에 기록됩니다. 따라서 두 Producer가 같은 Partition에 쓸 수도 있습니다.

내결함성, 고가용성 있는 Data를 만들기 위해 모든 Topic은 Replicate(복제)할 수 있으며 지리적으로나 Distribute하거나 Data Center에 걸쳐서도 가능합니다.
따라서 혹시나 모를 문제를 대비하거나 Broker 유지 관리 등을 위해 항상 Data 복제본을 가진 Multi Broker가 존재하게 됩니다.
보통 Production 환경에서는 Replication Factor를 3으로 설정합니다(Replication Factor가 3일 경우 복재본이 항상 3개 존재하게 됩니다.).
Data Replication은 Topic-Partition Level에서 이루어집니다.

## Kafka APIs

Kafka는 몇 가지 관리 작업과 Admin성 작업을 위한 Command Line Tool 외에도 Java와 Scala를 위한 핵심 API 다섯 가지를 제공합니다.

-   Topic, Broker, 다른 Kafka Object를 관리하고 점검할 수 있는 Admin API
-   하나 이상의 Kafka Topic의 Event Stream을 Write할 수 있는 Producer API
-   하나 이상의 Kafka Topic의 Event Stream을 Read & Process할 수 있는 Consumer API
-   Stream Processing Application과 Micro-Service를 구현할 수 있는 Kafka Streams API
    Kafka Streams API는 Data 변환, 집계, JOIN 같은 Stateful 연산, Windowing, Event Time-Based Processing 등 Event Stream을 처리하는 고급 기능을 제공합니다.
    하나 이상의 Topic에서 Read한 Data를 Input 받아 하나 이상의 Topic에 쓸 Output을 만들 수 있습니다.
    즉, Input Stream을 Output Stream으로 효과적으로 변환합니다.
-   재사용 가능한 Data Import/Export Connector를 만들고 실행할 수 있는 Kafka Connector API
    Connertor는 외부 System과 Application 간 Event Stream을 Consume(Read)하고 Produce(Write)할 수 있기 때문에 외부 System을 Kafka와 통합할 수 있습니다.
    예로 PostgreSQL과 같은 RDB를 연결해주는 Connector로는 Table Set에 생기는 모든 변경 사항을 잡아낼 수 있습니다.
    Kafka Community에는 즉시 사용할 수 있는 Connector는 수백 개 가량 준비되어 있어 실제로 자체 Connector를 구현할 일이 적습니다.

## Link Book

>   [Apache Kafka Quickstart](https://kafka.apache.org/quickstart)
>
>   [Use Cases](https://kafka.apache.org/powered-by)
>
>   [Kafka Meetup Group](https://kafka.apache.org/events)
>
>   [Kafka Summit](https://www.kafka-summit.org/past-events)

# Use Cases

Apache Kafka의 대표적인 Use Case를 설명합니다.

## Messaging

Kafka는 다른 전통적인 Message Broker를 대체할 수 있습니다.
Message Broker는 다양한 목적으로 활용합니다(Data Processing Logic을 Producer와 분리하거나 처리되지 않은 Message를 Buffer에 담는 등).
Kafka를 다른 Messaging System과 비교해보면 보통 더 효율적이며 Partitioning 기능이 내장되어 있으며 Replicate와 내결함성을 제공하므로 대규모 Message Processing Application의 Solution으로 적합합니다.

경험상 Messagine System은 비교적 처리량이 낮아도 보통 End-to-Ent 지연 시간이 짧아야 하며 Kafka가 보장하는 강력한 내구성이 필요합니다.

Kafka의 역할은 ActiveMQ나 RabbitMQ와 같은 전통적인 Messaging System과 유사합니다.

## Website Activity Tracking

원래 Kafka의 Use Case는 User 활동을 추적하는 Pipeline을 Real-Time Publish-Subscribe Feed Set으로 재구성하는 것이였습니다.
사이트 활동(Page 조회, Search 등 User가 취할 수 있는 활동)은 활동 Type마다 그에 해당하는 하나의 중앙 Topic으로 Publishing됩니다.
Real-Time Processing, Real-Time Monitoring, Offline Processing과 보고를 위해 Hadoop이나 다른 Offline Data Warehouse System에 Load하는 등 다양한 Use Case에 따라 이 Feed를 Subscribe할 수 있습니다

각 User가 Page를 조회할 때마다 방대한 활동 Message가 만들어지기에  User 활동을 추적할 땐 보통 대용량 Data를 생성하게 됩니다.

## Metrics

Kafka는 운영 Monitoring Data에도 자주 활용됩니다.
여기에는 Distributed Application의 통계 Data를 집계해서 운영 Data의 중앙 집중식 Feed를 구성하는 것도 포함됩니다.

## Log Aggregation

많은 곳에서 Log 집계 Solution 대신 Kafka를 사용하고 있습니다.
Log 집계에서는 보통 Server에서 Physical Log File을 수집해 향후 Log를 처리할 수 있게 중앙 저장소(File Server나 HDFS)에 저장하는 것을 말합니다.
Kafka는 File의 상세 정보를 추상화해 Log나 Event Data를 Message Stream으로 더 깔끔하게 추상화해 줍니다.
이를 통해 Processing Latency Time을 줄일 수 있고 더 쉽게 Multi-Data Source와 Distributed Data Consuming을 지원할 수 있습니다.
Kafka를 Scribe나 Flume 같은 Log-Based System과 비교해보면 똑같이 좋은 성능을 보여주며 Replicate로 인해 더 강한 내구성과 낮은 End-to-End Latency Time을 제공해줍니다.

## Stream Processing

많은 User들이 Kafka Topic에서 원본 Input Data를 Consume해 새 Topic으로 집계, 보강, 변환해 추가 Consuming이나 후속 Processing을 진행하는 Multi-Step으로 구성된 Pipeline으로 Data를 Processing하고 있습니다.
이런 Data Processing Pipeline은 각 Topic을 기반으로 Real-Time Data Flow Graph를 생성합니다.
0.10.0.0부터 Apache Kafka는 Kafka Streams라는 가벼우나 강력한 Stream Processing Library를 제공하므로 앞에서 설명한 방식대로 Data를 처리할 수 있습니다.
Kafka Streams 외에도 대체할 수 있는 Open Source Stream Processing Tool로는 Apache Storm, Apache Samza가 있습니다.

## Event Sourcing

Event Sourcing은 상태 변경을 시간 순에 따라 Record Sequence로 기록하는 Application 설계 방식입니다.
Kafka엔 아주 큰 Log Data도 저장할 수 있기 때문에 Event Sourcing Style로 구축한 Application이 사용하기에 적합한 Backend System입니다.

## Commit Log

Kafka는 Distributed System에서 외부 Log를 Commit하는 용도로 사용할 수 있습니다.
Log는 Node 간 Data를 Replicate에 활용할 수 있으며 실패한 Node가 Data를 Recover 할 수 있도록 재 동기화 메커니즘 역할을 수행해줍니다.
Kafka의 Log Compaction 기능도 유용합니다.
이 Use Case에서 Kafka는 Apache BookKeeper Project와 유사합니다.

# Quick Start

## Step 1: Download Kafka

최신 Kafka Release를 Download 받고 압축을 풉니다.

```bash
tar -xzf kafka_2.13-3.4.0.tgz
cd kafka_2.13-3.4.0
```

## Step 2: Start The Kafka Environment

Local 환경에 Java 8+ 이상이 설치되어 있어야 합니다.

아래 Command들을 실행시켜 전체 Service를 올바른 순서대로 시작합니다.

```bash
# Start the Zookeeper Service
# Note: Soon, Zookeeper will no longer be required by Apache Kafka
bin/zookeeper-server-start.sh config/zookeeper.properties
```

세션 하나를 추가로 연 뒤 다음을 실행합니다.

```ba
# Start the Kafka broker service
bin/kafka-server-start.sh config/server.properties
```

모든 Service를 성공적으로 Startup시켰다면 Kafka 기본 환경과 사용 준비를 마친것입니다.

## Step 3: Create a Topic to Store your Events

Kafka는 여러 System에 걸쳐 Event(Record, Message는 같은 뜻입니다.)를 Read, Write, Store, Processing할 수 있는 Distributed Event Streaming Plaform입니다.

Event는 Topic안에 구성되고 저장됩니다.
간단히 말해 Topic은 File System의 Folder와 유사하며 Event는 Folder안에 들어있는 File이라고 보시면 편합니다.

Event를 작성하기 위해서는 Topic을 먼저 만들어야 합니다.
Terminal Session을 열어 다음을 실행해 Topic을 만듭니다.

```bash
bin/kafka-topics.sh --create --topic quickstart-events --bootstrap-server localhost:9092
```

Kafka의 모든 Command Line Tool은 별도의 Option을 가지고 있습니다.
예로 인자 없이 `kafka-topics.sh`를 실행하면 사용 정보를 출력해줍니다.
또한 새 Topic의 Partition Count같은 세부 정보도 확인할 수 있습니다.

```bash
bin/kafka-topics.sh --describe --topic quickstart-events --bootstrap-server localhost:9092
```

## Step 4: Write some Events into the Topic

Kafka Client는 Event Read & Write를 위해 Network를 통해 Kafka Broker와 통신합니다.
Broker는 일단 Event를 받으면 필요한 기간 동안 내구성 있고 내결함성 있는 방식으로 Event를 저장하며 영구적으로 저장하는 것도 가능합니다.

Console Producer Client를 실행해 Topic에 몇 개의 Event를 작성해 볼 수 있습니다.
기본적으로 Line을 입력할 때마다 Topic에 별도의 Event로 작성됩니다.

```bash
bin/kafka-console-producer.sh --topic quickstart-events --bootstrap-server localhost:9092
first event
second event
```

Producer Client는 `ctrl` + `c`로 중지할 수 있습니다.

## Step 5: Read the Events

Terminal Session을 하나 더 열어 Console Consumer Client를 실행해 Event를 읽을 수 있습니다.

```bash
bin/kafka-console-consumer.sh --topic quickstart-events --from-beginning --bootstarp-server localhost:9092
first event
second event
```

Consumer Client는 `ctrl` + `c`로 중지할 수 있습니다.

Event는 Kafka에 지속적으로 저장되기에 필요한 만큼의 Consumer로 원하는 횟수만큼 읽을 수 있습니다.
Terminal Session을 별도로 열어 이전 Command를 실행시키면 쉽게 확인할 수 있습니다.

## Step 6: Import/Export your Data as Streams of Events with Kafka Connect

RDB나 전통적인 Messaging System같은 기존 System에 Data가 많다면 이미 다수의 Application에서 이 System을 사용하고 있을 수 있습니다.
Kafka Connect를 사용하면 되부 System Data를 Kafka로 끊임 없이 수집할 수 있으며 반대도 가능합니다.
이 이유로 기존 System을 Kafka에 통합하기 쉽습니다.
손쉽게 사용할 수 있는 Connector가 수백 개에 달하기에 통합 Process는 더 쉬워집니다.

Kafka Connect Section에서 Data를 지속적으로 Kafka로 Import/Export하는 내용이 언급됩니다.

## Step 7: Process your Events with Kafka Streams

Data를 Kafka에 Event로 저장하고 나면 Java/Scala용 Kafka Streams Client Library를 사용해 Data를 처리할 수 있습니다.
Input/Output Data를 Kafka Topic에 저장하는 Service 운영에 필수적인 Real-Time Application과 Micro Service를 구현할 수 있습니다.
Kafka Streams는 Kafka의 Server Side Cluster 기술에 Standard Java/Scala Client Side Appliaction을 작성하고 배포하는 단순성을 더해 Streaming Appliaction의 확장성과 탄력성, 내결함성, 분상성을 높여줍니다.
Kafka Streams Library는 Exactly-Once Processing, Stateful 연산 및 집계, Windowing, Join, Time-Based Event Processing 등을 지원합니다.

Kafka Streams에서 많이 사용하는 `WordCount` Algorithm 구현 방법을 예시로 설명하겠습니다.

```java
KStream<String, String> textLines = builder.stream("quickstart-events");

KTable<String, Long> wordCounts = textLines
    .flatMapValues(line -> Arrays.asList(line.toLowerCase().split(" ")))
    .groupBy((keyIgnored, word) -> word)
    .count();

wordCounts.toSream().to("output-topic"), Produced.with(Serdes.String(), Serdes.Long());
```

>   [Kafka Streams Demo](https://kafka.apache.org/25/documentation/streams/quickstart)
>
>   [Write a Kafka Streams Application Tutorial](https://kafka.apache.org/25/documentation/streams/tutorial)

##  Step 8: Terminate the Kafka Environment

1.   Producer와 Consumer Client를 중단하지 않았다면 `ctrl` + `c`로 중지합니다.
2.   Kafka Broker를 `ctrl` + `c`로 중지합니다
3.   Zookeeper를 마지막으로 `ctrl` + `c`로 중단합니다.

앞서 생성한 Event 등의 Local Kafka 환경에 있는 모든 Data를 삭제하고 싶다면 아래 Command를 실행하면 됩니다.

```bash
rm -rf /tmp/kafka-logs /tmp/zookeeper
```

# Ecosystem

Main 배포판 이외에도 Kafka를 통합할 수 있는 Tool은 무수히 많습니다.

>   [Ecosystem](https://cwiki.apache.org/confluence/display/KAFKA/Ecosystem)