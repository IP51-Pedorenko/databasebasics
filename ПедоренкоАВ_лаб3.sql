--- Task 1 ---
--- part 1 ---
SELECT 'Andrii'
UNION
SELECT 'Pedorenko'
UNION
SELECT 'Victorovich';

--- part 2 ---
SELECT
  CASE
    WHEN 14 < ALL(ARRAY[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19])
    THEN ';-)'
    ELSE ':-D'
    END;
--- Right solution
SELECT ':-D';
/*Explanation:
Array of ALL numbers in a group always contains my number, too
My number can't be smaller then my number
That's why result ';-D' will never be printed and  there is no need
in condition
 */

--- part 3 ---
SELECT FullName FROM
(SELECT CASE
  WHEN 'Svetlana' NOT IN ('Alina', 'Anna','Masha', 'Ksenia')
    THEN 'Reutska Svetlana Vitaliivna'
    END AS FullName
UNION
SELECT CASE
       WHEN 'Anastasia' NOT IN ('Alina', 'Anna','Masha', 'Ksenia')
         THEN 'Starchenko Anastasia Sergiivna'
       END AS FullName
UNION
SELECT CASE
       WHEN 'Anna' NOT IN ('Alina', 'Anna','Masha', 'Ksenia')
         THEN 'Khuda Anna Oleksandrivna'
       END AS FullName) AS Result
WHERE FullName IS NOT NULL;


--- part 4 ---
SELECT
  CASE
    WHEN Number BETWEEN 0 AND 9
    THEN
      CASE
      WHEN number = 0
        THEN 'Zero'
      WHEN number = 1
        THEN '0ne'
      WHEN number = 2
        THEN 'Two'
      WHEN number = 3
        THEN 'Three'
      WHEN number = 4
        THEN 'Four'
      WHEN number = 5
        THEN 'Five'
      WHEN number = 6
        THEN 'Six'
      WHEN number = 7
        THEN 'Seven'
      WHEN number = 8
        THEN 'Eight'
      WHEN number = 9
        THEN 'Nine'
      END
    ELSE Number::char(20)
  END Number
FROM Numbers;

--- part 5 ---
SELECT * FROM table1 CROSS JOIN table2;

--- Task 2 ---
--- part 1 ---
SELECT "OrderID"
      ,"CustomerID"
      ,"EmployeeID"
      ,"OrderDate"
      ,"RequiredDate"
      ,"ShippedDate"
      ,"ShipVia"
      ,"Freight"
      ,"ShipName"
      ,"ShipAddress"
      ,"ShipCity"
      ,"ShipRegion"
      ,"ShipPostalCode"
      ,"ShipCountry"
      ,"ShipperID"
      ,CASE
  WHEN "ShipperID" = 3
  THEN 'Andrii Pedorenko Victorovich'
  ELSE "CompanyName"
  END
      ,"Phone"
FROM orders JOIN
    shippers AS srs ON "ShipVia" = "ShipperID";

--- part 2 ---
SELECT "City" FROM customers
UNION
SELECT "City" FROM employees
UNION
SELECT "ShipCity" FROM orders
ORDER BY 1;

--- part 3 ---
SELECT "LastName"
      ,"FirstName"
      ,(SELECT COUNT("OrderID") FROM orders
             WHERE orders."EmployeeID" = employees."EmployeeID"
                   AND "OrderDate" BETWEEN '1998-01-01' AND '1998-03-31') AS AmountOfOrders
FROM employees;


--- part 4 ---
WITH TooManyProducts AS
(SELECT "OrderID"
       ,"Discount"
FROM (SELECT * FROM products WHERE "UnitsInStock" > 100) AS LotProducts JOIN
  order_details ON LotProducts."ProductID" = order_details."ProductID")

SELECT * FROM orders
WHERE "OrderID" IN (SELECT "OrderID" FROM TooManyProducts
                   WHERE "Discount" = (SELECT MAX("Discount")FROM TooManyProducts));

--- part 5 ---
WITH employeeregion AS
(SELECT "EmployeeID", "RegionDescription"
FROM employeeterritories JOIN
  territories AS tts ON tts."TerritoryID" =employeeterritories."TerritoryID" JOIN
  region AS rg ON rg."RegionID" = tts."RegionID")

,notnorthrenemployee AS (SELECT *
FROM employeeregion
  EXCEPT
  SELECT *
  FROM employeeregion
  WHERE "RegionDescription" = 'Northern')

SELECT DISTINCT "ProductName"
FROM orders JOIN
notnorthrenemployee AS nne ON nne."EmployeeID" = orders."EmployeeID" JOIN
order_details AS od ON od."OrderID" = orders."OrderID" JOIN
products AS pds ON pds."ProductID" = od."ProductID";
