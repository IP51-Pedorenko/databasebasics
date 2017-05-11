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

SELECT ORDERS_IN_RANGE('1996-07-05', '1996-07-15');

--- Task 4 ---
CREATE OR REPLACE
FUNCTION PRODUCTS_BY_CATEGORY(cat1 SMALLINT,
                              cat2 INTEGER DEFAULT -1,
                              cat3 INTEGER DEFAULT -1,
                              cat4 INTEGER DEFAULT -1,
                              cat5 INTEGER DEFAULT -1) RETURNS SETOF products AS $$
BEGIN
  RETURN QUERY SELECT cat1, * FROM products WHERE "CategoryID" = cat1;

  RETURN;
END;
$$ LANGUAGE plpgsql;

SELECT PRODUCTS_BY_CATEGORY(1);
