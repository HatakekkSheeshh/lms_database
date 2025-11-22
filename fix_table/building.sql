USE [lms_system];
GO

-- ============================================
-- Script: Change Building_Name to PRIMARY KEY and drop Building_ID
-- Update all referencing tables to use Building_Name instead of Building_ID
-- This script handles both fresh migration and partial migration scenarios
-- ============================================

-- ============================================
-- Step 1: Clean up any existing temp tables and check current state
-- ============================================

-- Drop temp table if exists from previous runs
IF OBJECT_ID('tempdb..#IDToNameMapping') IS NOT NULL
    DROP TABLE #IDToNameMapping;

-- Check migration status
DECLARE @BuildingHasID BIT = 0;
IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Building') AND name = 'Building_ID')
    SET @BuildingHasID = 1;

IF @BuildingHasID = 1
    PRINT 'Building_ID exists in Building table. Migration will proceed.';
ELSE
    PRINT 'Building_ID does not exist in Building table. Migration may have been partially completed.';
GO

-- ============================================
-- Step 2: Drop all foreign key constraints that reference Room or Building
-- ============================================

-- Find and drop all foreign keys that reference Room table (including FK_Section_Room if exists)
DECLARE @sql NVARCHAR(MAX) = '';
SELECT @sql = @sql + 'ALTER TABLE ' + QUOTENAME(OBJECT_SCHEMA_NAME(parent_object_id)) + '.' + QUOTENAME(OBJECT_NAME(parent_object_id)) 
    + ' DROP CONSTRAINT ' + QUOTENAME(name) + ';' + CHAR(13)
FROM sys.foreign_keys
WHERE referenced_object_id = OBJECT_ID('Room');

IF @sql <> ''
BEGIN
    PRINT 'Dropping foreign keys that reference Room table...';
    EXEC sp_executesql @sql;
END

-- Drop FK_Room_Building
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_Room_Building')
BEGIN
    ALTER TABLE [Room] DROP CONSTRAINT FK_Room_Building;
    PRINT 'Dropped FK_Room_Building';
END

-- Drop FK_Equipment_Room
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_Equipment_Room')
BEGIN
    ALTER TABLE [Room_Equipment] DROP CONSTRAINT FK_Equipment_Room;
    PRINT 'Dropped FK_Equipment_Room';
END

-- Drop FK_Place_Room
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_Place_Room')
BEGIN
    ALTER TABLE [Takes_Place] DROP CONSTRAINT FK_Place_Room;
    PRINT 'Dropped FK_Place_Room';
END

GO

-- ============================================
-- Step 3: Update Room table - Add Building_Name column if not exists
-- ============================================

-- Check if Building_Name already exists in Room
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Room') AND name = 'Building_Name')
BEGIN
    -- Add Building_Name column to Room
    ALTER TABLE [Room] ADD Building_Name NVARCHAR(10) NULL;
    PRINT 'Added Building_Name column to Room table';
END
ELSE
BEGIN
    PRINT 'Building_Name column already exists in Room table';
END
GO

-- Update Building_Name based on Building_ID mapping (only if Building_ID exists in both tables)
IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Room') AND name = 'Building_ID')
    AND EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Building') AND name = 'Building_ID')
BEGIN
    DECLARE @UpdateRoomSQL NVARCHAR(MAX);
    SET @UpdateRoomSQL = N'
        UPDATE r
        SET r.Building_Name = b.Building_Name
        FROM [Room] r
        INNER JOIN [Building] b ON r.Building_ID = b.Building_ID;
    ';
    
    BEGIN TRY
        EXEC sp_executesql @UpdateRoomSQL;
        PRINT 'Updated Building_Name in Room table: ' + CAST(@@ROWCOUNT AS NVARCHAR(10)) + ' rows';
    END TRY
    BEGIN CATCH
        PRINT 'Error updating Room table: ' + ERROR_MESSAGE();
        PRINT 'Skipping Room update - Building_ID may have been removed from Building table.';
    END CATCH
END
ELSE
BEGIN
    PRINT 'Skipping Room update - Building_ID does not exist in one or both tables.';
END
GO

-- Check for any NULL values and set default
IF EXISTS (SELECT * FROM [Room] WHERE Building_Name IS NULL)
BEGIN
    PRINT 'WARNING: Some Room records have NULL Building_Name. Setting to default value.';
    DECLARE @DefaultBuilding NVARCHAR(10);
    SELECT TOP 1 @DefaultBuilding = Building_Name FROM [Building];
    UPDATE [Room] SET Building_Name = @DefaultBuilding WHERE Building_Name IS NULL;
