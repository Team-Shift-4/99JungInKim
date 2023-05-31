# MySQL & MariaDB

### MySQL

```bash
#설치
yum localinstall https://dev.mysql.com/get/mysql57-community-release-el7-11.noarch.rpm
yum install mysql-community-server

#GPG key 오류시 해결
rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2022

#시작 시 작동 및 mysql 구동
systemctl enable mysqld
systemctl start mysqld

#root 임시 비밀번호
grep 'temporary password' /var/log/mysqld.log

#시작
mysql -u root -p
```

```sql
-- root 비밀번호 변경
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password by '<password>';

-- 변경사항 저장
FLUSH PRIVILEGES;
```

### MariaDB

```bash
# 설치
yum install -y mariadb-server

#설치 확인
rpm -qa maria*

#mysql DB 생성 및 계정 생성
mysql_install_db --user=mariadb

#시작 시 작동 및 mariadb 구동
systemctl enable mariadb
systemctl start mariadb

#MariaDB 접속
mysqladmin password <password>
mysql -u root -p
```

# 문제 해결

- [FATAL] Mysql error> error code : [1045], sql sqlstate [28000], error message : [Access denied for user 'ARKMGR'@'192.168.56.120' (using password: YES)]$
    - 다 맞게 설정해도 안되었는데 default.conn의 `USERNAME`이 대소문자를 가려 소문자로 바꾸니 해결
    - 이전에 문제를 미리 피하기 위해 계정을 만들 때 localhost가 아닌 %로 모든 ip에 대한 접속 허용 및 권한 부여
- [FATAL] Mysql error> error code : [1049], sql sqlstate [42000], error message : [Unknown database 'mariadb']$
    - MariaDB에서 기본적으로 생성되는 DB에 연결하고 싶다면 이름은 `DBNAME`은 mysql이다