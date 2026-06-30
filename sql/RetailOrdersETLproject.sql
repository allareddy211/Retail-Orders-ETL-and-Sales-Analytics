
-- CREATE TABLE orders ( order_id INT PRIMARY KEY, order_date DATE, ship_mode VARCHAR(20), segment VARCHAR(20), country VARCHAR(20), city VARCHAR(20), state VARCHAR(20),
-- postal_code VARCHAR(20), region VARCHAR(20), category VARCHAR(20), sub_category VARCHAR(20), product_id VARCHAR(50), quantity INT, discount DECIMAL(7,2), sale_price DECIMAL(7,2),
-- profit DECIMAL(7,2));

SELECT *
FROM orders

-- find top 10 highest reveue generating products 
SELECT product_id, SUM(sale_price) as total_sales
FROM orders
GROUP BY product_id
ORDER BY total_sales DESC
LIMIT 10;

-- find top 5 highest selling products in each region
WITH CTE AS (SELECT region, product_id, SUM(sale_price) AS total_sales,
ROW_NUMBER() OVER(PARTITION BY region ORDER BY SUM(sale_price) DESC ) AS rn
FROM orders
GROUP BY region, product_id)

SELECT *
FROM CTE
WHERE rn<=5;

-- find month over month growth comparison for 2022 and 2023 sales eg : jan 2022 vs jan 2023

WITH CTE AS (SELECT YEAR(order_date)AS order_year, MONTH(order_date) AS order_month,SUM(sale_price) AS total_sales
FROM orders 
GROUP BY YEAR(order_date), MONTH(order_date))

SELECT order_month, SUM(CASE WHEN order_year = 2022 THEN total_sales ELSE 0 END) AS sales_22,
SUM(CASE WHEN order_year = 2023 THEN total_sales ELSE 0 END) AS sales_23
FROM CTE
GROUP BY order_month
ORDER BY order_month;

-- for each category which month had highest sales 

WITH CTE AS (SELECT category,YEAR(order_date) as order_year, MONTH(order_date) as order_month,SUM(sale_price) as sales
FROM orders
GROUP BY category, YEAR(order_date),MONTH(order_date))

SELECT * FROM (SELECT *, ROW_NUMBER() OVER(PARTITION BY category ORDER BY sales DESC) AS rn
FROM CTE) sub
WHERE rn = 1;

-- which sub category had highest growth by profit in 2023 compare to 2022

WITH CTE AS (SELECT sub_category, SUM(profit) AS total_profit, YEAR(order_date) as order_year
FROM orders
GROUP BY sub_category, order_year),

CTE2 AS (
SELECT sub_category, SUM(CASE WHEN order_year = 2022 then total_profit else 0 END) AS profit_22,
SUM(CASE WHEN order_year = 2023 then total_profit else 0 END) AS profit_23
FROM CTE
GROUP BY sub_category)

SELECT *, (profit_23 - profit_22) AS growth_profit
FROM CTE2
ORDER BY growth_profit DESC
LIMIT 1;
