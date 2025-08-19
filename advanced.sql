CREATE TABLE sales (
    dt DATE PRIMARY KEY,
    num_sales INTEGER
);
	
INSERT INTO sales (dt, num_sales) VALUES
('2025-01-01', 61),
('2025-01-02', 72),
('2025-01-04', 84),
('2025-01-05', 95),
('2025-01-07', 77);

SELECT * FROM sales;

-- generating series of dates - UNION And UNION ALL -- 
-- UNION - duplicated values will be removed - will stack all values and remove duplicate 
-- UNION ALL - duplicate values are retained

SELECT '2025-01-01' AS dt
UNION ALL
SELECT '2025-01-02'
UNION ALL
SELECT '2025-01-03'
UNION ALL
SELECT '2025-01-04'
UNION ALL
SELECT '2025-01-05'
UNION ALL
SELECT '2025-01-06'
UNION ALL
SELECT '2025-01-07';


-- subquery, LEFt JOIN, INNER JOIN 
SELECT * FROM

	(SELECT '2025-01-01'::DATE AS dt
    UNION ALL SELECT '2025-01-02'::DATE
    UNION ALL SELECT '2025-01-03'::DATE
    UNION ALL SELECT '2025-01-04'::DATE
    UNION ALL SELECT '2025-01-05'::DATE
    UNION ALL SELECT '2025-01-06'::DATE
    UNION ALL SELECT '2025-01-07'::DATE) AS sq

LEFT JOIN sales on sq.dt = sales.dt;

-- CTE (CTE vs Subquery - with CTE, you can state everything at the top and write clean quering at the bottom, all about organisation)
-- use case - when you have mutliple subqueries

WITH cte AS (SELECT '2025-01-01'::DATE AS dt
			UNION ALL SELECT '2025-01-02'::DATE
			UNION ALL SELECT '2025-01-03'::DATE
			UNION ALL SELECT '2025-01-04'::DATE
			UNION ALL SELECT '2025-01-05'::DATE
			UNION ALL SELECT '2025-01-06'::DATE
			UNION ALL SELECT '2025-01-07'::DATE)

SELECT cte.dt, sales.num_sales
FROM cte
LEFT JOIN sales ON cte.dt = sales.dt;

-- Recursive CTE 
WITH RECURSIVE cte AS (
    SELECT CAST('2025-01-01' AS DATE) AS dt
    UNION ALL
    SELECT (dt + INTERVAL '1 day')::DATE
    FROM cte
    WHERE dt < CAST('2025-01-07' AS DATE)
)
SELECT * FROM cte;

--COALESE : searches and rows for null values and fills in with something
WITH RECURSIVE cte AS (
    SELECT CAST('2025-01-01' AS DATE) AS dt
    UNION ALL
    SELECT (dt + INTERVAL '1 day')::DATE
    FROM cte
    WHERE dt < CAST('2025-01-07' AS DATE)
)
SELECT cte.dt, sales.num_sales,
	   COALESCE(sales.num_sales, 0) AS sales_estimate,
	   COALESCE(sales.num_sales, ROUND((SELECT AVG(sales.num_sales) FROM sales), 1)) AS sales_estimate_2
FROM cte 
LEFT JOIN sales on cte.dt = sales.dt;

-- window function: generate a gorup of values across a window of data (certain rows of your data)
SELECT dt, num_sales,
	   ROW_NUMBER() OVER() as row_num,
	   LAG(num_sales) OVER() as prior_row,
	   LEAD(num_sales) OVER() as next_row
FROM sales;

-- Final query
WITH RECURSIVE cte AS (
    SELECT CAST('2025-01-01' AS DATE) AS dt
    UNION ALL
    SELECT (dt + INTERVAL '1 day')::DATE
    FROM cte
    WHERE dt < CAST('2025-01-07' AS DATE)
)
SELECT cte.dt, sales.num_sales,
	   COALESCE(sales.num_sales, 0) AS sales_estimate,
	   COALESCE(sales.num_sales, ROUND((SELECT AVG(sales.num_sales) FROM sales), 1)) AS sales_estimate_2,
	   COALESCE(sales.num_sales, (LAG(sales.num_sales) OVER() + LEAD(sales.num_sales) OVER()) / 2) AS sales_estimate_3
FROM cte 
LEFT JOIN sales on cte.dt = sales.dt;
