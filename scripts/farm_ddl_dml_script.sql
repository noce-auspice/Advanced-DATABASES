-- CASE STUDY: Agricultural Farm Production and Supply Management System

-- 1. CREATE DATABASE AND USE IT
CREATE DATABASE FarmManagementDB;
USE FarmManagementDB;

-- TASK 1: Build all six tables with FK, CHECK, and NOT NULL constraints.
-- TASK 2: Apply CASCADE DELETE between Crop → Harvest and Harvest → Sale

-- =============================================================
-- 1. DDL for Field 
CREATE TABLE Field (
    FieldID INT PRIMARY KEY AUTO_INCREMENT,
    FieldName VARCHAR(50) NOT NULL,
    SizeHectares DECIMAL(6,2) CHECK (SizeHectares > 0),
    Location VARCHAR(100) NOT NULL,
    SoilType VARCHAR(50) NOT NULL
);

-- 2. DDL Crop 
CREATE TABLE Crop (
    CropID INT PRIMARY KEY AUTO_INCREMENT,
    FieldID INT NOT NULL,
    CropName VARCHAR(50) NOT NULL,
    PlantingDate DATE NOT NULL,
    HarvestDate DATE,
    Status VARCHAR(20) CHECK (Status IN ('Planted', 'Growing', 'Harvested', 'Sold')),
    FOREIGN KEY (FieldID) REFERENCES Field(FieldID)
        ON DELETE CASCADE
);

-- 3. DDL Fertilizer
CREATE TABLE Fertilizer (
    FertilizerID INT PRIMARY KEY AUTO_INCREMENT,
    CropID INT NOT NULL,
    Name VARCHAR(50) NOT NULL,
    QuantityUsed DECIMAL(8,2) CHECK (QuantityUsed >= 0),
    Cost DECIMAL(10,2) CHECK (Cost >= 0),
    DateApplied DATE NOT NULL,
    FOREIGN KEY (CropID) REFERENCES Crop(CropID)
);

-- 4. DDL for Worker
CREATE TABLE Worker (
    WorkerID INT PRIMARY KEY AUTO_INCREMENT,
    FullName VARCHAR(100) NOT NULL,
    Role VARCHAR(50) NOT NULL,
    Contact VARCHAR(50),
    DailyWage DECIMAL(8,2) CHECK (DailyWage >= 0)
);

-- 5. DDL for Harvest
CREATE TABLE Harvest (
    HarvestID INT PRIMARY KEY AUTO_INCREMENT,
    CropID INT NOT NULL,
    WorkerID INT NOT NULL,
    QuantityKG DECIMAL(10,2) CHECK (QuantityKG >= 0),
    DateCollected DATE NOT NULL,
    Grade VARCHAR(10),
    Buyer VARCHAR(50),
    FOREIGN KEY (CropID) REFERENCES Crop(CropID)
        ON DELETE CASCADE,
    FOREIGN KEY (WorkerID) REFERENCES Worker(WorkerID)
);

-- 6. DDL for Sale
CREATE TABLE Sale (
    SaleID INT PRIMARY KEY AUTO_INCREMENT,
    HarvestID INT NOT NULL,
    Buyer VARCHAR(50) NOT NULL,
    QuantitySold DECIMAL(10,2) CHECK (QuantitySold >= 0),
    PricePerKG DECIMAL(10,2) CHECK (PricePerKG >= 0),
    SaleDate DATE NOT NULL,
    FOREIGN KEY (HarvestID) REFERENCES Harvest(HarvestID)
        ON DELETE CASCADE
);


-- TASK 3: Insert 3 Field, 5 Crops, and 5 Workers and other tables.

-- Insert Fields
INSERT INTO Field (FieldName, SizeHectares, Location, SoilType)
VALUES
('North Field', 10.5, 'Kigali', 'Clay'),
('East Field', 8.2, 'Rwamagana', 'Loam'),
('South Field', 12.0, 'Huye', 'Sandy');

-- Insert Crops
INSERT INTO Crop (FieldID, CropName, PlantingDate, HarvestDate, Status)
VALUES
(1, 'Maize', '2025-01-15', '2025-05-20', 'Harvested'),
(2, 'Beans', '2025-02-10', '2025-06-15', 'Harvested'),
(3, 'Rice', '2025-03-01', '2025-07-20', 'Growing'),
(1, 'Cassava', '2025-01-01', '2025-09-30', 'Planted'),
(2, 'Soybean', '2025-03-10', '2025-08-25', 'Planted');

