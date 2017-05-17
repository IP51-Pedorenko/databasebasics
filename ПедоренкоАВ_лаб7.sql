--- Task 1 ---
SELECT
  relname AS tablename, reltuples AS rowsnumber
FROM pg_class AS C
  LEFT JOIN pg_namespace AS N ON (N.oid = C.relnamespace)
WHERE
  nspname NOT IN ('pg_catalog', 'information_schema') AND
  relkind='r'
ORDER BY rowsnumber DESC;

--- Task 2 ---
CREATE OR REPLACE FUNCTION grantSelectToPublic() RETURNS integer AS $$
DECLARE
  userName VARCHAR(30);
BEGIN
  FOR userName IN SELECT usename FROM pg_shadow 
  LOOP
    EXECUTE format('GRANT SELECT ON ALL TABLES IN SCHEMA public TO %I', userName);
  END LOOP;
  RETURN 0;
END;
$$ LANGUAGE plpgsql;

SELECT grantSelectToPublic();

--- Task 3 ---
CREATE OR REPLACE FUNCTION revokeAllFromTestUser() RETURNS integer AS $$
DECLARE
  tableName VARCHAR(30);
  prodcursor CURSOR FOR 
      SELECT relname FROM pg_class 
	WHERE relnamespace = 2200 AND
	relkind='r' AND relname SIMILAR TO 'prod[_]%';
BEGIN
  FOR tableName IN prodcursor
  LOOP
    EXECUTE format('REVOKE ALL ON %I FROM TestUser', tableName.relname);
  END LOOP;
  RETURN 0;
END;
$$ LANGUAGE plpgsql;

SELECT revokellFromTestUser();
	
--- Task 4 ---
CREATE TYPE product AS (prodname VARCHAR(40), quantity SMALLINT, totalprice NUMERIC);

CREATE OR REPLACE FUNCTION productsByOrderId(orderId smallint) RETURNS SETOF product AS $$
BEGIN
   RETURN QUERY
  	SELECT "ProductName", "Quantity", ("Quantity" * order_details."UnitPrice" * (1 - "Discount"))::NUMERIC AS "total" 
  	FROM order_details
		  LEFT JOIN products ON (order_details."ProductID" = products."ProductID") 
		  WHERE order_details."OrderID" = orderId;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION allProductsByOrderIds() RETURNS SETOF product AS $$
DECLARE
  id SMALLINT;
  prod product;
BEGIN
    FOR id IN SELECT "OrderID" FROM order_details GROUP BY "OrderID" ORDER BY "OrderID"
    LOOP
	 FOR prod IN SELECT * FROM productsByOrderId(id)
	 LOOP
		RETURN NEXT prod;
	 END LOOP;
    END LOOP;
    RETURN;
END
$$ LANGUAGE 'plpgsql';

SELECT * From allProductsByOrderIds();

--- Task 5 ---
/*Cross-database references are not implemented in postgres(((*/

--- Task 6 ---
CREATE OR REPLACE FUNCTION validPhone() RETURNS trigger AS $$
BEGIN
    NEW."Phone" = regexp_replace(NEW."Phone", '\D*', '', 'g');
    return NEW;
END
$$ language 'plpgsql';

CREATE trigger validPhoneTrigger
BEFORE INSERT ON customers
    FOR EACH ROW EXECUTE PROCEDURE validPhone();

--- Task 7 ---
CREATE OR REPLACE FUNCTION setDiscount() RETURNS trigger AS $$
DECLARE
  totalPrice real;
BEGIN
    totalPrice = SUM("Quantity" * "UnitPrice") FROM order_details
		WHERE "OrderID" = NEW."OrderID";
    UPDATE order_details
	SET "Discount" = CASE
		WHEN totalPrice > 100 THEN 0.05
		WHEN totalPrice > 500 THEN 0.15
		WHEN totalPrice > 1000 THEN 0.25
		ELSE 0
	END
    WHERE "OrderID" = NEW."OrderID";
    RETURN NEW;
END $$ LANGUAGE 'plpgsql';

CREATE trigger setDiscountTrigger
AFTER INSERT ON order_details
    FOR EACH ROW EXECUTE PROCEDURE setDiscount();

--- Task 8 ---
CREATE TABLE Contacts (
    ContactID SMALLINT PRIMARY KEY,
    LastName VARCHAR(30),
    FirstName VARCHAR(30),
    PersonalPhone VARCHAR(15) NOT NULL,
    WorkPhone VARCHAR(15),
    Email VARCHAR(30),
    PreferablePhone VARCHAR(15)
)

CREATE OR REPLACE FUNCTION setPreferablePhone() RETURNS trigger AS $$
BEGIN
    IF (NEW."preferablephone" IS NULL) THEN
        IF (NEW."workphone" IS NOT NULL) THEN
	    NEW."preferablephone" = NEW."workphone";
        ELSE
            NEW."preferablephone" = NEW."personalphone";
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

CREATE trigger setPreferablePhoneTrigger
BEFORE INSERT ON contacts
    FOR EACH ROW EXECUTE PROCEDURE setPreferablePhone();

--- Task 9 ---
SELECT * INTO OrdersArchive FROM Orders;
DELETE FROM OrdersArchive;

ALTER TABLE OrdersArchive
ADD COLUMN "DeletionDateTime" DATE, 
ADD COLUMN "DeletedBy" VARCHAR(20);

CREATE OR REPLACE FUNCTION saveToArchive() RETURNS trigger AS $$
BEGIN
    INSERT INTO OrdersArchive SELECT OLD.*, now(), user;
    return NULL;
END
$$ language 'plpgsql';

CREATE trigger saveToArchiveTrigger
AFTER DELETE ON Orders
    FOR EACH ROW EXECUTE PROCEDURE saveToArchive();

--- Task 10 ---
CREATE TABLE TriggerTable1 (
    TriggerId BIGSERIAL PRIMARY KEY,
    TriggerDate DATE
);

CREATE TABLE TriggerTable2 (
    TriggerId BIGSERIAL PRIMARY KEY,
    TriggerDate DATE
);

CREATE TABLE TriggerTable3 (
    TriggerId BIGSERIAL PRIMARY KEY,
    TriggerDate DATE
);

CREATE OR REPLACE FUNCTION triggerFunction1() RETURNS trigger AS $$
BEGIN
    INSERT INTO TriggerTable2 ("triggerdate") VALUES(now());
    RETURN NULL;
END
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION triggerFunction2() RETURNS trigger AS $$
BEGIN
    INSERT INTO TriggerTable3 ("triggerdate") VALUES(now());
    RETURN NULL;
END
$$ language 'plpgsql';

CREATE OR REPLACE FUNCTION triggerFunction3() RETURNS trigger AS $$
BEGIN
    INSERT into TriggerTable1 ("triggerdate") values(now());
    return NULL;
END
$$ language 'plpgsql';

CREATE trigger trigger1
AFTER INSERT ON TriggerTable1
    FOR EACH ROW EXECUTE PROCEDURE triggerFunction1();

CREATE trigger trigger2
AFTER INSERT ON TriggerTable2
    FOR EACH ROW EXECUTE PROCEDURE triggerFunction2();

CREATE trigger trigger3
AFTER INSERT on TriggerTable3
    FOR EACH ROW EXECUTE PROCEDURE triggerFunction3();

INSERT into TriggerTable1 ("triggerdate") values(now());
SELECT * from TriggerTable1
SELECT * from TriggerTable2
SELECT * from TriggerTable3

/*Nothing was written because stack depth limit exceeded because of recursice functions*/
