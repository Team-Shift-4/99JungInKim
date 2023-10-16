------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------   UPDATE CHAINING / MIGRATION   ---------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------

-- UPDATE CHAINING / MIGRATION 테스트 케이스 #1 : row 분리 테스트
DROP TABLE UPD_CHAIN_TEST;

CREATE TABLE UPD_CHAIN_TEST (
		r_id	  NUMBER primary key,
        A    VARCHAR2(4000), 
        B    VARCHAR2(4000), 
        C    VARCHAR2(4000) NOT NULL, 
        D    VARCHAR2(4000), 
        E    VARCHAR2(4000)
);


-- 233 byte의 row 저장 ( block 당 33개 )
DECLARE
    r_id NUMBER := 1;
BEGIN
    FOR i IN 1..34 LOOP
        INSERT INTO UPD_CHAIN_TEST VALUES ( r_id,
                                                                            LPAD('A', 40 ,'A'),
                                                                            LPAD('B', 40 ,'B'),
                                                                            LPAD('C', 40 ,'C'),
                                                                            LPAD('D', 40 ,'D'),
                                                                            LPAD('E', 40 ,'E')
        );
        r_id := r_id + 1;
    END LOOP;
    commit;
END;
/

-- 1. 2개의 row로 분리 -->  H (lock) -> FL (insert : r_id ~ e)  > H (overwrite)
UPDATE UPD_CHAIN_TEST SET B = LPAD('B', 335 ,'B'),  c = LPAD('C', 335 ,'C'),  d = LPAD('D', 335 ,'D') WHERE r_id = 1;
COMMIT;

-- 2. Update FL block -->  H (lock) -> FL (update:  b, e)
UPDATE  UPD_CHAIN_TEST SET B = LPAD('B', 200 ,'B'),  e = LPAD('E', 200 ,'E')  WHERE r_id = 1;
COMMIT;

-- 3. 3개의 row로 분리 -->  H (lock) -> L (insert : D, E) -> F (insert: r_id ~ C) -> FL (delete) -> CFA
UPDATE  UPD_CHAIN_TEST SET C = LPAD('C', 4000 ,'C'),  e = LPAD('E', 4000 ,'E')  WHERE r_id = 1;
COMMIT;

-- 4. Update L block --> H (lock) -> Logminer (r_id) -> L (update: D, E)
UPDATE  UPD_CHAIN_TEST SET D = LPAD('D', 100 ,'D'),  e = LPAD('E', 100 ,'E')  WHERE r_id = 1;
COMMIT;

-- 5. Update F block --> H(lock) -> F (update : B)
UPDATE  UPD_CHAIN_TEST SET B = LPAD('X', 10 ,'X')  WHERE r_id = 1;
COMMIT;

-- 6. Update F, L block --> H(lock) -> F (update : C) -> L (update : D, E)
UPDATE  UPD_CHAIN_TEST SET  C = LPAD('C', 500 ,'C') , D = LPAD('D', 200 ,'D'),  e = LPAD('E', 200 ,'E')  WHERE r_id = 1;
COMMIT;

--  chaining된 block의 free space에 row 저장
DECLARE
    r_id NUMBER := 35;
BEGIN
    FOR i IN 1..100 LOOP
        INSERT INTO UPD_CHAIN_TEST VALUES ( r_id,
                                                                            LPAD('A', 40 ,'A'),
                                                                            LPAD('B', 40 ,'B'),
                                                                            LPAD('C', 40 ,'C'),
                                                                            LPAD('D', 40 ,'D'),
                                                                            LPAD('E', 40 ,'E')
        );
        r_id := r_id + 1;
    END LOOP;
    commit;
END;
/

-- 7. 4개의 row로 분리  H (lock) -> C (insert : C) -> F (insert : r_id ~ B) -> F (delete : r_id ~ B) -> 11.8
UPDATE  UPD_CHAIN_TEST SET  B = LPAD('B', 4000 ,'B'), C = LPAD('C', 4000 ,'C') WHERE r_id = 1;
COMMIT;

-- Update F, C block --> H (lock) -> C (update: C) -> F (update:B)
UPDATE  UPD_CHAIN_TEST SET  B = LPAD('B', 100 ,'B'), C = LPAD('C', 100 ,'C') WHERE r_id = 1;
COMMIT;

-- Update C, L block  --> H (lock) -> C (update: C) -> L (update:E)
UPDATE  UPD_CHAIN_TEST SET  E = LPAD('E', 100 ,'E'), C = LPAD('C', 200 ,'C') WHERE r_id = 1;
COMMIT;

