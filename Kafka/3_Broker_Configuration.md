# Broker Configuration

Kafka 설정은 Property File Format의 Key-Value 쌍을 사용합니다. 설정 값은 File로도 Programming 방식으로도 제공할 수 있습니다.

## Broker Configs

핵심 설정은 아래와 같습니다.

-   `broker.id`
-   `log.dirs`
-   `zookeeper.connect`

Topci Level 설정과 Default Value는 밑에서 자세히 설명합니다,

### `broker.id`

이 Server에서 사용할 Broker ID 값을 설정하지 않으면 Unique한 Broker ID가 생성됩니다.
Zookeeper에서 생성된 Broker ID와 사용자가 설정한 Broker ID의 충돌을 피하기 위해 Broker ID는 `reserved.broker.max.id` + 1 부터 시작합니다.

| Type | Default | Valid Values | Importance | Update Mode |
| ---- | ------- | ------------ | ---------- | ----------- |
| Int  | -1      |              | High       | Read-Only   |

### `log.dir`

Log Data를 보관할 Directory

| Default         | Valid Values | Importance | Update Mode |
| --------------- | ------------ | ---------- | ----------- |
| /tmp/kafka-logs |              | High       | Read-Only   |

### `zookeeper.connect`

Zookeeper Connection String을 지정하며 Format은 `<hostname>:<port>`를 사용합니다.
`host`와 `port`는 Zookeeper Server의 Host와 Port를 의미합니다.
Zookeeper가 Down되었을 때 다른 Zookeeper Node로 Connect를 위해 `<hostname1>:<port1>,<hostname2>:<port2>,...`와 같이 여러 Host를 지정할 수 있습니다.
Zookeeper Connection String에 Zookeeper chroot Path를 넣을 수 있습니다.
chroot Path를 넣을 경우 관련 Data를 해당 Zookeeper Namespace Path 아래 어딘가에 저장합니다.
예시로 chroot Path를 `/chroot/path`로 설정하기 위해 Connection String을 `<hostname1>:<port1>,<hostname2>:<port2>,/chroot/path`로 지정하면 됩니다,

| Type   | Default | Valid Values | Importance | Update Mode |
| ------ | ------- | ------------ | ---------- | ----------- |
| String |         |              | High       | Read-Only   |

### `advertised.host.name`

DEPRECATED: `advertised.listeners`나 `listeners`를 설정하지 않았을 때만 적용됩니다.
이 설정 대신 `advertised.listeners`를 사용하시는 것을 추천드립니다.
Client가 사용할 수 있도록 Zookeeper에 게시할 Hostname, IaaS Environment라면 Broker가 Bind하는 Interface와는 달라야 할 수 있습니다.
이 값을 설정하지 않으면 `host.name` 값을 사용합니다.
그 외는 `java.net.InetAddress.getCanonicalHostName()`이 반환한 값을 사용합니다.

| Type   | Default | Valid Values | Importance | Update Mode |
| ------ | ------- | ------------ | ---------- | ----------- |
| String | Null    |              | High       | Read-Only   |

### `advertised.listeners`

Client가 사용할 Listener `listeners` 설정 Property와 다른 때 사용할 수 있는 Listener입니다.
Client가 사용할 수 있도록 Zookeeper에 게시합니다.
IaaS Environment라면 Broker가 Bind하는 Interface와는 달라야 할 수 있습니다.
이 값이 설정되지 않을 경우 `listeners` 값을 사용합니다.
`listeners`와 달리 Meta Address 0.0.0.0은 유효하지 않고 이 Property에는 중복된 Port가 있을 수 있으므로 다른 Listener의 Address를 노출하도록 구성할 수 있습니다.

| Type   | Default | Valid Values | Importance | Update Mode |
| ------ | ------- | ------------ | ---------- | ----------- |
| String | Null    |              | High       | Per-Broker  |

### `advertised.port`

