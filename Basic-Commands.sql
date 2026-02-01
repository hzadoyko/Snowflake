/************************
    Warehouses
*************************/
-- Create a multi-cluster warehouse (max clusters = 3)
CREATE WAREHOUSE DUKE_UNIVERSITY_WAREHOUSE MAX_CLUSTER_COUNT = 3;

-- Set warehouse size to medium
ALTER WAREHOUSE DUKE_UNIVERSITY_WAREHOUSE SET warehouse_size = MEDIUM;

-- Set the auto_suspend and auto_resume parameters
ALTER WAREHOUSE DUKE_UNIVERSITY_WAREHOUSE SET AUTO_SUSPEND = 180 AUTO_RESUME = FALSE;

-- Drop warehouse
DROP WAREHOUSE DUKE_UNIVERSITY_WAREHOUSE;

-- Show all warehouses
SHOW WAREHOUSES;

/************************
    Databases
*************************/
-- Create database
CREATE DATABASE test_database;

-- Drop database
DROP DATABASE test_database;

-- Undrop database
UNDROP DATABASE test_database;

-- Use database
USE test_database;

-- See metadata about your database
DESCRIBE DATABASE TEST_DATABASE;

-- Show databases
SHOW DATABASES;

/************************
    Schemas
*************************/
-- Create schema
CREATE SCHEMA test_schema;

-- Drop schema
DROP SCHEMA test_schema;

-- Undrop schema
UNDROP SCHEMA test_schema;

-- Show schemas
SHOW SCHEMAS;

/************************
    Meta Data
*************************/
-- See table metadata
SELECT * FROM TASTY_BYTES.INFORMATION_SCHEMA.TABLES;

/************************
    Views
*************************/
-- Show views
SHOW VIEWS;

-- Drop a view
DROP VIEW tasty_bytes.harmonized.brand_names;

-- See metadata about a view
DESCRIBE VIEW tasty_bytes.harmonized.orders_v;

-- Create a materialized view
CREATE MATERIALIZED VIEW tasty_bytes.harmonized.brand_names_materialized 
    AS
SELECT DISTINCT truck_brand_name
FROM tasty_bytes.raw_pos.menu;

-- Show Materlized views
SHOW MATERIALIZED VIEWS;

-- See metadata about the materialized view we just made
DESCRIBE MATERIALIZED VIEW tasty_bytes.harmonized.brand_names_materialized;

-- Drop the materialized view
DROP MATERIALIZED VIEW tasty_bytes.harmonized.brand_names_materialized;

/************************
    Variables
*************************/
-- Assign variables
SET saved_query_id = LAST_QUERY_ID();
SET saved_timestamp = CURRENT_TIMESTAMP;

-- Show variables
SHOW VARIABLES;

-- Syntax for calling variables
SELECT $saved_query_id;
SELECT $saved_timestamp;

/************************
    Resource Monitors
*************************/
-- Create resource monitor
CREATE OR REPLACE RESOURCE MONITOR tasty_test_rm
WITH CREDIT_QUOTA = 15
FREQUENCY = DAILY
START_TIMESTAMP = IMMEDIATELY
TRIGGERS
    ON 90 PERCENT DO NOTIFY
    ON 100 PERCENT DO SUSPEND
    ON 110 PERCENT DO SUSPEND_IMMEDIATE;

-- Add resource monitor to warehouse
ALTER WAREHOUSE tasty_bytes
SET RESOURCE_MONITOR = tasty_test_rm;

-- Show resource monitors
SHOW RESOURCE MONITORS;

-- Change settings of resource monitor
ALTER RESOURCE MONITOR tasty_test_rm
SET CREDIT_QUOTA = 20;

/************************
    Functions
*************************/
-- Create a function
CREATE FUNCTION max_menu_price()
    RETURNS NUMBER(5,2)
    AS
    $$
        SELECT MAX(Sale_Price_USD) FROM Tasty_Bytes.Raw_Pos.Menu
    $$;

-- Create a function with an argument
CREATE FUNCTION max_menu_price_converted(USD_to_new NUBER)
    RETURNS NUBER(5,2)
    AS
    $$
        SELECT USD_TO_NEW * MAX(Sale_Price_USD) FROM Tasty_Bytes.Raw_Pos.Menu
    $$;

-- Create a Python function
CREATE FUNCTION winsorize (val NUMERIC, up_bound NUMERIC, low_bound NUMERIC)
RETURNS NUMERIC
LANGUAGE python
runtime_version = '3.14.2'
handler = 'winsorize_py'
AS
$$
def winsorize_py(val, up_bound, low_bound):
    if val > up_bound:
        return up_bound
    elif val < low_bound:
        return low_bound
    else:
        return val
$$;

-- Create a user-defined table function
CREATE FUNCTION menu_prices_above(price_floor NUMBER)
  RETURNS TABLE (item VARCHAR, price NUMBER)
  AS
  $$
    SELECT MENU_ITEM_NAME, SALE_PRICE_USD 
    FROM TASTY_BYTES.RAW_POS.MENU
    WHERE SALE_PRICE_USD > price_floor
    ORDER BY 2 DESC
  $$
  ;

-- Show functions
SHOW FUNCTIONS;

/************************
    Stored Procedures
*************************/
-- Show Procedures
SHOW PROCEDURES;

-- Create stored procedure
CREATE OR REPLACE PROCEDURE decrease_mango_sticky_rice_price()
RETURNS BOOLEAN
LANGUAGE SQL
AS
$$
BEGIN
    UPDATE tasty_bytes_clone.raw_pos.menu
    SET sale_price_usd = menu.sale_price_usd - 1
    WHERE menu_item_name = 'Mango Sticky Rice';
END
$$;

-- Describe procedure
DESCRIBE PROCEDURE decrease_mango_sticky_rice_price();