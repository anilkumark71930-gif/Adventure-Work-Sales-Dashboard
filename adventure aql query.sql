use adventureworks_project;

-- Append / Union Fact Tables
SELECT * FROM factinternetsales
UNION ALL
SELECT * FROM fact_internet_sales_new;


-- Merge Product, Category & SubCategory
SELECT 
    p.ProductKey,
    p.EnglishProductName AS ProductName,
    ps.EnglishProductSubcategoryName AS SubCategory,
    pc.EnglishProductCategoryName AS Category
FROM dimproduct p
LEFT JOIN dimproductsubcategory ps
    ON p.ProductSubcategoryKey = ps.ProductSubcategoryKey
LEFT JOIN dimproductcategory pc
    ON ps.ProductCategoryKey = pc.ProductCategoryKey;
    
    
-- Create Relationships (Join Fact with Dimensions)
SELECT *
FROM factinternetsales f
LEFT JOIN dimcustomer c 
    ON f.CustomerKey = c.CustomerKey
LEFT JOIN dimproduct p 
    ON f.ProductKey = p.ProductKey
LEFT JOIN dimdate d 
    ON f.OrderDateKey = d.DateKey;
    

-- Lookup Product Name in Sales
SELECT 
    f.SalesOrderNumber,
    p.EnglishProductName AS ProductName
FROM factinternetsales f
LEFT JOIN dimproduct p
    ON f.ProductKey = p.ProductKey;
    
    
-- Lookup Customer Full Name & Unit Price
SELECT 
    f.SalesOrderNumber,
    CONCAT(c.FirstName, ' ', c.LastName) AS CustomerFullName,
    p.ListPrice AS UnitPrice
FROM factinternetsales f
LEFT JOIN dimcustomer c
    ON f.CustomerKey = c.CustomerKey
LEFT JOIN dimproduct p
    ON f.ProductKey = p.ProductKey;
    
    
-- Date Calculations (From OrderDateKey)
SELECT 
    ProductKey,    
    STR_TO_DATE(CAST(OrderDateKey AS CHAR), '%Y%m%d') AS OrderDate,
    STR_TO_DATE(CAST(DueDateKey AS CHAR), '%Y%m%d') AS DueDate,
    STR_TO_DATE(CAST(ShipDateKey AS CHAR), '%Y%m%d') AS ShipDate    
FROM factinternetsales;

-- Year
SELECT 
    YEAR(STR_TO_DATE(CAST(DateKey AS CHAR), '%Y%m%d')) AS Year
FROM dimdate;

-- Month
SELECT 
    MONTH(STR_TO_DATE(CAST(DateKey AS CHAR), '%Y%m%d')) AS Month
FROM dimdate;

-- Month_Name
SELECT 
    MONTHNAME(STR_TO_DATE(CAST(DateKey AS CHAR), '%Y%m%d')) AS Monthname
FROM dimdate;

-- Quarter
SELECT 
    QUARTER(STR_TO_DATE(CAST(DateKey AS CHAR), '%Y%m%d')) AS Quarter
FROM dimdate;

-- Year-Month
SELECT 
    DATE_FORMAT(
        STR_TO_DATE(CAST(DateKey AS CHAR), '%Y%m%d'),
        '%Y-%b'
    ) AS YearMonth
FROM dimdate;

-- Weekday_number
SELECT 
    Week(STR_TO_DATE(CAST(DateKey AS CHAR), '%Y%m%d')) AS Weekday_number
FROM dimdate;

-- Weekday_name
SELECT 
    DATE_FORMAT(
        STR_TO_DATE(CAST(DateKey AS CHAR), '%Y%m%d'),
        '%W'
    ) AS Weekday_Name
FROM dimdate;

-- Financial Month (** Financial Year starts from April and ends at March - April : 1, May : 2 ….. March : 12)
SELECT 
    CASE 
        WHEN MONTH(STR_TO_DATE(CAST(DateKey AS CHAR), '%Y%m%d')) >= 4 
        THEN MONTH(STR_TO_DATE(CAST(DateKey AS CHAR), '%Y%m%d')) - 3
        ELSE MONTH(STR_TO_DATE(CAST(DateKey AS CHAR), '%Y%m%d')) + 9
    END AS Financial_Month
FROM dimdate;

-- Financial_year
SELECT 
    CASE 
        WHEN MONTH(STR_TO_DATE(CAST(DateKey AS CHAR), '%Y%m%d')) >= 4 
        THEN YEAR(STR_TO_DATE(CAST(DateKey AS CHAR), '%Y%m%d'))
        ELSE YEAR(STR_TO_DATE(CAST(DateKey AS CHAR), '%Y%m%d')) - 10
    END AS Financial_Year
FROM dimdate;

-- Financial_Quarter
SELECT 
    CASE 
        WHEN MONTH(STR_TO_DATE(CAST(DateKey AS CHAR), '%Y%m%d')) BETWEEN 4 AND 6 THEN 'Q1'
        WHEN MONTH(STR_TO_DATE(CAST(DateKey AS CHAR), '%Y%m%d')) BETWEEN 7 AND 9 THEN 'Q2'
        WHEN MONTH(STR_TO_DATE(CAST(DateKey AS CHAR), '%Y%m%d')) BETWEEN 10 AND 12 THEN 'Q3'
        ELSE 'Q4'
    END AS Financial_Quarter
FROM dimdate;


-- Sales Amount Calculation
SELECT 
    SalesOrderNumber,
    (UnitPrice * OrderQuantity) 
    - (UnitPrice * OrderQuantity * UnitPriceDiscountPct) 
    AS SalesAmount
FROM factinternetsales;

-- Production Cost

SELECT 
    f.SalesOrderNumber,
    (p.StandardCost * f.OrderQuantity) AS ProductionCost
FROM factinternetsales f
LEFT JOIN dimproduct p
    ON f.ProductKey = p.ProductKey;
    
    -- Profit
    SELECT 
    f.SalesOrderNumber,
    ((f.UnitPrice * f.OrderQuantity) 
    - (f.UnitPrice * f.OrderQuantity * f.UnitPriceDiscountPct))
    - (p.StandardCost * f.OrderQuantity) AS Profit
FROM factinternetsales f
LEFT JOIN dimproduct p
    ON f.ProductKey = p.ProductKey;
    
    -- Pivot for Month & Sales (Year Filter)
    SELECT 
    d.CalendarYear,
    
    SUM(
        (f.UnitPrice * f.OrderQuantity)
        - (f.UnitPrice * f.OrderQuantity * f.UnitPriceDiscountPct)
    ) AS Yearly_Sales

FROM factinternetsales f
JOIN dimdate d
    ON f.OrderDateKey = d.DateKey

GROUP BY d.CalendarYear
ORDER BY d.CalendarYear;

-- KPI by Product / Customer / Region

SELECT 
    p.EnglishProductName,
    
    SUM(
        (f.UnitPrice * f.OrderQuantity)
        - (f.UnitPrice * f.OrderQuantity * f.UnitPriceDiscountPct)
    ) AS Total_Sales

FROM factinternetsales f
JOIN dimproduct p
    ON f.ProductKey = p.ProductKey

GROUP BY p.EnglishProductName
ORDER BY Total_Sales DESC;