DEPRECATED: `advertised.listeners`나 `listeners`를 설정하지 않았을 때만 적용됩니다.
이 설정 대신 `advertised.listeners`를 사용하시는 것을 추천드립니다.
Client가 사용할 수 있도록 Zookeeper에 게시할 Port, IaaS Environment라면 Broker가 Bind하는 Interface와는 달라야 할 수 있습니다.
이 값을 설정하지 않으면 Broker가 Binding하는 Port와 동일한 Port를 게시합니다.

| Type   | Default | Valid Values | Importance | Update Mode |
| ------ | ------- | ------------ | ---------- | ----------- |
| String | Null    |              | High       | Read-Only   |

### `auto.create.topics.enable`

Server에서 Topic Auto Create를 활성화합니다.

| Type    | Default | Valid Values | Importance | Update Mode |
| ------- | ------- | ------------ | ---------- | ----------- |
| Boolean | True    |              | High       | Read-Only   |

### `auto.leader.rebalance.enable`

Auto Leader Balancing을 활성화합니다.
Background Thread에서 `leader.imbalance.check.interval.seconds`로 설정한 주기적인 Interval에 따라 Partition Leader Imbalance 수치가 `leader.imbalance.per.broker.percentage`를 초과하면 해당 Partition에 대해 선호하는 Leader로 Leader Rebalancing을 Trigger합니다.

| Type    | Default | Valid Values | Importance | Update Mode |
| ------- | ------- | ------------ | ---------- | ----------- |
| Boolean | True    |              | High       | Read-Only   |

### `background.threads`

여러 Background Processing Task에 사용할 Thread 수입니다.

| Type | Default | Valid Values | Importance | Update Mode  |
| ---- | ------- | ------------ | ---------- | ------------ |
| Int  | 10      | [1, ...]     | High       | Cluster-Wide |

### `compression.type`

주어진 Topic에 사용할 최종 Compression Type을 지정합니다.
이 설정은 Standard Compression Codec(`gzip`, `snappy`, `lz4`, `zstd`)을 허용하며 그 외 Compression 하지 않음을 나타내는 `uncompressed`, Producer가 설정한 기존 Compression Codec을 유지함을 나타내는 `producer`를 사용할 수 있습니다.

| Type   | Valid Values | Importance | Update Mode  |
| ------ | ------------ | ---------- | ------------ |
| String |              | High       | Cluster-Wide |

### `control.plane.listener.name`

Controller와 Broker 간 통신에 사용할 Listener Name이며 Broker는 이 값을 통해 Listener List에서 전용 End Point를 찾아 Controller의 Connection을 Listen합니다.
예로 아래의 설정을 확인하겠습니다.

```bash
listeners = INTERNAL://192.1.1.8:9092, EXTERNAL://10.1.1.5:9093,
CONTROLLER://192.1.1.8:9094
listener.security.protocol.map = INTERNAL:PLAINTEXT, EXTERNAL:SSL, CONTROLLER:SSL
control.plane.listener.name = CONTROLLER
```

위 브로커는 Security Protocol `SSL`을 사용해 `192.1.1.8:9094`에서 Listen을 시작합니다.
Controller에선 Zookeeper를 통해 게시된 Broker의 End Point를 발견하면 이 설정 값으로 전용 End Point를 찾아 Broker에 대한 Connection을 구축합니다.
아래의 예처럼 Broker의 End Point가 설정되어 있고,

```bash
"endpoints" : ["INTERNAL://broker1.example.com:9092", "EXTERNAL://broker1.example.com:9093", "CONTROLLER://broker1.example.com:9094"]
```

Controller의 설정은 아래의 예와 같다면

```bash
listener.security.protocol.map = INTERNAL:PLAINTEXT, EXTERNAL:SSL, CONTROLLER:SSL
control.plane.listener.name = CONTROLLER
```

