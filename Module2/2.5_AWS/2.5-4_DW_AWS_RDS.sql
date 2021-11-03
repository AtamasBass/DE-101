-- update stg.orders
-- create schema dw_rds
-- create dim tables (shipping, customer, product, geo)
-- fix data quality problem
-- create sales_fact table
-- match number of rows between staging and dw (business layer)

select count(*) from stg_rds.orders; --9994

-- update stg.orders.postal_code
update stg_rds.orders
set postal_code = 05401
where postal_code is null;

update stg_rds.orders 
set postal_code = lpad(postal_code,5,'0')
where postal_code like '____';

-- create schema
create schema dw_rds;

--customer_dim
CREATE TABLE dw_rds.customer_dim
(
customer_dim_id integer generated always as identity,
customer_name   varchar(22) NOT NULL,
customer_id     varchar(8) NOT NULL,
segment         varchar(11) NOT NULL,
CONSTRAINT PK_49 PRIMARY KEY ( customer_dim_id )
);

insert into dw_rds.customer_dim (customer_id, customer_name, segment)
select customer_id, customer_name, segment
from stg_rds.orders
group by customer_id, customer_name, segment
order by customer_name;

--geo_dim
CREATE TABLE dw_rds.geo_dim
(
geo_dim_id  integer generated always as identity,
country     varchar(13) NOT NULL,
city        varchar(17) NOT NULL,
state       varchar(20) NOT NULL,
region      varchar(7) NOT NULL,
postal_code varchar(50) NOT NULL,
CONSTRAINT PK_64 PRIMARY KEY ( geo_dim_id )
);

insert into dw_rds.geo_dim (country, city, state, region, postal_code)
select country, city, state, region, postal_code
from stg_rds.orders
group by country, city, state, region, postal_code
order by city;

--order_date_dim
CREATE TABLE dw_rds.order_date_dim
(
order_date_id integer generated always as identity,
order_date    date NOT NULL,
year          integer NOT NULL,
quarter       integer NOT NULL,
month         integer NOT NULL,
week          integer NOT NULL,
week_day      integer NOT NULL,
CONSTRAINT PK_138 PRIMARY KEY ( order_date_id )
);

insert into dw_rds.order_date_dim (order_date, year, quarter, month, week, week_day)
select order_date, extract (year from order_date) as year,
extract (quarter from order_date) as quarter,
extract (month from order_date) as month,
extract (week from order_date) as week,
extract (day from order_date) as week_day
from stg_rds.orders
group by 1
order by 1;

--product_dim
CREATE TABLE dw_rds.product_dim
(
product_dim_id integer generated always as identity,
category       varchar(15) NOT NULL,
subcategory    varchar(11) NOT NULL,
product_name   varchar(127) NOT NULL,
product_id     varchar(15) NOT NULL,
CONSTRAINT PK_56 PRIMARY KEY ( product_dim_id )
);

insert into dw_rds.product_dim (category, subcategory, product_name, product_id)
select category, subcategory, product_name, product_id
from stg_rds.orders
group by category, subcategory, product_name, product_id
order by product_id;

--ship_date_dim
CREATE TABLE dw_rds.ship_date_dim
(
ship_date_id integer generated always as identity,
ship_date    date NOT NULL,
year         integer NOT NULL,
quarter      integer NOT NULL,
month        integer NOT NULL,
week         integer NOT NULL,
week_day     integer NOT NULL,
CONSTRAINT PK_128 PRIMARY KEY ( ship_date_id )
);

insert into dw_rds.ship_date_dim (ship_date, year, quarter, month, week, week_day)
select ship_date , extract (year from ship_date) as year,
extract (quarter from ship_date) as quarter,
extract (month from ship_date) as month,
extract (week from ship_date) as week,
extract (day from ship_date) as week_day
from stg_rds.orders
group by 1
order by 1;

--shipping_dim
CREATE TABLE dw_rds.shipping_dim
(
ship_dim_id integer generated always as identity,
ship_mode   varchar(14) NOT NULL,
CONSTRAINT PK_74 PRIMARY KEY ( ship_dim_id )
);

insert into dw_rds.shipping_dim (ship_mode)
select distinct ship_mode
from stg_rds.orders
order by ship_mode;

