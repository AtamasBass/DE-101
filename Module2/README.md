:arrow_left: [To modules list](https://github.com/AtamasBass/DE-101)
# Module 2
## 2.2 Database
### 2.2.1 Install PostgreSQL
## 2.3 DB and SQL
### 2.3.1 Create a connection to PostgreSQL Data in DBeaver
### 2.3.2 Create tables and upload data from ![Superstore Excel](https://github.com/AtamasBass/DE-101/blob/master/Module1/Sample%20-%20Superstore%20O.Atamas.xlsx)
* [Orders table](https://github.com/AtamasBass/DE-101/blob/master/Module2/2.3_SQL/2.3-2_Orders.sql)
* [People table](https://github.com/AtamasBass/DE-101/blob/master/Module2/2.3_SQL/2.3-2_People.sql)
* [Return table](https://github.com/AtamasBass/DE-101/blob/master/Module2/2.3_SQL/2.3-2_Returns.sql)
### 2.3.3 ![SQL script](https://github.com/AtamasBass/DE-101/blob/master/Module2/2.3_SQL/2.3-3_Questions_module1.sql) with ![questions from Module 1](https://github.com/Data-Learn/data-engineering/tree/master/DE-101%20Modules/Module01/DE%20-%20101%20Lab%201.1#%D0%B0%D0%BD%D0%B0%D0%BB%D0%B8%D1%82%D0%B8%D0%BA%D0%B0-%D0%B2-excel)
## 2.4 Data model
### 2.4.1 Create data model in SQLdbm
#### Conceptual schema
![Conceptual schema](https://raw.githubusercontent.com/AtamasBass/DE-101/master/Module2/2.4_Data_models/2.4-1_Conceptual_model.png)
#### Logical schema
![Logical schema](https://raw.githubusercontent.com/AtamasBass/DE-101/master/Module2/2.4_Data_models/2.4-1_Logical_model.png)
#### Physical schema
![Physics schema](https://raw.githubusercontent.com/AtamasBass/DE-101/master/Module2/2.4_Data_models/2.4-1_Physics_model.png)
### 2.4.2 Create new tables with [DDL from SqlDBM](https://github.com/AtamasBass/DE-101/blob/master/Module2/2.4_Data_models/2.4-2_Create(SqlDBM_PostgreSQL).sql)
### 2.4.3 Upload data to [new tables](https://github.com/AtamasBass/DE-101/blob/master/Module2/2.4_Data_models/2.4-3_Upload_data.sql)
## 2.5. Cloud database
### 2.5.1 Create AWS account
### 2.5.2 Create Postgres DB in AWS Lightsail and AWS RDS
### 2.5.3 Create a connection to Lightsail and RDS in DBeaver
### 2.5.4 Upload data 
* From Module 2.3 to staging [stg](https://github.com/AtamasBass/DE-101/blob/master/Module2/2.5_AWS/2.5-4_Stg_orders.sql)
* From staging to dimensional model
  * AWS Lightsail [dw](https://github.com/AtamasBass/DE-101/blob/master/Module2/2.5_AWS/2.5-4_DW_AWS_Lightsail.sql)
  * AWS RDS [dw_rds](https://github.com/AtamasBass/DE-101/blob/master/Module2/2.5_AWS/2.5-4_DW_AWS_RDS.sql) 
## 2.6 BI
### Dashboard in [Google Data Studio](https://datastudio.google.com/reporting/e3a1b305-2ca3-4070-9a43-2fe16615d686) with data from AWS Lightsail
![Data Studio](https://github.com/AtamasBass/DE-101/blob/master/Module2/2.6_BI/2.6_Superstore_Dashboard_PNG(AWS_Lightsail).png)
### Dashboard in Power BI with data from AWS RDS 
![Power BI](https://github.com/AtamasBass/DE-101/blob/master/Module2/2.6_BI/2.6_Superstore_Dashboard_PNG(AWS_RDS).png)
