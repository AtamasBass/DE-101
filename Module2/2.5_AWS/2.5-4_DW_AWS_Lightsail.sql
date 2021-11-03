-- update stg.orders
-- create schema dw
-- create dim tables (shipping, customer, product, geo)
-- fix data quality problem
-- create sales_fact table
-- match number of rows between staging and dw (business layer)

-- update stg.orders.postal_code
update stg.orders 
set postal_code = lpad(postal_code,5,'0')
where postal_code like '____';

update stg.orders
set postal_code = '05401'
where postal_code is null;

-- create schema
create schema dw;

--customer_dim
CREATE TABLE dw.customer_dim
(
 customer_dim_id integer generated always as identity,
 customer_name   varchar(22) NOT NULL,
 customer_id     varchar(8) NOT NULL,
 segment         varchar(11) NOT NULL,
 CONSTRAINT PK_49 PRIMARY KEY ( customer_dim_id )
);

insert into dw.customer_dim (customer_id, customer_name, segment)
select customer_id, customer_name, segment
from stg.orders
group by customer_id, customer_name, segment
order by customer_name;

--geo_dim
CREATE TABLE dw.geo_dim
(
 geo_dim_id  integer generated always as identity,
 country     varchar(13) NOT NULL,
 city        varchar(17) NOT NULL,
 "state"       varchar(20) NOT NULL,
 region      varchar(7) NOT NULL,
 postal_code varchar(50) NOT NULL,
 CONSTRAINT PK_64 PRIMARY KEY ( geo_dim_id )
);

insert into dw.geo_dim (country, city, state, region, postal_code)
select country, city, state, region, postal_code
from stg.orders
group by country, city, state, region, postal_code
order by city;

--order_date_dim
CREATE TABLE dw.order_date_dim
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

insert into dw.order_date_dim (order_date, year, quarter, month, week, week_day)
select order_date, extract (year from order_date) as year, 
                   extract (quarter from order_date) as quarter, 
                   extract (month from order_date) as month,
                   extract (week from order_date) as week,
                   extract (day from order_date) as week_day              
from stg.orders
group by 1
order by 1;

--product_dim
CREATE TABLE dw.product_dim
(
 product_dim_id integer generated always as identity,
 category       varchar(15) NOT NULL,
 subcategory    varchar(11) NOT NULL,
 product_name   varchar(127) NOT NULL,
 product_id     varchar(15) NOT NULL,
 CONSTRAINT PK_56 PRIMARY KEY ( product_dim_id )
);

insert into dw.product_dim (category, subcategory, product_name, product_id)
select category, subcategory, product_name, product_id
from stg.orders
group by category, subcategory, product_name, product_id
order by product_id;

--ship_date_dim
CREATE TABLE dw.ship_date_dim
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

insert into dw.ship_date_dim (ship_date, year, quarter, month, week, week_day)
select ship_date , extract (year from ship_date) as year, 
                   extract (quarter from ship_date) as quarter, 
                   extract (month from ship_date) as month,
                   extract (week from ship_date) as week,
                   extract (day from ship_date) as week_day              
from stg.orders
group by 1
order by 1;

--shipping_dim
CREATE TABLE dw.shipping_dim
(
 ship_dim_id integer generated always as identity,
 ship_mode   varchar(14) NOT NULL,
 CONSTRAINT PK_74 PRIMARY KEY ( ship_dim_id )
);

insert into dw.shipping_dim (ship_mode)
select distinct ship_mode
from stg.orders
order by ship_mode;

--sales_fact
CREATE TABLE dw.sales_fact
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
 CONSTRAINT FK_156 FOREIGN KEY ( ship_date_id ) REFERENCES dw.ship_date_dim ( ship_date_id ),
 CONSTRAINT FK_14 FOREIGN KEY ( customer_dim_id ) REFERENCES dw.customer_dim ( customer_dim_id ),
 CONSTRAINT FK_17 FOREIGN KEY ( product_dim_id ) REFERENCES dw.product_dim ( product_dim_id ),
 CONSTRAINT FK_15 FOREIGN KEY ( geo_dim_id ) REFERENCES dw.geo_dim ( geo_dim_id ),
 CONSTRAINT FK_16 FOREIGN KEY ( ship_dim_id ) REFERENCES dw.shipping_dim ( ship_dim_id ),
 CONSTRAINT FK_20 FOREIGN KEY ( order_date_id ) REFERENCES dw.order_date_dim ( order_date_id )
);

insert into dw.sales_fact (order_id, sales, quantity, discount, profit, customer_dim_id, product_dim_id, order_date_id, ship_date_id, geo_dim_id, ship_dim_id)
select order_id, sales, quantity, discount, profit, customer_dim_id, product_dim_id, order_date_id, ship_date_id, geo_dim_id, ship_dim_id
from stg.orders
inner join dw.customer_dim on stg.orders.customer_id = dw.customer_dim.customer_id
inner join dw.geo_dim on stg.orders.postal_code = dw.geo_dim.postal_code and stg.orders.city = dw.geo_dim.city
inner join dw.shipping_dim on stg.orders.ship_mode = dw.shipping_dim.ship_mode
inner join dw.order_date_dim on stg.orders.order_date = dw.order_date_dim.order_date
inner join dw.product_dim on stg.orders.product_id = dw.product_dim.product_id and stg.orders.product_name = dw.product_dim.product_name
inner join dw.ship_date_dim on stg.orders.ship_date = dw.ship_date_dim.ship_date
order by stg.orders.order_id;

--do you get 9994 rows?
select count (*) from dw.sales_fact;

--custom query for BI
select * 
from dw.sales_fact sf 
inner join dw.customer_dim on sf.customer_dim_id = dw.customer_dim.customer_dim_id
inner join dw.geo_dim on sf.geo_dim_id = dw.geo_dim.geo_dim_id
inner join dw.shipping_dim on sf.ship_dim_id = dw.shipping_dim.ship_dim_id
inner join dw.order_date_dim on sf.order_date_id = dw.order_date_dim.order_date_id 
inner join dw.product_dim on sf.product_dim_id = dw.product_dim.product_dim_id
inner join dw.ship_date_dim on sf.ship_date_id = dw.ship_date_dim.ship_date_id;