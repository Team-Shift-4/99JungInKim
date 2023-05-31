# InfluxDB 설치 및 기초

<aside>
📌 해당 문서는 InfluxDB 1.8.10 기준으로 작성

</aside>

<aside>
📖 **InfluxDB 설치 및 기초 목차**

</aside>

# InfluxDB

- Open Source Time Series Database
- 타 TSDB와 달리 SQL과 유사한 Query 지원
- Go 언어로 작성
- Google의 LevelDB 사용
- Continuous Queries 지원
- Schemaless Design
- Rest API 제공
- 뛰어난 성능

| RDB | InfluxDB |
| --- | --- |
| Database | Database |
| Table | Measurement |
| Column | Key |
| Primary Key(PK), Indexed Column | Tag Key(String 타입) |
| SET of Index Entires | Series |
- Measurement(RDB의 Table)에 Data를 Point라는 틀에 맞게 저장
    - Tag Key: 구분자(String만 사용 가능)
    - Field Key: Data
    - Time Key: 자동으로 입력됨

## Install InfluxDB

[Downloads](https://portal.influxdata.com/downloads/)

```bash
wget https://dl.influxdata.com/influxdb/releases/influxdb-1.8.10.x86_64.rpm
sudo yum localinstall influxdb-1.8.10.x86_64.rpm
```

```bash
systemctl start influxdb
systemctl staus influxdb
systemctl enable influxdb
```

- cli
    
    ```bash
    [root@orcl ~]# wget https://dl.influxdata.com/influxdb/releases/influxdb-1.8.10.x86_64.rpm
    --2022-12-14 11:43:14--  https://dl.influxdata.com/influxdb/releases/influxdb-1.8.10.x86_64.rpm
    Resolving dl.influxdata.com (dl.influxdata.com)... 18.154.144.22, 18.154.144.85, 18.154.144.53, ...
    Connecting to dl.influxdata.com (dl.influxdata.com)|18.154.144.22|:443... connected.
    HTTP request sent, awaiting response... 200 OK
    Length: 54137545 (52M) [application/octet-stream]
    Saving to: ‘influxdb-1.8.10.x86_64.rpm’
    
    100%[================================================================================================================================================================================================================================>] 54,137,545   218KB/s   in 76s
    
    2022-12-14 11:44:31 (692 KB/s) - ‘influxdb-1.8.10.x86_64.rpm’ saved [54137545/54137545]
    
    [root@orcl ~]# sudo yum localinstall influxdb-1.8.10.x86_64.rpm
    Loaded plugins: fastestmirror, langpacks
    Examining influxdb-1.8.10.x86_64.rpm: influxdb-1.8.10-1.x86_64
    Marking influxdb-1.8.10.x86_64.rpm to be installed
    Resolving Dependencies
    --> Running transaction check
    ---> Package influxdb.x86_64 0:1.8.10-1 will be installed
    --> Finished Dependency Resolution
    base/7/x86_64                                                                                                                                                                                                                                      | 3.6 kB  00:00:00
    extras/7/x86_64                                                                                                                                                                                                                                    | 2.9 kB  00:00:00
    updates/7/x86_64                                                                                                                                                                                                                                   | 2.9 kB  00:00:00
    updates/7/x86_64/primary_db                                                                                                                                                                                                                        |  18 MB  00:00:05
    
    Dependencies Resolved
    
    ==========================================================================================================================================================================================================================================================================
     Package                                                      Arch                                                       Version                                                        Repository                                                                   Size
    ==========================================================================================================================================================================================================================================================================
    Installing:
     influxdb                                                     x86_64                                                     1.8.10-1                                                       /influxdb-1.8.10.x86_64                                                     146 M
    
    Transaction Summary
    ==========================================================================================================================================================================================================================================================================
    Install  1 Package
    
    Total size: 146 M
    Installed size: 146 M
    Is this ok [y/d/N]: y
    Downloading packages:
    Running transaction check
    \Running transaction test
    Transaction test succeeded
    Running transaction
      Installing : influxdb-1.8.10-1.x86_64                                                                                                                                                                                                                               1/1
    Created symlink from /etc/systemd/system/influxd.service to /usr/lib/systemd/system/influxdb.service.
    Created symlink from /etc/systemd/system/multi-user.target.wants/influxdb.service to /usr/lib/systemd/system/influxdb.service.
      Verifying  : influxdb-1.8.10-1.x86_64                                                                                                                                                                                                                               1/1
    
    Installed:
      influxdb.x86_64 0:1.8.10-1
    
    Complete!
    [root@orcl ~]# systemctl start influxdb
    [root@orcl ~]# systemctl status influxdb
    ● influxdb.service - InfluxDB is an open-source, distributed, time series database
       Loaded: loaded (/usr/lib/systemd/system/influxdb.service; enabled; vendor preset: disabled)
       Active: active (running) since Wed 2022-12-14 11:45:05 KST; 7s ago
         Docs: https://docs.influxdata.com/influxdb/
      Process: 21273 ExecStart=/usr/lib/influxdb/scripts/influxd-systemd-start.sh (code=exited, status=0/SUCCESS)
     Main PID: 21274 (influxd)
        Tasks: 10
       CGroup: /system.slice/influxdb.service
               └─21274 /usr/bin/influxd -config /etc/influxdb/influxdb.conf
    
    Dec 14 11:45:05 orcl.iarkdata.com influxd-systemd-start.sh[21273]: ts=2022-12-14T02:45:05.003458Z lvl=info msg="Starting continuous query service" log_id=0ekdBM~W000 service=continuous_querier
    Dec 14 11:45:05 orcl.iarkdata.com influxd-systemd-start.sh[21273]: ts=2022-12-14T02:45:05.003857Z lvl=info msg="Starting HTTP service" log_id=0ekdBM~W000 service=httpd authentication=false
    Dec 14 11:45:05 orcl.iarkdata.com influxd-systemd-start.sh[21273]: ts=2022-12-14T02:45:05.003867Z lvl=info msg="opened HTTP access log" log_id=0ekdBM~W000 service=httpd path=stderr
    Dec 14 11:45:05 orcl.iarkdata.com influxd-systemd-start.sh[21273]: ts=2022-12-14T02:45:05.004602Z lvl=info msg="Listening on HTTP" log_id=0ekdBM~W000 service=httpd addr=[::]:8086 https=false
    Dec 14 11:45:05 orcl.iarkdata.com influxd-systemd-start.sh[21273]: ts=2022-12-14T02:45:05.004617Z lvl=info msg="Starting retention policy enforcement service" log_id=0ekdBM~W000 service=retention check_interval=30m
    Dec 14 11:45:05 orcl.iarkdata.com influxd-systemd-start.sh[21273]: ts=2022-12-14T02:45:05.004736Z lvl=info msg="Listening for signals" log_id=0ekdBM~W000
    Dec 14 11:45:05 orcl.iarkdata.com influxd-systemd-start.sh[21273]: ts=2022-12-14T02:45:05.005424Z lvl=info msg="Storing statistics" log_id=0ekdBM~W000 service=monitor db_instance=_internal db_rp=monitor interval=10s
    Dec 14 11:45:05 orcl.iarkdata.com influxd-systemd-start.sh[21273]: ts=2022-12-14T02:45:05.005540Z lvl=info msg="Sending usage statistics to usage.influxdata.com" log_id=0ekdBM~W000
    Dec 14 11:45:05 orcl.iarkdata.com influxd-systemd-start.sh[21273]: [httpd] ::1 - - [14/Dec/2022:11:45:05 +0900] "GET /health HTTP/1.1" 200 107 "-" "curl/7.29.0" 51031b06-7b59-11ed-8001-0800272df459 171
    Dec 14 11:45:05 orcl.iarkdata.com systemd[1]: Started InfluxDB is an open-source, distributed, time series database.
    [root@orcl ~]#
    ```
    

## InfluxDB Command

### Start InfluxDB

```bash
influx
```

### Create Database

```sql
CREATE DATABASE <db name>
```

### Show Databases

```sql
SHOW DATABASES

# name: databases
# name
# ----
# _internal
# ARKCDC
```

### Use Database

```sql
USE <db name>

# Using database ARKCDC
```

### Create Retention Policy

- Retention Policy는 일정 기간이 지난 Data를 삭제해주는 정책
- 각 Database 별로 다르게 지정할 수 있음
- 별도의 설정을 하지 않을 경우 Database 생성 시 `autogen`이라는 기본 정책이 적용

```sql
CREATE RETENTION POLICY "<policy name>" ON "<database name>" duration_option replication_option <shard_group_duration_option> [DEFALT]
```

### Alter Retention Policy

```sql
ALTER RETENTION POLOCY "<policy name>" ON "<database name>" option [option] [option] ...
```

### Delete Retention Policy

```sql
DROP RETENTION POLICY <policy name> ON <database name>
```

### Show Retention Policy

```sql
SHOW RETENTION POLICIES

# name    duration shardGroupDuration replicaN default
# ----    -------- ------------------ -------- -------
# autogen 0s       168h0m0s           1        true
```

### Insert Data

```sql
INSERT <measurement name>,<tag name>=<tag value>,...<tag name>=<tag value> <field name>=<field value>,...<field name>=<field value> <time key(Optional)>
```

### Select Data

```sql
SELECT * FROM <measurement name>
```

```sql
SELECT "<field name>", "<field name>"... FROM <measurement name>
```

### Delete Data

```sql
DELETE FROM <measurement name> WHERE <conditional statement>
```

### Delete Measurement

```sql
DROP MEASUREMENT <measurement name>
```

### Delete Database

```sql
DROP DATABASE <database name>
```