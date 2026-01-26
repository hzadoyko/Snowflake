-- Set the Role
USE ROLE accountadmin;

-- Set the Warehouse
USE WAREHOUSE COMPUTE_WH;

/********************************************
    Database and Schema Creation
********************************************/

-- Create the Tasty Bytes Database
CREATE OR REPLACE DATABASE Tasty_Bytes;

-- Create the Raw POS (Point-of-Sale) Schema
CREATE OR REPLACE SCHEMA Tasty_Bytes.Raw_Pos;

-- Create Raw_Customer schema
CREATE OR REPLACE SCHEMA Tasty_Bytes.Raw_Customer;

-- Create Harmonized schema
CREATE OR REPLACE SCHEMA Tasty_Bytes.Harmonized;

-- Create Analytics schema
CREATE OR REPLACE SCHEMA Tasty_Bytes.Analytics;

/********************************************
    Table Creation
********************************************/
-- Raw_Pos Country
CREATE OR REPLACE TABLE Tasty_Bytes.Raw_Pos.Country
(
    Country_Id NUMBER(18,0),
    Country VARCHAR(16777216),
    ISO_Currency VARCHAR(3),
    ISO_Country VARCHAR(2),
    City_Id NUMBER(19,0),
    City VARCHAR(16777216),
    City_Population VARCHAR(16777216)
);

-- Raw_Pos Franchise
CREATE OR REPLACE TABLE Tasty_Bytes.Raw_Pos.Franchise 
(
    Franchise_Id NUMBER(38,0),
    First_Name VARCHAR(16777216),
    Last_Name VARCHAR(16777216),
    City VARCHAR(16777216),
    Country VARCHAR(16777216),
    E_Mail VARCHAR(16777216),
    Phone_Number VARCHAR(16777216) 
);

-- Raw_Pos Location
CREATE OR REPLACE TABLE Tasty_Bytes.Raw_Pos.Location
(
    Location_Id NUMBER(19,0),
    Placekey VARCHAR(16777216),
    Location VARCHAR(16777216),
    City VARCHAR(16777216),
    Region VARCHAR(16777216),
    ISO_Country_Code VARCHAR(16777216),
    Country VARCHAR(16777216)
);

-- Raw_Pos Menu
CREATE OR REPLACE TABLE Tasty_Bytes.Raw_Pos.Menu
(
    Menu_Id NUMBER(19,0),
    Menu_Type_Id NUMBER(38,0),
    Menu_Type VARCHAR(16777216),
    Truck_Brand_Name VARCHAR(16777216),
    Menu_Item_Id NUMBER(38,0),
    Menu_Item_Name VARCHAR(16777216),
    Item_Category VARCHAR(16777216),
    Item_SubCategory VARCHAR(16777216),
    Cost_Of_Goods_USD NUMBER(38,4),
    Sale_Price_USD NUMBER(38,4),
    Menu_Item_Health_Metrics_Obj VARIANT
);

-- Raw_Pos Truck
CREATE OR REPLACE TABLE Tasty_Bytes.Raw_Pos.Truck
(
    Truck_Id NUMBER(38,0),
    Menu_Type_Id NUMBER(38,0),
    Primary_City VARCHAR(16777216),
    Region VARCHAR(16777216),
    ISO_Region VARCHAR(16777216),
    Country VARCHAR(16777216),
    ISO_Country_Code VARCHAR(16777216),
    Franchise_Flag NUMBER(38,0),
    Year NUMBER(38,0),
    Make VARCHAR(16777216),
    Model VARCHAR(16777216),
    EV_Flag NUMBER(38,0),
    Franchise_Id NUMBER(38,0),
    Truck_Opening_Date DATE
);

-- Raw_Pos Order_Header
CREATE OR REPLACE TABLE Tasty_Bytes.Raw_Pos.Order_Header
(
    Order_Id NUMBER(38,0),
    Truck_Id NUMBER(38,0),
    Location_Id FLOAT,
    Customer_Id NUMBER(38,0),
    Discount_Id VARCHAR(16777216),
    Shift_Id NUMBER(38,0),
    Shift_Start_Time TIME(9),
    Shift_End_Time TIME(9),
    Order_Channel VARCHAR(16777216),
    Order_TS TIMESTAMP_NTZ(9),
    Served_TS VARCHAR(16777216),
    Order_Currency VARCHAR(3),
    Order_Amount NUMBER(38,4),
    Order_Tax_Amount VARCHAR(16777216),
    Order_Discount_Amount VARCHAR(16777216),
    Order_Total NUMBER(38,4)
);

-- Raw_Pos Order_Detail
CREATE OR REPLACE TABLE Tasty_Bytes.Raw_Pos.Order_Detail 
(
    Order_Detail_Id NUMBER(38,0),
    Order_Id NUMBER(38,0),
    Menu_Item_Id NUMBER(38,0),
    Discount_Id VARCHAR(16777216),
    Line_Number NUMBER(38,0),
    Quantity NUMBER(5,0),
    Unit_Price NUMBER(38,4),
    Price NUMBER(38,4),
    Order_Item_Discount_Amount VARCHAR(16777216)
);