--sales_fact
CREATE TABLE dw_rds.sales_fact
(
sales_fact_id   integer generated always as identity,
customer_dim_id integer NOT NULL,
product_dim_id  integer NOT NULL,
geo_dim_id      integer NOT NULL,
ship_dim_id     integer NOT NULL,
order_date_id   integer NOT NULL,
ship_date_id    integer NOT NULL,
order_id        varchar(14) NOT NULL,
sales           numeric(9,4) NOT NULL,
quantity        integer NOT NULL,
discount        numeric(4,2) NOT NULL,
profit          numeric(21,16) NOT NULL,
CONSTRAINT PK_139 PRIMARY KEY ( sales_fact_id ),
CONSTRAINT FK_156 FOREIGN KEY ( ship_date_id ) REFERENCES dw_rds.ship_date_dim ( ship_date_id ),
CONSTRAINT FK_14 FOREIGN KEY ( customer_dim_id ) REFERENCES dw_rds.customer_dim ( customer_dim_id ),
CONSTRAINT FK_17 FOREIGN KEY ( product_dim_id ) REFERENCES dw_rds.product_dim ( product_dim_id ),
CONSTRAINT FK_15 FOREIGN KEY ( geo_dim_id ) REFERENCES dw_rds.geo_dim ( geo_dim_id ),
CONSTRAINT FK_16 FOREIGN KEY ( ship_dim_id ) REFERENCES dw_rds.shipping_dim ( ship_dim_id ),
CONSTRAINT FK_20 FOREIGN KEY ( order_date_id ) REFERENCES dw_rds.order_date_dim ( order_date_id )
);

CREATE INDEX fkIdx_158 ON dw_rds.sales_fact
(
ship_date_id
);

CREATE INDEX fkIdx_24 ON dw_rds.sales_fact
(
customer_dim_id
);

CREATE INDEX fkIdx_57 ON dw_rds.sales_fact
(
product_dim_id
);

CREATE INDEX fkIdx_65 ON dw_rds.sales_fact
(
geo_dim_id
);

CREATE INDEX fkIdx_75 ON dw_rds.sales_fact
(
ship_dim_id
);

CREATE INDEX fkIdx_83 ON dw_rds.sales_fact
(
order_date_id
);

insert into dw_rds.sales_fact (order_id, sales, quantity, discount, profit, customer_dim_id, product_dim_id, order_date_id, ship_date_id, geo_dim_id, ship_dim_id)
select order_id, sales, quantity, discount, profit, customer_dim_id, product_dim_id, order_date_id, ship_date_id, geo_dim_id, ship_dim_id
from stg_rds.orders
inner join dw_rds.customer_dim on stg_rds.orders.customer_id = dw_rds.customer_dim.customer_id
inner join dw_rds.geo_dim on stg_rds.orders.postal_code = dw_rds.geo_dim.postal_code and stg_rds.orders.city = dw_rds.geo_dim.city
inner join dw_rds.shipping_dim on stg_rds.orders.ship_mode = dw_rds.shipping_dim.ship_mode
inner join dw_rds.order_date_dim on stg_rds.orders.order_date = dw_rds.order_date_dim.order_date
inner join dw_rds.product_dim on stg_rds.orders.product_id = dw_rds.product_dim.product_id and stg_rds.orders.product_name = dw_rds.product_dim.product_name
inner join dw_rds.ship_date_dim on stg_rds.orders.ship_date = dw_rds.ship_date_dim.ship_date
order by stg_rds.orders.order_id;

--do you get 9994 rows?
select count (*) from dw_rds.sales_fact;--9994

--custom query for BI
select * 
from dw_rds.sales_fact sf 
inner join dw_rds.customer_dim on sf.customer_dim_id = dw_rds.customer_dim.customer_dim_id
inner join dw_rds.geo_dim on sf.geo_dim_id = dw_rds.geo_dim.geo_dim_id
inner join dw_rds.shipping_dim on sf.ship_dim_id = dw_rds.shipping_dim.ship_dim_id
inner join dw_rds.order_date_dim on sf.order_date_id = dw_rds.order_date_dim.order_date_id 
inner join dw_rds.product_dim on sf.product_dim_id = dw_rds.product_dim.product_dim_id
inner join dw_rds.ship_date_dim on sf.ship_date_id = dw_rds.ship_date_dim.ship_date_id; 