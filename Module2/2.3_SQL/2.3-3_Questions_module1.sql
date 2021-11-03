-- Total Sales, Total Profit
select round(sum(sales)) as total_sales, round(sum(profit)) as total_profit 
from orders o ;

-- Profit Ratio
select round((profit/sales)*100) as profit_ratio
from orders o 
order by row_id;

-- Profit per Order
select order_id, round(sum(profit)) as profit_per_order
from  orders o 
group by 1 
order by 1;

-- Sales per Customer, Profit per Customer
select customer_name, round(sum(sales)) as sales_per_customer, round(sum(profit)) as profit_per_customer
from orders o 
group by 1
order by 1;

-- Avg. Discount
select extract(month from order_date) as month, extract(year from order_date) as year, round(avg(discount),2) as avg_discount
from orders o 
group by 1, 2
order by 2, 1;

-- Monthly Sales by Segment
select extract(year from order_date) as year, extract(month from order_date) as month, segment, round(sum(sales)) as monthly_sales
from orders o 
group by 1, 2, 3
order by 1, 2, 3;

-- Monthly Sales by Product Category
select extract(year from order_date) as year, extract(month from order_date) as month, category, round(sum(sales)) as monthly_sales
from orders o 
group by 1, 2, 3
order by 1, 2, 3;

-- Sales by Product Category
select category, round(sum(sales)) as sum_sales
from orders o 
group by 1
union
select 'Total_sales' as category , round(sum(sales)) as sum_sales
from orders o2
order by 1;

-- Profit by Customer
select customer_name, round(sum(profit)) as profit
from orders o 
group by 1
order by 2 desc 
limit 10;

-- Sales per region
select extract(year from order_date) as year, region, round(sum(sales)) as sum_sales
from orders o 
group by 1, 2
order by 1, 3 desc;

-- Sum sales per region
select region, round(sum(sales)) as sum_sales
from orders o 
group by 1
order by 2 desc;

-- Sales and profit per city
select city, round(sum(sales)) as sales_per_city, round(sum(profit)) as profit_per_city
from orders o 
group by 1
order by 3 desc
limit 10;

-- Sales and profit by manager
select person, round(sum(sales)) as manager_sales, round(sum(profit)) as manager_profit
from orders o 
inner join people using (region)
group by 1
order by 3 desc;