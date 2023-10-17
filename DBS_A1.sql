--******************************************************************
-- Group 12
-- Student1 Name: Hla Myint Myat Student1 ID: 185923216
-- Student2 Name: Justin Lee ID: 121354229
-- Student3 Name: Chris Kaipada ID: 160828224
-- Date: October 16 2023
-- Purpose: Assignment 1 - DBS311
-- All the content other than your sql code should be put in comment block.
-- Include your output in a comment block following with your sql code.
-- Remember add ; in the end of your statement for each question.
--******************************************************************

-- Q1 solution
SELECT EMPLOYEE_ID, FIRST_NAME, LAST_NAME, HIRE_DATE
FROM EMPLOYEES
WHERE HIRE_DATE >
(SELECT MAX(HIRE_DATE)
FROM EMPLOYEES
WHERE HIRE_DATE >= '2016-08-01' AND HIRE_DATE <= '2016-09-01')

AND HIRE_DATE <=(
  SELECT MIN(HIRE_DATE)
  FROM EMPLOYEES
  WHERE TO_CHAR(HIRE_DATE, 'MM') = '12'
) - INTERVAL '2' MONTH
ORDER BY HIRE_DATE, EMPLOYEE_ID;

/*
EMPLOYEE_ID FIRST_NAME LAST_NAME   HIRE_DATE
----------- ---------- ----------  --------
        101 Annabelle  Dunn        16-09-17
          2 Jude       Rivera      16-09-21
         11 Tyler      Ramirez     16-09-28
         27 Kai        Long        16-09-28
         12 Elliott    James       16-09-30
         46 Ava        Sullivan    16-10-01

6 rows selected.  */

-- Q2 solution

SELECT DISTINCT c.CUSTOMER_ID
FROM CUSTOMERS c
WHERE (
    SELECT COUNT(*) 
    FROM ORDERS o 
    WHERE c.CUSTOMER_ID = o.CUSTOMER_ID)
 > 1
ORDER BY c.CUSTOMER_ID;

/*CUSTOMER_ID
-----------
          1
          2
          3
          4
          5
          6
          7
          8
          9
         16
         17

CUSTOMER_ID
-----------
         18
         44
         45
         46
         47
         48
         49

18 rows selected. */

-- Q3 solution
SELECT
    M.MANAGER_ID AS "Manager ID",
    M.FIRST_NAME || ' ' || M.LAST_NAME AS "Full Name"
FROM
    EMPLOYEES M -- M represents managers
JOIN
    (SELECT MANAGER_ID, COUNT(*)
     FROM EMPLOYEES
     GROUP BY MANAGER_ID
     HAVING COUNT(*) = 1) E -- E represents employees with only one manager
ON
    M.EMPLOYEE_ID = E.MANAGER_ID
ORDER BY
    "Manager ID";

-- returned rows 
-- Manager_ID   Full_Name
--+-------------  +---------------+
--1	Blake Cooper
--1	Emma Perkins
--2	Rose Stephens


-- Q4 solution
SELECT oi.PRODUCT_ID AS "Product ID", o.ORDER_DATE AS "Order Date", COUNT(*) AS "Number of orders in a day"
FROM ORDERS o
LEFT JOIN ORDER_ITEMS oi ON o.ORDER_ID = oi.ORDER_ID
WHERE o.ORDER_DATE >= '2016-01-01' AND o.ORDER_DATE < '2017-01-01'
GROUP BY oi.PRODUCT_ID,o.order_date
HAVING COUNT(*) > 1
ORDER BY ORDER_DATE,oi.PRODUCT_ID;

/* PRODUCT_ID ORDER_DA Number of orders in a day
---------- -------- -------------------------
       163 16-06-13                         2
        71 16-08-16                         2
        93 16-08-16                         2
        62 16-08-24                         2
         1 16-11-29                         2
        96 16-11-29                         2
*/

-- Q5 solution
SELECT CUSTOMER_ID AS "CUSTOMER ID", NAME
FROM CUSTOMERS
WHERE CUSTOMER_ID IN (
    SELECT CUSTOMER_ID
    FROM ORDERS
    JOIN ORDER_ITEMS ON ORDERS.ORDER_ID = ORDER_ITEMS.ORDER_ID
    WHERE PRODUCT_ID IN (7, 40, 94)
    GROUP BY CUSTOMER_ID
    HAVING COUNT(DISTINCT PRODUCT_ID) = 3
)
ORDER BY CUSTOMER_ID;

--returned row 
-- CUSTOMER_ID  |NAME
-- 6         	Community Health Systems


-- Q6 solution

SELECT EMPLOYEE_ID AS "Employee ID", "Number of Orders"
FROM (
    SELECT
        E.EMPLOYEE_ID,
        COUNT(O.ORDER_ID) AS "Number of Orders"
    FROM EMPLOYEES E
    LEFT JOIN ORDERS O ON E.EMPLOYEE_ID = O.SALESMAN_ID
    GROUP BY E.EMPLOYEE_ID
    ORDER BY COUNT(O.ORDER_ID) DESC
)
WHERE ROWNUM = 1;

