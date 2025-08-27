/*
===============================================================================
Cumulative Analysis
===============================================================================
Purpose:
    - To calculate running totals or moving averages for key metrics.
    - To track performance over time cumulatively.
    - Useful for growth analysis or identifying long-term trends.

SQL Functions Used:
    - Window Functions: SUM() OVER(), AVG() OVER()
===============================================================================
*/

-- Calculate the total sales per month 
-- and the running total of sales over time

select
	order_date,
	total_sales,
	sum(total_sales) over(order by order_date) as running_total_sales,
	avg_price,
	round(avg(avg_price) over(order by order_date)) as moving_avg_price
from (
	select
  	to_char(order_date, 'YYYY-MM') as order_date,
  	sum(sales_amount) as total_sales,
  	round(avg(price)) as avg_price
	from gold.gold_fact_sales
	where order_date is not null
	group by to_char(order_date, 'YYYY-MM')
	order by order_date
) as sales_price_table