-- add not null default 
ALTER TABLE UPD_CHAIN_TEST ADD F VARCHAR2(4000) default 'F' NOT NULL;

-- Update F block -->   H (lock) -> F (update : A, B)
UPDATE  UPD_CHAIN_TEST SET  A = LPAD('A', 200 ,'A'), B = LPAD('B', 200 ,'B') WHERE r_id = 1;
COMMIT;

-- Update C block -->  H (lock) -> Logminer (r_id) -> C (update :C)
UPDATE  UPD_CHAIN_TEST SET  C = LPAD('C', 400 ,'C' ) WHERE r_id = 1;
COMMIT;


-- Update L block --> H (lock) -> Logminer (r_id) -> C (update :C)
UPDATE  UPD_CHAIN_TEST SET  D = LPAD('D', 200 ,'D' )WHERE r_id = 1;
COMMIT;

-- Update L block #2 --> H(lock) -> Logminer (r_id) -> L (update:E, F) -> lomginer (F)
UPDATE  UPD_CHAIN_TEST SET  E = LPAD('E', 500 ,'E' ), F = LPAD('F', 200, 'F') WHERE r_id = 1;
COMMIT;

------------------------------------------------------------------------------------------------------------------------------------------------------------
-- UPDATE CHAINING / MIGRATION 테스트 케이스 #2  
DROP TABLE UPD_CHAIN_TEST;
CREATE TABLE UPD_CHAIN_TEST (
		r_id	  NUMBER PRIMARY KEY,
        A    VARCHAR2(4000), 
        B    VARCHAR2(4000), 
        C    VARCHAR2(4000), 
        D    VARCHAR2(4000), 
        E    VARCHAR2(4000)
);

DECLARE
    r_id NUMBER := 1;
BEGIN
    FOR i IN 1..21 LOOP
        INSERT INTO UPD_CHAIN_TEST VALUES ( r_id,
                                                                            LPAD('A', 40 ,'A'),
                                                                            LPAD('B', 40 ,'B'),
                                                                            LPAD('C', 40 ,'C'),
                                                                            LPAD('D', 40 ,'D'),
                                                                            LPAD('E', 40 ,'E')
        );
        r_id := r_id + 1;
    END LOOP;
    commit;
END;
/

-- add column
ALTER TABLE UPD_CHAIN_TEST ADD F VARCHAR2(4000) default 'F' NOT NULL;
ALTER TABLE UPD_CHAIN_TEST ADD G VARCHAR2(4000);

-- HFL (update : A, B, E, F, G) -> logminer (G)
UPDATE  UPD_CHAIN_TEST SET  A = LPAD('A', 200,'A' ), B = LPAD('B', 200, 'B'), E = LPAD('C', 200, 'C'), F=LPAD('F', 200, 'F'), G= LPAD('G', 200, 'G' ) WHERE r_id = 1;
COMMIT;

-- H (lock) -> FL (insert : r_id ~ G) -> H (overwrite)  ------> default not null를 null로 추출한 이슈 재현 케이스 
UPDATE  UPD_CHAIN_TEST SET  A = LPAD('A', 1000,'A' ), B = LPAD('B', 1000, 'B'), E = LPAD('E', 1000, 'E'), G= LPAD('G', 2000, 'G' ) WHERE r_id = 20;
COMMIT;

------------------------------------------------------------------------------------------------------------------------------------------------------------
-- UPDATE CHAINING / MIGRATION 테스트 케이스 #3  
DROP TABLE UPD_CHAIN_TEST;
CREATE TABLE UPD_CHAIN_TEST (
		r_id	  NUMBER PRIMARY KEY,
        A    VARCHAR2(4000), 
        B    VARCHAR2(4000), 
        C    VARCHAR2(4000), 
        D    VARCHAR2(4000), 
        E    VARCHAR2(4000)
);

-- L (insert: B ~ E)  --> HF (insert: r_id ~ A)
INSERT INTO UPD_CHAIN_TEST VALUES(1, LPAD('A', 1700, 'A'), LPAD('B', 1700, 'B'), LPAD('C', 1700, 'C'), LPAD('D', 1700, 'D'), LPAD('E', 1700, 'E'));
commit;

-- add column
ALTER TABLE UPD_CHAIN_TEST ADD F VARCHAR2(4000) default 'F' NOT NULL;


-- H (lock) -> Logminer (NSRCI: r_id) -> L (update: F) -> Logminer (OSV: F)
UPDATE DEL_CHAIN_TEST  SET F = 'UPD-CASE 3';
commit;
------------------------------------------------------------------------------------------------------------------------------------------------------------





