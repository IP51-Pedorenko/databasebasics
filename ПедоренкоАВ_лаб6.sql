--- Task 1 ---
CREATE OR REPLACE FUNCTION MY_NAME() RETURNS VARCHAR(50) AS $$
  BEGIN
    RETURN('Pedorenko Andrii Victorovich');
  END;
  $$ LANGUAGE plpgsql;

SELECT MY_NAME();

--- Task 2 ---
CREATE OR REPLACE FUNCTION GET_EMPLOYEES_BY_SEX(SEX VARCHAR(1)) RETURNS SETOF employees AS $$
  BEGIN
    IF (SEX = 'F') THEN
      RETURN QUERY SELECT *
                   FROM employees
                   WHERE "TitleOfCourtesy" = 'Ms.' OR "TitleOfCourtesy" = 'Mrs.';
    END IF;
    IF (SEX = 'M') THEN
      RETURN QUERY SELECT *
                   FROM employees
                   WHERE "TitleOfCourtesy" = 'Mr.' OR "TitleOfCourtesy" = 'Dr.';
    END IF;

    RETURN;
  END;
  $$ LANGUAGE plpgsql;

SELECT * FROM GET_EMPLOYEES_BY_SEX('M');

--- Task 3 ---
CREATE OR REPLACE
FUNCTION ORDERS_IN_RANGE(fromdate DATE DEFAULT current_date, todate DATE DEFAULT current_date)
  RETURNS SETOF orders AS $$
  BEGIN
    RETURN QUERY SELECT *
                 FROM orders
                 WHERE "OrderDate" BETWEEN fromdate AND todate;
  END;
$$ LANGUAGE plpgsql;

SELECT * FROM ORDERS_IN_RANGE('1996-07-05', '1996-07-15');

--- Task 4 ---
﻿CREATE TYPE res AS ("ProductName" VARCHAR(40), "CategoryName" VARCHAR(15));

CREATE OR REPLACE FUNCTION products_by_cats(cat1 INTEGER DEFAULT 0,
				            cat2 INTEGER DEFAULT 0,
					    cat3 INTEGER DEFAULT 0,
				       	    cat4 INTEGER DEFAULT 0,
					    cat5 INTEGER DEFAULT 0) RETURNS SETOF res AS $$
BEGIN
  RETURN QUERY SELECT "ProductName", "CategoryName" FROM Products ps
         LEFT JOIN categories cs ON(ps."CategoryID"=cs."CategoryID") 
	 WHERE ps."CategoryID" IN (cat1, cat2, cat3, cat4, cat5) ORDER BY ps."CategoryID";
END;
$$ LANGUAGE plpgsql;

SELECT * FROM products_by_cats(1, 2, 3, 4);

--- Task 5 ---
-- Нет такого функционала в постгресе :'((((

--- Task 6 ---
CREATE OR REPLACE FUNCTION concatination(TitleOfCourtesy VARCHAR(5),
					FirstName VARCHAR(20),
					LastName VARCHAR(20)) RETURNS VARCHAR(45) AS $$
BEGIN
  RETURN TitleOfCourtesy || ' ' || FirstName || ' ' || LastName;
END;
$$ LANGUAGE plpgsql;

SELECT concatination('Dr.', 'Yevhen', 'Nedashkivskyi');

--- Task 7 ---
CREATE OR REPLACE FUNCTION get_price(UnitPrice NUMERIC, Quantity INTEGER, Discount NUMERIC) RETURNS NUMERIC AS $$
BEGIN
  RETURN UnitPrice * Quantity * (1 - Discount);
END;
$$ LANGUAGE plpgsql;

SELECT get_price(10, 10, 0.5);

--- Task 8 ---

CREATE OR REPLACE FUNCTION toPascalCase(str text)
  RETURNS SETOF text
AS $$
BEGIN
  RETURN QUERY SELECT replace(initcap(replace(str, '_', ' ')), ' ', '');
  END;
$$ LANGUAGE plpgsql;

SELECT * FROM toPascalCase('My little pony');

--- Task 9 ---
CREATE OR REPLACE FUNCTION get_employees(country VARCHAR(20)) RETURNS SETOF employees AS $$
BEGIN
  RETURN QUERY
    SELECT * FROM employees
    WHERE "Country" = country;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM get_employees('USA');

--- Task 10 ---
CREATE OR REPLACE FUNCTION get_customers(companyname VARCHAR(40)) RETURNS SETOF customers AS $$
BEGIN
  RETURN QUERY
    SELECT * FROM customers
    WHERE "CompanyName" = companyname;
END;
$$LANGUAGE plpgsql;

SELECT * FROM get_customers('Berglunds snabbköp');
