# Ark Tracing Structure

## TracingMeta

```c
typedef struct _TracingMeta {			// Total: 512 Byte
  uint8_t		version_signature[2];									// 매직넘버와 같은 기능을 하는 것 같음
  uint8_t		version[TRACING_VERSION_SIZE];				// TRACING_VERSION_SIZE = 2
  uint8_t		pad1[4];															// padding 1
  uint32_t	chksum;																// Checksum, CRC32(?)
  char			alias[LEN_ALIAS];											// LEN_ALIAS = 32
  uint8_t		postfix[LEN_TRACING_POSTFIX];					// LEN_TRACING_POSTFIX = 24
  uint8_t		unused;
  uint8_t		type;																	// regular = 1, persistence = 2, cache = 3
  uint8_t		pad2[2];
  uint32_t	options;
  char			filename[LEN_PATHSIZE];								// LEN_PATHSIZE = 256
  uint8_t		pad3[180];
} TracingMeta;
```

## TracingExtract

```c
typedef struct _TracingExtract {	// Total: 512 Byte
  char			alias[LEN_ALIAS];											// LEN_ALIAS = 32
  uint8_t		pad1[16];
  char			version[LEN_VERSION];									// LEN_VERSION = 16
  struct		timespec	begin_timestamp;						// 계산 상 16 Byte
  char			begin_timestring[LEN_TIMESTAMP];			// LEN_TIMESTAMP = 24
  ACDSN			begin_commit_dsn;											// ACDSN: 12 Byte
  uint8_t		pad3[4];
  struct		timespec	end_timestamp;
  char			end_timestring[LEN_TIMESTAMP];
  ACDSN			end_commit_dsn;
  uint8_t		pad5[4];
  uint8_t		pad6[16];
  uint8_t		pad7[64];
  uint8_t		pad8[256];
} TracingExtract;
```

### ACDSN

```c
typedef struct acscn {
  uint32_t	high;
  uint32_t	wrap;
  uint32_t	base;
} ACDSN;
```

## TracingOS

```c
typedef struct _TracingOS {		// Total: 512 Byte
  uint8_t		type;
  uint8_t		endian;
  uint8_t		pad1[2];
  uint8_t		pad2[12];
  char			osname[LEN_OSNAME];									// LEN_OSNAME = 16, uname 결과 값
  char			hostname[LEN_HOSTNAME];							// LEN_HOSTNAME = 16, uname -n 결과 값
  char			kernel_release[LEN_KERNEL_RELEASE];	// LEN_KERNEL_RELEASE = 32, uname -r 결과 값
  char			kernel_version[LEN_KERNEL_VERSION];	// LEN_KERNEL_VERSION = 40, uname -v 결과 값	
  uint8_t		pad3[8];
  char			architecture[LEN_ARCHITECTURE];			// LEN_ARCHITECTURE = 32, uname -p
  uint8_t		pad4[96];
  uint8_t		pad5[256];
} TracingOS;
```

### uname test

```bash
jik@gimjeong-in-ui-MacBookPro ~ % uname
Darwin

jik@gimjeong-in-ui-MacBookPro ~ % uname -n
gimjeong-in-ui-MacBookPro.local

jik@gimjeong-in-ui-MacBookPro ~ % uname -r
21.6.0

jik@gimjeong-in-ui-MacBookPro ~ % uname -v
Darwin Kernel Version 21.6.0: Wed Aug 10 14:28:23 PDT 2022; root:xnu-8020.141.5~2/RELEASE_ARM64_T6000

jik@gimjeong-in-ui-MacBookPro ~ % uname -p
arm
```

## TracingDatabase

```c
typedef struct _TracingDatabase {
  uint8_t		type;
  uint8_t		pad1[3];
  uint8_t		version_flag;
  uint8_t		pad2[3];
  char			db_name[LEN_DBNAME];
  char			instance_name[LEN_INSTANCE_NAME];
  uint8_t		pad3[8];
  char			version[LEN_DBVERSION];
  uint8_t		pad4[8];
  char			banner[LEN_DBBANNER];
  uint8_t		
}
```

| Asdf | asdf | Asdf                                                       |
| ---- | ---- | ---------------------------------------------------------- |
| 1    | Asd  | Asdfasdfadsfadsfadsfasdfadsfasdfasdfadsfadsfadsfasdfasdfsf |
| 2    | Asd  |                                                            |
| 3    | Asd  |                                                            |

