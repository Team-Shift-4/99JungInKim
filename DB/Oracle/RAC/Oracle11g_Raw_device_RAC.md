# Oracle11g Raw device RAC

## Information

| OS       | DB              |
| -------- | --------------- |
| CentOS 7 | Oracle 11.2.0.4 |



| Public IP    | Private IP     | Virtual IP   | SCAN IP      | Gateway      | DNS      |
| ------------ | -------------- | ------------ | ------------ | ------------ | -------- |
| 172.16.0.112 | 192.168.56.112 | 172.16.0.235 | 172.16.0.234 | 172.16.0.254 | loopback |
| 172.16.0.113 | 192.168.56.113 | 172.16.0.236 | 172.16.0.234 | 172.16.0.254 | loopback |

| Logical Volume | Size   | Description |
| -------------- | ------ | ----------- |
| ocr01          | 508m   |             |
| ocr02          | 508m   |             |
| ocr03          | 508m   |             |
| vote01         | 508m   |             |
| vote02         | 508m   |             |
| vote03         | 508m   |             |
| control01      | 108m   |             |
| control02      | 108m   |             |
| system01       | 1.01g  |             |
| sysaux02       | 1.01g  |             |
| undo01         | 1.01g  |             |
| undo02         | 1.01g  |             |
| users01        | 508m   |             |
| temp01         | 508m   |             |
| 200mredo01     | 208m   |             |
| 200mredo02     | 208m   |             |
| 200mredo03     | 208m   |             |
| 200mredo04     | 208m   |             |
| 200mredo05     | 208m   |             |
| 200mredo06     | 208m   |             |
| 200mredo07     | 208m   |             |
| 200mredo08     | 208m   |             |
| 200mredo09     | 208m   |             |
| 200mredo10     | 208m   |             |
| 200mredo11     | 208m   |             |
| 200mredo12     | 208m   |             |
| 200mredo13     | 208m   |             |
| 200mredo14     | 208m   |             |
| 200mredo15     | 208m   |             |
| 200mredo16     | 208m   |             |
| 200mredo17     | 208m   |             |
| 200mredo18     | 208m   |             |
| 200mredo19     | 208m   |             |
| 200mredo20     | 208m   |             |
| 1gredo01       | 1.01g  |             |
| 1gredo02       | 1.01g  |             |
| 1gredo03       | 1.01g  |             |
| 1gredo04       | 1.01g  |             |
| 1gredo05       | 1.01g  |             |
| 1gredo06       | 1.01g  |             |
| 1gredo07       | 1.01g  |             |
| 1gredo08       | 1.01g  |             |
| 1gredo09       | 1.01g  |             |
| 1gredo10       | 1.01g  |             |
| 5gredo01       | 5.01g  |             |
| 5gredo02       | 5.01g  |             |
| 5gredo03       | 5.01g  |             |
| 5gredo04       | 5.01g  |             |
| 5gredo05       | 5.01g  |             |
| 5gredo06       | 5.01g  |             |
| 5gredo07       | 5.01g  |             |
| 5gredo08       | 5.01g  |             |
| 5gredo09       | 5.01g  |             |
| 5gredo10       | 5.01g  |             |
| spfile         | 308m   |             |
| orapwd         | 308m   |             |
| tbs01          | 50.01g |             |
| tbs02          | 50.01g |             |

## Installation

### Network

```bash
vi /etc/hosts
```

```bash
# Public IP
172.16.0.112		rac-node1
172.16.0.113		rac-node2

# Private IP
192.168.56.112		rac-node1-priv
192.168.56.113		rac-node2-priv

# Virtaul IP
172.16.0.235		rac-node1-vip
172.16.0.236		rac-node2-vip

# Cluster SCAN
172.16.0.234		rac-scan
```

### DNSMASQ Service

```bash
service dnsmasq start
chkconfig dnsmasq on
```

### Install Package

```bash
yum -y install binutils compat-libcap1 compat-libstdc++-33 compat-libstdc++-33.i686 gcc gcc-c++ glibc \
glibc.i686 glibc-devel glibc-devel.i686 ksh libgcc libgcc.i686 libstdc++ libstdc++.i686 libstdc++-devel \
libstdc++-devel.i686 libaio libaio.i686 libaio-devel libaio-devel.i686 libXext libXext.i686 libXtst \
libXtst.i686 libX11 libX11.i686 libXau libXau.i686 libxcb libxcb.i686 libXi libXi.i686 make sysstat unixODBC \
unixODBC-devel zlib-devel elfutils-libelf-devel
```

