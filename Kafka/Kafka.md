# Kafka란

분산 Transaction Log로 구성된 확장 가능한 Pub.Sub Message Queue

Zookeeper, Broker, Consumer, Producer, Consumer로 구성

Sink Connector / Source Connecter

토리맘 Apach Kafka!!!

Oracle 공식 홈페이지에도 JDBC Sink Connecter 확인

Confluent Developer

Sink Connector 전 Worker를 실행함

Worker는 Sink Connector를 실행시키는 기반과 같다

AvroConverter, JsonConverter, String Converter

Sink Connector

Oracle Golden Gate

Converter 종류에 따라 Sink Connector의 옵션 종류가 달라짐

Tombstone



SASL_SSL : GSSAPI, PLAIN

Schema Registry를 쓰다가 막히면 버전을 바꿔야 함

-   Apache Kafka
-   Confluent Kafka
    -   Basic -> Apache랑 큰 차이 없음
    -   Zookeeper 없는 것
    -   SASL
        -   PLAIN
        -   KBRS
        -   SLARM(?)
    -   SSL/TLS
    -   Multi-Broker
    -   Schema Registry(Apache가 안됨)
-   AKHQ(8) -> Docker
-   AWS Cloud Kafka
-   Confluent Cloud Kafka

https://docs.confluent.io/platform/current/platform-quickstart.html#quick-start-for-cp