[toc]

# Oracle Database Installation Guide

본 자료는 Oracle Database 버전 별 Backup본을 만들며 작성한 문서입니다.
현재 Version 11g, 12c, 19c를 설치하며 정리할 예정이며 LTS나 필요에 의해 추가될 수 있습니다.

OS: CentOS 7


## Oracle Database 11g Enterprise 11.2.0.1.0

### [Download](https://edelivery.oracle.com)

![edelivery.oracle.com 접속 화면](C:/Users/Ark053/AppData/Roaming/Typora/typora-user-images/image-20230111110328196.png)

![Oracle Database 11g 검색](./Oracle%20Database%20Installation%20Guide.assets/image-20230111110407850.png)

![필요에 맞게 선택](./Oracle%20Database%20Installation%20Guide.assets/image-20230111110532816.png)

### User, Group 생성

```bash
# root #
groupadd dba	# dba group 생성
useradd -g dba oracle	# dba group의 User oracle 생성
passwd oracle	# User oracle의 Password 설정
```

### Oracle을 설치할 Directory 생성

```bash
# root #
mkdir -p /app/oracle	# Directory 생성
chown -R oracle.dba /app	# Directory Owner User, Group 변경
```

### 의존 Library 설치

```bash
# root #
yum -y install compat-libstdc++-33.x86_64 binutils elfutils-libelf elfutils-libelf-devel
yum -y install glibc glibc-common glibc-devel glibc-headers gcc gcc-c++ libaio libaio-devel
yum -y install libgcc libstdc++ libstdc++-devel make sysstat unixODBC unixODBC-devel
yum -y install unzip wget
wget ftp://ftp.pbone.net/mirror/archive.download.redhat.com/pub/redhat/linux/7.0/en/os/i386/RedHat/RPMS/pdksh-5.2.14-8.i386.rpm
rpm -Uvh --nodeps pdksh-5.2.14-8.i386.rpm --force
```

### OS Kernel Parameter 값 설정(ignore로 fix 가능)

```bash
# root #
vi /etc/sysctl.conf

# vi /etc/sysctl.conf st #
# Controls the maximum shared segment size, in bytes
kernel.shmmax = 68719476736

# Controls the maximum number of shared memory segments, in pages
kernel.shmall = 10523004
kernel.shmmni = 4096
kernel.sem = 250 32000 100 128

fs.aio-max-nr = 1048576
fs.file-max = 6815744

net.ipv4.ip_local_port_range = 9000 65500

net.core.rmem_default = 262144
net.core.rmem_max = 4194304
net.core.wmem_default = 262144
net.core.wmem_max = 1048586
# vi /etc/sysctl.conf ed #

/sbin/sysctl -p		# 적용
```

### User 자원 사용 제한 값 설정(ignore로 fix 가능)

```bash
# root #
vi /etc/security/limits.conf

# vi /etc/security/limits.conf st #
oracle soft nproc 2048
oracle hard nproc 65536
oracle soft nofile 1024
oracle hard nofile 65536
# vi /etc/security/limits.conf ed #
```

### SELINUX 설정 해제

```bash
# root #
vi /etc/selinux/config
# vi /etc/selinux/config st #
SELINUX=disabled
# vi /etc/selinux/config ed #
```

### Oracle User Environment Variable 설정

```bash
# oracle #
vi ~/.bash_profile

# vi ~/.bash_profile st #
export ORACLE_BASE=<oracle_base_path>	# ex) /app/oracle
export ORACLE_HOME=<oracle_home_path>	# ex) $ORACLE_BASE/product/11.2.0.1.0/dbhome_1
export ORACLE_SID=<oracle_sid>			# ex) orcl
export NLS_LANG=<nls_lang>				# ex) AMERICAN_AMERICA.AL32UTF8
export LD_LIBRARY_PATH=$ORACLE_HOME/lib:$LD_LIBRARY_PATH
export PATH=$ORACLE_HOME/bin:$PATH
```

### Swap Memory 설정(충분할 경우 필수 아님)

Expected Value까지 Swap Memory 확보