### Kernel Parameter

```bash
vi /etc/sysctl.conf
```

```bash
# Controls IP packet forwarding
net.ipv4.ip_forward = 0
 
# Controls source route verification
 
# Do not accept source routing
net.ipv4.conf.default.accept_source_route = 0
 
# Controls the System Request debugging functionality of the kernel
kernel.sysrq = 0
 
# Controls whether core dumps will append the PID to the core filename.
# Useful for debugging multi-threaded applications.
kernel.core_uses_pid = 1
 
# Controls the use of TCP syncookies
net.ipv4.tcp_syncookies = 1
 
# Controls the default maxmimum size of a mesage queue
kernel.msgmnb = 65536
 
# Controls the maximum size of a message, in bytes
kernel.msgmax = 65536
 
# Controls the maximum shared segment size, in bytes
 
# Controls the maximum number of shared memory segments, in pages
 
# oracle-rdbms-server-11gR2-preinstall setting for fs.file-max is 6815744
fs.file-max = 6815744
 
# oracle-rdbms-server-11gR2-preinstall setting for kernel.sem is '250 32000 100 128'
kernel.sem = 250 32000 100 128
 
# oracle-rdbms-server-11gR2-preinstall setting for kernel.shmmni is 4096
kernel.shmmni = 4096
 
# oracle-rdbms-server-11gR2-preinstall setting for kernel.shmall is 1073741824 on x86_64 and 2097152 on i386
kernel.shmall = 4294967296
```

### SELINUX Disable

```bash
vi /etc/selinux/config
```

```bash
# This file controls the state of SELinux on the system.
# SELINUX= can take one of these three values:
#     enforcing - SELinux security policy is enforced.
#     permissive - SELinux prints warnings instead of enforcing.
#     disabled - No SELinux policy is loaded.
SELINUX=disabled
# SELINUXTYPE= can take one of these two values:
#     targeted - Targeted processes are protected,
#     mls - Multi Level Security protection.
SELINUXTYPE=targeted
```

### Create User

```bash
groupadd oinstall
groupadd dba
groupadd asmadmin
groupadd asmoper
groupadd asmdba

useradd -g oinstall -G dba,asmdba oracle11
useradd -g oinstall -G asmadmin,asmoper,asmdba,dba grid11

passwd oracle11
passwd grid11
```

### User Resource

```bash
vi /etc/security/limits.conf
```

```bash
oracle11	soft	nproc		2047
oracle11	hard	nproc		16384
oracle11	soft	nofile		1024
oracle11	hard	nofile		65536
oracle11	soft	stack		10240

grid11		soft	nproc		2047
grid11		hard	nproc		16384
grid11		soft	nofile		1024
grid11		hard	nofile		65536
grid11		soft	stack		10240
```

### Set Oracle User Profile

```bash
vi ~oracle11/.bash_profile
```

```bash
export ORACLE_HOSTNAME=rac-node1
export ORACLE_UNQNAME=RAW-RAC-11
export ORACLE_SID=RAW-RAC-11-1
export ORACLE_BASE=/app/oracle/db_11g
export ORACLE_HOME=$ORACLE_BASE/product/11.2.0/db_1
export GRID_HOME=/app/oracle/grid_11g
export PATH=$ORACLE_HOME:$ORACLE_HOME/bin:$PATH
export LD_LIBRARY_PATH=$ORACLE_HOME/lib:$LD_LIBRARY_PATH
export LANG=en_US.utf8
export NLS_LANG=AMERICAN_AMERICA.AL32UTF8
export PS1='$ORACLE_SID:PWD> '
```

### Set Grid User Profile

```bash
vi ~grid11/.bash_profile
```

```bash
export GRID_BASE=/app/oracle/grid_11g_base
export GRID_HOME=/app/oracle/grid_11g_home
export ORACLE_BASE=$GRID_BASE
export ORACLE_HOME=$GRID_HOME
export PATH=$ORACLE_HOME:$ORACLE_HOME/bin:$PATH
export LD_LIBRARY_PATH=$ORACLE_HOME/lib
```

### Create Raw Device Disk

#### Partitioning LVM Type

