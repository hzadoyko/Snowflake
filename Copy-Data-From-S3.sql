-- Set the Role
USE ROLE accountadmin;

-- Set the Warehouse
USE WAREHOUSE COMPUTE_WH;

-- create warehouse for ingestion
CREATE OR REPLACE WAREHOUSE demo_build_wh
    WAREHOUSE_SIZE = 'xlarge'
    WAREHOUSE_TYPE = 'standard'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE;

/*********************************************
  File Format and Stage Creation
**********************************************/

CREATE OR REPLACE FILE FORMAT Tasty_Bytes.Public.csv_ff 
type = 'csv';

CREATE OR REPLACE STAGE Tasty_Bytes.Public.S3Load
url = 's3://sfquickstarts/tasty-bytes-builder-education/'
file_format = Tasty_Bytes.Public.csv_ff;

/**********************************************************
  Raw Table Load Using Larger Compute Warehouse
***********************************************************/

USE WAREHOUSE demo_build_wh;

-- Country Table Load
COPY INTO Tasty_Bytes.Raw_Pos.Country
FROM @Tasty_Bytes.Public.S3Load/Raw_Pos/country/;

-- Franchise Table Load
COPY INTO Tasty_Bytes.Raw_Pos.Franchise
FROM @Tasty_Bytes.Public.S3Load/Raw_Pos/franchise/;

-- Location Table Load
COPY INTO Tasty_Bytes.Raw_Pos.Location
FROM @Tasty_Bytes.Public.S3Load/Raw_Pos/location/;

-- Menu Table Load
COPY INTO Tasty_Bytes.Raw_Pos.Menu
FROM @Tasty_Bytes.Public.S3Load/Raw_Pos/menu/;

-- Truck Table Load
COPY INTO Tasty_Bytes.Raw_Pos.Truck
FROM @Tasty_Bytes.Public.S3Load/Raw_Pos/truck/;

-- Customer_Loyalty Table Load
COPY INTO Tasty_Bytes.raw_customer.Customer_Loyalty
FROM @Tasty_Bytes.Public.S3Load/raw_customer/customer_oyalty/;

-- Order_Header Table Load
COPY INTO Tasty_Bytes.Raw_Pos.Order_Header
FROM @Tasty_Bytes.Public.S3Load/Raw_Pos/subset_order_header/;

-- Order_Detail Table Load
COPY INTO Tasty_Bytes.Raw_Pos.Order_Detail
FROM @Tasty_Bytes.Public.S3Load/Raw_Pos/subset_order_detail/;

DROP WAREHOUSE demo_build_wh;
