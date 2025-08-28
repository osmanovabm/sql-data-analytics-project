/*
===============================================================================
Customer Report
===============================================================================
Purpose:
    - This report consolidates key customer metrics and behaviors

Highlights:
    1. Gathers essential fields such as names, ages, and transaction details.
	2. Segments customers into categories (VIP, Regular, New) and age groups.
    3. Aggregates customer-level metrics:
	   - total orders
	   - total sales
	   - total quantity purchased
	   - total products
	   - lifespan (in months)
    4. Calculates valuable KPIs:
	    - recency (months since last order)
		- average order value
		- average monthly spend
===============================================================================
*/

-- =============================================================================
-- Create Report: gold.report_customers
-- =============================================================================
DROP VIEW IF EXISTS gold.report_customers;

CREATE VIEW gold.report_customers AS 

with base_query as 
/*---------------------------------------------------------------------------
1) Base Query: Retrieves core columns from tables
---------------------------------------------------------------------------*/
(select
f.order_number,
f.product_key,
f.order_date,
f.sales_amount,
f.quantity,
c.customer_key,
c.customer_number,
concat(c.first_name, ' ', c.last_name) as customer_name,
c.birthdate,
extract (year from age(c.birthdate)) as age
from gold.gold_fact_sales f
left join gold.gold_dim_customers c
on c.customer_key = f.customer_key
where order_date is not null)

, customer_aggregation as (
/*---------------------------------------------------------------------------
2) Customer Aggregations: Summarizes key metrics at the customer level
---------------------------------------------------------------------------*/
select
customer_key,
customer_number,
customer_name,
age,
count(distinct order_number) as total_orders,
sum(sales_amount) as total_sales,
sum(quantity) as total_quantity,
count(distinct product_key) as total_products,
max(order_date) as last_order_date,
(date_part('year', max(order_date)) - date_part('year', min(order_date))) * 12 + (date_part('month', max(order_date)) - date_part('month', min(order_date))) as lifespan
from base_query
group by
customer_key,
customer_number,
customer_name,
age)


select
customer_key,
customer_number,
customer_name,
age,
(case
	when age < 20 then 'Under 20'
	when age between 20 and 29 then '20-29'
	when age between 30 and 39 then '30-39'
	when age between 40 and 49 then '40-49'
	else '50 and above'
end) as age_group,
(case
		when total_sales > 5000 and lifespan >= 12 then 'VIP'
		when total_sales <= 5000 and lifespan >= 12 then 'Regular'
		when lifespan < 12 then 'New'
end) as customer_segment,
last_order_date,
(date_part('year', current_date) - date_part('year', last_order_date)) * 12 + (date_part('month', current_date) - date_part('month', last_order_date)) as recency,
total_orders,
total_sales,
total_quantity,
total_products,
lifespan,
-- Average order value (AVO)
case 
	when total_orders = 0 then 0
	else round(total_sales / total_orders) 
end as avg_order_value,
-- Average monthly spend
case
	when lifespan = 0 then total_sales
	else round(total_sales / lifespan)
end as avg_monthly_spend
from customer_aggregation

