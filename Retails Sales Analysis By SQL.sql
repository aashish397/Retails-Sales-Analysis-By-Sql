
SELECT DB_NAME() AS CurrentDatabase;
USE [SQL PROJ];
SELECT 
   *
FROM [dbo].[SQL - Retail Sales Analysis_utf ]

-- Data Cleaning

SELECT * FROM [dbo].[SQL - Retail Sales Analysis_utf ]
WHERE 
    transactions_id IS NULL
    OR
    sale_date IS NULL
    OR 
    sale_time IS NULL
    OR
    gender IS NULL
    OR
    category IS NULL
    OR
    quantiy IS NULL
    OR
    cogs IS NULL
    OR
    total_sale IS NULL;
    
-- 
DELETE FROM [dbo].[SQL - Retail Sales Analysis_utf ]
WHERE 
    transactions_id IS NULL
    OR
    sale_date IS NULL
    OR 
    sale_time IS NULL
    OR
    gender IS NULL
    OR
    category IS NULL
    OR
    quantiy IS NULL
    OR
    cogs IS NULL
    OR
    total_sale IS NULL;
	-- 1. Check and remove duplicate transactions
WITH Duplicate_Transactions AS (
    SELECT transactions_id, COUNT(*) as cnt
    FROM [dbo].[SQL - Retail Sales Analysis_utf ]
    GROUP BY transactions_id
    HAVING COUNT(*) > 1
)
DELETE FROM [dbo].[SQL - Retail Sales Analysis_utf ]
WHERE transactions_id IN (SELECT transactions_id FROM Duplicate_Transactions);

-- 2. Checking for extreme quantities
SELECT * FROM [dbo].[SQL - Retail Sales Analysis_utf ]
WHERE quantiy > 100; -- Assume 100+ is abnormal

-- 3. Fix text format issues (making category consistent)
UPDATE [dbo].[SQL - Retail Sales Analysis_utf ]
SET category = UPPER(category);

-- 4. Checking for future dates
SELECT * FROM [dbo].[SQL - Retail Sales Analysis_utf ]
WHERE sale_date > GETDATE();

-- Data Exploration

-- How many sales we have?
SELECT COUNT(*) as total_sale FROM [dbo].[SQL - Retail Sales Analysis_utf ]

-- How many uniuque customers we have ?

SELECT COUNT(DISTINCT customer_id) as customers FROM [dbo].[SQL - Retail Sales Analysis_utf ]

--categories

SELECT DISTINCT category FROM [dbo].[SQL - Retail Sales Analysis_utf ]


-- Data Analysis & Business Key Problems & Answers

-- My Analysis & Findings
-- Q.1 Write a SQL query to retrieve all columns for sales made on '2022-11-05
-- Q.2 Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 10 in the month of Nov-2022
-- Q.3 Write a SQL query to calculate the total sales (total_sale) for each category.
-- Q.4 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.
-- Q.5 Write a SQL query to find all transactions where the total_sale is greater than 1000.
-- Q.6 Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.
-- Q.7 Write a SQL query to calculate the average sale for each month. Find out best selling month in each year
-- Q.8 Write a SQL query to find the top 5 customers based on the highest total sales 
-- Q.9 Write a SQL query to find the number of unique customers who purchased items from each category.
-- Q.10 Write a SQL query to create each shift and number of orders (Example Morning <=12, Afternoon Between 12 & 17, Evening >17)



 -- Q.1 Write a SQL query to retrieve all columns for sales made on '2022-11-05

SELECT *
FROM [dbo].[SQL - Retail Sales Analysis_utf ]
WHERE sale_date = '2022-11-05';


-- Q.2 Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 4 in the month of Nov-2022

SELECT 
  *
FROM [dbo].[SQL - Retail Sales Analysis_utf ]
WHERE 
  category = 'Clothing'
  AND 
  FORMAT(sale_date, 'yyyy-MM') = '2022-11'
  AND 
  quantiy >= 4;

-- Q.3 Write a SQL query to calculate the total sales (total_sale) for each category.

SELECT 
    category,
    SUM(total_sale) as net_sale,
    COUNT(*) as total_orders
FROM [dbo].[SQL - Retail Sales Analysis_utf ]
GROUP BY 1

