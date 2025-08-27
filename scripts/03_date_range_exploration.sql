/*
===============================================================================
Date Range Exploration 
===============================================================================
Purpose:
    - To determine the temporal boundaries of key data points.
    - To understand the range of historical data.

SQL Functions Used:
    - MIN(), MAX(), DATEDIFF()
===============================================================================
*/

-- Determine the first and last order date and the total duration in months
SELECT
	MIN(order_date)) AS first_order_date,
	MAX(order_date)) AS last_order_date,
	(DATE_PART('year', MAX(order_date)) - DATE_PART('year', MIN(order_date))) * 12 + (DATE_PART('month', MAX(order_date)) - DATE_PART('month', MIN(order_date))) AS order_range_month
FROM gold.gold_fact_sales
WHERE order_date IS NOT NULL;

-- Find the youngest and oldest customer based on birthdate
SELECT
	MIN(birthdate) AS oldest_birthdate,
	MAX(birthdate) AS youngest_birthdate
FROM gold.gold_dim_customers
WHERE birthdate IS NOT NULL;
