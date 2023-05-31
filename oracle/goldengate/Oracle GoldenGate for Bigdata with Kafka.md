# Bigdata용 Oracle GoldenGate with Kafka

📌 Oracle GoldenGate 21.1, Confluent Kafka 7.3.2 기준으로 작성된 문서

## Kafka Handler 

### 개요와 세부기능

OGG for Bigdata Kafka Handler는 OGG Trail에서 Kafka Topic으로 Change Chapter Data를 Streaming
Kafka Handler는 별도의 Schema Topic에 Message를 게시하는 기능을 제공
Avro와 JSON에 대한 Schema 게시가 지원

>   [Apache Kafka](https://kafka.apache.org/)

Kafka는 단일 Instance나 Multi Server의 Cluster로 실행할 수 있음
각 Kafka Server Instance를 Broker라 함
Kafka Topic은 Produver가 Message를 게시하고 Consumer가 검색하는 범주(Category, Feed)

Kafka에서 Topic 이름이 정규화된 Source Table 이름에 해당하는 경우 Kafka Handler는 Kafka Produver를 구현
Kafka Produver는 여러 Source Table에서 단일 Configuration된 Topic이나 분리된 Source Operation으로 Serialize된 Change Data Chapture를 다른 Kafka Topic에 기록

#### Transaction vs Operation Mode

Kafka Handler는 Kafka ProduverRecord Class의 Instance를 Kafka Producer API로 보내고 Kafka Producer API는 ProduverRecord를 Kafka Topic에 게시
Kafka ProducerRecord는 Kafka Message의 구현과 같음
ProducerRecord에는 Key와 Value가 있음
Key와 Value는 모두 Kafka Handler에 의해 Byte Array로 표시

##### Transaction Mode

gg.handler.name.Mode=tx로 Kafka Handler를 Transaction Mode로 설정

Transaction Mode에서 Serializing된 Data는 Source OGG Trail File에서 Transaction의 모든 Operation에 대해 연결
연결된 Operation Data의 내용은 Kafka ProducerRecord Object의 Value
Kafka ProducerRecord Object의 Key는 NULL
결과적으로 Kafka Message는 1에서 N까지의 Operation의 Data로 Configuration됨(N = Transaction의 Operation 수)

Group화된 Transaction의 경우 모든 Operation에 대한 모든 Data가 단일 Kafka Message로 연결
따라서 Group화된 Trnasaction으로 인해 많은 수의 Operation에 대한 Data가 클 경우 매우 큰 Kafka Message가 생성될 수 있음

##### Operation Mode

gg.handler.name.Mode=op로 Kafka Handler를 Operation Mode로 설정

Operation Mode에서 각 Operation에 대한 Serializing된 Data는 개별 ProducerRecord Object에 Value로 배치됨
ProducerRecord Object의 Key는 Source Operation의 fully qualified table name
ProducerRecord는 Kafka Producer API를 사용해 즉시 전송됨
이는 들어오는 Operation과 생성된 Kafka Message 수 관계가 1:1임을 나타냄

#### Topic 이름 설정

Topic명은 아래의 Property에 의해 지정

```
gg.handler.topicMappingTemplate
```

현재 Operation의 Context를 기반으로 Runtime에 Topc 이름을 동적으로 할당할 수 있음

#### Kafka Broker 설정

Topic을 자동으로 생성되도록 Configuration하기 위해 auto.create.topics.enable Property를 true로 설정(default)

auto.create.topics.enable Property가 false일 경우 Replicat Process를 시작하기 전 Topic을 수동으로 생성해야 함

#### Schema 전파

모든 Table의 Schema Data는 schemaTopicName Property로 Configuration된 Schema Topic으로 전달됨

### Kafka Handler 설정과 실행

>   [Kafka Single Node or Clusterd Instance Configuration](https://kafka.apache.org/documentation.html)

Kafka와 Kafka Broker의 필수 Configuration 요소인 Zookeeper가 실행 중이여야 함

Oracle은 실행 중인 Kafka Broker에서 Data Topic과 Schema Topic을 미리 Configuration하는 것을 권장
동적 Topic을 허용하도록 Configuration된 Kafka Broker에 의존하나 Kafka Topic을 동적으로 생성할 수 있음

Kafka Broker가 Kafka Handler Process와 함께 배치되지 않은 경우 Kafka Handler를 실행하는 System에서 Remote Host Port에 도달할 수 있어야 함

#### Classpath Configuration

Kafka Handler가 Kafka에 연결하고 실행하기 위해 Kafka Producer Properties File과 Kafka Client JAR가 gg.classpath Configuration 변수에 Configuration되어야 함
Kafka Client JAR는 Kafka Handler가 연결하는 Kafka Version과 일치해야 함

Kafka Producer Properties File의 권장 저장 위치는 $OGG_HOME/dirprm Directory
Kafka Client JAR File의 기본 저장 위치는 $KAFKA_HOME/libs/*

gg.classpath는 정확히 Configuration해야 함
Kafka Producer Properties File에는 *(Wild Card)가 추가되지 않은 경로가 포함되어야 함
Kafka Producer Properties File의 경로에 *가 포함된 경우 File이 선택되지 않음
반대로 Dependency JAR에는 해당 Directory의 모든 JAR File을 연관된 Classpath에 포함하기 위해 *를 포함해야 함(*.jar가 아닌 *)

#### Kafka Handler Configuration

| Property Name                                | Essential                 | Property Value                                               | Default                                                      | Description                                                  |
| :------------------------------------------- | :------------------------ | :----------------------------------------------------------- | :----------------------------------------------------------- | :----------------------------------------------------------- |
| `gg.handlerlist`                             | Y                         | `name` (choice of any name)                                  | None                                                         | 사용할 Handler List                                          |
| `gg.handler.name.type`                       | Y                         | `kafka`                                                      | None                                                         | 사용할 Handler Type                                          |
| `gg.handler.name.topicMappingTemplate`       | Y                         | Runtime 시 Kafka Topic 이름을 확인하기 위한 Template String Value | None                                                         | [Using Templates to Resolve the Topic Name and Message Key](https://docs.oracle.com/en/middleware/goldengate/big-data/21.1/gadbd/using-kafka-connect-handler.html#GUID-A87CAFFA-DACF-43A0-8C6C-5C64B578D606). |
| `gg.handler.name.keyMappingTemplate`         | Y                         | Runtime 시 Kafka Message Key를 확인하기 위한 Template String Value | None                                                         | [Using Templates to Resolve the Topic Name and Message Key](https://docs.oracle.com/en/middleware/goldengate/big-data/21.1/gadbd/using-kafka-connect-handler.html#GUID-A87CAFFA-DACF-43A0-8C6C-5C64B578D606). |
| `gg.handler.name.KafkaProducerConfigFile`    | N                         | File 이름                                                    | `kafka-producer-default.properties`                          | Apache Kafka Producer를 Configuration하기 위한 Apache Kafka Properties File의 경로와 이름 |
| `gg.handler.name.Format`                     | N                         | Formatter Class나 Short Code                                 | `delimitedtext`                                              | Payload Formatter(xml, delimitedtext, json, json_row, avro_row, avro_op0 중 택 1) |
| `gg.handler.name.SchemaTopicName`            | (schema delivery is Yes)Y | Schema Topic Name                                            | None                                                         | Schema가 전달될 Topic 이름 Property가 설정되지 않을 시 Schema가 전파되지 않음 Schema는 Avro Formatter에서만 전파 |
| `gg.handler.name.SchemaPrClassName`          | N                         | OGG for Big Data Kafka Handler용CreateProducerRecord Java Interface를 구현하는 사용자 정의 Class의 정규화된 Class 이름 | `구현 Class 제공: oracle.goldengate.handler.kafka``ProducerRecord` | Schema는 ProducerRecord로도 전파됨 PK는 fully qualified table name Schema Record에 대해 변경해야 하는 경우 CreateProducerRecord Interface의 사용자 정의 구현을 작성해 이 Property가 새 Class의 정규화된 이름을 가리키도록 설정 |
| `gg.handler.name.mode`                       | N                         | `tx`/`op`                                                    | `tx`                                                         | Kafka Handler Operation Mode를 사용하면 각 Change Capture Data Record(INSERT, UPDATE, DELETE 등) Payload가 Kafka Producer Record로 표시되고 한번에 하나씩 FlushKafka Handler Transaction Mode를 사용하면 Source Transaction 내의 모든 Operation이 하나의 Kafka Producer Record로 표시이 결합된 Byte Payload는 Transaction Commit Event에서 Flush |
| `gg.hander.name.logSuccessfullySentMessages` | N                         | `true` | `false`                                             | `true`                                                       | true로 설정 시 Kafka Handler가 Kafka에 성공적으로 전송된 INFO Level Message를 기록 이 Property를 활성화 할 경우 성능에 부정적 영향을 끼침 |
| `gg.handler.name.metaHeadersTemplate`        | N                         | Comma delimited list of metacolumn keywords.                 | None                                                         | 사용자가 Metacolumn Keyword 구문을 사용해 Context-based Key, Value Pair를 Kafka Message Header에 삽입 할 Metacolumn을 선택할 수 있음 |

#### Java Adapter Properties File

```bash
gg.handlerlist = kafkahandler
gg.handler.kafkahandler.Type = kafka
gg.handler.kafkahandler.KafkaProducerConfigFile = custom_kafka_producer.properties
gg.handler.kafkahandler.topicMappingTemplate=oggtopic
gg.handler.kafkahandler.keyMappingTemplate=${currentTimestamp}
gg.handler.kafkahandler.Format = avro_op
gg.handler.kafkahandler.SchemaTopicName = oggSchemaTopic
gg.handler.kafkahandler.SchemaPrClassName = com.company.kafkaProdRec.SchemaRecord
gg.handler.kafkahandler.Mode = tx
```

\$OGG_HOME/AdapterExamples/big-data/kafka에서 Sample들 확인 가능

#### Kafka Producer Configuration File

Kafka Handler는 Kafka에 Message를 게시하기 위해 Kafka Producer Configuration File에 Access해야 함
Kafka Producer Configuration File 이름은 Kafka Handler Property의 다음 Configuration에 의해 제어

```bash
gg.handler.kafkahandler.KafkaProducerConfigFile=custom_kafka_producer.properties
```

Kafka Handler는 Java Classpath를 사용해 Kafka Producer Configuration File을 찾고 Load하려 시도
Java Classpath에는 Kafka Producer Configuration File이 포함된 Directory가 포함되어야 함

Kafka Producer Configuration File에는 Kafka 독점 Property들이 포함되어 있음
Kafka 문서에 0.8.2.0 Kafka Producer Interface Property들에 대한 Configuration 정보를 제공해야 함
Kafka Handler는 이런 속성을 사용해 Kafka Broker의 Host와 Port를 확인해 Kafka Producer Configuration File의 Property들은 Kafka Producer Client와 Kafka Broker 간 상호 작용 동작을 제어

```bash
bootstrap.servers=localhost:9092
acks = 1
compression.type = gzip
reconnect.backoff.ms = 1000
value.serializer = org.apache.kafka.common.serialization.ByteArraySerializer
key.serializer = org.apache.kafka.common.serialization.ByteArraySerializer
# 100KB per partition
batch.size = 102400
linger.ms = 0
max.request.size = 1048576
send.buffer.bytes = 131072
```

#### Template을 사용해 Topic 이름과 Message Key 해결

Kafka Handler는 Template Configuration 값을 사용해 Runtime에 Topic 이름과 Message Key를 확인하는 기능을 제공
Template을 사용해 Static Value와 Keyword로 Configuration 가능

##### Template Mode

Source DB Transaction은 개별 INSERT, UPDATE, DELETE인 하나 이상의 개별 Operation으로 Configuration
Kafka Handler는 Operation(INSERT, UPDATE, DELETE) 당 하나의 Message를 보내도록 Configuration하거나 Transaction Level에서 Operation을 Message로 Grouping 해 Configuration할 수 있음
다수의 Template Keyword는 개별 Source DB Operation의 Context-Based로 Data를 확인
Transaction Level에서 Message를 보낼 때 많은 Keyword가 동작하지 않음 
예로 Trnasaction Level에서 Message를 보낼 때 \${fullyQualifiedTableName}을 사용하는 것이 작동하지 않고 Operation에 대한 정규화된 Source Table 이름으로 확인
하지만 Transaction에 많은 Source Table에 대한 여러 Operation이 포함될 수 있음
Transaction Level에서 Message의 정규화된 Table 이름을 확인하는 것은 결정적이지 않으므로 Runtime에 ABENDED로 ERROR

#### Kerberos로 Kafka Configuration

아래 단계대로 작성해 Kerberos가 있는 Kafka Handler Replicat을 Configuration해 Cloudera Instance가 Kafka Topic에 대한 OGG for Bigdata Trail을 추적할 수 있도록 처리

1.  GGSCI에서 ADD Replicat
    ```ggsci
    GGSCI> add replicat kafka, exttrail dirdat/gg
    ```

2.  prm File의 아래 Property들을 Configuration
    ```sql
    replicat kafka
    discardfile ./dirrpt/kafkax.dsc, purge
    SETENV (TZ=PST8PDT)
    GETTRUNCATES
    GETUPDATEBEFORES
    ReportCount Every 1000 Records, Rate
    MAP qasource.*, target qatarget.*;
    ```

    

3.  Replicat Properties File을 아래와 같이 Configuration
    ```bash
    ###KAFKA Properties file ###
    gg.log=log4j
    gg.log.level=info
    gg.report.time=30sec
    ###Kafka Classpath settings ###
    gg.classpath=/opt/cloudera/parcels/KAFKA-2.1.0-1.2.1.0.p0.115/lib/kafka/libs/*
    jvm.bootoptions=-Xmx64m -Xms64m -Djava.class.path=./ggjava/ggjava.jar -Dlog4j.configuration=log4j.properties -Djava.security.auth.login.config=/scratch/ydama/ogg/v123211/dirprm/jaas.conf -Djava.security.krb5.conf=/etc/krb5.conf
    ### Kafka handler properties ###
    gg.handlerlist = kafkahandler
    gg.handler.kafkahandler.type=kafka
    gg.handler.kafkahandler.KafkaProducerConfigFile=kafka-producer.properties
    gg.handler.kafkahandler.format=delimitedtext
    gg.handler.kafkahandler.format.PkUpdateHandling=update
    gg.handler.kafkahandler.mode=op
    gg.handler.kafkahandler.format.includeCurrentTimestamp=false
    gg.handler.kafkahandler.format.fieldDelimiter=|
    gg.handler.kafkahandler.format.lineDelimiter=CDATA[\n]
    gg.handler.kafkahandler.topicMappingTemplate=myoggtopic
    gg.handler.kafkahandler.keyMappingTemplate=${position}
    ```

    

4.  Kafka Producer File을 아래와 같이 Configuration
    ```bash
    bootstrap.servers=10.245.172.52:9092
    acks=1
    #compression.type=snappy
    reconnect.backoff.ms=1000
    value.serializer=org.apache.kafka.common.serialization.ByteArraySerializer
    key.serializer=org.apache.kafka.common.serialization.ByteArraySerializer
    batch.size=1024
    linger.ms=2000
    security.protocol=SASL_PLAINTEXT
    sasl.kerberos.service.name=kafka
    sasl.mechanism=GSSAPI
    ```

5.  jaas.conf File을 아래와 같이 Configuration
    ```bash
    KafkaClient {
    com.sun.security.auth.module.Krb5LoginModule required
    useKeyTab=true
    storeKey=true
    keyTab="/scratch/ydama/ogg/v123211/dirtmp/keytabs/slc06unm/kafka.keytab"
    principal="kafka/slc06unm.us.oracle.com@HADOOPTEST.ORACLE.COM";
    };
    ```

6.  Secured Kafka Topic을 연결하려면 Cloudera Instance의 최신 key.tab File이 있는지 확인

7.  GGSCI에서 Replicat을 실행한 후 INFO ALL로 실행 확인

8.  Replicat Report를 확인하며 Processing된 Record 수 확인
    ```bash
    Oracle GoldenGate for Big Data, 12.3.2.1.1.005
    
    Copyright (c) 2007, 2018. Oracle and/or its affiliates. All rights reserved
    
    Built with Java 1.8.0_161 (class version: 52.0)
    
    2018-08-05 22:15:28 INFO OGG-01815 Virtual Memory Facilities for: COM
    anon alloc: mmap(MAP_ANON) anon free: munmap
    file alloc: mmap(MAP_SHARED) file free: munmap
    target directories:
    /scratch/ydama/ogg/v123211/dirtmp.
    
    Database Version:
    
    Database Language and Character Set:
    
    ***********************************************************************
    ** Run Time Messages **
    ***********************************************************************
    
    
    2018-08-05 22:15:28 INFO OGG-02243 Opened trail file /scratch/ydama/ogg/v123211/dirdat/kfkCustR/gg000000 at 2018-08-05 22:15:28.258810.
    
    2018-08-05 22:15:28 INFO OGG-03506 The source database character set, as determined from the trail file, is UTF-8.
    
    2018-08-05 22:15:28 INFO OGG-06506 Wildcard MAP resolved (entry qasource.*): MAP "QASOURCE"."BDCUSTMER1", target qatarget."BDCUSTMER1".
    
    2018-08-05 22:15:28 INFO OGG-02756 The definition for table QASOURCE.BDCUSTMER1 is obtained from the trail file.
    
    2018-08-05 22:15:28 INFO OGG-06511 Using following columns in default map by name: CUST_CODE, NAME, CITY, STATE.
    
    2018-08-05 22:15:28 INFO OGG-06510 Using the following key columns for target table qatarget.BDCUSTMER1: CUST_CODE.
    
    2018-08-05 22:15:29 INFO OGG-06506 Wildcard MAP resolved (entry qasource.*): MAP "QASOURCE"."BDCUSTORD1", target qatarget."BDCUSTORD1".
    
    2018-08-05 22:15:29 INFO OGG-02756 The definition for table QASOURCE.BDCUSTORD1 is obtained from the trail file.
    
    2018-08-05 22:15:29 INFO OGG-06511 Using following columns in default map by name: CUST_CODE, ORDER_DATE, PRODUCT_CODE, ORDER_ID, PRODUCT_PRICE, PRODUCT_AMOUNT, TRANSACTION_ID.
    
    2018-08-05 22:15:29 INFO OGG-06510 Using the following key columns for target table qatarget.BDCUSTORD1: CUST_CODE, ORDER_DATE, PRODUCT_CODE, ORDER_ID.
    
    2018-08-05 22:15:33 INFO OGG-01021 Command received from GGSCI: STATS.
    
    2018-08-05 22:16:03 INFO OGG-01971 The previous message, 'INFO OGG-01021', repeated 1 times.
    
    2018-08-05 22:43:27 INFO OGG-01021 Command received from GGSCI: STOP.
    
    ***********************************************************************
    * ** Run Time Statistics ** *
    ***********************************************************************
    
    
    Last record for the last committed transaction is the following:
    ___________________________________________________________________
    Trail name : /scratch/ydama/ogg/v123211/dirdat/kfkCustR/gg000000
    Hdr-Ind : E (x45) Partition : . (x0c)
    UndoFlag : . (x00) BeforeAfter: A (x41)
    RecLength : 0 (x0000) IO Time : 2015-08-14 12:02:20.022027
    IOType : 100 (x64) OrigNode : 255 (xff)
    TransInd : . (x03) FormatType : R (x52)
    SyskeyLen : 0 (x00) Incomplete : . (x00)
    AuditRBA : 78233 AuditPos : 23968384
    Continued : N (x00) RecCount : 1 (x01)
    
    2015-08-14 12:02:20.022027 GGSPurgedata Len 0 RBA 6473
    TDR Index: 2
    ___________________________________________________________________
    
    Reading /scratch/ydama/ogg/v123211/dirdat/kfkCustR/gg000000, current RBA 6556, 20 records, m_file_seqno = 0, m_file_rba = 6556
    
    Report at 2018-08-05 22:43:27 (activity since 2018-08-05 22:15:28)
    
    From Table QASOURCE.BDCUSTMER1 to qatarget.BDCUSTMER1:
    # inserts: 5
    # updates: 1
    # deletes: 0
    # discards: 0
    From Table QASOURCE.BDCUSTORD1 to qatarget.BDCUSTORD1:
    # inserts: 5
    # updates: 3
    # deletes: 5
    # truncates: 1
    # discards: 0
    ```

9.  Secure Kafka Topic이 생성되었는지 확인
    ```bash
    /kafka/bin/kafka-topics.sh --zookeeper slc06unm:2181 --list   myoggtopic
    ```

10.  Secure Kafka Topir의 Content 확인

     1.  아래와 같이 consumer.properties File을 생성
         ```bash
         security.protocol=SASL_PLAINTEXT sasl.kerberos.service.name=kafka
         ```

     2.  아래와 같이 Environment Variable 설정
         ```bash
         export KAFKA_OPTS="-Djava.security.auth.login.config="/scratch/ogg/v123211/dirprm/jaas.conf"
         ```

     3.  Consumer Utility를 실행해 Record 확인
         ```bash
         /kafka/bin/kafka-console-consumer.sh --bootstrap-server sys06:9092 --topic myoggtopic --new-consumer --consumer.config consumer.properties
         ```

#### Kafka SSL 지원

Kafka는 Kafka Client와 Kafka Cluster 간 SSL 연결을 지원
SSL 연결은 Client와 Server 간 전송되는 Message의 인증 및 암호화를 모두 제공

SSL은 Server Authentication(Client가 Server Authenticate함)용으로 Configuration할 수 있으나 일반적으로 상호 인증(Client와 Server 모두 서로 Authenticate)용으로 Configuration
SSL Mutal Authentication에서 Connection의 각 측은 Keystore에서 Certificate를 검색해 Truststore의 Certificate에 대해 확인하는 Connection의 다른 측으로 전달

SSL을 설정할 때 실행 중인 특정 Kafka Version에 대한 자세한 내용은 Kafka 문서를 확인

-   SSL용 Kafka Cluster 설정
-   Keystore / Truststore File에 자체 서명된 Certificate 생성
-   SSL용 Kafka Client Configuration

Oracle은 OGG for Bigdata와 함께 SSL 연결을 사용하기 전 Kafka Producer와 Consumer Command Line Utility들을 사용해 SSL 연결을 구현할 것을 권장
OGG for Bigdata를 Hosting하는 System과 Kafka Cluster 간 SSL 연결이 확인되어야 함
이 작업은 OGG for Bigdata를 도입하기 전 SSL 연결이 올바르게 설정되고 작동함을 증명

```bash
bootstrap.servers=localhost:9092
acks=1
value.serializer=org.apache.kafka.common.serialization.ByteArraySerializer
key.serializer=org.apache.kafka.common.serialization.ByteArraySerializer
security.protocol=SSL
ssl.keystore.location=/var/private/ssl/server.keystore.jks
ssl.keystore.password=test1234 ssl.key.password=test1234
ssl.truststore.location=/var/private/ssl/server.truststore.jks
ssl.truststore.password=test1234
```

### Schema 전파

Kafka Handler는 Schema Topir에 Schema를 게시하는 기능을 제공
현재 Avro Row와 Operation Formatter는 Schema 게시에 사용할 수 있는 유일한 Formatter
Kafka Handler의 schemaTopicName Property가 설정된 경우 다음 Event에 대해 Schema가 게시

-   특정 Table에 대한 Avro Schema는 해당 Table에 대한 Operation이 처음 발생했을 때 게시

-   Kafka Handler가 Metadata Change Event를 수신할 경우 Schema는 Flush
    특정 Table에 대해 재생성된 Avro Schema는 Flush 후 해당 Table에 대한 Operation이 발생할 때 게시

-   Avro Wrapping 기능이 활성화 된 경우 Operation이 처음 발생할 때 일반 Wrapper Avro Schema가 게시

    일반 Wrapper를 활성화하기 위해 Avro Formatter Configuration에서 Avro Schema 기능을 활성화

    >   [Avro Row Formatter](https://docs.oracle.com/en/middleware/goldengate/big-data/21.1/gadbd/using-pluggable-formatters.html#GUID-3282CC22-92E8-4637-AD8D-E5E3F48BE9F5)
    >
    >   [Avro Operation Formatter](https://docs.oracle.com/en/middleware/goldengate/big-data/21.1/gadbd/using-pluggable-formatters.html#GUID-D77D819B-FDA2-4348-9899-711B50302F96)

Kafka ProducerRecord Value는 Schema, Key는 정규화된 Table 이름

Avro Message는 Avro Schema에 직접 의존하기에 Kafka를 통한 Avro User에게는 문제가 발생할 수 있음
Avro Message는 Binary이기에 사람이 읽을 수 없음
Avro Message를 Deserialize하기 위해 먼저 Receiver에게 올바른 Avro Schema가 있어야 하나 Source Database의 각 Table이 별도의 Avro Schema를 생성하기에 어려울 수 있음
Source OGG Trail File에 여러 Table의 Operation이 포함된 경우 Kafka Message Receiver는 개별 Message를 Deserialize하는 데 사용할 Avro Schema를 결정할 수 없음
이 문제를 해결하기 위해 특수 Avro Message를 일반 Avro Message Wrapper로 Wrap 가능
이 일반 Avro Wrapper는 정규화된 Table 이름, Schema String의 Hash Code와 Wrapping된 Avro Message를 제공
Receiver는 정규화된 Table 이름과 Schema String의 Hash Code를 사용해 Wrapping된 Message의 연결된 Schema를 확인한 후 해당 Schema를 사용해 Wrapped MEssage를 Deserialize할 수 있음

### 성능 고려 사항

성능 향상을 위해 Kafka Handler를 Operation Mode로 동작하도록 권장

Kafka Producer Properties File에서 batch.size와 linger.mg 값을 설정하는 것을 권장
사용 시나리오에 따라 값이 달라짐
일반적으로 값이 높을 수록 처리량이 높아지나 대기 시간이 증가

Replicat Variable인 GROUPTRANSOPS도 성능 향상에 도움이 됨(10000 권장)

Source Trail File의 Serialize된 Operation을 개별 Kafka Message로 전달해야 하는 경우 Kafka Handler를 Operation Mode로 설정해야 함

### Security

Kafka Version 0.9.0.0은 SSL/TLS와 SASL(Kerberos)을 통한 Security 도입
SSL/TLS와 SASL Security Offering 중 하나나 둘 모두 사용해 Kafka Handler를 보호할 수 있음
Kafka Producer Client Library는 해당 Library를 사용하는 동안 통합에서 Security 기능의 추상화를 제공
Security를 활성화하기 위해 Kafka Cluster에 대한 Security를 설정하고 System을 연결한 후 필요한 Security Property로 Kafka Producer Properties File을 Configuration해야 함
Kafka Cluster Securing은 Kafka Document를 참조

keytab File에서 Kerberos Password를 Decrypt 하지 못하는 문제가 발생할 수 있음
이로 인해 Kerberos Authentication이 Programming 방식으로 호출되기에 작동할 수 없는 Interactive Mode로 Fall Back
문제의 원인은 JRE에 JCE가 설치되어 있지 않기 때문

>   [JCE](http://www.oracle.com/technetwork/java/javase/downloads/jce8-download-2133166.html)

### Metadata Change Event

Metadata Change Event는 이제 Kafka Handler에서 처리
Schema Topic을 Configuration했고 사용된 Formatter가 Schema 전파를 지원하는 경우에만 관련 있음(현재 Avro Row & Avro Operation Formatter)
다음에 Schema가 변경된 Table에 대한 Operation이 발생하면 Update된 Schema가 Schema Topic에 게시

Metadata Change Event를 지원하려면 Source Database에서 변경 사항을 Capture하는 OGG Process가 OGG 12.2에 도입된 Trail 기능의 OGG Metadata를 지원해야 함

### Snappy 고려 사항

Kafka Producer Configuration File은 Compression 사용 지원
Configuration 가능한 Option 중 하나는 다른 Codec Library보다 더 나은 성능을 제공하는 Open Source Compression and Decompression(Codec) Library인 Snappy
Snappy JAR는 모든 Platform에서 실행되지 않음
Snappy는 Linux System에서 작동할 수 있으나 UNIX와 Windows에서는 작동하지 않음
Snappy Compression을 사용하기 전 Snappy가 Systme에서 작동하는지 테스트하는 것을 권장
Snappy가 필요한 모든 System에서 Porting되지 않는다면 대체 Codec Library를 사용하는 것을 권장

### Kafka Interceptor 지원

Kafka Producer Client Framework는 Producer Interceptor 사용 지원
Producer Interceptor는 단순히 Kafka Producer Client의 사용자 종료로 Interceptor Object가 Instance화 되고 Kafka Message Send Call과 Kafka Message Send Acknowledgement Call에 대한 알림 수신

Interceptor의 일반적인 사용 사례로는 Monitoring이 있음
Kafka Producer Interceptor는 org.apache.kafka.clients.producer.ProducerIntercpetor Interface를 준수해야 함
Kafka Handler는 Producer Interceptor 사용 지원

Handler에서 Interceptor를 사용하기 위한 요구사항

-   Kafka Producer Configuration Property인 "interceptor.classes"는 호출할 Interceptor의 Class 이름으로 구성되어야 함
-   Interceptor를 호출하려면 JVM에서 JAR File들과 모든 Dependency JAR들을 사용할 수 있어야 함
    Interceptor와 Dependency JAR들을 포함하는 JAR File을 Handler Configuration File의 gg.classpath에 추가해야 함

>   [Kafka Documentation](https://kafka.apache.org/documentation/)

### Kafka Partition 선택

Kafka Topic은 하나 이상의 Partition으로 구성
Kafka Client는 서로 다른 Topic/Partition 조합으로 Message 전송을 Parallelize하므로 Multiple Partition에 대한 Distribution은 Kafka 수집 성능을 개선하는 방법
Partition 선택은 Kafka Client에서 아래 계산에 의해 제어됨

```
(Kafka Message Key의 Hash 값) 계수 (Partition 수) = 선택한 Partition 번호
```

Kafka Message Key는 아래 Configuration Value에 의해 선택

```bash
gg.handler.<name>.keyMappingTemplate=
```

특이점이 없으나 Round-Robin Basis하게 작동시키기 위해서는 아래와 같이 작성
```bash
gg.handler.<name>.keyMappingTemplate=${Null}
```

각 Row에 대한 Operation에는 고유한 PK가 있어야 하므로 각 Row에 대한 Kafka Message Key를 생성
또 다른 중요한 고려 사항은 **다른 Partition으로 전송된 Kafka Message가 전송된 순서대로 Kafka Consumer에게 전달된다는 보장이 없다**는 것
위 전달 순서 보장에 대한 내용은 Kafka 사양 중 하나
순서는 **Partition 내에서만 유지
**PK를 Kafka Message Key로 사용한다는 것은 PK가 동일한 Row에 대한 Operation은 동일한 Kafka Message Key를 생성하므로 동일한 Kafka Partition으로 전송됨을 의미
이로 인해 동일한 Row에 대한 Operation의 순서가 유지

DEBUG Log Level에서 Kafka Message Coordinate(Topic, Partition, Offset)는 성공적으로 전송된 Message에 대해 .log File에 기록

### Troubleshooting

#### Kafka 설정 확인

Command Line Kafka Producer를 사용해 Dummy Data를 Kafka Topic에 쓸 수 있고 Kafka Consumer를 사용해 Kafka Topic에서 Data를 읽을 수 있음

#### Classpath Issue

Java Classpath 문제는 자주 일어나며 log4j Log File의 ClassNotFoundException 문제를 포함하거나 gg.classpath Variable의 Typographic Error로 인해 Classpath를 해결하는 오류일 수 있음
Kafka Client Library는 OGG for Bigdata에 포함되어 있지 않아 직접 설치 후 gg.classpath Property에 설정해줘야 함

#### 지원하지 않는 Kafka Version

Kafka Handler는 Kafka Version 0.8.2.2 이하를 지원하지 않음
지원하지 않는 Version의 Kafka를 실행할 경우 Runtime Java Exception인 java.lang.NoSuchMethodError가 발생
org.apache.kafka.clients.producer.KafkaProducer.flush() Method를 찾을 수 없음을 의미
이 오류 발생 시 Kafka Version 0.9.0.0 이상으로 Migration 하면 해결

####  Kafka Producer Properties File을 찾을 수 없음

```java
ERROR 2015-11-11 11:49:08,482 [main] Error loading the kafka producer properties
```

위와 같은 에러 발생 시 gg.handler.<name>.KafkaProducerConfigFile Configuration Variable을 확인해 올바르게 설정 되었는지 확인
gg.classpath Variable을 확인해 Classpath에 Kafka Properties File에 대한 경로가 포함되어 있고 Configuration File에 대한 경로 끝에 *(Wild Card)가 포함되어 있지 않은 지 확인

#### Kafka Connection 문제

```java
WARN 2015-11-11 11:25:50,784 [kafka-producer-network-thread | producer-1] WARN  (Selector.java:276) - Error in I/O with localhost/127.0.0.1
java.net.ConnectException: Connection refused
```

Connection Retry Interval이 만료되고 Kafka Handler Process가 ABENDED
Kafka Broker가 실행 중이고 Kafka Producer Properties File에 제공된 Host와 Port가 올바른 지 확인
Kafka Broker를 Hosting하는 System에서 Network Shell Command(netstat -l)를 사용해 Kafka가 예상 Port에서 수신 대기 중인지 확인 가능

### Kafka Handler Dependencies

Kafka Handler가 Apache Kafka Database에 연결하기 위한 Dependency들을 확인

-   Maven GroupID: org.apache.kafka
-   Maven AtifactID: kafka-clients
-   Maven Version: 아래 리스트 참조

#### Kafka 2.8.0

```
kafka-clients-2.8.0.jar
lz4-java-1.7.1.jar
slf4j-api-1.7.30.jar
snappy-java-1.1.8.1.jar
zstd-jni-1.4.9-1.jar
```

#### Kafka 2.7.0

```
kafka-clients-2.7.0.jar
lz4-java-1.7.1.jar
slf4j-api-1.7.30.jar
snappy-java-1.1.7.7.jar
zstd-jni-1.4.5-6.jar
```

#### Kafka 2.6.0

```
kafka-clients-2.6.0.jarlz4-java-1.7.1.jarslf4j-api-1.7.30.jarsnappy-java-1.1.7.3.jarzstd-jni-1.4.4-7.jar
```

#### Kafka 2.5.1

```
kafka-clients-2.5.1.jar
lz4-java-1.7.1.jar
slf4j-api-1.7.30.jar
snappy-java-1.1.7.3.jar
zstd-jni-1.4.4-7.jar
```

#### Kafka 2.4.1

```
kafka-clients-2.4.1.jar
lz4-java-1.6.0.jar
slf4j-api-1.7.28.jar
snappy-java-1.1.7.3.jar
zstd-jni-1.4.3-1.jarr
```

#### Kafka 2.3.1

```
kafka-clients-2.3.1.jar
lz4-java-1.6.0.jar
slf4j-api-1.7.26.jar
snappy-java-1.1.7.3.jar
zstd-jni-1.4.0-1.jar
```

## Kafka Connect Handler

### 개요와 세부 기능

[Confluent Open Source Kafka Connector 모음](https://www.confluent.io/product/connectors/)(추후 Debezium PostgreSQL CDC 활용 예정)

Kafka Connect Handler = Kafka Connect Source Connector
이 Handler를 이용해 Oracle EHCS(Event Hub Cloud Services)에 연결 가능

Kafka Connect Handler는 Kafka Handler에서 지원하는 Pluggable Formatter를 지원하지 않음

#### JSON Converter

Kafka Connect Framework는 Memory 내 Kafka Connect Message를 Network를 통한 전송에 적합한 Serialized Format으로 Convert하는 Converter 제공
Converter는 Kafka Producer Properties File의 Property를 사용해 선택

Kafka Connect와 JSON Converter는 Apache Kafka Download의 일부로 사용할 수 있음
JSON Converter는 Kafka의 Key와 Value를 JSON으로 변환한 다음 Kafka의 Topic으로 전송
Kafka Producer Properties File에서 다음 Configuration으로 JSON Converter를 식별

```bash
key.converter=org.apache.kafka.connect.json.JsonConverter
key.converter.schemas.enable=true
value.converter=org.apache.kafka.connect.json.JsonConverter
value.converter.schemas.enable=true
```

Message 형식은 Payload 정보가 뒤에 오는 Message Schema 정보
JSON은 자체 설명 형식이므로 Kafka에 게시된 각 Message에 Schema 정보를 포함하면 안됨

Message에서 JSON Schema 정보를 생략하기 위해 아래와 같이 설정
설정할 경우 Avro의 양식과 유사하게 출력됨

##### `Key.converter.schemas.enable=true`

```json
{
    "schema": {
        "type": "string",
        "optional": false
    },
    "payload": "1_test "
}
```

##### `Key.converter.schemas.enable=false`

```json
"1_test "
```

##### `value.converter.schemas.enable=true`

```json
{
    "schema": {
        "type": "struct",
        "fields": [
            {
                "type": "double",
                "optional": true,
                "field": "TEST_COL_1"
            },
            {
                "type": "string",
                "optional": true,
                "field": "TEST_COL_2"
            },
            {
                "type": "string",
                "optional": true,
                "field": "TEST_COL_3"
            },
            {
                "type": "string",
                "optional": true,
                "field": "TEST_COL_4"
            },
            {
                "type": "string",
                "optional": true,
                "field": "TEST_COL_5"
            },
            {
                "type": "double",
                "optional": true,
                "field": "TEST_COL_6"
            },
            {
                "type": "double",
                "optional": true,
                "field": "TEST_COL_7"
            },
            {
                "type": "double",
                "optional": true,
                "field": "TEST_COL_8"
            }
        ],
        "optional": false,
        "name": "OGGTEST.TEST"
    },
    "payload": {
        "TEST_COL_1": 1,
        "TEST_COL_2": "test ",
        "TEST_COL_3": "test",
        "TEST_COL_4": "2023-04-03 17:22:27.000000000",
        "TEST_COL_5": "2023-04-03 17:22:27",
        "TEST_COL_6": 0.3,
        "TEST_COL_7": 0.3,
        "TEST_COL_8": 0.3
    }
}
```

##### `value.converter.schemas.enable=false`

```json
{
	"TEST_COL_1": 1,
	"TEST_COL_2": "test ",
	"TEST_COL_3": "test",
	"TEST_COL_4": "2023-04-06 11:32:33.000000000",
	"TEST_COL_5": "2023-04-06 11:32:33",
	"TEST_COL_6": 0.3,
	"TEST_COL_7": 0.3,
	"TEST_COL_8": 0.3
}
```

### Avro Converter

일반적인 Kafka 사용 사례와 같이 Avro Message를 보내는 것은 Deserialize하기 위해 Avro Schema가 필요(없을 시 수신 측 문제 발생 가능)
Schema는 정확히 Message를 생성한 Avro Schema와 일치해야 하기 때문에 문제 발생이 증가할 수 있음
잘못된 Avro Schema로 Avro Message를 Deserialize하면 Runtime Error, 불완전하거나 잘못된 데이터가 발생 가능
Confluent는 Schema Registry와 Confluent Schema Converter를 사용해 이 문제를 해결

아래는 Kafka Producer Propertie File의 Configuration으로 Avro Converter를 식별

```bash
key.converter=io.confluent.connect.avro.AvroConverter
value.converter=io.confluent.connect.avro.AvroConverter
key.converter.schema.registry.url=http://localhost:8081
value.converter.schema.registry.url=http://localhost:8081 
```

Message가 Kafka에 게시되면 Avro Schema가 등록되어 Schema Registry에 저장
Kafka에서 Message를 사용할 때 Message를 생성하는 데 사용된 정확한 Avro Schema를 Schema Registry에서 검색해 Avro Message를 Deserialize할 수 있음
이렇게 할 시 수신 측도 Avro Message를 해당 Avro Schema와 일치시켜 이 문제를 해결

아래는 Avro Converter를 사용하기 위한 요구 사항

-   Confluent Kafka 사용(Open Source or Enterprise)
-   Confluent Schema Registry Service가 실행 중
-   Source DB Table에는 연결된 Avro Schema가 있어야 함(다른 Avro Schema와 연결된 Message는 다른 Kafka Topic으로 전송되어야 함)
-   Confluent Avro Converter와 Schema Registry Client는 Classpath에서 사용할 수 있어야 함

Schema Registry는 Topic 별 Avro Schema를 추적
동일한 Schema 또는 동일한 Schema의 진화된 버전이 있는 Topic으로 Message를 보내야 함
Source Message에는 Source DB Table Schema를 기반으로 하는 Avro Schema가 있으므로 Avro Schema는 각 Source Table에 대해 고유함
여러 Source Table에 대해 한 Topic에 Message를 게시하면 이전 Message와 다른 Source Table에서 Message가 전송될 때마다 Schema가 진화하는 Schema Registry에 표시

### Protobuf Converter

Protobuf Converter를 사용하면 Kafka Connect Message를 Google Protocol Buffer Format으로 형형식화 가능
Protobuf Converter는 Confluent Schema Registry와 통합되며 이 기능은 Confluent의 Open Source와 Enterprize 버전 모두에서 사용 가능
Confluent Version 5.5.0 부터 Protobuf Converter를 추가

```bash
key.converter=io.confluent.connect.protobuf.ProtobufConverter
value.converter=io.confluent.connect.protobuf.ProtobufConverter
key.converter.schema.registry.url=http://localhost:8081
value.converter.schema.registry.url=http://localhost:8081
```

아래는 Protobuf Converter를 사용하기 위한 요구 사항

-   5.5.0 이상의 Confluent Kafka
-   Confluent Schema Registry Service 실행 중
-   Schema(Source Table)가 다른 Message는 다른 Kafka Topic으로 전송
-   Confluent Protobuf Converter와 Schema Registry Client는 Classpath에서 사용할 수 있어야 함

Schema Registry는 Topic 별 Protobuf Schema를 추적
동일한 Schema나 Schema의 진화형이 있는 Topic으로 Message를 보내야 함
Source Message에는 Source Database Table Schema 기반으로 하는 Protobuf Schema가 있으므로 Protobuf Schema는 각 Source Table에 대해 고유함
여러 Source Table에 대해 한 Topic에서 Message를 게시하면 이전 Message와 다른 Source Table에서 Message가 전송될 때마다 Schema가 진화하는 Schema Registry에 표시 

###  Kafka Connect Handler 설정과 실행

#### Classpath Configuration

Kafka Connect Handler가 Kafka에 연결과 실행할 수 있도록 `gg.classpath`에 두 가지를 Configuration해야 함
필수 항목은 Kafka Producer Properties File과 Client JAR File이며 Kafka Client JAR는 Kafka Connect Handler가 연결하는 Kafka 버전과 일치해야 함

>   [Kafka Connect Handler Client Dependencies](https://docs.oracle.com/en/middleware/goldengate/big-data/19.1/gadbd/kafka-connect-handler-client-dependencies.html#GUID-A3C18E49-9867-44DE-A202-EC685BB32D42)

Kafka Producer Properties File 저장 위치의 권장 경로는 $OGG_HOME/dirprm

Kafka Connect Client JAR 기본 경로는 $KAFKA_HOME/libs/*

`gg.classpath`는 정확히 Configuration되어야 함
Kafka Producer Properties File에 대한 경로에는 *(Wildcard, Asterisk)가 추가되지 않은 경로가 포함되어야 함
Kafka Producer Properties File의 경로에 *r가 포함되면 File이 Discard(버리다, 제거하다: 의미가 정확하지 않아 영단어를 그대로 작성)됨
Dependency JAR에 대한 경로 지정에는 *를 사용해 관련 Classpath에 해당 Directory에 있는 모든 JAR File을 포함해야 함(*.jar는 사용 불가)

```bash
`gg.classpath`=dirprm:{kafka_install_dir}/libs/*
```

#### Kafka Connect Handler Configuration

생성된 Kafka Connect Message에서 Metacolumn Field의 자동 출력은 OGG for Big Data Release 21.1 부터 제거
Metacolumn Field는 gg.handler.name.metaColumnsTemplate을 사용해 Configuration

이전 버전들의 Default와 똑같이 출력하기 위한 양식: gg.handler.name.metaColumnsTemplate=\${objectname[table]},\${optype[op_type]},\${timestamp[op_ts]},\${currenttimestamp[current_ts]},\${position[pos]}

Pk와 Token 포함: gg.handler.name.metaColumnsTemplate=\${objectname[table]},\${optype[op_type]},\${timestamp[op_ts]},\${currenttimestamp[current_ts]},\${position[pos]},\${primarykeycolumns[primary_keys]},\${alltokens[tokens]}

##### Kafka Connect Handler Configuration Properties

| Properties                                   | `Essential` | Legal Values                                                 | Default | Explanation                                                  |
| :------------------------------------------- | :---------- | :----------------------------------------------------------- | :------ | :----------------------------------------------------------- |
| `gg.handler.name.type`                       | Y           | `kafkaconnect`                                               | None    | Kafka Connect Handler를 선택하기 위한 Configuration          |
| `gg.handler.name.kafkaProducerConfigFile`    | Y           | string                                                       | None    | Kafka와 Kafka Connect Configuration Property들을 포함하는 Properties File의 이름 `gg.classpath` Property로 Configuration된 Classpath의 일부여야 함 |
| `gg.handler.name.topicMappingTemplate`       | Y           | Runtime 시 Kafka Topic 이름을 확인하기 위한 Template String  | None    | [Using Templates to Resolve the Topic Name and Message Key](https://docs.oracle.com/en/middleware/goldengate/big-data/21.1/gadbd/using-kafka-connect-handler.html#GUID-A87CAFFA-DACF-43A0-8C6C-5C64B578D606). |
| `gg.handler.name.keyMappingTemplate`         | Y           | Runtime 시 Kafka Message Key를 확인하기 위한 Template String | None    | [Using Templates to Resolve the Topic Name and Message Key](https://docs.oracle.com/en/middleware/goldengate/big-data/21.1/gadbd/using-kafka-connect-handler.html#GUID-A87CAFFA-DACF-43A0-8C6C-5C64B578D606). |
| `gg.handler.name.includeTokens`              | N           | `true``false`                                                | `false` | 출력 Message에 Map Field를 포함하기 위해 True 설정 Key는 Token, Value는 Token Key와 OGG Source Trail File의 Token Value인 MapFalse로 설정 시 Map 출력하지 않음 |
| `gg.handler.name.messageFormatting`          | N           | `row``op`                                                    | `row`   | 출력 Message가 Modeling되는 방법을 제어 Row 선택 시 출력 Message가 Row로 출력 Op 선택 시 출력 Message가 Operation으로 출력 |
| `gg.handler.name.insertOpKey`                | N           | any string                                                   | `I`     | Insert Operation의 op_type의 값                              |
| `gg.handler.name.updateOpKey`                | N           | any string                                                   | `U`     | Update Operation의 op_type의 값                              |
| `gg.handler.name.deleteOpKey`                | N           | any string                                                   | `D`     | Delete Operation의 op_type의 값                              |
| `gg.handler.name.truncateOpKey`              | N           | any string                                                   | `T`     | Truncate Operation의 op_type의 값                            |
| `gg.handler.name.treatAllColumnsAsStrings`   | N           | `true``false`                                                | `false` | 모든 출력 Field를 String 처리 시 TrueFalse로 설정 시 Handler가 Source Trail File의 해당 Field Type을 가장 적합한 Kafka Connect Data Type으로 Mapping |
| `gg.handler.name.mapLargeNumbersAsStrings`   | N           | `true``false`                                                | `false` | 큰 숫자는 Doubles로 Number Field에 Mapping되나 이는 정밀도가 떨어질 수 있음True로 설정 시 정밀도 유지를 위해 위와 같은 Field가 String으로 Mapping |
| `gg.handler.name.pkUpdateHandling`           | N           | `abendupdatedelete-insert`                                   | `abend` | Modeling Row Message가(gg.handler.name.massageFormatting) Row일 때 적용 가능Update 시 Modeling Operation Message가 Before, After로 전파되는 경우(Op) 해당하지 않음 |
| `gg.handler.name.metaColumnsTemplate`        | N           | 쉼표(,)로 구분된 [Metacolumn Keyword](https://docs.oracle.com/en/middleware/goldengate/big-data/21.1/gadbd/metacolumn-keywords.html#GUID-7231D03B-5470-4E46-9852-C61273D7EEEA) | None    | Template을 나타내는 하나 이상의 Template Value로 Configuration된 쉼표(,)로 구분된 String |
| `gg.handler.name.includeIsMissingFields`     | N           | `truefalse`                                                  | `true`  | extract{column_name}을 포함하려면 True로 설정 Source Trail File에서 Null 값이 실제로 Null인지 누락인지 Downstream Application이 구분할 수 있도록 각 Column에 대해 이 Property를 설정 |
| `gg.handler.name.enableDecimalLogicalType`   | N           | `truefalse`                                                  | `false` | True로 설정 시 Kafka Connect에서 Decimal Logical Type을 활성화 Decimal Logical Type을 활성화할 시 64Bit에 맞지 않는 수도 표현할 수 있음 |
| `gg.handler.name.oracleNumberScale`          | N           | 양의 정수                                                    | 38      | Decimal Logical Type(gg.handler.name.enableDecimalLogicalType = true)일 때만 적용 가능 일부 Source Data Type에는 고정된 Scale이 없음 Kafka Connect Decimal Logical Type에 대해 Scale을 설정해야 함 Metadata에 Scale이 없을 경우 이 Parameter의 값을 사용해 Scale 설정 |
| `gg.handler.name.EnableTimestampLogicalType` | N           | `true|false`                                                 | `false` | True로 설정 시 Kafka Connect Timestap Logical Type을 활성화 Kafka Connect Timestamp Logical Type은 Java Epoch 이후(1970-01-01 00:00:00.000) 경과된 Milli-Second 값 Timestamp Logical Type이 사용되는 경우 Milli-Second 값 이상의 정밀도는 불가능이 Property를 사용 시 gg.format.timestamp Propery를 사용해야 함 |
| `gg.format.timestamp`                        | N           | yyyy-MM-dd HH-mm:ss.SSS                                      | None    | 문자열 형식의 Timestamp 출력을 결정하는 데 사용되는 Timestamp Format String 예시로 **gg.format.timestamp=yyyy-MM-dd HH-mm:ss.SSS**와 같이 사용 가능goldengate.usereixt.timestamp Property가 Configuration File에 설정되어 있지 않은지 확인 위 속성을 설정하면 입력 Timestamp에 필요한 Java Object로 Parsing하는 것을 방지할 수 있음 |
| `gg.handler.name.metaHeadersTemplate`        | N           | 쉼표(,)로 구분된 [Metacolumn Keyword](https://docs.oracle.com/en/middleware/goldengate/big-data/21.1/gadbd/metacolumn-keywords.html#GUID-7231D03B-5470-4E46-9852-C61273D7EEEA) | None    | Template을 나타내는 하나 이상의 Template Value로 Configuration된 쉼표(,)로 구분된 String |
| `gg.handler.name.schemaNamespace`            | N           | Kafka Connector Avro Schema 명명 요구 사항을 위반하지 않는 String | None    | 생성된 Kafka Connect Schema 이름을 제어하는 데에 사용 미설정시 Schema 이름은 정규화된 Source Table 이름과 동일 예시로 Source Table 이름이 QASOURCE.TCUSTMER인 경우 Schema 이름도 QA.SOURCE.TCUSTMER 이 Property을 사용하면 생성된 Schema 이름을 제어 할 수 있음 예시로 이 Property가 com.example.company일 경우 위 예시와 동일한 Source Table 이름이라면 Schema 이름은 com.exmaple.conpany.TCUSTMER |
| `gg.handler.name.enableNonnullable`          | N           | `truefalse`                                                  | `false` | 기본 동작은 생성된 Kafka Connect Schema에서 모든 Field를 Nullable로 설정 True로 설정시 Metadata Provider가 제공한 Metadata에 Configuration된 Nullable Value를 적용 하지만 True로 설정 시 여러 Side Effect가 발생할 수 있음 Field를 Not Null로 설정하면 Field에 유효한 값이 있어야 하나 Field가 Not Null인데 값이 Null 일 경우 Runtime Error가 발생Field를 Not Null로 설정하면 Truncate Operation을 전파할 수 없음. Truncate Operation에는 Field Value가 없어 Field에 대한 값이 Kafka Connect Converter Serialization이 됨Not Null인 Field를 추가하는 Schema 변경으로 인해 Schema Registry에서 Schema 이전 버전과 호환성 Error가 발생 호환성 Error 발생 시 사용자는 Confluent Schema Registry의 호환성 Configuration을 조정하거나 비활성화 해야 함 |

#### Template을 사용해 Topic 이름과 Message Key 해결

Kafka Connect Handler는 Template Configuration 값을 사용해 Runtime에 Topic 이름과 Message Key를 확인하는 기능을 제공
Template을 사용하면 Static Value와 Keyword를 Configuration할 수 있음
Keyword는 현재 Processing Context로 Dynamic하게 대체하는 데 사용

```bash
gg.handler.name.topicMappingTemplate
gg.handler.name.keyMappingTemplate
```

##### Template Mode

Kafka Connect Handler는 Operation Message만 보낼 수 있음
Kafka Connect Handler는 Operation Message를 더 큰 Transaction Message로 Grouping 할 수 있음

>   [Template Keywords](https://docs.oracle.com/en/middleware/goldengate/big-data/21.1/gadbd/template-keywords.html#GUID-742BA6BE-D446-4E21-8E38-7105AC9F5E5E)
>
>   [Example Templates](https://docs.oracle.com/en/middleware/goldengate/big-data/21.1/gadbd/template-keywords.html#GUID-742BA6BE-D446-4E21-8E38-7105AC9F5E5E__GUID-E09AEF9F-FD17-4AF0-A73B-1B876A4C6A40)

###  Kafka Connect Handler에서 Security Configuration

Kafka Version 0.9.0.0은 SSL/TLS나 Kerberos를 통한 Security를 도입
Handler는 SSL/TSL이나 Kerberos를 사용해 보호할 수 있음
Kafka Producer Client Library는 해당 Library를 활용하는 통합에서 Security 기능의 추상화를 제공
Security를 사용하기 위해 Kafka Cluster에 대한 Security를 설정하고 System을 연결한 후 Kafka Handler가 필수 Security Property들과 함께 Processing에 사용하는 Kafka Producer Properties File을 Configuration해야 함

Keytab File에서 Kerberos Password를 Decrypt하지 못하는 문제가 발생할 수 있고 이로 인해 Kerberos Authentication이 Programming 방식으로 호출되기 때문에 작동할 수 없는 Interactive Mode로 Fall Back됨
이러한 문제의 원인은 JRE(Java Runtime Environment)에 JCE(Java Cryptography Extension)가 설치되어 있지 않기 때문

>   [JCE](https://www.oracle.com/java/technologies/javase-jce8-downloads.html)

### Secure Schema Registry에 연결

Kafka Connect의 Customer Topology는 보안이 유지되는 Schema Registry를 포함할 수 있음
Secured Schema Registry에 대한 연결을 위해 Configuration된 Kafka Producer Property들을 설정하는 방법이 아래에 있음

```bash
key.converter.schema.registry.ssl.truststore.location=
key.converter.schema.registry.ssl.truststore.password=
key.converter.schema.registry.ssl.keystore.location=
key.converter.schema.registry.ssl.keystore.password=
key.converter.schema.registry.ssl.key.password=
value.converter.schema.registry.ssl.truststore.location=
value.converter.schema.registry.ssl.truststore.password=
value.converter.schema.registry.ssl.keystore.location=
value.converter.schema.registry.ssl.keystore.password=
value.converter.schema.registry.ssl.key.password=
```

```bash
key.converter.basic.auth.credentials.source=USER_INFO
key.converter.basic.auth.user.info=username:password
key.converter.schema.registry.ssl.truststore.location=
key.converter.schema.registry.ssl.truststore.password=
value.converter.basic.auth.credentials.source=USER_INFO
value.converter.basic.auth.user.info=username:password
value.converter.schema.registry.ssl.truststore.location=
value.converter.schema.registry.ssl.truststore.password=
```

#### Kafka Connect Handler 성능 고려 사항

OGG for Big Data Configuration과 Kafka Producer 모두에 대해 성능에 영향을 미치는 여러 Configuration Property들이 있음

성능에 가장 큰 영향을 미치는 OGG Parameter는 Replicat GROUPTRANSOPS Parameter
GROUPTRANSOPS를 사용하면 Replicat에서 여러 Source Transaction을 단일 Source Transaction으로 Grouping이 가능
Transaction Commit 시 Kafka Connect Handler는 Kafka Producer에서 Flush를 Call해 Write Durability와 Checkpoint를 위해 Message를 Kafka로 Push
Flush Call은 고비용의 Call이기에 Replicat GROUPTRANSOPS 설정을 더 크게 설정하면 Replicat이 Flush Call을 덜 호출해 성능 향상 가능

GROUPTRANSOPS의 Default는 1000dlau 2500, 5000, 10000으로 올려 성능 향상 가능

Op mode gg.handler.kafkaconnect.mode=op Parameter는 Transaction Mode gg.handler.kafkaconnect.mode=tx보다 성능을 향상시킬 수 있음

아래 리스트는 Kafka Producer Property들 중 성능에 영향을 크게 미치는 Parameter

-   `linger.ms`
-   `batch.size`
-   `acks`
-   `buffer.memory`
-   `compression.type`

### Kafka Interceptor 지원

Kafka Producer Client Framework는 Producer Interceptor 사용을 지원
Producer Interceptor는 단순히 Kafka Producer Client의 사용자 종료로 Interceptor Object가 Instance화 되고 Kafka Message 전송 호출과 Kafka Message 전송 승인 호출에 대한 알림을 받음

Interceptor의 일반적인 사용은 Monitoring
Kafka Producer Interceptor는 org.apache.kafka.clients.producer.ProducerInterceptor Interface를 준수해야 함
Kafka Connect Handler는 Producer Interceptor 사용을 지원

Interceptor를 사용하기 위한 요구 사항

-   Kafka Producer Configuration Property인 interceptor.classes가 호출할 Interceptor의 Class 이름으로 Configuration되어야 함
-   Interceptor를 호출하려면 JVM에서 JAR File과 모든 Dependency JAR를 사용할 수 있어야 함
    따라서 Interceptor와 Dependency JAR를 포함하는 JAR File을 Handler Configuration File의 gg,classpath에 추가해야 함

>   [Kafka Documentation](https://kafka.apache.org/documentation/)

### Kafka Partition 선택

Kafka Topic은 하나 이상의 Partition으로 Configuration
Kafka Client는 서로 다른 Topic/Partition 조합으로 Message 전송을 Parallelization하므로 Multiple Partition에 대한 배포는 Kafka 수집 성능을 개선하는 방법 중 하나
Partition Selection은 Kafka Client에서 아래 계산에 의해 제어

(Kafka Message Key의 Hash) Modulus(Partition 수) = 선택한 Partition 번호

Kafka Message Key는 다음 Configuration 값으로 선택

```bash
gg.handler.name.keyMappingTemplate=
```

이 Parameter를 Static Key를 생성하는 값으로 설정 시 모든 Message가 같은 Partition으로 이동

```bash
gg.handler.name.keyMappingTemplate=StaticValue
```

이 Parameter가 드물게 변경하는 Key를 생성하는 값으로 설정하면 Partition 선택이 드물게 변경

```bash
gg.handler.name.keyMappingTemplate=${tableName}
```

Null Kafka Message Key는 Round-Robin 방식으로 Partition에 배포

```bash
gg.handler.name.keyMappingTemplate=${null}
```

OGG 권장 값은 PK

```bash
gg.handler.name.keyMappingTemplate=${primaryKeys}
```

PK로 설정 시 PK가 Key 값인 Kafka Message Key가 생성

각 Row에 대한 Operation에는 Unique한 PK가 있어 각 Row에 대해 고유한 Kafka Message Key를 생성해야 함
다른 고려사항은 **다른 Partition으로 전송된 Kafka Message가 전송된 원래 순서대로 Kafka Consumer에게 전달된다는 보장이 없다**는 것
순서는 Partition 내에서만 유지되므로 PK를 Kafka Message Key로 사용한다는 것은 동일한 Partition(동일한 Key를 가진 동일한 Kafka Message Key를 생성하므로 동일한 Row이자 Partition) 대한 Operation을 의미
요약해 PK를 Kafka Message Key로 사용한다면 순서대로 Kafka Consumer에 전달됨

DEBUG log level에서 Kafka Message Coordinate(Topic, Partion, Offset)는 성공적으로 전송된 Message에 대해 .log File에 기록

### Kafka Connect Handler 문제 해결

#### Kafka Connect Handler용 Java Classpath

Java Classpath 관련 문제는 가장 자수 발생하는 문제 중 하나
Classpath 문제의 로그는 OGG Java `log4j` Log File의 ClassNotFoundException이나 `gg.classpath` Parameter에 입력 오류가 있는 경우

Kafka Client Library는 OGG for Big Data와 함께 제공되지 않으므로 Kafka Client Library의 올바른 Version을 받아 `gg.classpath` Property를 적절히 Configuration해야 함

#### 잘못된 Kafka Version

Kafka Connect는 Kafka 0.9.0.0 Version에서 도입되었으므로 Kafka Connect Handler는 Kafka 0.8.2.2 이하에서 동작하지 않음
Kafka 0.8.2.2 Version과 함께 Kafka Connect를 사용할 경우 일반적으로 Runtime 시 ClassNotFoundException Error 발생

#### Kafka Producer Properties File을 찾을 수 없음

일반적으로 아래와 같은 Error Message가 발생

```java
ERROR 2015-11-11 11:49:08,482 [main] Error loading the kafka producer properties
```

Kafka Producer Properties File에 대한 gg.handler.kafkahandler.kafkaProducerConfigFile Configuration Property가 올바르게 설정되었는지 확인

`gg.classpath` 변수에 Kafka Producer Propertiess File에 대한 경로가 포함되어 있고 Properties File에 대한 경로 끝 *(Wildcard, Asterisk)가 포함되어 있지 않은지 확인

#### Kafka 연결 문제

일반적으로 아래와 같은 Error Message가 발생

```java
WARN 2015-11-11 11:25:50,784 [kafka-producer-network-thread | producer-1]
    
WARN  (Selector.java:276) - Error in I/O with localhost/127.0.0.1  java.net.ConnectException: Connection refused
```

이 경우 연결 재시도 간격이 만료되고 Kafka Connection Handler Process가 Abend됨
Kafka Broker가 실행 중이고 Kafka Producer Properties File에 제공된 Host와 Port가 올바른 지 확인

Network Shell Command를 사용해 Kafka Broker를 Hosting하는 System에서 Kafka가 예상 Port에서 수신 대기 중인지 확인 가능(netstat -l 등)