Controller는 Security Protocol `SSL`과 `broker1.example.comL:9094`를 사용해 Broker와 연결하게 됩니다.
이 설정을 명시하지 않을 경우 Default 값은 Null이며 Controller Connection을 위한 전용 End Point를 사용하지 않습니다.

| Type   | Default | Valid Values | Importance | Update Mode |
| ------ | ------- | ------------ | ---------- | ----------- |
| String | Null    |              | High       | Read-Only   |

### `delete.topic.enable`

Topic 삭제를 활성화합니다. 이 설정을 끌 시 Admin Tool에서 Topic을 삭제해도 실제로 지워지지 않습니다.

| Type    | Default | Valid Values | Importance | Update Mode |
| ------- | ------- | ------------ | ---------- | ----------- |
| Boolean | True    |              | High       | Read-Only   |

### `host.name`

DEPRECATED: `listeners`를 설정하지 않았을 때만 적용됩니다.
이 설정 대신 `listeners`를 사용하는 것을 추천드립니다.
Broker의 Host Name이며 설정하면 이 Address로만 Binding합니다.
설정하지 않으면 모든 Interface에 Binding합니다.

| Type   | Default | Valid Values | Importance | Update Mode |
| ------ | ------- | ------------ | ---------- | ----------- |
| String | ""      |              | High       | Read-Only   |

### `leader.imbalance.check/interval.seconds`

Controller가 Partition Rebalancing 검사를 Trigger할 주기입니다.

| Type | Default | Valid Values | Importance | Update Mode |
| ---- | ------- | ------------ | ---------- | ----------- |
| Long | 300     |              | High       | Read-Only   |

### `leader.imbalance.per.broker.percentage`

Broker 하나 당 허용하는 Leader imbalance 비율입니다.
Broker 당 수치가 이 값을 초과할 시 Controller가 Leader Rebalance를 Trigger합니다.
값은 백분율입니다.

| Type | Default | Valid Values | Importance | Update Mode |
| ---- | ------- | ------------ | ---------- | ----------- |
| Int  | 10      |              | High       | Read-Only   |

### `listeners`

URI와 Listener Name의 List이며 `,`로 구분합니다.
Listener Name이 Security Protocol이 아니라면, `listener.security.protocol.map`을 함께 설정해야 합니다.
Listenr Name과 Port는 Unique해야 합니다.
모든 Interface에 Bind 하려면 Host Name을 0.0.0.0으로 지정해야 합니다.
Default Interface와 Binding하려면 Host Name을 비우면 됩니다.
아래는 예시입니다.

```bash
PLAINTEXT://myhost:9092,SSL://:9091
CLIENT://0.0.0.0:9092,REPLICATION://localhost:9093
```

| Type   | Default | Valid Values | Importance | Update Mode |
| ------ | ------- | ------------ | ---------- | ----------- |
| String | Null    |              | High       | Per-Broker  |

### `logs.dirs`

Log Data를 보관할 Directory들이며 설정하지 않을 시 `log.dir`에 있는 값을 사용합니다.

| Default | Valid Values | Importance | Update Mode |
| ------- | ------------ | ---------- | ----------- |
| Null    |              | High       | Read-Only   |

### `log.flush.interval.messages`

Message를 Disk로 Flush하기 전 Log Partition에 누적할 Message 수입니다.

| Type | Default             | Valid Values | Importance | Update Mode  |
| ---- | ------------------- | ------------ | ---------- | ------------ |
| Long | 9223372036854775807 | [1, ...]     | High       | Cluster-Wide |

### `log.flush.interval.ms`

모든 Topic의 Message를 Disk로 Flush하기 전 Memory에 보관할 최대 시간(ms)입니다.
설정하지 않을 시 `log.flush.scheduler.interval.ms`값을 사용합니다.

| Type | Default | Valid Values | Importance | Update Mode  |
| ---- | ------- | ------------ | ---------- | ------------ |
| Long | Null    |              | High       | Cluster-Wide |

