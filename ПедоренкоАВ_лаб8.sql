--- Task 1 ---
CREATE DATABASE LazyStudent;

--- Task 2 ---
-- Okay, let's do it!

--- Task 3 ---
CREATE TABLE Students (
  StudentId               INTEGER PRIMARY KEY,
  FirstName               VARCHAR(20),
  LastName                VARCHAR(30),
  StudentEmail            VARCHAR(30),
  StudentPassword         VARCHAR(20),
  StudentPhone            VARCHAR(20),
  StudentRegistrationDate DATE
);

--- Task 4 ---
CREATE TABLE Tutors (
  TutorId               INTEGER PRIMARY KEY,
  FirstName             VARCHAR(20),
  LastName              VARCHAR(30),
  TutorEmail            VARCHAR(30),
  TutorPassword         VARCHAR(20),
  TutorPhone            VARCHAR(20),
  TutorRating           NUMERIC,
  TutorRegistrationDate DATE
);

CREATE TABLE Disciplines (
  DisciplinId   INTEGER PRIMARY KEY,
  DisciplinName VARCHAR(50)
);

CREATE TABLE TutorsDisciplines (
  DisciplinId INTEGER REFERENCES Disciplines (DisciplinId),
  TutorId     INTEGER REFERENCES Tutors (TutorId)
);

--- Task 5 ---
CREATE TABLE Companies (
  CompanyId    INTEGER PRIMARY KEY,
  CompanyName  VARCHAR(40),
  CompanyPhone VARCHAR(20)
);

--- Task 6 ---
CREATE TABLE Orders (
  OrderId          INTEGER PRIMARY KEY,
  StudentId        INTEGER REFERENCES Students (StudentId),
  TutorId          INTEGER REFERENCES Tutors (TutorId),
  CompanyId        INTEGER REFERENCES Companies (CompanyId),
  OrderDate        DATE NOT NULL,
  OrderConfirmDate DATE,
  OrderCost        NUMERIC
);

--- Task 7 ---
CREATE ROLE administrator WITH LOGIN SUPERUSER CREATEROLE PASSWORD 'difficultpassword';
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO administrator;

CREATE ROLE worker WITH LOGIN PASSWORD 'qwerty123';
GRANT SELECT ON Companies, Disciplines, Orders, Students, Tutors, TutorsDisciplines TO worker;
GRANT DELETE ON Companies, Disciplines, Orders, Students, Tutors, TutorsDisciplines TO worker;
GRANT INSERT ON Companies, Disciplines, Orders, Students, Tutors, TutorsDisciplines TO worker;

CREATE ROLE manager WITH LOGIN CREATEUSER PASSWORD 'iwanttobeadmin';
GRANT SELECT ON ALL TABLES IN SCHEMA public TO worker;
GRANT DELETE ON Companies, Disciplines, Orders, Students, Tutors, TutorsDisciplines TO worker;
GRANT INSERT ON Companies, Disciplines, Orders, Students, Tutors, TutorsDisciplines TO worker;

--- Task 8 ---
CREATE TABLE StudentsBackup (
  StudentId               INTEGER PRIMARY KEY,
  FirstName               VARCHAR(20),
  LastName                VARCHAR(30),
  StudentEmail            VARCHAR(30),
  StudentPassword         VARCHAR(20),
  StudentPhone            VARCHAR(20),
  StudentRegistrationDate DATE,
  DeletedDate             DATE,
  DeletedBy               VARCHAR(20)
);

CREATE OR REPLACE FUNCTION saveStudentsBackup() RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO StudentsBackup SELECT OLD.*, now(), user;
  RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER saveStudentsBackupTrigger
  AFTER DELETE ON Students
  FOR EACH ROW EXECUTE PROCEDURE saveStudentsBackup();

CREATE TABLE TutorsBackup (
  TutorId               INTEGER PRIMARY KEY,
  FirstName             VARCHAR(20),
  LastName              VARCHAR(30),
  TutorEmail            VARCHAR(30),
  TutorPassword         VARCHAR(20),
  TutorPhone            VARCHAR(20),
  TutorRating           NUMERIC,
  TutorRegistrationDate DATE,
  DeletedDate           DATE,
  DeletedBy             VARCHAR(20)
);

CREATE OR REPLACE FUNCTION saveTutorsBackup() RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO TutorsBackup SELECT OLD.*, now(), user;
  RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER saveTutorsBackupTrigger
AFTER DELETE ON Tutors
FOR EACH ROW EXECUTE PROCEDURE saveTutorsBackup();

