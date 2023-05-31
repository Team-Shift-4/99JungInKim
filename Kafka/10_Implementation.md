# Network Layer

Network Layer는 직관적인 NIO Server입니다.
Sendfile은 `MessageSet` Interface에 `writeTo` Method를 제공하는 식으로 구현됐습니다.
이렇게 하면 Process에 전송할 Data를 Buffering하지 않고 대신 File에 저장된 Message Set을 사용해 효율적인 `transferTo`를 활용할 수 있습니다.
Threading Model은 Single Acceptor Thread와 각각 Connection을 고정된 수만큼 처리하는 N개의 Processor Thread입니다.
구현이 빠르고 간단하며 유지에도 이점이 있어 향후 다른 언어로도 Client를 구현할 수 있습니다.

*NIO(New Input/Output) Server: 집약적인 I/O 작업을 위한 기능을 제공하는 Java Programming Language API 모음입니다.
기존 Standard I/O를 보완하기 위해 Sun Microsystems에서 Java의 J2SE 1.4 Release와 함께 도입되었습니다.

# Messages

Message는 가변 길이 Header와 특정 구조를 강제하지 않는(opaque) 가변 길이의 Key Byte Array, Value Byte Array로 구성됩니다.
Header형식은 아래 Message Format에서 설명합니다.
Key와 Value는 직렬화 Library에서 많은 것들이 개선되고 있으며 특정 Value를 선택하게 되면 모든 용도로 활용하기 어렵기에 특정 구조를 미리 정의하지 않았습니다.
Kafka를 사용하는 Application은 특정 직렬화 Type을 지정할 수 있습니다.
Record Batch Interface는 Message에 사용할 수 있는 Iterator로 NIO Channel에서 Bulk로 Read/Write를 수행하기 위한 특수 Method를 가지고 있습니다.

# Message Format

Message(Record)는 항상 Batch로 Write됩니다. Message Batch Processing을 기술적으로 표현하면 Record Batch라고 하며 Record Batch는 하나 이상의 Record를 가집니다.
구버전에서 Record를 하나만 가진 Record Batch가 있을 수 있습니다.
Record Batch와 Record엔 자체 Header가 있습니다.

## Record Batch

다음은 RecordBatch의 Disk Storage Format입니다.

```
baseOffset: int64
batchLength: int32
partitionLeaderEpoch: int32
magic: int8 (current magic value is 2)
crc: int32
attributes: int16
	bit 0~2:
		0: no compression
		1: gzip
		2: snappy
		3: lz4
		4: zstd
    bit 3: timestampType
    bit 4: isTransactional (0 == not Transactional)
    bit 5: isControlBatch (0 == not a control batch)
    bit 6~15: unused
lastOffsetDelta: int32
firstTimestamp: int64
maxTimestamp: int64
producerId: int64
producerEpoch: int16
baseSequence: int32
records: [Record]
```

Compression을 활성화하면 Compressed Record Data를 Record 수에 따라 그대로 직렬화합니다.

`crc`는 Attribute부터 Batch 끝까지 있는 Data를 Cover합니다.(`crc` 뒤 나오는 모든 Byte)
`crc`는 `magic` Byte 뒤에 나옵니다.
따라서 Client는 `batchLength`와 `magic` Byte 사이에 있는 Byte를 어떻게 해석할 지 결정하기 전 먼저 `magic` Byte를 Parsing해야 합니다. 
`partitionLeaderEpoch` Field는 CRC 계산에 포함하지 않는데 Broker가 받는 Batch마다 이 Field를 매번 할당하면 CRC를 다시 계산해야 하기 때문입니다.
계산에는 CRC-32C(Castagnoli) 다항식을 사용합니다.

Compression 시: 이전 Message Format과 달리 magic v2 이상에서는 Log를 정리해도 기존 Batch의 첫 번째와 마지막 Offset/Sequence Number를 유지합니다.
Log를 다시 Load할 때 Producer는 `OutOfSequence` Error를 만날 수 있습니다.
중복을 확인하기 위해 Base가 될 Sequence Number를 보존해야 합니다(Broker는 Produce 요청을 받으면 요청으로 받은 Batch의 첫 번째와 마지막 Sequence Number를, 해당 Producer의 마지막 Sequence Number와 비교해 중복을 체크합니다.).
결론은 Batch안에 있는 모든 Record를 정리하고서도 Producer의 마지막 Sequence Number를 유지하기 위해 Batch를 남겨뒀다면 Log에 빈 Batch가 있을 수 있습니다.
특이한 유의사항으론 `firstTimestamp` Field는 Compression 중 보존되지 않아 Compression할 때 Batch의 첫 Record가 사라지면 변경됩니다.

### Control Batches

Control Batch에는 Control Record라 부르는 Single Record가 들어있습니다.
Control Record는 Application에 전달되지 않습니다.
Consumer가 중단된 Transaction Message를 Filtering하는 데 사용합니다.

Control Record의 Key는 아래 Schema를 따릅니다.

```
version: int16 (current version is 0)
type: int16 (0 indivates an abort marker, 1 indicates a commit)
```

Control Record에 Value에 대한 Schema는 Type에 따라 다릅니다.
이 값은 Client에서는 알아볼 수 없습니다.

## Record

Record Level Header는 Kafka 0.11.0에서 도입되었습니다.
Header를 사용하는 Record의 Disk Storage Format은 아래 예시를 참고하시면 좋습니다.