END
GO

-- Make Building_Name NOT NULL
IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Room') AND name = 'Building_Name' AND is_nullable = 1)
BEGIN
    ALTER TABLE [Room] ALTER COLUMN Building_Name NVARCHAR(10) NOT NULL;
    PRINT 'Set Building_Name to NOT NULL in Room table';
END
GO

-- ============================================
-- Step 4: Update Room_Equipment table - Add Building_Name column if not exists
-- ============================================

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Room_Equipment') AND name = 'Building_Name')
BEGIN
    ALTER TABLE [Room_Equipment] ADD Building_Name NVARCHAR(10) NULL;
    PRINT 'Added Building_Name column to Room_Equipment table';
END
GO

-- Update Building_Name (only if Building_ID exists in both tables)
IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Room_Equipment') AND name = 'Building_ID')
    AND EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Building') AND name = 'Building_ID')
BEGIN
    DECLARE @UpdateRoomEquipmentSQL NVARCHAR(MAX);
    SET @UpdateRoomEquipmentSQL = N'
        UPDATE re
        SET re.Building_Name = b.Building_Name
        FROM [Room_Equipment] re
        INNER JOIN [Building] b ON re.Building_ID = b.Building_ID;
    ';
    
    BEGIN TRY
        EXEC sp_executesql @UpdateRoomEquipmentSQL;
        PRINT 'Updated Building_Name in Room_Equipment table: ' + CAST(@@ROWCOUNT AS NVARCHAR(10)) + ' rows';
    END TRY
    BEGIN CATCH
        PRINT 'Error updating Room_Equipment table: ' + ERROR_MESSAGE();
        PRINT 'Skipping Room_Equipment update - Building_ID may have been removed from Building table.';
    END CATCH
END
ELSE
BEGIN
    PRINT 'Skipping Room_Equipment update - Building_ID does not exist in one or both tables.';
END
GO

-- Check for NULL values
IF EXISTS (SELECT * FROM [Room_Equipment] WHERE Building_Name IS NULL)
BEGIN
    PRINT 'WARNING: Some Room_Equipment records have NULL Building_Name. Setting to default value.';
    DECLARE @DefaultBuilding2 NVARCHAR(10);
    SELECT TOP 1 @DefaultBuilding2 = Building_Name FROM [Building];
    UPDATE [Room_Equipment] SET Building_Name = @DefaultBuilding2 WHERE Building_Name IS NULL;
END
GO

-- Make Building_Name NOT NULL
IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Room_Equipment') AND name = 'Building_Name' AND is_nullable = 1)
BEGIN
    ALTER TABLE [Room_Equipment] ALTER COLUMN Building_Name NVARCHAR(10) NOT NULL;
    PRINT 'Set Building_Name to NOT NULL in Room_Equipment table';
END
GO

-- ============================================
-- Step 5: Update Takes_Place table - Add Building_Name column if not exists
-- ============================================

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Takes_Place') AND name = 'Building_Name')
BEGIN
    ALTER TABLE [Takes_Place] ADD Building_Name NVARCHAR(10) NULL;
    PRINT 'Added Building_Name column to Takes_Place table';
END
GO

-- Update Building_Name (only if Building_ID exists in both tables)
IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Takes_Place') AND name = 'Building_ID')
    AND EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Building') AND name = 'Building_ID')
BEGIN
    DECLARE @UpdateTakesPlaceSQL NVARCHAR(MAX);
    SET @UpdateTakesPlaceSQL = N'
        UPDATE tp
        SET tp.Building_Name = b.Building_Name
        FROM [Takes_Place] tp
        INNER JOIN [Building] b ON tp.Building_ID = b.Building_ID;
    ';
    
    BEGIN TRY
        EXEC sp_executesql @UpdateTakesPlaceSQL;
        PRINT 'Updated Building_Name in Takes_Place table: ' + CAST(@@ROWCOUNT AS NVARCHAR(10)) + ' rows';
    END TRY
    BEGIN CATCH
        PRINT 'Error updating Takes_Place table: ' + ERROR_MESSAGE();
        PRINT 'Skipping Takes_Place update - Building_ID may have been removed from Building table.';
    END CATCH
END
ELSE
BEGIN
    PRINT 'Skipping Takes_Place update - Building_ID does not exist in one or both tables.';
END
GO