-- Q.4 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.

SELECT
    ROUND(AVG(age), 2) as avg_age
FROM [dbo].[SQL - Retail Sales Analysis_utf ]
WHERE category = 'Beauty'


-- Q.5 Write a SQL query to find all transactions where the total_sale is greater than 1000.

SELECT * FROM [dbo].[SQL - Retail Sales Analysis_utf ]
WHERE total_sale > 1000


-- Q.6 Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.

SELECT 
    category,
    gender,
    COUNT(*) as total_trans
FROM [dbo].[SQL - Retail Sales Analysis_utf ]
GROUP 
    BY 
    category,
    gender
ORDER BY 1


-- Q.7 Write a SQL query to calculate the average sale for each month. Find out best selling month in each year

SELECT 
       year,
       month,
    avg_sale
FROM 
(    
SELECT 
    EXTRACT(YEAR FROM sale_date) as year,
    EXTRACT(MONTH FROM sale_date) as month,
    AVG(total_sale) as avg_sale,
    RANK() OVER(PARTITION BY EXTRACT(YEAR FROM sale_date) ORDER BY AVG(total_sale) DESC) as rank
FROM [dbo].[SQL - Retail Sales Analysis_utf ]
GROUP BY 1, 2
) as t1
WHERE rank = 1
    
-- ORDER BY 1, 3 DESC

-- Q.8 Write a SQL query to find the top 5 customers based on the highest total sales 
SELECT TOP 5
    customer_id,
    SUM(total_sale) AS total_sales
FROM [dbo].[SQL - Retail Sales Analysis_utf ]
GROUP BY customer_id
ORDER BY total_sales DESC;


-- Q.9 Write a SQL query to find the number of unique customers who purchased items from each category.


SELECT 
    category,    
    COUNT(DISTINCT customer_id) as cnt_unique_cs
FROM [dbo].[SQL - Retail Sales Analysis_utf ]
GROUP BY category



-- Q.10 Write a SQL query to create each shift and number of orders (Example Morning <12, Afternoon Between 12 & 17, Evening >17)

WITH hourly_sale AS (
    SELECT *,
        CASE
            WHEN DATEPART(HOUR, sale_time) < 12 THEN 'Morning'
            WHEN DATEPART(HOUR, sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
            ELSE 'Evening'
        END AS shift
    FROM [dbo].[SQL - Retail Sales Analysis_utf ]
)
SELECT 
    shift,
    COUNT(*) AS total_orders    
FROM hourly_sale
GROUP BY shift;

-- Monthly Sales Trend

SELECT 
    FORMAT(sale_date, 'yyyy-MM') AS sale_month,
    SUM(total_sale) AS total_sales,
    COUNT(*) AS total_orders
FROM [dbo].[SQL - Retail Sales Analysis_utf ]
GROUP BY FORMAT(sale_date, 'yyyy-MM')
ORDER BY sale_month;

-- Stored Procedure to get Top 5 Customers by Total Sales

CREATE PROCEDURE GetTop5Customers
AS
BEGIN
    SELECT TOP 5
        customer_id,
        SUM(total_sale) AS total_sales
    FROM [dbo].[SQL - Retail Sales Analysis_utf ]
    GROUP BY customer_id
    ORDER BY total_sales DESC;
END;
EXEC GetTop5Customers;

--Time series Analysis and Forecasting

SELECT 
   FORMAT(sale_date, 'yyyy-MM') AS sale_month,
   SUM(total_sale) AS total_sales
FROM [dbo].[SQL - Retail Sales Analysis_utf ]
GROUP BY FORMAT(sale_date, 'yyyy-MM')
ORDER BY sale_month;

-- Add a moving average for forecasting
SELECT 
   sale_month,
   total_sales,
   AVG(total_sales) OVER (ORDER BY sale_month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS moving_avg
FROM (
    SELECT 
       FORMAT(sale_date, 'yyyy-MM') AS sale_month,
       SUM(total_sale) AS total_sales
    FROM [dbo].[SQL - Retail Sales Analysis_utf ]
    GROUP BY FORMAT(sale_date, 'yyyy-MM')
) AS sales_data;


-- End of project