```bash
fdisk -l

fdisk /dev/sdf
n p default default default
t 8e(LVM)
w
```

#### Create Logical Volume

```bash
pvcreate -d /dev/sdf1

vgcreate rac /dev/sdf1

lvcreate --name <lv_name> --size <lv_size> <vg_name>

lvs
```

#### Raw Device Binding

```bash
raw /dev/raw/raw<number> <device>

raw -qa

lvs -o +lv_kernel_major,lv_kernel_minor -O lv_kernel_major
```

```bash
[root@rac-node1 ~]# lvs -o +lv_kernel_major,lv_kernel_minor -O lv_kernel_major
  LV         VG     Attr       LSize    Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert KMaj KMin
  swap       centos -wi-ao----    2.00g                                                      253    1
  root       centos -wi-ao----  <17.00g                                                      253    0
  lv_app     app    -wi-ao---- <200.00g                                                      253   32
  ocr01      rac    -wi-a-----  508.00m                                                      253    2
  ocr02      rac    -wi-a-----  508.00m                                                      253    3
  ocr03      rac    -wi-a-----  508.00m                                                      253    4
  vote01     rac    -wi-a-----  508.00m                                                      253    5
  vote02     rac    -wi-a-----  508.00m                                                      253    6
  vote03     rac    -wi-a-----  508.00m                                                      253    7
  control01  rac    -wi-a-----  108.00m                                                      253    8
  control02  rac    -wi-a-----  108.00m                                                      253    9
  system01   rac    -wi-a-----   <1.01g                                                      253   10
  sysaux01   rac    -wi-a-----   <1.01g                                                      253   11
  undo01     rac    -wi-a-----   <1.01g                                                      253   12
  undo02     rac    -wi-a-----   <1.01g                                                      253   13
  users01    rac    -wi-a-----  508.00m                                                      253   14
  temp01     rac    -wi-a-----  508.00m                                                      253   15
  200mredo01 rac    -wi-a-----  208.00m                                                      253   16
  200mredo02 rac    -wi-a-----  208.00m                                                      253   17
  200mredo03 rac    -wi-a-----  208.00m                                                      253   18
  200mredo04 rac    -wi-a-----  208.00m                                                      253   19
  200mredo05 rac    -wi-a-----  208.00m                                                      253   20
  200mredo06 rac    -wi-a-----  208.00m                                                      253   21
  200mredo07 rac    -wi-a-----  208.00m                                                      253   22
  200mredo08 rac    -wi-a-----  208.00m                                                      253   23
  200mredo09 rac    -wi-a-----  208.00m                                                      253   24
  200mredo10 rac    -wi-a-----  208.00m                                                      253   25
  200mredo11 rac    -wi-a-----  208.00m                                                      253   26
  200mredo12 rac    -wi-a-----  208.00m                                                      253   27
  200mredo13 rac    -wi-a-----  208.00m                                                      253   28
  200mredo14 rac    -wi-a-----  208.00m                                                      253   29
  200mredo15 rac    -wi-a-----  208.00m                                                      253   30
  200mredo16 rac    -wi-a-----  208.00m                                                      253   31
  200mredo17 rac    -wi-a-----  208.00m                                                      253   33
  200mredo18 rac    -wi-a-----  208.00m                                                      253   34
  200mredo19 rac    -wi-a-----  208.00m                                                      253   35
  200mredo20 rac    -wi-a-----  208.00m                                                      253   36
  1gredo01   rac    -wi-a-----   <1.01g                                                      253   37
  1gredo02   rac    -wi-a-----   <1.01g                                                      253   38
  1gredo03   rac    -wi-a-----   <1.01g                                                      253   39
  1gredo04   rac    -wi-a-----   <1.01g                                                      253   40
  1gredo05   rac    -wi-a-----   <1.01g                                                      253   41
  1gredo06   rac    -wi-a-----   <1.01g                                                      253   42
  1gredo07   rac    -wi-a-----   <1.01g                                                      253   43
  1gredo08   rac    -wi-a-----   <1.01g                                                      253   44
  1gredo09   rac    -wi-a-----   <1.01g                                                      253   45
  1gredo10   rac    -wi-a-----   <1.01g                                                      253   46
  5gredo01   rac    -wi-a-----   <5.01g                                                      253   47
  5gredo02   rac    -wi-a-----   <5.01g                                                      253   48
  5gredo03   rac    -wi-a-----   <5.01g                                                      253   49
  5gredo04   rac    -wi-a-----   <5.01g                                                      253   50
  5gredo05   rac    -wi-a-----   <5.01g                                                      253   51
  5gredo06   rac    -wi-a-----   <5.01g                                                      253   52
  5gredo07   rac    -wi-a-----   <5.01g                                                      253   53
  5gredo08   rac    -wi-a-----   <5.01g                                                      253   54
  5gredo09   rac    -wi-a-----   <5.01g                                                      253   55
  5gredo10   rac    -wi-a-----   <5.01g                                                      253   56
  spfile     rac    -wi-a-----  308.00m                                                      253   57
  orapwd     rac    -wi-a-----  308.00m                                                      253   58
  tbs01      rac    -wi-a-----  <50.01g                                                      253   59
  tbs02      rac    -wi-a-----  <50.01g                                                      253   60
```

