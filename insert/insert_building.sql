USE [lms_system];
GO

-- ============================================
-- Script insert Building: Insert all building names
-- Building_Name is now PRIMARY KEY (no Building_ID needed)
-- ============================================

-- ============================================
-- Step 1: Delete data from referencing tables first
-- ============================================

-- Delete from Room_Equipment (references Room)
DELETE FROM [Room_Equipment];
GO

-- Delete from Takes_Place (references Room)
DELETE FROM [Takes_Place];
GO

-- Delete from Room (references Building)
DELETE FROM [Room];
GO

-- ============================================
-- Step 2: Delete existing buildings
-- ============================================

DELETE FROM [Building];
GO

-- ============================================
-- Step 3: Insert all buildings
-- ============================================

INSERT INTO [Building] (Building_Name) VALUES
-- Prefix A
('A1'),
('A2'),
('A3'),
('A4'),
('A5'),

-- Prefix B
('B1A'),
('B1B'),
('B2'),
('B3'),
('B4'),
('B5'),
('B6'),
('B8'),
('B9'),
('B10'),
('B11'),
('B12'),

-- Prefix C
('C1'),
('C2'),
('C3'),
('C4'),
('C5'),
('C6');
GO

-- ============================================
-- Step 4: Verify results
-- ============================================

DECLARE @TotalCount INT;
SELECT @TotalCount = COUNT(*) FROM [Building];

PRINT 'Building data inserted successfully.';
PRINT 'Total buildings: ' + CAST(@TotalCount AS NVARCHAR(10));
PRINT '';

SELECT 
    Building_Name,
    LEFT(Building_Name, 1) AS Prefix
FROM [Building]
ORDER BY Building_Name;
GO
