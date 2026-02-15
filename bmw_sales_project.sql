use company;

SHOW VARIABLES LIKE 'secure_file_priv';
CREATE TABLE bmw_sales (
    color VARCHAR(20),
    fuel_type VARCHAR(20),
    transmission VARCHAR(20),
    engine_size_l DECIMAL(3,1),
    mileage_km INT,
    price_usd DECIMAL(12,2),
    sales_volume INT,
    sales_classification VARCHAR(10)
);
show tables;
DESCRIBE bmw_sales;

DROP TABLE bmw_sales;
CREATE TABLE bmw_sales (
    model VARCHAR(50),
    year INT,
    region VARCHAR(50),
    color VARCHAR(20),
    fuel_type VARCHAR(20),
    transmission VARCHAR(20),
    engine_size_l DECIMAL(3,1),
    mileage_km INT,
    price_usd DECIMAL(12,2),
    sales_volume INT,
    sales_classification VARCHAR(10)
);
LOAD DATA INFILE
'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/bmw_clean.csv'
INTO TABLE bmw_sales
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

SELECT COUNT(*) FROM bmw_sales;
select * from bmw_sales;


DESC bmw_sales;

#   TOTAL REVENUE
SELECT SUM(Price_USD * Sales_Volume) AS total_revenue
FROM bmw_sales;


# 1. TOTAL REVENUE BY REGION
SELECT Region,
       SUM(Price_USD * Sales_Volume) AS revenue
FROM bmw_sales
GROUP BY Region
ORDER BY revenue DESC;

# 2. BEST SELLING MODEL

SELECT Model,
       SUM(Sales_Volume) AS total_units
FROM bmw_sales
GROUP BY Model
ORDER BY total_units DESC;




# Step 3: Pricing Strategy Analysis
# ---------Price vs Sales Trend


SELECT Model,
       AVG(Price_USD) AS avg_price,
       AVG(Sales_Volume) AS avg_sales
FROM bmw_sales
GROUP BY Model
ORDER BY avg_price DESC;



# Step 4: Fuel Type Demand
# --------Sales by Fuel Type


SELECT Fuel_Type,
       SUM(Sales_Volume) AS total_sales,
       SUM(Price_USD * Sales_Volume) AS revenue
FROM bmw_sales
GROUP BY Fuel_Type
ORDER BY total_sales DESC;





# Step 5: Regional Preferences
----    Preferred Engine Size by Region

SELECT Region,
       AVG(Engine_Size_L) AS avg_engine
FROM bmw_sales
GROUP BY Region
ORDER BY avg_engine DESC;



#  Step 6: Top 2 Models per Region (Window Function)

SELECT *
FROM (SELECT Region, Model,
           SUM(Sales_Volume) AS total_sales,
           RANK() OVER (PARTITION BY Region
		   ORDER BY SUM(Sales_Volume) DESC) AS rnk FROM bmw_sales
		   GROUP BY Region, Model) t WHERE rnk <= 2;

# Step 7: Inventory Risk Detection
---------  High Mileage but High Sales

SELECT Model,
       AVG(Mileage_KM) AS avg_mileage,
       SUM(Sales_Volume) AS total_sales
FROM bmw_sales
GROUP BY Model
HAVING AVG(Mileage_KM) > 100000
ORDER BY total_sales DESC;



# Step 8: Classification Validation
------- Check Classification Logic

SELECT Sales_Classification,
       AVG(Sales_Volume) AS avg_sales
FROM bmw_sales
GROUP BY Sales_Classification;




# Step 9: Yearly Growth

SELECT Year,
       SUM(Sales_Volume) AS units,
       SUM(Price_USD * Sales_Volume) AS revenue
FROM bmw_sales
GROUP BY Year
ORDER BY Year;



# Step 10: Advanced Business Questions
 -------   Which Region Depends Too Much on One Model?

SELECT Region, Model,
       SUM(Sales_Volume) AS total_sales
FROM bmw_sales
GROUP BY Region, Model
ORDER BY Region, total_sales DESC;



# 11:Profit Simulation (Business Thinking)
---- Assume:Production cost = 60% of price

SELECT 
    model,
    SUM(price_usd * sales_volume) AS revenue,
    SUM(price_usd * 0.60 * sales_volume) AS production_cost,
    SUM(price_usd * sales_volume) 
      - SUM(price_usd * 0.60 * sales_volume) AS estimated_profit
FROM bmw_sales
GROUP BY model
ORDER BY estimated_profit DESC;
