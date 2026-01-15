CREATE DATABASE RealTimeSalesDB;
GO
USE RealTimeSalesDB;
GO

CREATE TABLE DimRegion (
    RegionID INT IDENTITY PRIMARY KEY,
    RegionName VARCHAR(50)
);

CREATE TABLE DimProduct (
    ProductID INT IDENTITY PRIMARY KEY,
    ProductName VARCHAR(100),
    Category VARCHAR(50)
);

CREATE TABLE DimDate (
    DateKey INT PRIMARY KEY,
    FullDate DATE,
    Year INT,
    Month INT,
    MonthName VARCHAR(20),
    Day INT
);

CREATE TABLE FactOrders (
    OrderID INT IDENTITY PRIMARY KEY,
    OrderDateTime DATETIME,
    DateKey INT,
    ProductID INT,
    RegionID INT,
    Quantity INT,
    SalesAmount DECIMAL(10,2),
    Cost DECIMAL(10,2),

    FOREIGN KEY (DateKey) REFERENCES DimDate(DateKey),
    FOREIGN KEY (ProductID) REFERENCES DimProduct(ProductID),
    FOREIGN KEY (RegionID) REFERENCES DimRegion(RegionID)
);



DECLARE @i INT = 1;
WHILE @i <= 500
BEGIN
    INSERT INTO DimRegion (RegionName)
    VALUES ('Region_' + CAST(@i AS VARCHAR));
    SET @i += 1;
END

DECLARE @i INT = 1;
WHILE @i <= 500
BEGIN
    INSERT INTO DimProduct (ProductName, Category)
    VALUES (
        'Product_' + CAST(@i AS VARCHAR),
        CASE 
            WHEN @i % 3 = 0 THEN 'Electronics'
            WHEN @i % 3 = 1 THEN 'Accessories'
            ELSE 'Appliances'
        END
    );
    SET @i += 1;
END

DECLARE @startDate DATE = DATEADD(DAY, -499, GETDATE());
DECLARE @i INT = 0;

WHILE @i < 500
BEGIN
    INSERT INTO DimDate
    VALUES (
        CONVERT(INT, FORMAT(DATEADD(DAY, @i, @startDate),'yyyyMMdd')),
        DATEADD(DAY, @i, @startDate),
        YEAR(DATEADD(DAY, @i, @startDate)),
        MONTH(DATEADD(DAY, @i, @startDate)),
        DATENAME(MONTH, DATEADD(DAY, @i, @startDate)),
        DAY(DATEADD(DAY, @i, @startDate))
    );
    SET @i += 1;
END

DECLARE @i INT = 1;

DECLARE @i INT;
SET @i = 1;

 
 DECLARE @i INT;
SET @i = 1;

WHILE @i <= 500
BEGIN
    DECLARE @RandomDateKey INT;
    DECLARE @ProductID INT;
    DECLARE @RegionID INT;
    DECLARE @Qty INT;
    DECLARE @Sales DECIMAL(10,2);
    DECLARE @Cost DECIMAL(10,2);

    SELECT TOP 1 @RandomDateKey = DateKey
    FROM DimDate
    ORDER BY NEWID();

    SELECT TOP 1 @ProductID = ProductID
    FROM DimProduct
    ORDER BY NEWID();

    SELECT TOP 1 @RegionID = RegionID
    FROM DimRegion
    ORDER BY NEWID();

    SET @Qty = FLOOR(RAND() * 5) + 1;
    SET @Sales = @Qty * (1000 + RAND() * 2000);
    SET @Cost = @Sales * 0.7;

    INSERT INTO FactOrders
    (
        OrderDateTime,
        DateKey,
        ProductID,
        RegionID,
        Quantity,
        SalesAmount,
        Cost
    )
    VALUES
    (
        GETDATE(),
        @RandomDateKey,
        @ProductID,
        @RegionID,
        @Qty,
        @Sales,
        @Cost
    );

    SET @i = @i + 1;
END;


SELECT 'DimRegion' AS TableName, COUNT(*) Rows FROM DimRegion
UNION ALL
SELECT 'DimProduct', COUNT(*) FROM DimProduct
UNION ALL
SELECT 'DimDate', COUNT(*) FROM DimDate
UNION ALL
SELECT 'FactOrders', COUNT(*) FROM FactOrders;

SELECT TOP 10
f.OrderID,
d.FullDate,
p.ProductName,
r.RegionName,
f.Quantity,
f.SalesAmount,
f.Cost
FROM FactOrders f
JOIN DimDate d ON f.DateKey = d.DateKey
JOIN DimProduct p ON f.ProductID = p.ProductID
JOIN DimRegion r ON f.RegionID = r.RegionID;

SELECT SUM(SalesAmount) AS TotalSales FROM FactOrders;

SELECT SUM(SalesAmount - Cost) AS Profit FROM FactOrders;

SELECT COUNT(*) AS TotalRows FROM FactOrders;


SELECT r.RegionName, SUM(f.SalesAmount) Sales
FROM FactOrders f
JOIN DimRegion r ON f.RegionID = r.RegionID
GROUP BY r.RegionName;


SELECT p.ProductName, SUM(f.SalesAmount) Sales
FROM FactOrders f
JOIN DimProduct p ON f.ProductID = p.ProductID
GROUP BY p.ProductName;



SELECT d.MonthName, SUM(f.SalesAmount) Sales
FROM FactOrders f
JOIN DimDate d ON f.DateKey = d.DateKey
GROUP BY d.MonthName;


CREATE OR ALTER PROCEDURE InsertLiveOrder
AS
BEGIN
    DECLARE @DateKey INT =
        (SELECT TOP 1 DateKey FROM DimDate ORDER BY NEWID());

    DECLARE @ProductID INT =
        (SELECT TOP 1 ProductID FROM DimProduct ORDER BY NEWID());

    DECLARE @RegionID INT =
        (SELECT TOP 1 RegionID FROM DimRegion ORDER BY NEWID());

    DECLARE @Qty INT = FLOOR(RAND() * 5) + 1;
    DECLARE @Sales DECIMAL(10,2) = @Qty * (1000 + RAND() * 2000);
    DECLARE @Cost DECIMAL(10,2) = @Sales * 0.7;

    INSERT INTO FactOrders
    (
        OrderDateTime,
        DateKey,
        ProductID,
        RegionID,
        Quantity,
        SalesAmount,
        Cost
    )
    VALUES
    (
        GETDATE(),
        @DateKey,
        @ProductID,
        @RegionID,
        @Qty,
        @Sales,
        @Cost
    );
END;


EXEC InsertLiveOrder;

SELECT TOP 5 *
FROM FactOrders
ORDER BY OrderID DESC;

SELECT * FROM DimDate WHERE DateKey = 20250101;
SELECT * FROM DimProduct WHERE ProductID = 10;
SELECT * FROM DimRegion WHERE RegionID = 5;

