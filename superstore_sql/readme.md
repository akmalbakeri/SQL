Superstore Sales Analysis - MySQL Project

📊 Project Overview  
[Source from Kaggle](https://www.kaggle.com/datasets/vivek468/superstore-dataset-final)  
Analyzed 9,995 retail transactions from a US-based superstore to uncover sales trends, 
identify product performance patterns, and provide data-driven recommendations for business optimization.  

This project also proceeded with Power BI Visualization in another repo in [here](https://github.com/akmalbakeri/Visualization/tree/main/Superstore)

🔍 Analysis Breakdown
🧭 Basic Exploration

Scoped the dataset: 9,994 rows, 4 ship modes, 793 customers, 1,862 products across 49 US states
Validated data integrity (e.g., confirmed no ship dates precede order dates)
Mapped all categories → sub-categories

📈 Sales & Revenue Trends

Overall metrics: Total revenue, profit, unique products, and transaction count at a glance
Monthly sales by year: Identified seasonal peaks and slow periods
Year-over-year growth: Used LAG() window function to calculate annual % change
Month-over-month growth: Granular trend monitoring across the full 4-year period

👥 Customer Segments

Compared Consumer, Corporate, and Home Office segments
Broken down by category and sub-category with profit margin %
Filtered to only profitable segment–product combinations

🗺️ Geographic Distribution

Ranked all regions by total sales to identify top revenue drivers

🏆 Product Performance

Top sellers by revenue: Full product-level breakdown with profit
Top 10 most profitable products: Filtered and ranked by net profit
Loss-making products: Identified bottom 10 consistently unprofitable products
Growth vs. decline (2017): Used LAG() partitioned by product_id to flag growing and declining products year-over-year