```bash
# root #
free -h					# Swap Memory 확인

dd if=<dev_path> of=<swap_file> bs=<bytes> count=<count>	# Swap Memory File 생성
						# ex) dd if=/dev/zero of=/home/swapfile bs=1024 count=1000000	# 1GB의 Swap Memory File 생성
				
mkswap <swap_file>		# File에 Swap Memory 영역 설정			# ex) mkswap /home/swapfile

swapon <swap_file>		# Swap Memory 활성화					# ex) swapon /home/swapfile
chmod 664 <swap_file>	# ex) chmod 664 /home/swapfile

vi /etc/fstab
# vi /etc/fstab st #
<swap_file>	swap	swap	defaults	1 1	# Swap Memory Rebooting 후에도 적용
						# ex) /home/swapfile	swap	swap defaults	1 1
# vi /etc/fstab ed #

free -h					# Swap Memory 확인

swapoff <swap_file>		# Swap Memory 비활성화					# ex) swapoff /home/swapfile
rm -rf <swap_file>		# Swap Memory File 삭제				# ex) rm -rf /home/swapfile
```

### Download한 File Unzip

```bash
# oracle #
unzip <oracle_zip_file_1>	# ex) unzip V17530-01_1of2.zip
unzip <oracle_zip_file_2>	# ex) unzip V17530-01_2of2.zip
```

### Installer 실행

```bash
# oracle #
./database/runInstaller
```

![My Oracle Support와 Email 무시](./Oracle%20Database%20Installation%20Guide.assets/image-20230111134803636.png)

![Install database software only](./Oracle%20Database%20Installation%20Guide.assets/image-20230111134852687.png)

![Single instance database installation(RAC database installation은 하기 전 GI 설치)](./Oracle%20Database%20Installation%20Guide.assets/image-20230111134917469.png)

![필요한 언어 추가](./Oracle%20Database%20Installation%20Guide.assets/image-20230111135015687.png)

![Enterprise Edition(실 서비스 이용이 아닌 이상 무료로 사용 가능)](./Oracle%20Database%20Installation%20Guide.assets/image-20230111135030945.png)

![Environment Variables와 비교](./Oracle%20Database%20Installation%20Guide.assets/image-20230111135101595.png)

![Environment Variables와 비교](./Oracle%20Database%20Installation%20Guide.assets/image-20230111135117466.png)

![Administrator Group과 Operator Group 확인](./Oracle%20Database%20Installation%20Guide.assets/image-20230111135139075.png)

![해결 가능한 문제들 해결하고 Ignore All Check 후 Next(?: libaio 및 다른 library를 설치했으나 i386을 찾음)](./Oracle%20Database%20Installation%20Guide.assets/image-20230111135312808.png)

![Finish](./Oracle%20Database%20Installation%20Guide.assets/image-20230111135447487.png)

![설치](./Oracle%20Database%20Installation%20Guide.assets/image-20230111135506353.png)

![설치 중 에러 발생 1](./Oracle%20Database%20Installation%20Guide.assets/image-20230111135711723.png)

설치 중 발생한 Error를 창을 유지시킨 채로 새 Session으로 들어가 수정

```bash
# oracle #
vi <error_mk_file>	# ex) vi /app/oracle/product/11.2.0.1.0/dbhome_1/ctx/lib/ins_ctx.mk

# vi <error_mk_file> st #
# ctxhx: $(CTXHXOBJ)
#	$(LINK_CTXHX) $(CTXHXOBJ) $(INSO_LINK) 부분을 아래와 같이 변경
ctxhx: $(CTXHXOBJ)
	-static $(LINK_CTXHX) $(CTXHXOBJ) $(INSO_LINK)
# vi <error_mk_file> st #
```

이후 Retry

![설치 중 에러 발생 2](./Oracle%20Database%20Installation%20Guide.assets/image-20230111140323885.png)

설치 중 발생한 Error를 창을 유지시킨 채로 새 Session으로 들어가 수정

