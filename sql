-- Return a list of all customers, RANKED in order from highest to lowest total spendings
-- WITHIN the country they live in.

WITH customer_lifetime_amount AS (
SELECT
c.customerid,
SUM(od.unitprice * od.quantity) AS spend_amount,
c.country
FROM customers c
INNER JOIN orders o ON c.customerid=o.customerid
INNER JOIN orderdetails od ON o.orderid=od.orderid
GROUP BY c.customerid
)

SELECT 
cla.customerid,
cla.spend_amount,
SUM(cla.spend_amount) OVER(PARTITION BY cla.country),
cla.country
FROM customer_lifetime_amount cla

---- Return the same list as before, but with only the top 3 customers in each country. 

WITH customer_lifetime_amount AS (
SELECT
RANK() OVER (PARTITION BY c.country ORDER BY SUM(od.unitprice * od.quantity)),
c.customerid,
SUM(od.unitprice * od.quantity) AS spend_amount,
c.country
FROM customers c
INNER JOIN orders o ON c.customerid=o.customerid
INNER JOIN orderdetails od ON o.orderid=od.orderid
GROUP BY c.customerid
)

SELECT 
cla.customerid,
cla.spend_amount,
RANK() OVER(PARTITION BY cla.country ORDER BY cla.spend_amount DESC),
cla.country
FROM customer_lifetime_amount cla
WHERE cla.rank <= 3