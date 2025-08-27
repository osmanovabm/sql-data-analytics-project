/*
===============================================================================
Performance Analysis (Year-over-Year, Month-over-Month)
===============================================================================
Purpose:
    - To measure the performance of products, customers, or regions over time.
    - For benchmarking and identifying high-performing entities.
    - To track yearly trends and growth.

SQL Functions Used:
    - LAG(): Accesses data from previous rows.
    - AVG() OVER(): Computes average values within partitions.
    - CASE: Defines conditional logic for trend analysis.
===============================================================================
*/

/* Analyze the yearly performance of products by comparing their sales 
to both the average sales performance of the product and the previous year's sales */

with yearly_product_sales as (
  select
    extract(year from f.order_date) as order_year,
    p.product_name,
    sum(f.sales_amount) as current_sales
  from gold.gold_fact_sales f
  left join gold.gold_dim_products p
    on f.product_key = p.product_key
  where order_date is not null
  group by
    extract(year from f.order_date),
    p.product_name
)

select
  order_year,
  product_name,
  current_sales,
  avg(current_sales) over(partition by product_name) as avg_sales,
  (current_sales - avg(current_sales) over(partition by product_name)) as diff_avg,
  case when (current_sales - avg(current_sales) over(partition by product_name)) > 0 then 'Above Avg'
  	when (current_sales - avg(current_sales) over(partition by product_name)) < 0 then 'Below Avg'
  	else 'Avg'
  end as avg_change,
  -- Year-over-Year Analysis
  lag(current_sales) over(partition by product_name order by order_year) as py_sales,
  (current_sales - lag(current_sales) over(partition by product_name order by order_year)) as diff_py,
  case when (current_sales - lag(current_sales) over(partition by product_name order by order_year)) > 0 then 'Increase'
  	when (current_sales - lag(current_sales) over(partition by product_name order by order_year)) < 0 then 'Decrease'
  	else 'No Change'
  end as py_change
from yearly_product_sales
order by
  product_name,
  order_year