```bash
# oracle #
vi <error_mk_file>	# ex) vi /app/oracle/product/11.2.0.1.0/dbhome_1/sysman/lib/ins_emagent.mk

# vi <error_mk_file> st #
# $(SYSMANBIN) emdctl:
#	$(MK_EMAGENT_NMECTL) 부분을 아래와 같이 변경
$(SYSMANBIN) emdctl:
	$(MK_EMAGENT_NMECTL) -lnnz11
# vi <error_mk_file> st #
```

이후 Retry

![설치 완료되기 전 root user로 해당 script들 실행](./Oracle%20Database%20Installation%20Guide.assets/image-20230111140912674.png)

```bash
# root #
<script1>	# ex) /app/oraInventory/orainstRoot.sh
<script2>	# ex) /app/oracle/product/11.2.0.1.0/dbhome_1/root.sh
# <script2> st #
[root@localhost ~]# /app/oracle/product/11.2.0.1.0/dbhome_1/root.sh
Running Oracle 11g root.sh script...

The following environment variables are set as:
    ORACLE_OWNER= oracle
    ORACLE_HOME=  /app/oracle/product/11.2.0.1.0/dbhome_1

Enter the full pathname of the local bin directory: [/usr/local/bin]:<press_enter(Default)>
   Copying dbhome to /usr/local/bin ...
   Copying oraenv to /usr/local/bin ...
   Copying coraenv to /usr/local/bin ...


Creating /etc/oratab file...
Entries will be added to the /etc/oratab file as needed by
Database Configuration Assistant when a database is created
Finished running generic part of root.sh script.
Now product-specific root actions will be performed.
Finished product-specific root actions.
# <script2> ed #
```

![설치 완료](./Oracle%20Database%20Installation%20Guide.assets/image-20230111141342821.png)

### Listener 생성

```bash
# oracle #
netca
```

![Listener configuration](./Oracle%20Database%20Installation%20Guide.assets/image-20230111141501398.png)

![최초 구성이여서 Add 밖에 선택 못함](./Oracle%20Database%20Installation%20Guide.assets/image-20230111141536254.png)

![Listener Name 설정(Default)](./Oracle%20Database%20Installation%20Guide.assets/image-20230111141556392.png)

![Protocol 설정(Default)](./Oracle%20Database%20Installation%20Guide.assets/image-20230111141613454.png)

![Oracle Port Number 지정(Default)](./Oracle%20Database%20Installation%20Guide.assets/image-20230111141653985.png)

![추가 Listener 설정 여부(Default)](./Oracle%20Database%20Installation%20Guide.assets/image-20230111141712811.png)

![완료 후 Finish](./Oracle%20Database%20Installation%20Guide.assets/image-20230111141745659.png)

### Database 생성

```bash
# oracle #
dbca
```

![DB 생성](./Oracle%20Database%20Installation%20Guide.assets/image-20230111141842719.png)

![DB 생성(Default)](./Oracle%20Database%20Installation%20Guide.assets/image-20230111141858999.png)

![DB Template 선택(Default)](./Oracle%20Database%20Installation%20Guide.assets/image-20230111141931462.png)

![Global Database Name과 SID 설정](./Oracle%20Database%20Installation%20Guide.assets/image-20230111141957566.png)

![Enterprise Manager 설정(Default)](./Oracle%20Database%20Installation%20Guide.assets/image-20230111142029977.png)

![Administrator 계정 Password 설정(Use the Same Administrative Password for All Accounts)](./Oracle%20Database%20Installation%20Guide.assets/image-20230111142120415.png)

![Storage Type과 Location 설정(Default)](./Oracle%20Database%20Installation%20Guide.assets/image-20230111142220931.png)

![Recovery Option 선택(Default)](./Oracle%20Database%20Installation%20Guide.assets/image-20230111142253691.png)

![Sample Schema와 Custom Script 여부(Default)](./Oracle%20Database%20Installation%20Guide.assets/image-20230111142358687.png)

![Memory 설정(Default(사양에 적당하게 알아서 계산해서 설정됨))](./Oracle%20Database%20Installation%20Guide.assets/image-20230111142449742.png)

![Block Size와 Process 개수 확인(Default)](./Oracle%20Database%20Installation%20Guide.assets/image-20230111142536147.png)

