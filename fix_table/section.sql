USE [lms_system];
GO

-- ============================================
-- Add Room_ID and Building_ID columns to Section table
-- ============================================

-- Step 1: Add Building_ID column
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Section') AND name = 'Building_ID')
BEGIN
    ALTER TABLE [Section]
    ADD Building_ID INT NULL;
    PRINT 'Column Building_ID added to Section table.';
END
ELSE
BEGIN
    PRINT 'Column Building_ID already exists in Section table.';
END
GO

-- Step 2: Add Room_ID column
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Section') AND name = 'Room_ID')
BEGIN
    ALTER TABLE [Section]
    ADD Room_ID INT NULL;
    PRINT 'Column Room_ID added to Section table.';
END
ELSE
BEGIN
    PRINT 'Column Room_ID already exists in Section table.';
END
GO

-- Step 3: Add Building_Name column (for convenience, can be computed or updated from Building table)
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Section') AND name = 'Building_Name')
BEGIN
    ALTER TABLE [Section]
    ADD Building_Name NVARCHAR(10) NULL;
    PRINT 'Column Building_Name added to Section table.';
END
ELSE
BEGIN
    PRINT 'Column Building_Name already exists in Section table.';
END
GO

-- ============================================
-- Update existing Section records with random Room_ID and Building_ID
-- ============================================

DECLARE @SectionCount INT;
DECLARE @RoomCount INT;
DECLARE @BuildingCount INT;

-- Get counts
SELECT @SectionCount = COUNT(*) FROM [Section];
SELECT @RoomCount = COUNT(*) FROM [Room];
SELECT @BuildingCount = COUNT(*) FROM [Building];

PRINT 'Updating ' + CAST(@SectionCount AS NVARCHAR(10)) + ' Section records with random Room and Building assignments.';
PRINT 'Available: ' + CAST(@BuildingCount AS NVARCHAR(10)) + ' Buildings, ' + CAST(@RoomCount AS NVARCHAR(10)) + ' Rooms.';

IF @RoomCount = 0 OR @BuildingCount = 0
BEGIN
    PRINT 'WARNING: No Rooms or Buildings found. Please insert data into Building and Room tables first.';
    PRINT 'Skipping random assignment.';
END
ELSE
BEGIN
    -- Update Section with random Building_ID and Room_ID
    -- Select a random Room (which has both Building_ID and Room_ID) for each Section
    DECLARE @RandomBuildingID INT;
    DECLARE @RandomRoomID INT;
    DECLARE @CurSectionID NVARCHAR(10);
    DECLARE @CurCourseID NVARCHAR(15);
    DECLARE @CurSemester NVARCHAR(10);
    
    DECLARE section_cursor CURSOR FOR
    SELECT Section_ID, Course_ID, Semester
    FROM [Section]
    WHERE Building_ID IS NULL OR Room_ID IS NULL;
    
    OPEN section_cursor;
    FETCH NEXT FROM section_cursor INTO @CurSectionID, @CurCourseID, @CurSemester;
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Get random Room (ensures valid Building_ID, Room_ID combination)
        SELECT TOP 1 
            @RandomBuildingID = Building_ID,
            @RandomRoomID = Room_ID
        FROM [Room]
        ORDER BY NEWID();
        
        -- Update Section
        UPDATE [Section]
        SET 
            Building_ID = @RandomBuildingID,
            Room_ID = @RandomRoomID
        WHERE Section_ID = @CurSectionID
            AND Course_ID = @CurCourseID
            AND Semester = @CurSemester;
        
        FETCH NEXT FROM section_cursor INTO @CurSectionID, @CurCourseID, @CurSemester;
    END;
    
    CLOSE section_cursor;
    DEALLOCATE section_cursor;
    
    -- Update Building_Name from Building table
    UPDATE s
    SET s.Building_Name = b.Building_Name
    FROM [Section] s
    INNER JOIN [Building] b ON s.Building_ID = b.Building_ID
    WHERE s.Building_ID IS NOT NULL;
    
    PRINT 'Section records updated with random Room and Building assignments.';
END
GO

-- ============================================
-- Add Foreign Key Constraints
-- ============================================

-- Drop existing FK if exists (in case of re-run)
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_Section_Room')
BEGIN
    ALTER TABLE [Section] DROP CONSTRAINT FK_Section_Room;
    PRINT 'Existing FK_Section_Room constraint dropped.';
END
GO

-- Add Foreign Key constraint to Room table
-- Note: Room has composite primary key (Building_ID, Room_ID)
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_Section_Room')
BEGIN
    BEGIN TRY
        ALTER TABLE [Section]
        ADD CONSTRAINT FK_Section_Room 
        FOREIGN KEY (Building_ID, Room_ID)
        REFERENCES [Room](Building_ID, Room_ID);
        PRINT 'Foreign Key constraint FK_Section_Room added successfully.';
    END TRY
    BEGIN CATCH
        PRINT 'ERROR: Cannot add FK_Section_Room constraint.';
        PRINT 'Error: ' + ERROR_MESSAGE();
        PRINT 'Make sure all Section records have valid Building_ID and Room_ID that exist in Room table.';
    END CATCH
END
ELSE
BEGIN
    PRINT 'FK_Section_Room constraint already exists.';
END
GO

-- ============================================
-- Verification
-- ============================================

PRINT '';
PRINT '========================================';
PRINT 'Verification:';
PRINT '========================================';

-- Check columns
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Section'
AND COLUMN_NAME IN ('Building_ID', 'Room_ID', 'Building_Name')
ORDER BY COLUMN_NAME;
GO

-- Check data
SELECT 
    COUNT(*) AS TotalSections,
    COUNT(Building_ID) AS SectionsWithBuilding,
    COUNT(Room_ID) AS SectionsWithRoom,
    COUNT(Building_Name) AS SectionsWithBuildingName
FROM [Section];
GO


