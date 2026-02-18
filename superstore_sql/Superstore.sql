-- BASIC EXPLORATION
SELECT * FROM orders LIMIT 20;  -- checkout all columns and rows

SELECT   -- easy to see one table aggregation of important info
	COUNT(*) AS total_rows,  -- find total of rows
    COUNT(DISTINCT ship_mode) AS unique_ship_mode, -- find no of unique ship mode
	COUNT(DISTINCT customer_id) AS unique_customers, -- find no of unique customers
	COUNT(DISTINCT product_id) AS unique_products,  -- find no of unique products
	COUNT(DISTINCT  country) AS unique_country, -- find no of unique country
    COUNT(DISTINCT state) AS unique_state, -- find no of unique state
    COUNT(DISTINCT category) AS unique_category,  -- find no of category
    COUNT(DISTINCT sub_category) AS unique_sub_category  -- find no of category
FROM orders; 

SELECT DISTINCT category, sub_category FROM orders ORDER BY category; -- checkout category to subcategory division
SELECT COUNT(*) AS invalid_dates FROM orders WHERE ship_date < order_date; --  ship_date must be after order_date

-- REVENUE & PERFORMANCE 
--  Overall business metrics : Total revenue, profit, number of products, transaction count

SELECT 
SUM(sales) AS total_revenue,
SUM(profit) AS total_profit,
COUNT(DISTINCT product_id) AS no_of_product,
COUNT(DISTINCT order_id) AS transaction_count
FROM orders;


-- 1. Sales trend by month. Which month is most sales?
-- 1.1 Sales by year and month &
-- 1.2 Sales by month

SELECT 
    YEAR(order_date) AS year,
    MONTH(order_date) AS month,
    SUM(sales) AS total_sales
FROM orders
GROUP BY year, month
ORDER BY year, month

-- 2. Sales trend over time : Monthly or yearly trends - is business growing?
-- (total_sales - prev_month_sales)/(prev_month_sales)*100 = (%) monthly_pct_change
-- 2.1 yearly sales trend perentage

WITH yearly_sales AS (
SELECT 
    YEAR(order_date) AS year,
    SUM(sales) AS total_sales,
    LAG(SUM(sales)) OVER(ORDER BY YEAR(order_date)) AS prev_year_sales
    FROM orders
	GROUP BY year
	ORDER BY year
)
SELECT 
	year,
    total_sales,
	prev_year_sales,
    total_sales - prev_year_sales AS year_sales_diff,
    ROUND((total_sales - prev_year_sales)
    / prev_year_sales*100,2) as year_pct_change
FROM yearly_sales
ORDER BY year;

-- 2.2 monthly sales trend percentage

WITH monthly_sales AS (
SELECT 
    YEAR(order_date) AS year,
    MONTH(order_date) AS month,
    SUM(sales) AS total_sales,
    LAG(SUM(sales)) OVER(ORDER BY YEAR(order_date),MONTH(order_date)) AS prev_month_sales
    FROM orders
	GROUP BY year, month
	ORDER BY year, month
)
SELECT 
	year,
    month,
    total_sales,
	prev_month_sales,
    total_sales - prev_month_sales AS month_sales_diff,
    ROUND((total_sales - prev_month_sales)
    / prev_month_sales*100,2) as month_pct_change
FROM monthly_sales
ORDER BY year, month;

-- 3. Customer segments : Consumer vs Corporate vs Home Office - who buys what?
-- Find total sales, profit, and profit margin according to each segment and sub category

SELECT 
	segment,
	category,
    sub_category,
    SUM(sales) AS total_sales,
    SUM(profit) AS total_profit,
    ROUND((SUM(profit) / SUM(sales)) * 100, 2) AS profit_margin_pct
FROM orders 
GROUP BY segment, category, sub_category
HAVING profit_margin_pct > 0
ORDER BY profit_margin_pct DESC;

-- 4. Geographic distribution : Which regions drive sales?

SELECT region, SUM(sales) AS total_sales
FROM orders
GROUP BY region
ORDER BY total_sales DESC;

-- 5. Top performing products : Which products generate most sales AND profit?
-- 5.1 Top sales by product

SELECT 
	product_id,
    sub_category,
    REPLACE(product_name, ',', ' ') AS product_name, 
    -- use Replace, product_name contains , at most random place, replace it temporarily, or else it will ruin export to csv
    SUM(sales) AS total_sales,
    SUM(profit) AS total_profit
FROM orders
GROUP BY product_id, sub_category, product_name
ORDER BY total_sales DESC;

-- 5.2 Top profit by products
SELECT 
	product_id,
	REPLACE(product_name, ',', ' ') AS product_name,
	SUM(profit)  AS total_profit
FROM orders
GROUP BY product_id, product_name
ORDER BY total_profit DESC
LIMIT 10;


-- 6. Underperforming/loss-making products : Which products lose money consistently?
-- avg_profit_per_transaction = total_profit / num_transactions  

SELECT 
    product_id,
    product_name,
    category,
    sub_category,
    SUM(profit) AS total_profit
FROM orders
GROUP BY product_id, product_name, category, sub_category
HAVING SUM(profit) < 0  
ORDER BY total_profit 
LIMIT 10;

-- 8. Product sales velocity & trends : Which products are growing vs declining? 
-- For recent year (2017) find product with biggest growth and worst decline. 
-- Create cte for product_sales which contains previous year sales using LAG function and for sales_diff
-- Calling lag function in one table is extremely tedious 

WITH product_sales AS (
    SELECT 
        product_id, 
        product_name, 
        YEAR(order_date) AS year,
        SUM(sales) AS total_sales,
        LAG(SUM(sales)) OVER (PARTITION BY product_id ORDER BY YEAR(order_date)) AS previous_year_sales
    FROM orders
    GROUP BY product_id, product_name, YEAR(order_date)
)
SELECT 
    product_id,
    product_name,
    year,
    total_sales,
    previous_year_sales,
    total_sales - previous_year_sales AS sales_diff,
    ROUND((total_sales - previous_year_sales) / previous_year_sales * 100, 2) AS growth_rate_pct 
FROM product_sales
WHERE previous_year_sales IS NOT NULL 
AND year = 2017 -- recent  year
AND ROUND((total_sales - previous_year_sales) / previous_year_sales * 100, 2) > 0  -- > this s growth_rate_pct . if growing, but < if declining
ORDER BY growth_rate_pct DESC -- DESC if growing, ASC if declining
LIMIT 10; 




