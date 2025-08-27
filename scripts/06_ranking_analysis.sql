/*
===============================================================================
Ranking Analysis
===============================================================================
Purpose:
    - To rank items (e.g., products, customers) based on performance or other metrics.
    - To identify top performers or laggards.

SQL Functions Used:
    - Window Ranking Functions: RANK(), DENSE_RANK(), ROW_NUMBER(), TOP
    - Clauses: GROUP BY, ORDER BY
===============================================================================
*/

-- Which 5 products Generating the Highest Revenue?
-- Simple Ranking
select
	p.product_name,
	sum(f.sales_amount) as total_revenue
from gold.gold_fact_sales f
left join gold.gold_dim_products p
  on f.product_key = p.product_key
group by p.product_name
order by total_revenue desc
limit 5

-- Complex but Flexibly Ranking Using Window Functions
select * 
from 
  	(select
  		p.product_name,
  		sum(f.sales_amount) as total_revenue,
  		dense_rank() over (order by sum(f.sales_amount) desc) as rank_products
  	from gold.gold_fact_sales f
  	left join gold.gold_dim_products p
  	  on f.product_key = p.product_key
  	group by p.product_name) as ranked_products
where rank_products <= 5
  
-- What are the 5 worst-performing products in terms of sales?
select
	p.product_name,
	sum(f.sales_amount) as total_revenue
from gold.gold_fact_sales f
left join gold.gold_dim_products p
  on f.product_key = p.product_key
group by p.product_name
order by total_revenue
limit 5

-- Find the top 10 customers who have generated the highest revenue
select
	c.customer_key,
	c.first_name,
	c.last_name,
	sum(f.sales_amount) as total_revenue
from gold.gold_fact_sales f
left join gold.gold_dim_customers c
	on c.customer_key = f.customer_key
group by
	c.customer_key,
	c.first_name,
	c.last_name
order by total_revenue desc
limit 10
  
-- The 3 customers with the fewest orders placed
select
	c.customer_key,
	c.first_name,
	c.last_name,
	count(distinct f.order_number) as total_orders
from gold.gold_fact_sales f
left join gold.gold_dim_customers c
	on f.customer_key = c.customer_key
group by
	c.customer_key,
	c.first_name,
	c.last_name
order by total_orders desc
limit 3
