-- Create Database
CREATE DATABASE IF NOT EXISTS superstore_db;
USE superstore_db;

-- Create Table
CREATE TABLE orders (
    row_id INT PRIMARY KEY,
    order_id VARCHAR(20) NOT NULL,
    order_date DATE NOT NULL,
    ship_date DATE NOT NULL,
    ship_mode VARCHAR(20),
    customer_id VARCHAR(20) NOT NULL,
    customer_name VARCHAR(50),
    segment VARCHAR(20),
    country VARCHAR(50),
    city VARCHAR(50),
    state VARCHAR(50),
    postal_code VARCHAR(10),
    region VARCHAR(20),
    product_id VARCHAR(20) NOT NULL,
    category VARCHAR(30),
    sub_category VARCHAR(30),
    product_name VARCHAR(255),
    sales DECIMAL(10, 4),
    quantity INT,
    discount DECIMAL(4, 2),
    profit DECIMAL(10, 4)
);

-- Load CSV Data (file is in uploads folder, no LOCAL keyword needed)
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Sample - Superstore.csv'
INTO TABLE orders
CHARACTER SET latin1
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(row_id, order_id, @order_date, @ship_date, ship_mode, customer_id, 
 customer_name, segment, country, city, state, postal_code, region, 
 product_id, category, sub_category, product_name, sales, quantity, 
 discount, profit)
SET 
    order_date = STR_TO_DATE(@order_date, '%m/%d/%Y'),
    ship_date = STR_TO_DATE(@ship_date, '%m/%d/%Y');

-- Verify Import
SELECT COUNT(*) AS total_rows FROM orders;
SELECT * FROM orders LIMIT 10;