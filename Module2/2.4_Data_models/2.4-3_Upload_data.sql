-- insert into customer_dim
insert into customer_dim (customer_id, customer_name, segment)
select customer_id, customer_name, segment
from orders
group by customer_id, customer_name, segment
order by customer_name;

--update orders.postal_code
select country, city, state, region, postal_code
from orders o 
where postal_code is null;

update orders
set postal_code = 05401
where postal_code is null;

-- insert into geo_dim
insert into geo_dim (country, city, state, region, postal_code)
select country, city, state, region, postal_code
from orders
group by country, city, state, region, postal_code
order by city;

-- insert into product_dim
insert into product_dim (category, subcategory, product_name, product_id)
select category, subcategory, product_name, product_id
from orders
group by category, subcategory, product_name, product_id
order by product_id;

-- insert into shipping_dim
insert into shipping_dim (ship_mode)
select distinct ship_mode
from orders
order by ship_mode;

--insert into order_date_dim
insert into order_date_dim (order_date, year, quarter, month, week, week_day)
select order_date, extract (year from order_date) as year, 
                   extract (quarter from order_date) as quarter, 
                   extract (month from order_date) as month,
                   extract (week from order_date) as week,
                   extract (day from order_date) as week_day              
from orders
group by 1
order by 1;

--insert into ship_date_dim
insert into ship_date_dim (ship_date, year, quarter, month, week, week_day)
select ship_date , extract (year from ship_date) as year, 
                   extract (quarter from ship_date) as quarter, 
                   extract (month from ship_date) as month,
                   extract (week from ship_date) as week,
                   extract (day from ship_date) as week_day              
from orders
group by 1
order by 1;

--insert into sales_fact
insert into sales_fact (order_id, sales, quantity, discount, profit, customer_dim_id, product_dim_id, order_date_id, ship_date_id, geo_dim_id, ship_dim_id)
select order_id, sales, quantity, discount, profit, customer_dim_id, product_dim_id, order_date_id, ship_date_id, geo_dim_id, ship_dim_id
from orders
inner join customer_dim on orders.customer_id = customer_dim.customer_id
inner join geo_dim on orders.postal_code = geo_dim.postal_code and orders.city = geo_dim.city
inner join shipping_dim on orders.ship_mode = shipping_dim.ship_mode
inner join order_date_dim on orders.order_date = order_date_dim.order_date
inner join product_dim on orders.product_id = product_dim.product_id and orders.product_name = product_dim.product_name
inner join ship_date_dim on orders.ship_date = ship_date_dim.ship_date
order by orders.order_id; 

--alter and update postal_code
alter table orders 
alter column postal_code type varchar (50);

update orders 
set postal_code = lpad(postal_code,5,'0')
where postal_code like '____';

--do you get 9994 rows?
select count(*) from sales_fact;

--custom query for BI
select * 
from sales_fact sf 
inner join customer_dim on sf.customer_dim_id = customer_dim.customer_dim_id
inner join geo_dim on sf.geo_dim_id = geo_dim.geo_dim_id
inner join shipping_dim on sf.ship_dim_id = shipping_dim.ship_dim_id
inner join order_date_dim on sf.order_date_id = order_date_dim.order_date_id 
inner join product_dim on sf.product_dim_id = product_dim.product_dim_id
inner join ship_date_dim on sf.ship_date_id = ship_date_dim.ship_date_id; 
