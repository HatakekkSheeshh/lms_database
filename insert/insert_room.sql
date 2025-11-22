USE [lms_system];
GO

-- ============================================
-- Script insert Room: Insert rooms for each building
-- Each building has 6 floors (1-6), each floor has 6 rooms (01-06)
-- Room names pattern: [1-9][0-9][1-9] (e.g., 101, 102, ..., 106, 201, ..., 606)
-- ============================================

-- ============================================
-- Step 1: Delete data from referencing tables first (to avoid FK constraint conflicts)
-- ============================================

-- Delete from Room_Equipment (references Room)
DELETE FROM [Room_Equipment];
GO

-- Delete from Takes_Place (references Room)
DELETE FROM [Takes_Place];
GO

-- ============================================
-- Step 2: Delete existing rooms
-- ============================================

DELETE FROM [Room];
GO

-- ============================================
-- Step 3: Insert rooms for each building using Building_Name
-- ============================================

DECLARE @Current_Building_Name NVARCHAR(10);
DECLARE building_cursor CURSOR FOR
SELECT Building_Name FROM [Building] ORDER BY Building_Name;

OPEN building_cursor;
FETCH NEXT FROM building_cursor INTO @Current_Building_Name;

WHILE @@FETCH_STATUS = 0
BEGIN
    DECLARE @Floor INT = 1;
    DECLARE @Room_Number INT;
    DECLARE @Capacity_To_Insert INT;
    
    -- 6 floors
    WHILE @Floor <= 6
    BEGIN
        -- 6 rooms per floor (01-06)
        SET @Room_Number = 1;
        WHILE @Room_Number <= 6
        BEGIN
            -- Calculate capacity based on floor and room number
            SET @Capacity_To_Insert = CASE (@Floor + @Room_Number) % 7
                                        WHEN 1 THEN 40
                                        WHEN 2 THEN 60
                                        WHEN 3 THEN 40
                                        WHEN 4 THEN 60
                                        WHEN 5 THEN 40
                                        WHEN 6 THEN 60
                                        ELSE 80 
                                      END;
            
            -- Insert room with Building_Name and Room_Name
            -- Room_Name format: [floor][0][room_number] (e.g., 101, 102, ..., 606)
            INSERT INTO [Room] (Building_Name, Room_Name, Capacity)
            VALUES (@Current_Building_Name, 
                    CAST(@Floor AS NVARCHAR(1)) + '0' + CAST(@Room_Number AS NVARCHAR(1)), 
                    @Capacity_To_Insert);
            
            SET @Room_Number = @Room_Number + 1;
        END;
        
        SET @Floor = @Floor + 1;
    END;
    
    FETCH NEXT FROM building_cursor INTO @Current_Building_Name;
END;

CLOSE building_cursor;
DEALLOCATE building_cursor;

-- ============================================
-- Step 4: Verify results
-- ============================================

DECLARE @TotalRooms INT;
SELECT @TotalRooms = COUNT(*) FROM [Room];

PRINT 'Room data inserted successfully.';
PRINT 'Total rooms: ' + CAST(@TotalRooms AS NVARCHAR(10));
GO