#### Raw Device Everlasting Binding

```bash
vi /etc/udev/rules.d/70-persistent-ipoib.rules
```

```bash
ACTION=="add", ENV{MAJOR}=="253", ENV{MINOR}=="2", RUN+="/bin/raw /dev/raw/raw1 %M %m"
ACTION=="add", ENV{MAJOR}=="253", ENV{MINOR}=="3", RUN+="/bin/raw /dev/raw/raw2 %M %m"
ACTION=="add", ENV{MAJOR}=="253", ENV{MINOR}=="4", RUN+="/bin/raw /dev/raw/raw3 %M %m"
ACTION=="add", ENV{MAJOR}=="253", ENV{MINOR}=="5", RUN+="/bin/raw /dev/raw/raw4 %M %m"
ACTION=="add", ENV{MAJOR}=="253", ENV{MINOR}=="6", RUN+="/bin/raw /dev/raw/raw5 %M %m"
ACTION=="add", ENV{MAJOR}=="253", ENV{MINOR}=="7", RUN+="/bin/raw /dev/raw/raw6 %M %m"
ACTION=="add", ENV{MAJOR}=="253", ENV{MINOR}=="8", RUN+="/bin/raw /dev/raw/raw7 %M %m"
ACTION=="add", ENV{MAJOR}=="253", ENV{MINOR}=="9", RUN+="/bin/raw /dev/raw/raw8 %M %m"
ACTION=="add", ENV{MAJOR}=="253", ENV{MINOR}=="10", RUN+="/bin/raw /dev/raw/raw9 %M %m"
ACTION=="add", ENV{MAJOR}=="253", ENV{MINOR}=="11", RUN+="/bin/raw /dev/raw/raw10 %M %m"
ACTION=="add", ENV{MAJOR}=="253", ENV{MINOR}=="12", RUN+="/bin/raw /dev/raw/raw11 %M %m"
ACTION=="add", ENV{MAJOR}=="253", ENV{MINOR}=="13", RUN+="/bin/raw /dev/raw/raw12 %M %m"
ACTION=="add", ENV{MAJOR}=="253", ENV{MINOR}=="14", RUN+="/bin/raw /dev/raw/raw13 %M %m"
ACTION=="add", ENV{MAJOR}=="253", ENV{MINOR}=="15", RUN+="/bin/raw /dev/raw/raw14 %M %m"
ACTION=="add", ENV{MAJOR}=="253", ENV{MINOR}=="16", RUN+="/bin/raw /dev/raw/raw15 %M %m"
ACTION=="add", ENV{MAJOR}=="253", ENV{MINOR}=="17", RUN+="/bin/raw /dev/raw/raw16 %M %m"
ACTION=="add", ENV{MAJOR}=="253", ENV{MINOR}=="18", RUN+="/bin/raw /dev/raw/raw17 %M %m"
ACTION=="add", ENV{MAJOR}=="253", ENV{MINOR}=="19", RUN+="/bin/raw /dev/raw/raw18 %M %m"
ACTION=="add", ENV{MAJOR}=="253", ENV{MINOR}=="20", RUN+="/bin/raw /dev/raw/raw19 %M %m"
ACTION=="add", ENV{MAJOR}=="253", ENV{MINOR}=="21", RUN+="/bin/raw /dev/raw/raw20 %M %m"
ACTION=="add", ENV{MAJOR}=="253", ENV{MINOR}=="22", RUN+="/bin/raw /dev/raw/raw21 %M %m"
ACTION=="add", ENV{MAJOR}=="253", ENV{MINOR}=="23", RUN+="/bin/raw /dev/raw/raw22 %M %m"
ACTION=="add", ENV{MAJOR}=="253", ENV{MINOR}=="24", RUN+="/bin/raw /dev/raw/raw23 %M %m"
ACTION=="add", ENV{MAJOR}=="253", ENV{MINOR}=="25", RUN+="/bin/raw /dev/raw/raw24 %M %m"
ACTION=="add", ENV{MAJOR}=="253", ENV{MINOR}=="26", RUN+="/bin/raw /dev/raw/raw25 %M %m"
ACTION=="add", ENV{MAJOR}=="253", ENV{MINOR}=="27", RUN+="/bin/raw /dev/raw/raw26 %M %m"
ACTION=="add", ENV{MAJOR}=="253", ENV{MINOR}=="28", RUN+="/bin/raw /dev/raw/raw27 %M %m"
ACTION=="add", ENV{MAJOR}=="253", ENV{MINOR}=="29", RUN+="/bin/raw /dev/raw/raw28 %M %m"
ACTION=="add", ENV{MAJOR}=="253", ENV{MINOR}=="30", RUN+="/bin/raw /dev/raw/raw29 %M %m"
ACTION=="add", ENV{MAJOR}=="253", ENV{MINOR}=="31", RUN+="/bin/raw /dev/raw/raw30 %M %m"
ACTION=="add", ENV{MAJOR}=="253", ENV{MINOR}=="33", RUN+="/bin/raw /dev/raw/raw31 %M %m"
ACTION=="add", ENV{MAJOR}=="253", ENV{MINOR}=="34", RUN+="/bin/raw /dev/raw/raw32 %M %m"
ACTION=="add", ENV{MAJOR}=="253", ENV{MINOR}=="35", RUN+="/bin/raw /dev/raw/raw33 %M %m"
ACTION=="add", ENV{MAJOR}=="253", ENV{MINOR}=="36", RUN+="/bin/raw /dev/raw/raw34 %M %m"
ACTION=="add", ENV{MAJOR}=="253", ENV{MINOR}=="37", RUN+="/bin/raw /dev/raw/raw35 %M %m"
ACTION=="add", ENV{MAJOR}=="253", ENV{MINOR}=="38", RUN+="/bin/raw /dev/raw/raw36 %M %m"
ACTION=="add", ENV{MAJOR}=="253", ENV{MINOR}=="39", RUN+="/bin/raw /dev/raw/raw37 %M %m"
ACTION=="add", ENV{MAJOR}=="253", ENV{MINOR}=="40", RUN+="/bin/raw /dev/raw/raw38 %M %m"
ACTION=="add", ENV{MAJOR}=="253", ENV{MINOR}=="41", RUN+="/bin/raw /dev/raw/raw39 %M %m"
ACTION=="add", ENV{MAJOR}=="253", ENV{MINOR}=="42", RUN+="/bin/raw /dev/raw/raw40 %M %m"
ACTION=="add", ENV{MAJOR}=="253", ENV{MINOR}=="43", RUN+="/bin/raw /dev/raw/raw41 %M %m"
ACTION=="add", ENV{MAJOR}=="253", ENV{MINOR}=="44", RUN+="/bin/raw /dev/raw/raw42 %M %m"
ACTION=="add", ENV{MAJOR}=="253", ENV{MINOR}=="45", RUN+="/bin/raw /dev/raw/raw43 %M %m"
ACTION=="add", ENV{MAJOR}=="253", ENV{MINOR}=="46", RUN+="/bin/raw /dev/raw/raw44 %M %m"
ACTION=="add", ENV{MAJOR}=="253", ENV{MINOR}=="47", RUN+="/bin/raw /dev/raw/raw45 %M %m"
ACTION=="add", ENV{MAJOR}=="253", ENV{MINOR}=="48", RUN+="/bin/raw /dev/raw/raw46 %M %m"
ACTION=="add", ENV{MAJOR}=="253", ENV{MINOR}=="49", RUN+="/bin/raw /dev/raw/raw47 %M %m"
ACTION=="add", ENV{MAJOR}=="253", ENV{MINOR}=="50", RUN+="/bin/raw /dev/raw/raw48 %M %m"
ACTION=="add", ENV{MAJOR}=="253", ENV{MINOR}=="51", RUN+="/bin/raw /dev/raw/raw49 %M %m"
ACTION=="add", ENV{MAJOR}=="253", ENV{MINOR}=="52", RUN+="/bin/raw /dev/raw/raw50 %M %m"
ACTION=="add", ENV{MAJOR}=="253", ENV{MINOR}=="53", RUN+="/bin/raw /dev/raw/raw51 %M %m"
ACTION=="add", ENV{MAJOR}=="253", ENV{MINOR}=="54", RUN+="/bin/raw /dev/raw/raw52 %M %m"
ACTION=="add", ENV{MAJOR}=="253", ENV{MINOR}=="55", RUN+="/bin/raw /dev/raw/raw53 %M %m"
ACTION=="add", ENV{MAJOR}=="253", ENV{MINOR}=="56", RUN+="/bin/raw /dev/raw/raw54 %M %m"
ACTION=="add", ENV{MAJOR}=="253", ENV{MINOR}=="57", RUN+="/bin/raw /dev/raw/raw55 %M %m"
ACTION=="add", ENV{MAJOR}=="253", ENV{MINOR}=="58", RUN+="/bin/raw /dev/raw/raw56 %M %m"
ACTION=="add", ENV{MAJOR}=="253", ENV{MINOR}=="59", RUN+="/bin/raw /dev/raw/raw57 %M %m"
ACTION=="add", ENV{MAJOR}=="253", ENV{MINOR}=="60", RUN+="/bin/raw /dev/raw/raw58 %M %m"

ACTION=="add", KERNEL=="raw*", OWNER="oracle11", GROUP="oinstall", MODE="0660"
```

