-- top 110 revenue generating products
use kaggleAPI;
select product_id , sum(sell_price) as sales
from dfOrders
group by product_id
ORDER BY sales desc limit 10

-- find top 5 highest selling prducts in each region

-- select distinct region from dfOrders; 
-- select region,product_id,sum(sell_price) as sales
-- from dfOrders
-- group by region,product_id
-- order by region,sales desc 
with cte as(
select region,product_id,sum(sell_price) as sales
from dfOrders
group by region,product_id
)
select * from (
select *,row_number() 
over(partition by region order by sales desc) as rnk
from cte) A
where rnk <= 5


-- find month over month comparision for 2022 ans 2023 sales eg. jan 2022 vs jan 2023

-- select year(order_date) as order_year,month(order_date) as order_month,
-- sum(sell_price) as sales
-- from dfOrders
-- group by year(order_date),month(order_date)
-- order by year(order_date),month(order_date) 
with cte as (
	select year(order_date) as order_year,month(order_date) as order_month,
	sum(sell_price) as sales
	from dfOrders
	group by year(order_date),month(order_date)
)
select order_month, 
sum(case when order_year =2022 then sales else 0 end) as sales_2022,
sum(case when order_year =2023 then sales else 0 end) as sales_2023
from cte
group by order_month
order by order_month


-- for each category which month had highest sales
with cte as(
select category, year(order_date) as order_year,month(order_date) as order_month, sum(sell_price) as sales
from dfOrders
group by category,order_year,order_month
-- order by category,order_year,order_month
)
select * from (
select *,row_number()
over (partition by category order by sales desc) as rnk
from cte
) A
where rnk <= 1

-- wich sub-category had highest growthby profit in 2023 compared to 2022
with cte as (
	select sub_category,year(order_date) as order_year,
	sum(sell_price) as sales
	from dfOrders
	group by sub_category,year(order_date)
)
, cte2 as(
	select sub_category, 
	sum(case when order_year =2022 then sales else 0 end) as sales_2022,
	sum(case when order_year =2023 then sales else 0 end) as sales_2023
	from cte
	group by sub_category
)
select * ,
(sales_2023 - sales_2022) as growth
from cte2
order by growth desc limit 1