------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------                  INSERT CHAINING              ---------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------

DROP TABLE INSERT_CHAIN_TEST;
CREATE TABLE INSERT_CHAIN_TEST (
    r_id    NUMBER PRIMARY KEY,
    A       VARCHAR2(4000),
    B       VARCHAR2(4000),
    C       VARCHAR2(4000),
    D       VARCHAR2(4000),
    E       VARCHAR2(4000)
);

-- L (insert: B ~ E)  --> HF (insert: r_id ~ A)
INSERT INTO INSERT_CHAIN_TEST VALUES(1, LPAD('A', 1700, 'A'), LPAD('B', 1700, 'B'), LPAD('C', 1700, 'C'), LPAD('D', 1700, 'D'), LPAD('E', 1700, 'E'));
commit;

-- L (insert : D ~ E)  --> C (insert: B~ C) --> F (insert: r_id ~ A)
INSERT INTO INSERT_CHAIN_TEST VALUES(2, LPAD('A', 3500, 'A'), LPAD('B', 3500, 'B'), LPAD('C', 3500, 'C'), LPAD('D', 3500, 'D'), LPAD('E', 3500, 'E'));
commit;

-- L (insert : E ) --> C (insert: D) -> C (insert: C) -> C(insert: B) -> HF (insert: r_id ~ A)
INSERT INTO INSERT_CHAIN_TEST VALUES(3, LPAD('A', 4000, 'A'), LPAD('B', 4000, 'B'), LPAD('C', 4000, 'C'), LPAD('D', 4000, 'D'), LPAD('E', 4000, 'E'));
commit;


------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------                  DELETE CHAINING              ---------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------

--  DELETE CHAINING  테스트 케이스 #1,

DROP TABLE DEL_CHAIN_TEST;
CREATE TABLE DEL_CHAIN_TEST (
    r_id    NUMBER PRIMARY KEY,
    A       VARCHAR2(4000),
    B       VARCHAR2(4000),
    C       VARCHAR2(4000),
    D       VARCHAR2(4000),
    E       VARCHAR2(4000)
);

-- L (insert: B ~ E)  --> HF (insert: r_id ~ A)
INSERT INTO DEL_CHAIN_TEST VALUES(1, LPAD('A', 1700, 'A'), LPAD('B', 1700, 'B'), LPAD('C', 1700, 'C'), LPAD('D', 1700, 'D'), LPAD('E', 1700, 'E'));
-- L (insert : D ~ E)  --> C (insert: B~ C) --> HF (insert: r_id ~ A)
INSERT INTO DEL_CHAIN_TEST VALUES(2, LPAD('A', 3500, 'A'), LPAD('B', 3500, 'B'), LPAD('C', 3500, 'C'), LPAD('D', 3500, 'D'), LPAD('E', 3500, 'E'));
-- L (insert : E ) --> C (insert: D) -> C (insert: C) -> C(insert: B) -> HF (insert: r_id ~ A)
INSERT INTO DEL_CHAIN_TEST VALUES(3, LPAD('A', 4000, 'A'), LPAD('B', 4000, 'B'), LPAD('C', 4000, 'C'), LPAD('D', 4000, 'D'), LPAD('E', 4000, 'E'));
commit;

--  HF (delete: r_id ~ A) -> L (delete: B~E)
DELETE DEL_CHAIN_TEST where r_id = 1;
--  HF (delete: r_id ~ A) ->  C (insert: B~ C)
DELETE DEL_CHAIN_TEST where r_id = 2;
--  HF (delete: r_id ~ A) -> C (delete: B) -> C (delete: C) -> C (delete: D) ->  L (delete : E)
DELETE DEL_CHAIN_TEST where r_id = 3;
commit;


------------------------------------------------------------------------------------------------------------------------------------------------------------

-- DELETE CHAINING  테스트 케이스 #2.  위 Update chaining / migration 발생 후 DELETE 수행

------------------------------------------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------------------------------------------

-- DELETE CHAINING  테스트 케이스 #3
TRUNCATE TABLE DEL_CHAIN_TEST;

-- 233 byte의 row 저장 ( block 당 33개 )
DECLARE
    r_id NUMBER := 1;
BEGIN
    FOR i IN 1..34 LOOP
        INSERT INTO DEL_CHAIN_TEST VALUES ( r_id,
                                                                            LPAD('A', 40 ,'A'),
                                                                            LPAD('B', 40 ,'B'),
                                                                            LPAD('C', 40 ,'C'),
                                                                            LPAD('D', 40 ,'D'),
                                                                            LPAD('E', 40 ,'E')
        );
        r_id := r_id + 1;
    END LOOP;
    commit;