### Set NTP Daemon Disable

```bash
service ntpd stop
chkconfig ntpd off
mv /etc/ntp.conf /etc/ntp.conf.back
```

-   Cluster 구성에서 Node 간 시간 동기화를 NTP Daemon을 사용하거나 Cluster Time Synchronization Service를 이용하도록 권장되어 있다.
-   이 예제에서는 CTSS를 사용하여 시간동기화를 하기 때문에 NTP Daemon을 비활성화 한다.

### Set NTP Daemon Enable

```bash
yum install -y chrony

vi /etc/chrony.conf
```

```bash
server 3.kr.pool.ntp.org
server 1.asia.pool.ntp.org
```



### Create Product Path & Change Authority

```bash
    source ~grid11/.bash_profile
    source ~oracle11/.bash_profile
    mkdir -p $ORACLE_HOME
    mkdir -p $GRID_BASE
    mkdir -p $GRID_HOME
    chown -R grid11:oinstall /app
    chmod -R 775 /app
    chown -R oracle11:oinstall $ORACLE_BASE
```

### Setting Node 2

#### Replicate Node 1 Virtual Machine

-   VM 복제 시 공유 디스크 연결을 해제하고 복제를 진행한다.

#### Setting Network

```bash
vi /etc/sysconfig/network
```