-- Raw_Customer Customer_Loyalty
CREATE OR REPLACE TABLE Tasty_Bytes.Raw_Customer.Customer_Loyalty
(
    Customer_Id NUMBER(38,0),
    First_Name VARCHAR(16777216),
    Last_Name VARCHAR(16777216),
    City VARCHAR(16777216),
    Country VARCHAR(16777216),
    Postal_Code VARCHAR(16777216),
    Preferred_Language VARCHAR(16777216),
    Gender VARCHAR(16777216),
    Favourite_Brand VARCHAR(16777216),
    Marital_Status VARCHAR(16777216),
    Children_Count VARCHAR(16777216),
    Sign_Up_Date DATE,
    Birthday_Date DATE,
    E_Mail VARCHAR(16777216),
    Phone_Number VARCHAR(16777216)
);

/********************************************
    View Creation
********************************************/

-- Harmonized Orders_V
CREATE OR REPLACE VIEW Tasty_Bytes.Harmonized.Orders_V
    AS
SELECT 
    oh.Order_Id,
    oh.Truck_Id,
    oh.Order_TS,
    od.Order_Detail_Id,
    od.Line_Number,
    m.Truck_Brand_Name,
    m.Menu_Type,
    t.Primary_City,
    t.Region,
    t.Country,
    t.Franchise_Flag,
    t.Franchise_Id,
    f.First_Name AS Franchisee_First_Name,
    f.Last_Name AS Franchisee_Last_Name,
    l.Location_Id,
    cl.Customer_Id,
    cl.First_Name,
    cl.Last_Name,
    cl.E_Mail,
    cl.Phone_Number,
    cl.Children_Count,
    cl.Gender,
    cl.Marital_Status,
    od.Menu_Item_Id,
    m.Menu_Item_Name,
    od.Quantity,
    od.Unit_Price,
    od.Price,
    oh.Order_Amount,
    oh.Order_Tax_Amount,
    oh.Order_Discount_Amount,
    oh.Order_Total
FROM Tasty_Bytes.Raw_Pos.Order_Detail od
INNER JOIN Tasty_Bytes.Raw_Pos.Order_Header oh ON od.Order_Id = oh.Order_Id
INNER JOIN Tasty_Bytes.Raw_Pos.Truck t ON oh.Truck_Id = t.Truck_Id
INNER JOIN Tasty_Bytes.Raw_Pos.Menu m ON od.Menu_Item_Id = m.Menu_Item_Id
INNER JOIN Tasty_Bytes.Raw_Pos.Franchise f ON t.Franchise_Id = f.Franchise_Id
INNER JOIN Tasty_Bytes.Raw_Pos.Location l ON oh.Location_Id = l.Location_Id
LEFT JOIN Tasty_Bytes.Raw_Customer.Customer_Loyalty cl ON oh.Customer_Id = cl.Customer_Id;

-- Harmonized Loyalty_Metrics_V
CREATE OR REPLACE VIEW Tasty_Bytes.Harmonized.Customer_Loyalty_Metrics_V
    AS
SELECT 
    cl.Customer_Id,
    cl.City,
    cl.Country,
    cl.First_Name,
    cl.Last_Name,
    cl.Phone_Number,
    cl.E_Mail,
    SUM(oh.Order_Total) AS Total_Sales,
    ARRAY_AGG(DISTINCT oh.Location_Id) AS Visited_Location_Ids_Array
FROM Tasty_Bytes.Raw_Customer.Customer_Loyalty cl
INNER JOIN Tasty_Bytes.Raw_Pos.Order_Header oh ON cl.Customer_Id = oh.Customer_Id
GROUP BY 
    cl.Customer_Id,
    cl.City,
    cl.Country,
    cl.First_Name,
    cl.Last_Name,
    cl.Phone_Number,
    cl.E_Mail;

-- Analytics Orders_V
CREATE OR REPLACE VIEW Tasty_Bytes.Analytics.Orders_V
COMMENT = 'Tasty Bytes Order Detail View'
    AS
SELECT 
    DATE(o.Order_TS) AS Date,
    o.Order_Id,
    o.Truck_Id,
    o.Order_TS,
    o.Order_Detail_Id,
    o.Line_Number,
    o.Truck_Brand_Name,
    o.Menu_Type,
    o.Primary_City,
    o.Region,
    o.Country,
    o.Franchise_Flag,
    o.Franchise_Id,
    o.Franchisee_First_Name,
    o.Franchisee_Last_Name,
    o.Location_Id,
    o.Customer_Id,
    o.First_Name,
    o.Last_Name,
    o.E_Mail,
    o.Phone_Number,
    o.Children_Count,
    o.Gender,
    o.Marital_Status,
    o.Menu_Item_Id,
    o.Menu_Item_Name,
    o.Quantity,
    o.Unit_Price,
    o.Price,
    o.Order_Amount,
    o.Order_Tax_Amount,
    o.Order_Discount_Amount,
    o.Order_Total
FROM Tasty_Bytes.Harmonized.Orders_V o;

-- Analytics Customer_Loyalty_Metrics_V
CREATE OR REPLACE VIEW Tasty_Bytes.Analytics.Customer_Loyalty_Metrics_V
COMMENT = 'Tasty Bytes Customer Loyalty Member Metrics View'
    AS
SELECT 
    Customer_Id,
    City,
    Country,
    First_Name,
    Last_Name,
    Phone_Number,
    E_Mail,
    Total_Sales,
    Visited_Location_Ids_Array
FROM Tasty_Bytes.Harmonized.Customer_Loyalty_Metrics_V;