END;
/

--  H (lock) -> FL (insert : r_id ~ e)  > H (overwrite)
UPDATE  DEL_CHAIN_TEST SET b = LPAD('B', 335 ,'B'),  c = LPAD('C', 335 ,'C'),  d = LPAD('D', 335 ,'D') WHERE r_id = 1;
COMMIT;

-- H (delete) -> FL (delete : r_id ~ E)
DELETE DEL_CHAIN_TEST WHERE r_id = 1;
commit;

------------------------------------------------------------------------------------------------------------------------------------------------------------
-- DELETE CHAINING  테스트 케이스 #3 :  Delete chaining + Logminer 레코드 패턴
TRUNCATE TABLE DEL_CHAIN_TEST;

DECLARE
    r_id NUMBER := 1;
BEGIN
    FOR i IN 1..10 LOOP
    INSERT INTO DEL_CHAIN_TEST VALUES (r_id, LPAD('A', 1700, 'A'), LPAD('B', 1700, 'B'), LPAD('C', 1700, 'C'), LPAD('D', 1700, 'D'), LPAD('E', 1700, 'E') );
    r_id := r_id + 1;
    END LOOP;
    commit;
END;
/
-- default not null 컬럼 추가 
ALTER TABLE DEL_CHAIN_TEST ADD F VARCHAR2(4000) default 'F' NOT NULL;

-- default not null 컬럼 체크 
select col#, segcol#, name, property
from sys.col$ 
where obj# = (select object_id from dba_objects 
                        where owner = 'CDCTEST' and object_name = 'DEL_CHAIN_TEST' and object_type = 'TABLE')
order by col#, segcol#;


-- 다른 체이닝 레코드에 logminer 레코드 생성을 위해  default not null 컬럼 update 
UPDATE DEL_CHAIN_TEST  SET F = 'ARK';
commit;

-- HF  (delete: r_id ~ A) -> L (delete: B ~ E) -> Logminer (OSV: F)
DELETE DEL_CHAIN_TEST;
commit;

DROP TABLE DEL_CHAIN_TEST;
CREATE TABLE DEL_CHAIN_TEST (
    r_id    NUMBER PRIMARY KEY,
    A       VARCHAR2(4000),
    B       VARCHAR2(4000),
    C       VARCHAR2(4000),
    D       VARCHAR2(4000),
    E       VARCHAR2(4000)
);

-- L (insert: B ~ E)  --> HF (insert: r_id ~ A)
INSERT INTO DEL_CHAIN_TEST VALUES(1, LPAD('A', 1700, 'A'), LPAD('B', 1700, 'B'), LPAD('C', 1700, 'C'), LPAD('D', 1700, 'D'), LPAD('E', 1700, 'E'));
commit;

-- default not null 컬럼 추가 
ALTER TABLE DEL_CHAIN_TEST ADD F VARCHAR2(4000) default 'F' NOT NULL;

-- (r_id : 1) : H (lock) -> Logminer (NSRCI: r_id) -> L (update: F) -> Logminer (OSV: F)
UPDATE DEL_CHAIN_TEST  SET F = 'DEL-CASE 2';
commit;

DELETE DEL_CHAIN_TEST;
commit;

------------------------------------------------------------------------------------------------------------------------------------------------------------
-- SDO_GEOMETRY Table's row chaining / migration
------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE TABLE t_sp_chain (
		r_id NUMBER,
        A    VARCHAR2(4000), 
        B    VARCHAR2(4000), 
        C    VARCHAR2(4000), 
        C4   SDO_GEOMETRY,
        D    VARCHAR2(4000), 
        E    VARCHAR2(4000)
);

INSERT INTO t_sp_chain 
VALUES( 1, 
        LPAD('A', 3000 ,'A'),
        LPAD('B', 3000 ,'B'),
        LPAD('C', 3000 ,'C'),
        SDO_GEOMETRY(
            5000,
            NULL,
            SDO_POINT_TYPE(12, 14, NULL),
            NULL,
            NULL
        ),
        LPAD('D', 3000 ,'D'),
        LPAD('E', 3000 ,'E') 
       );
commit;

update t_sp_chain
set A = LPAD('A', 200 ,'A'), 
    B = LPAD('B', 200 ,'B'),
    C4 = SDO_GEOMETRY(
                        2003,
                        NULL,
                        SDO_POINT_TYPE(12, 14, NULL),
                        NULL,
                        NULL
                        );
commit;                        

delete t_sp_chain;
commit;