--returned row
-- EMPLOYEE_ID   Number of Orders
-- 62	         13


-- Q7 solution
SELECT
    EXTRACT(MONTH FROM o.ORDER_DATE) AS "Month Number",
    TO_CHAR(o.ORDER_DATE, 'Month') AS "Month",
    EXTRACT(YEAR FROM o.ORDER_DATE) AS "Year",
    COUNT(DISTINCT o.ORDER_ID) AS "Total Number of Orders",
    SUM(oi.QUANTITY * oi.UNIT_PRICE) AS "Sales Amount"
FROM
    ORDERS o
LEFT JOIN ORDER_ITEMS oi ON o.ORDER_ID = oi.ORDER_ID
WHERE
    EXTRACT(YEAR FROM o.ORDER_DATE) = 2017
GROUP BY
    EXTRACT(MONTH FROM o.ORDER_DATE), TO_CHAR(o.ORDER_DATE, 'Month'), EXTRACT(YEAR FROM o.ORDER_DATE)
ORDER BY
    "Month Number";

/* Month Number Month           Year Total Number of Orders Sales Amount
------------ --------- ---------- ---------------------- ------------
           1 January         2017                      5   2281459.09
           2 February        2017                     13   7919446.52
           3 March           2017                      4   2246625.47
           4 April           2017                      2    609150.35
           5 May             2017                      4   1367115.47
           6 June            2017                      1    926416.51
           8 August          2017                      5   2539537.86
           9 September       2017                      4   1675983.52
          10 October         2017                      2   2040864.95
          11 November        2017                      1    307842.27

10 rows selected. */


-- Q8 solution
SELECT
    EXTRACT(MONTH FROM o.ORDER_DATE) AS "Month Number",
    TO_CHAR(o.ORDER_DATE, 'Month') AS "Month",
    ROUND(AVG(oi.QUANTITY * oi.UNIT_PRICE), 2) AS "Average Sales Amount"
From ORDERS o
LEFT JOIN ORDER_ITEMS oi ON o.ORDER_ID = oi.ORDER_ID
WHERE
    EXTRACT(YEAR FROM o.ORDER_DATE) = 2017
    GROUP BY
    EXTRACT(MONTH FROM o.ORDER_DATE), TO_CHAR(o.ORDER_DATE, 'Month'), EXTRACT(YEAR FROM o.ORDER_DATE)
    HAVING  AVG(oi.QUANTITY * oi.UNIT_PRICE) > (SELECT  AVG(oi.QUANTITY * oi.UNIT_PRICE)
From ORDERS o 
LEFT JOIN ORDER_ITEMS oi ON o.ORDER_ID = oi.ORDER_ID
WHERE
    EXTRACT(YEAR FROM o.ORDER_DATE) = 2017 )
ORDER BY
    "Month Number";

    

 /* Month Number Month     Average Sales Amount
------------ --------- --------------------
           2 February              93169.96
           3 March                 89865.02
           6 June                 132345.22
          10 October               92766.59
          11 November             153921.14
*/

-- Q9 solution

SELECT DISTINCT E.FIRST_NAME
FROM EMPLOYEES E
WHERE E.FIRST_NAME LIKE 'B%'
AND E.FIRST_NAME NOT IN (SELECT C.FIRST_NAME FROM CONTACTS C)
ORDER BY E.FIRST_NAME;

--returned rows
-- FIRST_NAME
-- Bella
-- Blake


-- Q10 solution

SELECT 'The number of employees with total order amount over average order amount: ' AS " ", COUNT(*) AS "  "
From EMPLOYEES e
INNER JOIN ORDERS o ON e.EMPLOYEE_ID = o.SALESMAN_ID
WHERE (SELECT AVG(oi.QUANTITY * oi.UNIT_PRICE)
FROM ORDER_ITEMS oi
where o.ORDER_ID = oi.ORDER_ID) > (SELECT AVG(QUANTITY * UNIT_PRICE)
FROM ORDER_ITEMS )
UNION ALL
SELECT 'The number of employees with total number of orders greater than 10: ', COUNT(*)
From EMPLOYEES e
INNER JOIN ORDERS o ON e.EMPLOYEE_ID = o.SALESMAN_ID
WHERE (Select COUNT(*)
from ORDERS o 
where e.EMPLOYEE_ID = o.SALESMAN_ID) > 10
UNION ALL
SELECT 'The number of employees with no order: ', COUNT(*)
From EMPLOYEES e
WHERE (Select COUNT(*)
from ORDERS o
where e.EMPLOYEE_ID = o.SALESMAN_ID) > 1
UNION ALL
SELECT 'The number of employees with orders: ', COUNT(*)
From EMPLOYEES e
WHERE (Select COUNT(*)
from ORDERS o
where e.EMPLOYEE_ID = o.SALESMAN_ID) < 1;

/* --------------------------------------------------------------------- ----------
The number of employees with total number of orders greater than 10:          25
The number of employees with no order:                                         9
The number of employees with orders:                                          98
*/





