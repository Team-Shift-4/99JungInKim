```sql
CREATE TABLESPACE ARK_TBS DATAFILE '/data1/oracle/11g/oradata/ORA11a/arktbs01.dbf' SIZE 100M;
ALTER TABLESPACE ARK_TBS ADD DATAFILE '/data1/oracle/11g/oradata/ORA11a/arktbs02.dbf' SIZE 100M;

ALTER DATABASE DATAFILE '/data1/oracle/11g/oradata/ORA11a/arktbs01.dbf' RESIZE 500M;
ALTER DATABASE DATAFILE '/data1/oracle/11g/oradata/ORA11a/arktbs01.dbf' AUTOEXTEND ON NEXT 100M MAXSIZE 1000M;

DROP TABLESPACE ARK_TBS;
DROP TABLESPACE ARK_TBS INCLUDING CONTENTS AND DATAFILES;


select distinct d.file_id   file#,
    d.tablespace_name       ts_name,
    d.bytes /1024 /1024     MB,
    d.bytes / 8192          total_blocks,
    sum(e.blocks)           used_blocks,
    to_char( nvl( round( sum(e.blocks)/(d.bytes/8192), 4),0) *100,'09.99') || ' %' pct_used
from dba_extents e, dba_data_files d
where d.file_id = e.file_id(+)
group by d.file_id , d.tablespace_name , d.bytes
order by 1,2 ;

desc dba_free_space

select tablespace_name, round((sum(bytes)/1024/1024), 0) MB 
from dba_free_space 
group by tablespace_name

select tablespace_name, bytes/1024/1024 MB,
    file_name, autoextensible AUTO, status
from dba_data_files;

select
    tablespace_name
    ,contents
    ,extent_management
    ,allocation_type
    ,segment_space_management
    ,bigfile 
from dba_tablespaces 
where tablespace_name = 'ARK_TBS'

CREATE TEMPORARY TABLESPACE ARK_TEMP
TEMPFILE '/data1/oracle/11g/oradata/ORA11a/ark_temp01.dbf' SIZE 50M 
EXTENT MANAGEMENT LOCAL;
DROP TABLESPACE ARK_TEMP INCLUDING CONTENTS AND DATAFILES;

--ALTER DATABASE DEFAULT TEMPORARY TABLESPACE ARK_TEMP;

CREATE USER arktest IDENTIFIED BY rnd5815 DEFAULT TABLESPACE ARK_TBS TEMPORARY TABLESPACE ARK_TEMP;
GRANT connect, resource TO arktest;

select * from user_constraints where OWNER = 'ARKTEST';
select * from dba_constraints where table_name = upper('test1');

select a.process, a.sid, a.serial# from v$session a, v$lock b, dba_objects c where a.sid=b.sid and b.id1=c.object_id and username = 'ARKTEST'
alter system kill session '160, 48393';
```