![DB Character Set 설정(AL32UTF8)](./Oracle%20Database%20Installation%20Guide.assets/image-20230111142618890.png)

![Connection Mode 설정(Default)](./Oracle%20Database%20Installation%20Guide.assets/image-20230111142650446.png)

![설정 확인 창](./Oracle%20Database%20Installation%20Guide.assets/image-20230111142714649.png)

![Finish](./Oracle%20Database%20Installation%20Guide.assets/image-20230111142727768.png)

![설치 전 요약 창](./Oracle%20Database%20Installation%20Guide.assets/image-20230111142830555.png)

![설치 중](./Oracle%20Database%20Installation%20Guide.assets/image-20230111143054942.png)

![설치 완료](./Oracle%20Database%20Installation%20Guide.assets/image-20230111143248876.png)

### 정상적으로 설치되었는지 확인

```bash
# oracle #
sqlplus -version
sqlplus / as sysdba
```

```sql
shutdown immediate
startup
exit
```

```bash
# oracle #
lsnrctl start
lsnrctl status
```

## Oracle Database 12c Enterprise 12.2.0.1.0

### [Download](https://edelivery.oracle.com)

![edelivery.oracle.com 접속 화면](./Oracle%20Database%20Installation%20Guide.assets/image-20230111110328196.png)

![Oracle Database 12c 검색](./Oracle%20Database%20Installation%20Guide.assets/image-20230111143945928.png)

![필요에 맞게 선택](./Oracle%20Database%20Installation%20Guide.assets/image-20230111144111457.png)

### User, Group 생성

```bash
# root #
groupadd dba	# dba group 생성
useradd -g dba oracle	# dba group의 User oracle 생성
passwd oracle	# User oracle의 Password 설정
```

### Oracle을 설치할 Directory 생성

```bash
# root #
mkdir -p /app/oracle	# Directory 생성
chown -R oracle.dba /app	# Directory Owner User, Group 변경
```

### 의존 Library 설치

```bash
# root #
yum -y install compat-libstdc++-33.x86_64 binutils elfutils-libelf elfutils-libelf-devel
yum -y install glibc glibc-common glibc-devel glibc-headers gcc gcc-c++ libaio libaio-devel
yum -y install libgcc libstdc++ libstdc++-devel make sysstat unixODBC unixODBC-devel
yum -y install unzip wget ksh
```

### OS Kernel Parameter 값 설정

```bash
# root #
vi /etc/sysctl.conf

# vi /etc/sysctl.conf st #
# Controls the maximum shared segment size, in bytes
kernel.shmmax = 4398046511104

# Controls the maximum number of shared memory segments, in pages
kernel.shmall = 1073741824
kernel.shmmni = 16384
kernel.sem = 1000 32000 1000 1000

fs.aio-max-nr = 1048576
fs.file-max = 16777216

net.ipv4.ip_local_port_range = 9000 65500

net.core.rmem_default = 262144
net.core.rmem_max = 4194304
net.core.wmem_default = 262144
net.core.wmem_max = 1048586
# vi /etc/sysctl.conf ed #

/sbin/sysctl -p		# 적용
```

### User 자원 사용 제한 값 설정

```bash
# root #
vi /etc/security/limits.conf

# vi /etc/security/limits.conf st #
oracle soft nproc 2047
oracle hard nproc 16384
oracle soft nofile 1024
oracle hard nofile 65536
# vi /etc/security/limits.conf ed #
```

### SELINUX 설정 해제

```bash
# root #
vi /etc/selinux/config
# vi /etc/selinux/config st #
SELINUX=disabled
# vi /etc/selinux/config ed #
```

### Oracle User Environment Variable 설정

