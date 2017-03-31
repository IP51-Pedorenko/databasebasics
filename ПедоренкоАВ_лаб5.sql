--- Task 1 ---
CREATE DATABASE pedorenko;

--- Task 2 ---
CREATE TABLE Student (
  StudentId INT,
  SecondName NCHAR(20),
  FirstName NCHAR(20),
  SEX CHAR
);

--- Task 3 ---
ALTER TABLE Student
ADD PRIMARY KEY (StudentId);

--- Task 4 ---
CREATE SEQUENCE id_stud_seq
START WITH 1
INCREMENT BY 1;

ALTER TABLE Student
ALTER COLUMN StudentId SET DEFAULT nextval('id_stud_seq'::REGCLASS);

--- Task 5 ---
ALTER TABLE Student
ADD COLUMN BirthDate DATE;

--- Task 6 ---
--ALTER TABLE Student
--ADD COLUMN CurrentAge INT DEFAULT (date_part('year', current_date) - date_part('year', public.student.BirthDate));
--I can't use columns in default statements, so I don't know, how to do this task(

--- Task 7 ---
ALTER TABLE Student
ADD CHECK (Sex SIMILAR TO '[fm]');

--- Task 8 ---
INSERT INTO Student VALUES (DEFAULT ,'Pedorenko', 'Andrii', 'm', '05-04-1998');
INSERT INTO Student VALUES (DEFAULT ,'Paterylo', 'Vladislav', 'm', '08-08-1998');
INSERT INTO Student VALUES (DEFAULT ,'Reutska', 'Svetlana', 'f', '20-07-1997');

--- Task 9 ---
CREATE VIEW vMaleStudent AS
  SELECT StudentId, SecondName, FirstName, birthdate, currentage
  FROM student
  WHERE Sex = 'm';

CREATE VIEW vFemaleStudent AS
  SELECT StudentId, SecondName, FirstName, birthdate, currentage
  FROM student
  WHERE Sex = 'f';

--- Task 10 --
ALTER TABLE Student
DROP CONSTRAINT student_pkey;

DROP VIEW vMaleStudent; --It doesn't let to change type
DROP VIEW vFemaleStudent;

ALTER TABLE Student
ALTER COLUMN StudentId TYPE SMALLINT;

CREATE VIEW vMaleStudent AS
  SELECT StudentId, SecondName, FirstName, birthdate, currentage
  FROM student
  WHERE Sex = 'm';

CREATE VIEW vFemaleStudent AS
  SELECT StudentId, SecondName, FirstName, birthdate, currentage
  FROM student
  WHERE Sex = 'f';

ALTER TABLE Student
ADD PRIMARY KEY (StudentId);