```
length: varint
attributes: int8
	bit 0~7: unused
timestampDelta: varint
offsetDelta: varint
keyLength: varint
key: byte[]
valueLen: varint
value: byte[]
Headers => [Header]
```

### Record Header

```
headerKeyLength: varint
headerKey: String
headerValueLength: varint
Value: byte[]
```

Protobuf와 동일한 `varint` Encoding을 사용합니다.

`varint` Encoding

```
0000 0001
^ Most Significant Bit
```

Most Significant Bit가 1일 경우 이후 Byte 사용하며 0일 경우 마지막 Byte란 뜻입니다.
아래에 예시를 붙여 설명하겠습니다.

```
# 520
0000 0010 0000 1000 // Value
0 0000100 0 0001000 // Slice Number to 7 Bits
0001000 0000100 // Drop MSB & Change to Little-Endian Order
10001000 00000100 // Done!
```

## Old Message Format

Kafka 0.11 이전에는 Message들을 전송하고 Message는 Message Set안에 저장했습니다.
Message Set 안에서 각 Message는 자체 Metadata를 가집니다.
Message Set은 Array로 표현되나 이 Protocol은 다른 Array Element처럼 앞에 `int32` Array Size가 나오지 않습니다.

```
MessageSet (Version: 0) => [offset message_size message]
	offset => int64
	message_size => int32
	message => crc magic_byte attributes key value
		crc => int32
		magic_byte => int8
		attributes => int8
			bit 0~2:
				0: no compression
				1: gzip
				2: snappy
            bit 3~7: unused
        key => bytes
        value => bytes
```

```
MessageSet (Version: 1) => [offset message_size message]
	offset => int64
	message_size => int32
	message => crc magic_byte attributes key value
		crc => int32
		magic_byte => int8
		attributes => int8
			bit 0~2:
				0: no compression
				1: gzip
				2: snappy
				3: lz4
            bit 3: timestampType
            	0: create time
            	1: log append time
            bit 4~7: unused
        timestamp => int64
        key => bytes
        value => bytes
```

Kafka 0.10 Ver 이전에 유일하게 지원하는 Message Format Version(`magic` 값으로 나타내는)은 0이었습니다.
Message Format Version 1은 0.10 Ver에서 Timestamp 지원과 함께 도입되었습니다.

-   위에 있는 Ver 2와 유사하게 가장 낮은 `attributes ` Bit는 Compression Type을 나타냅니다.
-   Ver 1에서 Producer는 항상 `timestampType` Bit를 0으로 설정해야 합니다.
    Log에 추가된 시간을 Timestamp로 사용하는 Topic(`log.message.timestamp.type` = `LogAppendTime` 또는 `message.timestamp.tpye` = `LogAppendTime`으로 설정)이라면 Broker가 Message Set에 있는 Timestamp Type과 Typestamp를 Rewrite합니다.
-   `attributes` Bit의 MSB는 반드시 0으로 설정해야 합니다.

Message Format Version 0, 1에선 Kafka는 Recursive Message를 통해 Compression을 지원합니다.
이땐 Message의 `attributes`에 반드시 Compression Type 중 하나를 나타내도록 설정해야 하며 `value` Field에는 이 Type으로 Compressed Message Set이 담깁니다.
위와 같이 중첩된 Message를 Inner Message라고 부르며 Wrapping한 Message를 Outer Message라고 말합니다.
Outer Message에서는 `key`가 Null이여야 하며 Inner Message 마지막 Offset이 Outer Message의 Offset이 됩니다.

0 Version을 사용하는 Recursive Message를 받으면 Broker는 Message를 Decompression 후 각 Inner Message에 개별적으로 Offset을 할당합니다.
1 Version에선 Server Side에서 다시 Compression하지 않도록 Wrapper Message에만 Offset을 할당합니다.
Inner Message에는 상대적인 Offset이 담깁니다.
절대적인 Offset 값을 계산하는 방법은 마지막 Inner Message에 할당된 Offset에 해당하는 Outer Message의 Offset으로 계산할 수 있습니다.

`crc` Field는 후속 Message Byte(`magic` ~ `value`)의 CRC32(CRC-32C와 다릅니다.)가 저장됩니다.

# Log

두 개의 Partition으로 구성된 `my_topic`이란 Topic의 Log는 두 Directory로 구성되며(`my_topic_0`, `my_topic_1`) 이 Directory는 Topic Message를 가진 Data File로 채워집니다.
Log File은 Log Entry의 Sequence 형식입니다.
각 Log Entry는 Message Length를 저장하는 4 Byte Integer N과 그 뒤에 나오는 N Byte Message로 이루어집니다.
각 Message는 64bit Integer Offset으로 고유히 식별됩니다.
Offset은 해당 Topic Partition으로 전송된 모든 Message Stream에서 이 Message가 시작하는 Byte 상 위치를 제공합니다.
각 Message의 Disk Storage Format은 아래 사진과 같습니다.

![kafka_log](./10_Implementation.assets/kafka_log.png)

## Writes

## Reads

## Deletes

## Guarantees

# Distribution

## Consumer Offset Tracking

## ZooKeeper Directories

## Notation

## Broker Node Registry

## Broker Topic Registry

## Cluster ID

## Broker Node Registration