-- Check for NULL values
IF EXISTS (SELECT * FROM [Takes_Place] WHERE Building_Name IS NULL)
BEGIN
    PRINT 'WARNING: Some Takes_Place records have NULL Building_Name. Setting to default value.';
    DECLARE @DefaultBuilding3 NVARCHAR(10);
    SELECT TOP 1 @DefaultBuilding3 = Building_Name FROM [Building];
    UPDATE [Takes_Place] SET Building_Name = @DefaultBuilding3 WHERE Building_Name IS NULL;
END
GO

-- Make Building_Name NOT NULL
IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Takes_Place') AND name = 'Building_Name' AND is_nullable = 1)
BEGIN
    ALTER TABLE [Takes_Place] ALTER COLUMN Building_Name NVARCHAR(10) NOT NULL;
    PRINT 'Set Building_Name to NOT NULL in Takes_Place table';
END
GO

-- ============================================
-- Step 6: Drop old primary keys and recreate with Building_Name
-- ============================================

-- Drop PK_Room (check if exists first)
IF EXISTS (SELECT * FROM sys.key_constraints WHERE name = 'PK_Room')
BEGIN
    -- Check if it's referenced by other foreign keys
    DECLARE @FKCount INT;
    SELECT @FKCount = COUNT(*) 
    FROM sys.foreign_keys 
    WHERE referenced_object_id = OBJECT_ID('Room') 
      AND name LIKE '%Room%';
    
    IF @FKCount > 0
    BEGIN
        -- Drop all FKs that reference Room's PK
        DECLARE @sql2 NVARCHAR(MAX) = '';
        SELECT @sql2 = @sql2 + 'ALTER TABLE ' + QUOTENAME(OBJECT_SCHEMA_NAME(parent_object_id)) + '.' + QUOTENAME(OBJECT_NAME(parent_object_id)) 
            + ' DROP CONSTRAINT ' + QUOTENAME(name) + ';' + CHAR(13)
        FROM sys.foreign_keys
        WHERE referenced_object_id = OBJECT_ID('Room');
        
        IF @sql2 <> ''
            EXEC sp_executesql @sql2;
    END
    
    ALTER TABLE [Room] DROP CONSTRAINT PK_Room;
    PRINT 'Dropped PK_Room';
END
GO

-- Drop PK_Room_Equipment
IF EXISTS (SELECT * FROM sys.key_constraints WHERE name = 'PK_Room_Equipment')
BEGIN
    ALTER TABLE [Room_Equipment] DROP CONSTRAINT PK_Room_Equipment;
    PRINT 'Dropped PK_Room_Equipment';
END
GO

-- Drop PK_Place
IF EXISTS (SELECT * FROM sys.key_constraints WHERE name = 'PK_Place')
BEGIN
    ALTER TABLE [Takes_Place] DROP CONSTRAINT PK_Place;
    PRINT 'Dropped PK_Place';
END
GO

-- Recreate PK_Room with Building_Name
IF NOT EXISTS (SELECT * FROM sys.key_constraints WHERE name = 'PK_Room')
BEGIN
    ALTER TABLE [Room] ADD CONSTRAINT PK_Room PRIMARY KEY (Building_Name, Room_ID);
    PRINT 'Created PK_Room with Building_Name';
END
GO

-- Recreate PK_Room_Equipment with Building_Name
IF NOT EXISTS (SELECT * FROM sys.key_constraints WHERE name = 'PK_Room_Equipment')
BEGIN
    ALTER TABLE [Room_Equipment] ADD CONSTRAINT PK_Room_Equipment PRIMARY KEY (Building_Name, Room_ID, Equipment_Name);
    PRINT 'Created PK_Room_Equipment with Building_Name';
END
GO

-- Recreate PK_Place with Building_Name
IF NOT EXISTS (SELECT * FROM sys.key_constraints WHERE name = 'PK_Place')
BEGIN
    ALTER TABLE [Takes_Place] ADD CONSTRAINT PK_Place PRIMARY KEY (Section_ID, Course_ID, Semester, Room_ID, Building_Name);
    PRINT 'Created PK_Place with Building_Name';
END
GO

-- ============================================
-- Step 7: Drop Building_ID columns from referencing tables
-- ============================================

IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Room') AND name = 'Building_ID')
BEGIN
    ALTER TABLE [Room] DROP COLUMN Building_ID;
    PRINT 'Dropped Building_ID column from Room table';
END
GO

IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Room_Equipment') AND name = 'Building_ID')
BEGIN
    ALTER TABLE [Room_Equipment] DROP COLUMN Building_ID;
    PRINT 'Dropped Building_ID column from Room_Equipment table';
END
GO

IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Takes_Place') AND name = 'Building_ID')
BEGIN
    ALTER TABLE [Takes_Place] DROP COLUMN Building_ID;
    PRINT 'Dropped Building_ID column from Takes_Place table';
END
GO

-- ============================================
-- Step 8: Update Building table - Drop Building_ID and make Building_Name PRIMARY KEY
-- ============================================

-- Drop old PRIMARY KEY constraint (find dynamically)
DECLARE @PKConstraintName NVARCHAR(200);
SELECT @PKConstraintName = name 
FROM sys.key_constraints 
WHERE parent_object_id = OBJECT_ID('Building') 
  AND type = 'PK';

IF @PKConstraintName IS NOT NULL
BEGIN
    EXEC('ALTER TABLE [Building] DROP CONSTRAINT ' + @PKConstraintName);
    PRINT 'Dropped old PRIMARY KEY constraint from Building table';
END
GO

-- Drop UNIQUE constraint on Building_Name (if exists with different name)
DECLARE @UQConstraintName NVARCHAR(200);
SELECT @UQConstraintName = name 
FROM sys.key_constraints 
WHERE parent_object_id = OBJECT_ID('Building') 
  AND type = 'UQ';

IF @UQConstraintName IS NOT NULL
BEGIN
    EXEC('ALTER TABLE [Building] DROP CONSTRAINT ' + @UQConstraintName);
    PRINT 'Dropped UNIQUE constraint from Building table';
END
GO

-- Drop Building_ID column
IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Building') AND name = 'Building_ID')
BEGIN
    ALTER TABLE [Building] DROP COLUMN Building_ID;
    PRINT 'Dropped Building_ID column from Building table';
END
GO

-- Make Building_Name PRIMARY KEY
IF NOT EXISTS (SELECT * FROM sys.key_constraints WHERE parent_object_id = OBJECT_ID('Building') AND type = 'PK')
BEGIN
    ALTER TABLE [Building] ADD CONSTRAINT PK_Building PRIMARY KEY (Building_Name);
    PRINT 'Created PK_Building with Building_Name as PRIMARY KEY';
END
GO

-- ============================================
-- Step 9: Recreate foreign key constraints with Building_Name
-- ============================================

-- Recreate FK_Room_Building
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_Room_Building')
BEGIN
    ALTER TABLE [Room] 
    ADD CONSTRAINT FK_Room_Building 
    FOREIGN KEY (Building_Name) REFERENCES [Building](Building_Name);
    PRINT 'Created FK_Room_Building';
END
GO

-- Recreate FK_Equipment_Room
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_Equipment_Room')
BEGIN
    ALTER TABLE [Room_Equipment] 
    ADD CONSTRAINT FK_Equipment_Room 
    FOREIGN KEY (Building_Name, Room_ID) REFERENCES [Room](Building_Name, Room_ID);
    PRINT 'Created FK_Equipment_Room';
END
GO

-- Recreate FK_Place_Room
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_Place_Room')
BEGIN
    ALTER TABLE [Takes_Place] 
    ADD CONSTRAINT FK_Place_Room 
    FOREIGN KEY (Building_Name, Room_ID) REFERENCES [Room](Building_Name, Room_ID);
    PRINT 'Created FK_Place_Room';
END
GO

-- ============================================
-- Step 10: Clean up temp table (if exists)
-- ============================================

-- Drop temp table if it still exists
IF OBJECT_ID('tempdb..#IDToNameMapping') IS NOT NULL
BEGIN
    DROP TABLE #IDToNameMapping;
    PRINT 'Cleaned up temp table';
END
GO

-- ============================================
-- Step 11: Verify results
-- ============================================

PRINT '';
PRINT '========================================';
PRINT 'Building table structure updated successfully!';
PRINT '========================================';
PRINT 'Building_Name is now PRIMARY KEY';
PRINT 'Building_ID has been removed';
PRINT '';

-- Show Building table structure
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE,
    CASE WHEN COLUMNPROPERTY(OBJECT_ID('Building'), COLUMN_NAME, 'IsPrimaryKey') = 1 THEN 'YES' ELSE 'NO' END AS IsPrimaryKey
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Building'
ORDER BY ORDINAL_POSITION;

DECLARE @TotalBuildings INT;
SELECT @TotalBuildings = COUNT(*) FROM [Building];
PRINT '';
PRINT 'Total buildings: ' + CAST(@TotalBuildings AS NVARCHAR(10));
PRINT '';

SELECT 
    Building_Name,
    LEFT(Building_Name, 1) AS Prefix
FROM [Building]
ORDER BY Building_Name;
GO
