-- BASIC EXPLORATION
SELECT * FROM orders LIMIT 20;  -- checkout all columns and rows
SELECT COUNT(*) AS total_rows FROM orders; -- find total of rows
SELECT COUNT(DISTINCT customer_id) AS unique_customers FROM orders; -- find no of unique customers
SELECT COUNT(DISTINCT product_id) AS unique_products FROM orders;  -- find no of unique products
SELECT COUNT(DISTINCT  country) AS unique_country FROM orders; -- find no of unique country
SELECT COUNT(*) AS invalid_dates FROM orders WHERE ship_date < order_date; --  ship_date must be after order_date
SELECT DISTINCT category, sub_category FROM orders ORDER BY category; -- checkout category to subcategory division


-- REVENUE & PERFORMANCE 
--  1. Overall business metrics : Total revenue, profit, number of products, transaction count

SELECT 
SUM(sales) AS total_revenue,
SUM(profit) AS total_profit,
COUNT(DISTINCT product_id) AS no_of_product,
COUNT(DISTINCT order_id) AS transaction_count
FROM orders;

-- 2. Sales by category : Which categories (Furniture, Office Supplies, Technology) perform best?

SELECT category, SUM(profit) AS total_profit
FROM orders
GROUP BY category
ORDER BY total_profit DESC;

-- 3. Sales trend over time : Monthly or yearly trends - is business growing?
-- sales trend monthly
-- (total_sales - prev_month_sales)/(prev_month_sales)*100 = (%) monthly_pct_change

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

-- yearly sales trend

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

-- 4. Customer segments : Consumer vs Corporate vs Home Office - who buys what?

SELECT 
	segment, 
	sub_category, 
    COUNT(sub_category) AS num_order_sub,
    SUM(SALES) AS total_sales
FROM orders 
GROUP BY segment, sub_category
ORDER BY segment;

-- 5. Geographic distribution : Which regions drive sales?

SELECT region, SUM(sales) AS total_sales
FROM orders
GROUP BY region
ORDER BY total_sales DESC;

-- 6. Top performing products : Which products generate most revenue AND profit?
-- Top revenue

SELECT product_id,product_name, SUM(sales) AS total_revenue
FROM orders
GROUP BY product_id, product_name
ORDER BY total_revenue DESC
LIMIT 10;

-- top profit
SELECT product_id,product_name, SUM(profit)  AS total_profit
FROM orders
GROUP BY product_id, product_name
ORDER BY total_profit DESC
LIMIT 10;

--  top profit margin

SELECT 
    product_id,
    product_name,
    SUM(sales) AS total_revenue,      
    SUM(profit) AS total_profit,       
    ROUND((SUM(profit) / SUM(sales)) * 100, 2) AS profit_margin_pct
FROM orders
GROUP BY product_id, product_name
ORDER BY profit_margin_pct DESC;

-- 7. Underperforming/loss-making products : Which products lose money consistently?

SELECT 
    product_id,
    product_name,
    category,
    sub_category,
    COUNT(*) AS num_transactions,
    SUM(profit) AS total_profit,
    ROUND(SUM(profit) / COUNT(*), 2) AS avg_profit_per_transaction -- some product have more than 1 transaction.
FROM orders
GROUP BY product_id, product_name, category, sub_category
HAVING SUM(profit) < 0  
ORDER BY avg_profit_per_transaction ASC
LIMIT 10;

-- 8. Product sales velocity & trends : Which products are growing vs declining?

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
AND ROUND((total_sales - previous_year_sales) / previous_year_sales * 100, 2) > 0  -- > if growing, but < if declining
ORDER BY growth_rate_pct DESC -- DESC if growing, ASC if declining
LIMIT 10; 