### `log.flush.scheduler.interval.ms`

Log Flusher가 Disk로 Flush할 Log가 있는지 확인하는 주기(ms)입니다.

| Type | Default             | Valid Values | Importance | Update Mode |
| ---- | ------------------- | ------------ | ---------- | ----------- |
| Long | 9223372036854775807 |              | High       | Read-Only   |

`log.flush.start.offset.checkpoint.interval.ms`

Start Log Offset을 저장하는 Persistent Record를 Update할 주기(ms)입니다.

| Type | Default   | Valid Values | Importance | Update Mode |
| ---- | --------- | ------------ | ---------- | ----------- |
| Int  | 60000(1m) |              | High       | Read-Only   |

### `log.retention.bytes`

Log를 유지할 최대 Size로 이 값을 초과하면 Log를 삭제합니다.

| Type | Default | Valid Values | Importance | Update Mode  |
| ---- | ------- | ------------ | ---------- | ------------ |
| Long | -1      |              | High       | Cluster-Wide |

### `log.retention.hours`

Log File을 유지할 기간(h)으로 이 기간이 지나면 삭제합니다.
`log.retention.ms` Property의 다음 다음 후보로 사용하는 설정입니다.

| Type | Default | Valid Values | Importance | Update Mode |
| ---- | ------- | ------------ | ---------- | ----------- |
| Int  | 168     |              | High       | Read-Only   |

### `log.retention.minutes`

Log File을 유지할 기간(m)으로 이 기간이 지나면 삭제합니다.
`log.retention.ms` Property의 다음 후보로 사용하는 설정입니다.

| Type | Default | Valid Values | Importance | Update Mode |
| ---- | ------- | ------------ | ---------- | ----------- |
| Int  | Null    |              | High       | Read-Only   |

### `log.retention.ms`

Log File을 유지한 기간(ms)으로 이 기간이 지나면 삭제합니다.
값을 설정하지 않을 시 `log.retention.minutes`값을 사용합니다.
-1로 설정할 시 시간 제한을 적용하지 않습니다.

| Type | Default | Valid Values | Importance | Update Mode  |
| ---- | ------- | ------------ | ---------- | ------------ |
| Long | Null    |              | High       | Cluster-Wide |

### `log.roll.hours`

새 Log Segment를 Roll Out하기 전까지의 최대 기간(h)입니다.
`log.roll.ms` Property 다음으로 사용하는 값입니다.

| Type | Default | Valid Values | Importance | Update Mode |
| ---- | ------- | ------------ | ---------- | ----------- |
| Int  | 168     | [1, ...]     | High       | Read-Only   |

### `log.roll.jitter.hours`

최대 Jitter 기간(h)으로 logRollTimeMillis에서 이 값을 뺍니다.
`log.roll.jitter.ms` Property 다음으로 사용하는 값입니다.

| Type | Default | Valid Values | Importance | Update Mode |
| ---- | ------- | ------------ | ---------- | ----------- |
| Int  | 0       | [0, ...]     | High       | Read-Only   |

### `log.roll.jiter.ms`

최대 Jitter 기간(ms)으로 logRollTimeMillis에서 이 값을 뺍니다.
값을 지정하지 않으면 `log.roll.jitter.hours`에 있는 값을 사용합니다.

| Type | Default | Valid Values | Importance | Update Mode  |
| ---- | ------- | ------------ | ---------- | ------------ |
| Long | Null    |              | High       | Cluster-Wide |

### `log.roll.ms`

새 Log Segment를 Roll Out하기 전까지의 최대 기간(ms)입니다.
값을 지정하지 않으면 `log.roll.hours`에 있는 값을 사용합니다.

| ype  | Default | Valid Values | Importance | Update Mode  |
| ---- | ------- | ------------ | ---------- | ------------ |
| Long | Null    |              | High       | Cluster-Wide |