-- Insert Fertilizers
INSERT INTO Fertilizer (CropID, Name, QuantityUsed, Cost, DateApplied)
VALUES
(1, 'NPK', 50, 25000, '2025-02-01'),
(2, 'Urea', 40, 20000, '2025-03-15'),
(3, 'DAP', 60, 30000, '2025-04-10'),
(4, 'Compost', 70, 15000, '2025-03-05'),
(5, 'Organic Mix', 30, 12000, '2025-04-01');

-- Insert Workers
INSERT INTO Worker (FullName, Role, Contact, DailyWage)
VALUES
('Alice Uwimana', 'Harvester', '0788000001', 3000),
('John Nkurunziza', 'Planter', '0788000002', 3500),
('Claudine Uwera', 'Supervisor', '0788000003', 4000),
('Eric Ndayisenga', 'Weeder', '0788000004', 2500),
('Diane Mukamana', 'Sprayer', '0788000005', 2800);

-- Insert Harvests
INSERT INTO Harvest (CropID, WorkerID, QuantityKG, DateCollected, Grade, Buyer)
VALUES
(1, 1, 5000, '2025-05-21', 'A', 'AgroCo Ltd'),
(2, 2, 3500, '2025-06-16', 'B', 'FarmLink'),
(3, 3, 0, '2025-07-20', 'A', NULL),
(4, 4, 4200, '2025-09-30', 'A', 'GreenMart'),
(5, 5, 3000, '2025-08-26', 'B', 'BioFarm');

-- Insert Sales
INSERT INTO Sale (HarvestID, Buyer, QuantitySold, PricePerKG, SaleDate)
VALUES
(1, 'AgroCo Ltd', 5000, 500, '2025-05-25'),
(2, 'FarmLink', 3500, 400, '2025-06-18'),
(4, 'GreenMart', 4200, 450, '2025-10-01'),
(5, 'BioFarm', 3000, 380, '2025-08-30');


-- TASK 4. RETRIEVE HARVEST YIELD PER FIELD

SELECT f.FieldName, SUM(h.QuantityKG) AS TotalYieldKG
FROM Field f
JOIN Crop c ON f.FieldID = c.FieldID
JOIN Harvest h ON c.CropID = h.CropID
GROUP BY f.FieldName;

-- TASK 5. UPDATE CROP STATUS AFTER SALE COMPLETION
-- =============================================================
UPDATE Crop
SET Status = 'Sold'
WHERE CropID IN (
    SELECT DISTINCT c.CropID
    FROM Crop c
    JOIN Harvest h ON c.CropID = h.CropID
    JOIN Sale s ON h.HarvestID = s.HarvestID
);

-- 
-- TASK 6. IDENTIFY THE MOST PROFITABLE CROP OF THE SEASON
SELECT 
    c.CropName,
    SUM(s.QuantitySold * s.PricePerKG) - SUM(fz.Cost) AS Profit
FROM Crop c
JOIN Harvest h ON c.CropID = h.CropID
JOIN Sale s ON h.HarvestID = s.HarvestID
JOIN Fertilizer fz ON c.CropID = fz.CropID
GROUP BY c.CropName
ORDER BY Profit DESC
LIMIT 1;


-- TASK 7. CREATE A VIEW SUMMARIZING TOTAL FERTILIZER COST PER CROP
-- =============================================================
CREATE OR REPLACE VIEW FertilizerCostPerCrop AS
SELECT 
    c.CropName,
    SUM(fz.Cost) AS TotalFertilizerCost
FROM Crop c
JOIN Fertilizer fz ON c.CropID = fz.CropID
GROUP BY c.CropName;

-- To view the data:
SELECT * FROM FertilizerCostPerCrop;


-- TASK 8. IMPLEMENT A TRIGGER PREVENTING FERTILIZER APPLICATION BEFORE PLANTING DATE
DELIMITER $$

CREATE TRIGGER PreventEarlyFertilizerApplication
BEFORE INSERT ON Fertilizer
FOR EACH ROW
BEGIN
    DECLARE plantDate DATE;
    SELECT PlantingDate INTO plantDate FROM Crop WHERE CropID = NEW.CropID;
    IF NEW.DateApplied < plantDate THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Cannot apply fertilizer before crop planting date.';
    END IF;
END$$

DELIMITER ;
