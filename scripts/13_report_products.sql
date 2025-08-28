/*
===============================================================================
Product Report
===============================================================================
Purpose:
    - This report consolidates key product metrics and behaviors.

Highlights:
    1. Gathers essential fields such as product name, category, subcategory, and cost.
    2. Segments products by revenue to identify High-Performers, Mid-Range, or Low-Performers.
    3. Aggregates product-level metrics:
       - total orders
       - total sales
       - total quantity sold
       - total customers (unique)
       - lifespan (in months)
    4. Calculates valuable KPIs:
       - recency (months since last sale)
       - average order revenue (AOR)
       - average monthly revenue
===============================================================================
*/
-- =============================================================================
-- Create Report: gold.report_products
-- =============================================================================
DROP VIEW IF EXISTS gold.report_products;

CREATE VIEW gold.report_products AS 
with base_query as (
	select
  	f.order_number,
  	f.order_date,
  	f.customer_key,
  	f.sales_amount,
  	f.quantity,
  	p.product_key,
  	p.product_name,
  	p.category,
  	p.subcategory,
  	p.cost
	from gold.gold_fact_sales f
	left join gold.gold_dim_products p
	  on p.product_key = f.product_key
	where order_date is not null
),

product_aggregations as (
  /*---------------------------------------------------------------------------
2) Product Aggregations: Summarizes key metrics at the product level
---------------------------------------------------------------------------*/
	select
  	product_key,
  	product_name,
  	category,
  	subcategory,
  	cost,
  	(date_part('year', max(order_date)) - date_part('year', min(order_date))) * 12 + (date_part('month', max(order_date)) - date_part('month', min(order_date))) as lifespan,
  	max(order_date) as last_sale_date,
  	count(distinct order_number) as total_orders,
  	count(distinct customer_key) as total_customers,
  	sum(sales_amount) as total_sales,
  	sum(quantity) as total_quantity,
  	avg(cast(sales_amount as float) / nullif(quantity, 0)) as avg_selling_price
	from base_query
	group by
  	product_key,
  	product_name,
  	category,
  	subcategory,
  	cost
)

/*---------------------------------------------------------------------------
  3) Final Query: Combines all product results into one output
---------------------------------------------------------------------------*/
select
  product_key,
  product_name,
  category,
  subcategory,
  cost,
  last_sale_date,
  (date_part('year', current_date) - date_part('year', last_sale_date)) * 12 + (date_part('month', current_date) - date_part('month', last_sale_date)) as recency_in_months,
  case
  	when total_sales > 50000 then 'High-Performer'
  	when total_sales >= 10000 then 'Mid-Range'
  	else 'Low-Performer'
  end as product_segment,
  lifespan,
  total_orders,
  total_sales,
  total_quantity,
  total_customers,
  avg_selling_price,
-- Average Order Revenue (AOR)
  case
  	when total_orders = 0 then 0
  	else total_sales / total_orders
  end as avg_order_revenue,
-- Average Monthly Revenue
  case
  	when lifespan = 0 then 0
  	else round(total_sales / lifespan)
  end as avg_monthly_revenue
from product_aggregations