```bash
# oracle #
vi ~/.bash_profile

# vi ~/.bash_profile st #
export TMP=/tmp
export TMPDIR=$TMP
export ORACLE_BASE=<oracle_base_path>	# ex) /app/oracle
export ORACLE_HOME=<oracle_home_path>	# ex) $ORACLE_BASE/product/12.2.0.1.0/dbhome_1
export ORACLE_SID=<oracle_sid>			# ex) orcl
export NLS_LANG=<nls_lang>				# ex) AMERICAN_AMERICA.AL32UTF8
export ORACLE_HOME_LISTNER=$ORACLE_HOME/bin/lsnrctl
export LD_LIBRARY_PATH=$ORACLE_HOME/lib:$LD_LIBRARY_PATH
export PATH=$ORACLE_HOME/bin:$PATH:$HOME/.local/bin:$HOME/bin
```

### Java 설치 및 Environment Variable 설정

설치를 위해 Java가 필요

```bash
# root #
java -version	# 설치되었을 시 Java 설치 할 필요 없음

yum list installed | grep java	# 이미 설치된 Java Version 확인

yum -y remove <java>	# Java 삭제 원할 시 실행 # ex) yum -y remove java-1.8.0-openjdk.x86_64
```

> [Oracle JDK](https://www.oracle.com/java/technologies/javase-downloads.html)

```bash
# root #
cd /usr/lib	# Program과 Sub System을 위한 변경되지 않는 Data File

wget <jdk_path>	# ex) wget https://download.java.net/java/GA/jdk16.0.2/d4a915d82b4c4fbb9bde534da945d746/7/GPL/openjdk-16.0.2_linux-x64_bin.tar.gz

tar -zxvf <jdk_tar>	# ex) tar -zxvf openjdk-16.0.2_linux-x64_bin.tar.gz

vi /etc/profile	# Environment Variable 등록
# vi /etc/profile st #
export JAVA_HOME=<java_path> # ex) export JAVA_HOME=usr/lib/jdk-16.0.2
export PATH=$PATH:$JAVA_HOME/bin
# vi /etc/profile ed #

source /etc/profile	# 적용
```

### Swap Memory 설정(충분할 경우 필수 아님)

Expected Value까지 Swap Memory 확보

```bash
# root #
free -h					# Swap Memory 확인

dd if=<dev_path> of=<swap_file> bs=<bytes> count=<count>	# Swap Memory File 생성
						# ex) dd if=/dev/zero of=/home/swapfile bs=1024 count=1000000	# 1GB의 Swap Memory File 생성
				
mkswap <swap_file>		# File에 Swap Memory 영역 설정			# ex) mkswap /home/swapfile

swapon <swap_file>		# Swap Memory 활성화					# ex) swapon /home/swapfile
chmod 664 <swap_file>	# ex) chmod 664 /home/swapfile

vi /etc/fstab
# vi /etc/fstab st #
<swap_file>	swap	swap	defaults	1 1	# Swap Memory Rebooting 후에도 적용
						# ex) /home/swapfile	swap	swap defaults	1 1
# vi /etc/fstab ed #

free -h					# Swap Memory 확인

swapoff <swap_file>		# Swap Memory 비활성화					# ex) swapoff /home/swapfile
rm -rf <swap_file>		# Swap Memory File 삭제				# ex) rm -rf /home/swapfile
```

### Download한 File Unzip

```bash
# oracle #
unzip <oracle_zip_file>	# ex) unzip V839960-01.zip
```

### Installer 실행

```bash
# oracle #
./database/runInstaller
```

![설치](./Oracle%20Database%20Installation%20Guide.assets/image-20230111162553817.png)

![이번에는 Create and configure a database로 설치](./Oracle%20Database%20Installation%20Guide.assets/image-20230111162646547.png)

![Server Class의 경우 RAC Instance에 대한 Option을 선택 가능](./Oracle%20Database%20Installation%20Guide.assets/image-20230111162907127.png)

![Single Instance를 설치할 예정(Default)](./Oracle%20Database%20Installation%20Guide.assets/image-20230111162932994.png)

![Typical install 진행(Default)](./Oracle%20Database%20Installation%20Guide.assets/image-20230111163031659.png)

![Password 설정해주고 Container DB를 사용하지 않을 예정이기에 해제](./Oracle%20Database%20Installation%20Guide.assets/image-20230111163418519.png)

![Environment Variable들과 비교, 확인](./Oracle%20Database%20Installation%20Guide.assets/image-20230111163520034.png)

![고칠 수 있는 것을 고치고 Ignore All](./Oracle%20Database%20Installation%20Guide.assets/image-20230111163737908.png)

![설치 요약 확인](./Oracle%20Database%20Installation%20Guide.assets/image-20230111164250478.png)

![설치](./Oracle%20Database%20Installation%20Guide.assets/image-20230111164337660.png)

![설치 완료되기 전 root user로 해당 script들 실행](./Oracle%20Database%20Installation%20Guide.assets/image-20230111164824552.png)

```bash
# root #
<script1>	# ex) /app/oraInventory/orainstRoot.sh
<script2>	# ex) /app/oracle/product/12.2.0.1.0/dbhome_1/root.sh
# <script2> st #
[root@localhost ~]# /app/oracle/product/12.2.0.1.0/dbhome_1/root.sh
Performing root user operation.

The following environment variables are set as:
    ORACLE_OWNER= oracle
    ORACLE_HOME=  /app/oracle/product/12.2.0.1.0/dbhome_1

Enter the full pathname of the local bin directory: [/usr/local/bin]:<press_enter(Default)>
   Copying dbhome to /usr/local/bin ...
   Copying oraenv to /usr/local/bin ...
   Copying coraenv to /usr/local/bin ...


Creating /etc/oratab file...
Entries will be added to the /etc/oratab file as needed by
Database Configuration Assistant when a database is created
Finished running generic part of root script.
Now product-specific root actions will be performed.
Do you want to setup Oracle Trace File Analyzer (TFA) now ? yes|[no] :<press_enter(Default)>

Oracle Trace File Analyzer (TFA - User Mode) is available at :
    /app/oracle/product/12.2.0.1.0/dbhome_1/suptools/tfa/release/tfa_home/bin/tfactl

OR

Oracle Trace File Analyzer (TFA - Daemon Mode) can be installed by running this script :
    /app/oracle/product/12.2.0.1.0/dbhome_1/suptools/tfa/release/tfa_home/install/roottfa.sh
# <script2> ed #
```

![설치 완료](./Oracle%20Database%20Installation%20Guide.assets/image-20230111165914902.png)

### 정상적으로 설치되었는지 확인

```bash
# oracle #
sqlplus -version
sqlplus / as sysdba
```

```sql
shutdown immediate
startup
exit
```

```bash
# oracle #
lsnrctl start
lsnrctl status
```

## Oracle Database 19c Enterprise 19.3.0.0.0

### [Download](https://edelivery.oracle.com)

![edelivery.oracle.com 접속 화면](./Oracle%20Database%20Installation%20Guide.assets/image-20230111110328196-1673425487179-2.png)

![Oracle Database 11g 검색](./Oracle%20Database%20Installation%20Guide.assets/image-20230111171750565.png)

![필요에 맞게 선택](./Oracle%20Database%20Installation%20Guide.assets/image-20230111171901160.png)

### User, Group 생성

```bash
# root #
groupadd dba	# dba group 생성
useradd -g dba oracle	# dba group의 User oracle 생성
passwd oracle	# User oracle의 Password 설정
```

### Oracle을 설치할 Directory 생성

```bash
# root #
mkdir -p /app/oracle/product/19.3.0.0.0/dbhome_1	# Directory 생성(ORACLE_HOME)
chown -R oracle.dba /app	# Directory Owner User, Group 변경
```

### 의존 Library 설치

```bash
# root #
yum -y install compat-libstdc++-33.x86_64 binutils elfutils-libelf elfutils-libelf-devel
yum -y install glibc glibc-common glibc-devel glibc-headers gcc gcc-c++ libaio libaio-devel
yum -y install libgcc libstdc++ libstdc++-devel make sysstat unixODBC unixODBC-devel
yum -y install unzip wget ksh
yum -y install https://yum.oracle.com/repo/OracleLinux/OL7/latest/x86_64/getPackage/oracle-database-preinstall-19c-1.0-3.el7.x86_64.rpm
```

### Oracle User Environment Variable 설정

```bash
# oracle #
vi ~/.bash_profile

# vi ~/.bash_profile st #
export TMP=/tmp
export TMPDIR=$TMP
export ORACLE_BASE=<oracle_base_path>	# ex) /app/oracle
export ORACLE_HOME=<oracle_home_path>	# ex) $ORACLE_BASE/product/19.3.0.0.0/dbhome_1
export ORACLE_SID=<oracle_sid>			# ex) orcl
export NLS_LANG=<nls_lang>				# ex) AMERICAN_AMERICA.AL32UTF8
export TNS_ADMIN=$ORACLE_HOME/network/admin
export ORACLE_HOSTNAME=<hostname>		# ex) localhost
export LD_LIBRARY_PATH=$ORACLE_HOME/lib:$LD_LIBRARY_PATH
export PATH=$ORACLE_HOME/bin:$PATH:$HOME/.local/bin:$HOME/bin
# vi ~/.bash_profile ed #
```

### Download한 File Unzip

```bash
# oracle #
mv <oracle_zip_file> $ORACLE_HOME
cd $ORACLE_HOME
unzip <oracle_zip_file>	# ex) unzip V982063-01.zip
```

### Installer 실행

```bash
# oracle #
./runInstaller
```

![Default](./Oracle%20Database%20Installation%20Guide.assets/image-20230112093849093.png)

![Server class](./Oracle%20Database%20Installation%20Guide.assets/image-20230112093902747.png)

![Default](./Oracle%20Database%20Installation%20Guide.assets/image-20230112093916363.png)

![ORACLE_BASE, ORACLE_HOME 확인](./Oracle%20Database%20Installation%20Guide.assets/image-20230112093932634.png)

![Inventory, Inventory에 Write할 수 있는 Group 확인](./Oracle%20Database%20Installation%20Guide.assets/image-20230112094011275.png)

![Default](./Oracle%20Database%20Installation%20Guide.assets/image-20230112094101686.png)

![CDB, PDB 사용하지 않을 예정이기에 체크 해제](./Oracle%20Database%20Installation%20Guide.assets/image-20230112094113302.png)

![설정 값 확인](./Oracle%20Database%20Installation%20Guide.assets/image-20230112094135707.png)

![Character Set 확인](./Oracle%20Database%20Installation%20Guide.assets/image-20230112094302839.png)

![Default(Sample Schema 필요 없음)](./Oracle%20Database%20Installation%20Guide.assets/image-20230112094315984.png)

![ASM 설치하지 않았기에 Default](./Oracle%20Database%20Installation%20Guide.assets/image-20230112094428270.png)

![EM Cloud Control 사용하지 않기에 Default](./Oracle%20Database%20Installation%20Guide.assets/image-20230112094457427.png)

![Recovery 설정](./Oracle%20Database%20Installation%20Guide.assets/image-20230112094523440.png)

![Oracle Administrator Password 설정](./Oracle%20Database%20Installation%20Guide.assets/image-20230112094558425.png)

![oper Group 미생성이기에 dba](./Oracle%20Database%20Installation%20Guide.assets/image-20230112094639912.png)

![root로 실행해야 하는 Script 자동 동작 설정](./Oracle%20Database%20Installation%20Guide.assets/image-20230112094708505.png)

![고칠 수 있는 것 고치고 Ignore All](./Oracle%20Database%20Installation%20Guide.assets/image-20230112094751645.png)

![설치 요약 페이지](./Oracle%20Database%20Installation%20Guide.assets/image-20230112094822087.png)

![설치](./Oracle%20Database%20Installation%20Guide.assets/image-20230112094841501.png)

![root User가 Script 실행할건지 여부(Yes)](./Oracle%20Database%20Installation%20Guide.assets/image-20230112095014350.png)

![설치 완료](./Oracle%20Database%20Installation%20Guide.assets/image-20230112100308558.png)

### 정상적으로 설치되었는지 확인

```bash
# oracle #
sqlplus -version
sqlplus / as sysdba
```

```sql
shutdown immediate
startup
exit
```

```bash
# oracle #
lsnrctl start
lsnrctl status
```