```sql
select sysdate from dual;

DROP TABLE TAB_TEST01;
DROP TABLE TAB_TEST02;
DROP TABLE TAB_TEST03;
DROP TABLE TAB_TEST04;
DROP TABLE TAB_TEST05;


CREATE TABLE TAB_TEST01
(	ID NUMBER PRIMARY KEY,
	NAME VARCHAR2(30),
	SAL NUMBER(7,2),
	HIREDATE DATE,
	ADDRESS VARCHAR2(100)
);

CREATE TABLE TAB_TEST02
(	ID NUMBER,
	NAME VARCHAR2(30),
	SAL NUMBER(7,2),
	HIREDATE DATE,
	ADDRESS VARCHAR2(100),
	PRIMARY KEY (ID, NAME)
);

CREATE TABLE TAB_TEST03
(	ID NUMBER,
	NAME VARCHAR2(30),
	SAL NUMBER(7,2),
	HIREDATE DATE,
	ADDRESS VARCHAR2(100)
);


CREATE TABLE TAB_TEST04
(	ID NUMBER,
	NAME VARCHAR2(30),
	SAL NUMBER(7,2),
	HIREDATE DATE,
	ADDRESS VARCHAR2(100)
);

CREATE TABLE TAB_TEST05
(	ID NUMBER NOT NULL UNIQUE,
	NAME VARCHAR2(30),
	SAL NUMBER(7,2),
	HIREDATE DATE DEFAULT SYSDATE NOT NULL,
	ADDRESS VARCHAR2(100)
);

desc TAB_TEST01;
desc TAB_TEST02;
desc TAB_TEST03;
desc TAB_TEST04;
desc TAB_TEST05;

CREATE INDEX TAB_TEST03_ID_IDX ON TAB_TEST03(ID);

select * from user_constraints where table_name like 'TAB_TEST%';


insert into TAB_TEST01(ID, NAME, SAL, HIREDATE, ADDRESS)
values(1001, 'jason', 1000, TO_DATE('2020-01-01', 'YYYY-MM-DD'), NULL);
insert into TAB_TEST01(ID, NAME, SAL, HIREDATE, ADDRESS)
values(1001, 'james', 2000, TO_DATE('2021-01-01', 'YYYY-MM-DD'), NULL);
insert into TAB_TEST01(ID, NAME, SAL, HIREDATE, ADDRESS)
values(NULL, 'scott', 2000, TO_DATE('2022-01-01', 'YYYY-MM-DD'), NULL);
insert into TAB_TEST01(ID, NAME, SAL, HIREDATE, ADDRESS)
values(1002, 'john', 3000, TO_DATE('2022-01-01', 'YYYY-MM-DD'), NULL);
commit;

select * from TAB_TEST01;

insert into TAB_TEST02(ID, NAME, SAL, HIREDATE, ADDRESS)
values(1001, 'jason', 1000, TO_DATE('2020-01-01', 'YYYY-MM-DD'), NULL);
insert into TAB_TEST02(ID, NAME, SAL, HIREDATE, ADDRESS)
values(1001, 'james', 2000, TO_DATE('2021-01-01', 'YYYY-MM-DD'), NULL);
insert into TAB_TEST02(ID, NAME, SAL, HIREDATE, ADDRESS)
values(NULL, 'scott', 2000, TO_DATE('2022-01-01', 'YYYY-MM-DD'), NULL);
insert into TAB_TEST02(ID, NAME, SAL, HIREDATE, ADDRESS)
values(1002, 'john', 3000, TO_DATE('2022-01-01', 'YYYY-MM-DD'), NULL);
commit;

select * from TAB_TEST02;


insert into TAB_TEST03(ID, NAME, SAL)
values(1001, 'jason', 1000);
insert into TAB_TEST03(ID, NAME, SAL)
values(1001, 'james', 2000);
insert into TAB_TEST03(ID, NAME, SAL)
values(NULL, 'scott', 2000);
insert into TAB_TEST03(ID, NAME, SAL)
values(1002, 'john', 3000);
commit;

select * from TAB_TEST03;

insert into TAB_TEST04(ID, NAME, SAL)
values(1001, 'jason', 1000);
insert into TAB_TEST04(ID, NAME, SAL)
values(1001, 'james', 2000);
insert into TAB_TEST04(ID, NAME, SAL)
values(NULL, 'scott', 2000);
insert into TAB_TEST04(ID, NAME, SAL)
values(1002, 'john', 3000);
commit;

select * from TAB_TEST04;


insert into TAB_TEST05(ID, NAME, SAL)
values(1001, 'jason', 1000);
insert into TAB_TEST05(ID, NAME, SAL)
values(1001, 'james', 2000);
insert into TAB_TEST05(ID, NAME, SAL)
values(NULL, 'scott', 2000);
insert into TAB_TEST05(ID, NAME, SAL)
values(1002, 'john', 3000);
commit;

select * from TAB_TEST05;
```