CREATE TABLE DisciplinesBackup (
  DisciplinId   INTEGER PRIMARY KEY,
  DisciplinName VARCHAR(50),
  DeletedDate   DATE,
  DeletedBy     VARCHAR(20)
);

CREATE OR REPLACE FUNCTION saveDisciplinesBackup() RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO DisciplinesBackup SELECT OLD.*, now(), user;
  RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER saveDisciplinesBackupTrigger
AFTER DELETE ON Disciplines
FOR EACH ROW EXECUTE PROCEDURE saveDisciplinesBackup();

CREATE TABLE TutorsDisciplinesBackup (
  DisciplinId INTEGER REFERENCES Disciplines (DisciplinId),
  TutorId     INTEGER REFERENCES Tutors (TutorId),
  DeletedDate DATE,
  DeletedBy   VARCHAR(20)
);

CREATE OR REPLACE FUNCTION saveTutorsDisciplinesBackup() RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO TutorsDisciplinesBackup SELECT OLD.*, now(), user;
  RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER saveTutorsDisciplinesBackupTrigger
AFTER DELETE ON TutorsDisciplines
FOR EACH ROW EXECUTE PROCEDURE saveTutorsDisciplinesBackup();

CREATE TABLE CompaniesBackup (
  CompanyId    INTEGER PRIMARY KEY,
  CompanyName  VARCHAR(40),
  CompanyPhone VARCHAR(20),
  DeletedDate  DATE,
  DeletedBy    VARCHAR(20)
);

CREATE OR REPLACE FUNCTION saveCompaniesBackup() RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO CompaniesBackup SELECT OLD.*, now(), user;
  RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER saveCompaniesTrigger
AFTER DELETE ON Companies
FOR EACH ROW EXECUTE PROCEDURE saveCompaniesBackup();

CREATE TABLE OrdersBackup (
  OrderId          INTEGER PRIMARY KEY,
  StudentId        INTEGER REFERENCES Students (StudentId),
  TutorId          INTEGER REFERENCES Tutors (TutorId),
  CompanyId        INTEGER REFERENCES Companies (CompanyId),
  OrderDate        DATE NOT NULL,
  OrderConfirmDate DATE,
  OrderCost        NUMERIC,
  DeletedDate      DATE,
  DeletedBy        VARCHAR(20)
);

CREATE OR REPLACE FUNCTION saveOrdersBackup() RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO OrdersBackup SELECT OLD.*, now(), user;
  RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER saveOrdersTrigger
AFTER DELETE ON Orders
FOR EACH ROW EXECUTE PROCEDURE saveOrdersBackup();

--- Task 9 ---
/*Computing columns are not supported by postgresql, but it is possible to
 create function, which behaves like column. The function and the example
 how to use it is below.*/
CREATE OR REPLACE FUNCTION Discount(Students) RETURNS NUMERIC AS $$
  SELECT CASE
    WHEN date_part('day', now() - $1.StudentRegistrationDate) >= 365 * 4 THEN 0.15
    WHEN date_part('day', now() - $1.StudentRegistrationDate) >= 365 * 3 THEN 0.11
    WHEN date_part('day', now() - $1.StudentRegistrationDate) >= 365 * 2 THEN 0.08
    WHEN date_part('day', now() - $1.StudentRegistrationDate) >= 365 THEN 0.05
    ELSE 0
  END;
$$ LANGUAGE SQL STABLE;

SELECT *, s.Discount FROM Students s;

--- Task 10 ---
CREATE TABLE CompaniesDiscount (
  DiscountId   INTEGER PRIMARY KEY,
  CompanyId    INTEGER REFERENCES Companies (CompanyId),
  DiscountName VARCHAR(50),
  Discount     NUMERIC NOT NULL,
  BeginingDate DATE,
  EndDate      DATE
);

CREATE TABLE CompaniesDiscountBackup (
  DiscountId   INTEGER PRIMARY KEY,
  CompanyId    INTEGER REFERENCES Companies (CompanyId),
  DiscountName VARCHAR(50),
  Discount     NUMERIC NOT NULL,
  BeginingDate DATE,
  EndDate      DATE,
  DeletedDate  DATE,
  DeletedBy    VARCHAR(20)
);
CREATE OR REPLACE FUNCTION saveCompaniesDiscountBackup() RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO CompaniesDiscountBackup SELECT OLD.*, now(), user;
  RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER saveCompaniesDiscountTrigger
AFTER DELETE ON CompaniesDiscount
FOR EACH ROW EXECUTE PROCEDURE saveCompaniesDiscountBackup();
