# Oracle GoldenGate 기본 명령어

# OGG 접속

```bash
./ggsci
```

# OGG Extractor, Replicator Status 확인

```bash
INFO * # INFO ALL
INFO *, DETAIL
INFO *, SHOWCH
```

## 해당 Process Status 자세히 확인

```bash
SEND <alias>, STATUS
SEND <alias>, SHOWTRANS
```

# Manager, Extractor, Replicator

## 시작

```bash
START MGR
START <alias> 
```

## 중지

```bash
STOP MGR
STOP <alias>
```

## 강제 중지

```bash
send [EXTRACT | REPLICAT] <alias>, FORCESTOP
```

## Kill

```bash
KILL [EXTRACT | REPLICAT] <alias>
```

# Parameter File 변경

```bash
EDIT PARAM <alias>
```