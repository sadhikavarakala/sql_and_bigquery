-- Exploring menus table
-- View menu_items table
SELECT *
FROM menu_items;

-- Number of items on the menu
SELECT COUNT(*)
FROM menu_items;

-- Least and most expensive items on menu
SELECT item_name, price
FROM menu_items
ORDER BY price desc;  -- most expensive

SELECT item_name, price
FROM menu_items
ORDER BY price;  -- least expensive
 
-- Number of italian dishes on the menu
SELECT COUNT(item_name)
FROM menu_items
WHERE category LIKE 'Italian';

-- least and most expensive italian dishes on the menu
SELECT *
FROM menu_items
WHERE category LIKE 'Italian' 
ORDER BY price;

SELECT *
FROM menu_items
WHERE category LIKE 'Italian' 
ORDER BY price desc;

-- how many dishes are in each category
SELECT category, COUNT(menu_item_id) AS num_dishes
FROM menu_items
GROUP BY category;

-- Avg dish price within each category
SELECT category, avg(price) AS avg_price
FROM menu_items
GROUP BY category;

-- Exploring orders tables
-- Table overiew
SELECT *
FROM order_details;

-- What is the date range of the the table
SELECT MIN(order_date), MAX(order_date)
FROM order_details;

-- How many orders were made within this date range
SELECT MIN(order_date), MAX(order_date), COUNT(DISTINCT(order_id)) as Num_of_orders
FROM order_details;

-- How many items were ordered 
SELECT MIN(order_date), MAX(order_date), COUNT (*) as Num_of_items
FROM order_details;

-- Which orders had most number of items
SELECT order_id, COUNT(item_id) AS num_of_items
FROM order_details
GROUP BY order_id
ORDER BY num_of_items DESC;

-- How many orders had more than 12 items
SELECT COUNT (*) FROM
	(SELECT order_id, COUNT(item_id) AS num_of_items
	FROM order_details
	GROUP BY order_id
	HAVING COUNT(item_id)> 12) AS num_orders;
	
-- Analysis
-- Combine the menu_items and order_details table into a single table

SELECT *
FROM order_details od
LEFT JOIN menu_items mi
	ON od.item_id = mi.menu_item_id;
	
-- least and most ordered items, which categories were they in

SELECT item_name, category, COUNT(order_details_id) AS num_purchases
FROM order_details od
LEFT JOIN menu_items mi
	ON od.item_id = mi.menu_item_id
GROUP BY item_name, category
ORDER BY num_purchases DESC;

-- top 5 orders that spent the most money
SELECT order_id, SUM(price) total_spend
FROM order_details od
LEFT JOIN menu_items mi
	ON od.item_id = mi.menu_item_id
GROUP BY order_id
HAVING COUNT(mi.menu_item_id) > 0 -- or: HAVING SUM(mi.price) IS NOT NULL
ORDER BY total_spend DESC
LIMIT 5;

-- details of highest spend order
SELECT category, COUNT(item_id) AS num_items
FROM order_details od
LEFT JOIN menu_items mi
	ON od.item_id = mi.menu_item_id
WHERE order_id = 440
GROUP BY category;

-- Details of all 5 top orders
SELECT order_id, category, COUNT(item_id) AS num_items
FROM order_details od
LEFT JOIN menu_items mi
	ON od.item_id = mi.menu_item_id
WHERE order_id IN (440, 2075, 1957, 330, 2675)
GROUP BY order_id, category;