```bash
# Created by anaconda
NETWORKING=yes
HOSTNAME=rac-node2
NTPSERVERARGS=iburst
NOZEROCONF=yes
```

#### Set Oracle User Profile

```bash
vi ~oracle11/.bash_profile
```

```bash
export ORACLE_HOSTNAME=rac-node2
export ORACLE_UNQNAME=RAC11
export ORACLE_BASE=/app/oracle/db_11g
export ORACLE_HOME=$ORACLE_BASE/product/11.2.0/db_home
export PATH=$ORACLE_HOME:$ORACLE_HOME/bin:$PATH
export LD_LIBRARY_PATH=$ORACLE_HOME/lib:$LD_LIBRARY_PATH
export LANG=en_US.utf8
export NLS_LANG=AMERICAN_AMERICA.AL32UTF8
export ORACLE_SID=RAW-RAC-11-2
export PS1='$ORACLE_SID:PWD> '
```

### Before Intall Grid Infrastructure

#### Set User Equivalence

-   Node 1, 2 간 SSH 접속 시 Password 인증 없이 접속할 수 있도록 SSH 인증 키를 생성한다.
-   각 노드 당 실행한다.
-   authorized_keys는 ~/.ssh에 존재해야 한다.

```bash
su - oracle11
```

```bash
ssh-keygen -t rsa
ssh-keygen -t dsa

ssh rac-node1 cat /home/oracle11/.ssh/id_rsa.pub >> authorized_keys
ssh rac-node1 cat /home/oracle11/.ssh/id_dsa.pub >> authorized_keys
ssh rac-node2 cat /home/oracle11/.ssh/id_rsa.pub >> authorized_keys
ssh rac-node2 cat /home/oracle11/.ssh/id_dsa.pub >> authorized_keys
```

