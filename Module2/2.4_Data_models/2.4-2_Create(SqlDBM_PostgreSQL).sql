-- *************** SqlDBM: PostgreSQL ****************;
-- ***************************************************;

-- ************************************** customer_dim

CREATE TABLE customer_dim
(
 customer_dim_id integer generated always as identity,
 customer_name   varchar(22) NOT NULL,
 customer_id     varchar(8) NOT NULL,
 segment         varchar(11) NOT NULL,
 CONSTRAINT PK_49 PRIMARY KEY ( customer_dim_id )
);
-- ************************************** geo_dim

CREATE TABLE geo_dim
(
 geo_dim_id  integer generated always as identity,
 country     varchar(13) NOT NULL,
 city        varchar(17) NOT NULL,
 "state"       varchar(20) NOT NULL,
 region      varchar(7) NOT NULL,
 postal_code integer NOT NULL,
 CONSTRAINT PK_64 PRIMARY KEY ( geo_dim_id )
);
-- ************************************** order_date_dim

CREATE TABLE order_date_dim
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
-- ************************************** product_dim

CREATE TABLE product_dim
(
 product_dim_id integer generated always as identity,
 category       varchar(15) NOT NULL,
 subcategory    varchar(11) NOT NULL,
 product_name   varchar(127) NOT NULL,
 product_id     varchar(15) NOT NULL,
 CONSTRAINT PK_56 PRIMARY KEY ( product_dim_id )
);
-- ************************************** ship_date_dim

CREATE TABLE ship_date_dim
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
-- ************************************** shipping_dim

CREATE TABLE shipping_dim
(
 ship_dim_id integer generated always as identity,
 ship_mode   varchar(14) NOT NULL,
 CONSTRAINT PK_74 PRIMARY KEY ( ship_dim_id )
);
-- ************************************** sales_fact

CREATE TABLE sales_fact
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
 CONSTRAINT FK_156 FOREIGN KEY ( ship_date_id ) REFERENCES ship_date_dim ( ship_date_id ),
 CONSTRAINT FK_14 FOREIGN KEY ( customer_dim_id ) REFERENCES customer_dim ( customer_dim_id ),
 CONSTRAINT FK_17 FOREIGN KEY ( product_dim_id ) REFERENCES product_dim ( product_dim_id ),
 CONSTRAINT FK_15 FOREIGN KEY ( geo_dim_id ) REFERENCES geo_dim ( geo_dim_id ),
 CONSTRAINT FK_16 FOREIGN KEY ( ship_dim_id ) REFERENCES shipping_dim ( ship_dim_id ),
 CONSTRAINT FK_20 FOREIGN KEY ( order_date_id ) REFERENCES order_date_dim ( order_date_id )
);

CREATE INDEX fkIdx_158 ON sales_fact
(
 ship_date_id
);

CREATE INDEX fkIdx_24 ON sales_fact
(
 customer_dim_id
);

CREATE INDEX fkIdx_57 ON sales_fact
(
 product_dim_id
);

CREATE INDEX fkIdx_65 ON sales_fact
(
 geo_dim_id
);

CREATE INDEX fkIdx_75 ON sales_fact
(
 ship_dim_id
);

CREATE INDEX fkIdx_83 ON sales_fact
(
 order_date_id
);
