--- Task 1 ---
INSERT INTO employees ("EmployeeID", "LastName", "FirstName", "Title")
VALUES (10, 'Pedorenko', 'Andrii', 'Intern');

--- Task 2 ---
UPDATE employees
SET "Title" = 'Director'
WHERE "EmployeeID" = 10;

--- Task 3 ---
SELECT * INTO OrdersArchive FROM orders;

--- Task 4 ---
DELETE FROM OrdersArchive;

--- Task 5 ---
INSERT INTO OrdersArchive ("OrderID", "CustomerID", "EmployeeID",
                           "OrderDate", "RequiredDate", "ShippedDate",
                           "ShipVia", "Freight", "ShipName", "ShipAddress",
                           "ShipCity", "ShipRegion", "ShipPostalCode", "ShipCountry")
    SELECT * FROM orders;

--- Task 6 ---
DELETE FROM OrdersArchive
WHERE "CustomerID" IN (SELECT "CustomerID" FROM customers
                       WHERE "City" = 'Berlin');

--- Task 7 ---
INSERT INTO products ("ProductID", "ProductName", "Discontinued")
  (SELECT 78, 'Andrii', 0
   UNION
   SELECT  79, 'IP-51', 0);

--- Task 8 ---
UPDATE products
SET "Discontinued" = 1
WHERE "ProductID" IN
      (SELECT "ProductID" FROM products
       EXCEPT
       SELECT "ProductID" FROM order_details);

--- Task 9 ---
DROP TABLE OrdersArchive;

--- Task 10 --
DROP DATABASE northwind;