```bash
su - grid11
```

```bash
ssh-keygen -t rsa
ssh-keygen -t dsa

ssh rac-node1 cat /home/grid11/.ssh/id_rsa.pub >> authorized_keys
ssh rac-node1 cat /home/grid11/.ssh/id_dsa.pub >> authorized_keys
ssh rac-node2 cat /home/grid11/.ssh/id_rsa.pub >> authorized_keys
ssh rac-node2 cat /home/grid11/.ssh/id_dsa.pub >> authorized_keys
```

#### Check Network Interface Name

-   각 Node 간 대응되는 IP가 물려있는 NIC 이름이 같은지 확인한다.

```bash
ifconfig
```

### Install Grid Infrastructure

#### [node1] Unzip Grid

```bash
su - grid11
```

```bash
mv V17531-01.zip $GRID_HOME
cd $GRID_HOME
unzip V17531-01.zip
```

```bash
cd grid/rpm
scp cvuqdisk-1.0.7-1.rpm rac-node2:/tmp
```

#### [both] Install cvuqdisk Package

```bash
rpm -qi cvuqdisk

# 설치되었을 시
rpm -e cvuqdisk

# 설치
su root
export CVUQDISK_GRP=oinstall
rpm -Uvh cvuqdisk-1.0.7-1.rpm
```

#### [node1] Run Check Shell Script

```bash
su - grid11
```

```bash
cd $GRID_HOME/grid

./runcluvfy.sh stage -pre crsinst -n rac-node1,rac-node2 -fixup -verbose
```

#### [node1] Run runInstaller

![image-20231110215533993](./assets/image-20231110215533993.png)

![image-20231110215632760](./assets/image-20231110215632760.png)

![image-20231110215645792](./assets/image-20231110215645792.png)

![image-20231110215748197](./assets/image-20231110215748197.png)

![image-20231110215802423](./assets/image-20231110215802423.png)

![image-20231110215817356](./assets/image-20231110215817356.png)

![image-20231110215853528](./assets/image-20231110215853528.png)

![image-20231110215900250](./assets/image-20231110215900250.png)

![image-20231110215924912](./assets/image-20231110215924912.png)

![image-20231110220005957](./assets/image-20231110220005957.png)

![image-20231110220236075](./assets/image-20231110220236075.png)

![image-20231110220304376](./assets/image-20231110220304376.png)

![image-20231110220310769](./assets/image-20231110220310769.png)

![image-20231110220321207](./assets/image-20231110220321207.png)

![image-20231110220339231](./assets/image-20231110220339231.png)

![image-20231110220455290](./assets/image-20231110220455290.png)

![image-20231110220708255](./assets/image-20231110220708255.png)

![image-20231110220722982](./assets/image-20231110220722982.png)

![image-20231110220845641](./assets/image-20231110220845641.png)

![image-20231110221003104](./assets/image-20231110221003104.png)

![image-20231110221016462](./assets/image-20231110221016462.png)

![image-20231110222006003](./assets/image-20231110222006003.png)

```bash
/app/oracle/oraInventory/orainstRoot.sh
/app/oracle/grid_11g_home/product/11.2.0/grid/root.sh
```

![image-20231110222633608](./assets/image-20231110222633608.png)





ntp

![image-20231113195248229](./assets/image-20231113195248229.png)

![image-20231113195306829](./assets/image-20231113195306829.png)

![image-20231113195313481](./assets/image-20231113195313481.png)

![image-20231113195336500](./assets/image-20231113195336500.png)

![image-20231113195515415](./assets/image-20231113195515415.png)

![image-20231113195539103](./assets/image-20231113195539103.png)

![image-20231113195550365](./assets/image-20231113195550365.png)

![image-20231113195615397](./assets/image-20231113195615397.png)

![image-20231113195620304](./assets/image-20231113195620304.png)

![image-20231113215552775](./assets/image-20231113215552775.png)