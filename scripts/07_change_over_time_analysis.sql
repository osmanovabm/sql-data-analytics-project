/*
===============================================================================
Change Over Time Analysis
===============================================================================
Purpose:
    - To track trends, growth, and changes in key metrics over time.
    - For time-series analysis and identifying seasonality.
    - To measure growth or decline over specific periods.

SQL Functions Used:
    - Date Functions: EXTRACT(YEAR FROM column_name), EXTRACT(MONTH FROM column_name)
    - Aggregate Functions: SUM(), COUNT(), AVG()
===============================================================================
*/

-- Analyse sales performance over time
select
	extract (year from order_date) as order_year,
	extract (month from order_date) as order_month,
  sum(sales_amount) as total_sales,
  count(distinct customer_key) as total_customers,
  sum(quantity) as total_quantity
from gold.gold_fact_sales
where order_date is not null
group by
	extract (year from order_date),
	extract (month from order_date)
order by order_year, order_month
