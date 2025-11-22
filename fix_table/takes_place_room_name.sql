USE [lms_system];
GO

-- ============================================
-- Script: Add Room_Name column to takes_place table
-- and add constraint to ensure Room_Name matches Room table
-- ============================================

-- ============================================
-- Step 1: Add Room_Name column if not exists
-- ============================================

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('takes_place') AND name = 'Room_Name')
BEGIN
    ALTER TABLE [takes_place] ADD Room_Name NVARCHAR(10) NULL;
    PRINT 'Added Room_Name column to takes_place table';
END
ELSE
BEGIN
    PRINT 'Room_Name column already exists in takes_place table';
END
GO

-- ============================================
-- Step 2: Populate Room_Name from Room table (if data exists)
-- ============================================

UPDATE tp
SET tp.Room_Name = r.Room_Name
FROM [takes_place] tp
INNER JOIN [Room] r
    ON tp.Building_Name = r.Building_Name
    AND tp.Room_ID = r.Room_ID
WHERE tp.Room_Name IS NULL
    AND r.Room_Name IS NOT NULL;

DECLARE @UpdatedRows INT = @@ROWCOUNT;
IF @UpdatedRows > 0
BEGIN
    PRINT 'Updated ' + CAST(@UpdatedRows AS NVARCHAR(10)) + ' rows with Room_Name from Room table';
END
GO

-- ============================================
-- Step 3: Drop existing FK constraint if exists (to recreate with Room_Name)
-- ============================================

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_Place_Room')
BEGIN
    ALTER TABLE [takes_place] DROP CONSTRAINT FK_Place_Room;
    PRINT 'Dropped existing FK_Place_Room constraint';
END
GO

-- ============================================
-- Step 4: Ensure Room table has unique constraint on (Building_Name, Room_Name)
-- Note: CHECK constraint with subquery is not supported in SQL Server
-- FK constraint will ensure data integrity instead
-- ============================================

-- Check if unique constraint exists on Room(Building_Name, Room_Name)
IF NOT EXISTS (
    SELECT * FROM sys.indexes 
    WHERE object_id = OBJECT_ID('Room') 
      AND name = 'UQ_Room_Building_Name_Room_Name'
      AND is_unique = 1
)
BEGIN
    -- Create unique constraint on (Building_Name, Room_Name) in Room table
    ALTER TABLE [Room]
    ADD CONSTRAINT UQ_Room_Building_Name_Room_Name
    UNIQUE (Building_Name, Room_Name);
    PRINT 'Created unique constraint UQ_Room_Building_Name_Room_Name on Room table';
END
ELSE
BEGIN
    PRINT 'Unique constraint UQ_Room_Building_Name_Room_Name already exists on Room table';
END
GO

-- ============================================
-- Step 5: Recreate FK constraint to Room (using Building_Name and Room_Name)
-- This FK constraint will ensure that Building_Name and Room_Name in takes_place
-- must exist in Room table, providing data integrity
-- ============================================

ALTER TABLE [takes_place]
ADD CONSTRAINT FK_Place_Room
FOREIGN KEY (Building_Name, Room_Name)
REFERENCES [Room](Building_Name, Room_Name);
PRINT 'Recreated FK_Place_Room constraint using Building_Name and Room_Name';
GO

-- ============================================
-- Step 6: Make Room_Name NOT NULL (after data is populated)
-- ============================================

IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('takes_place') AND name = 'Room_Name' AND is_nullable = 1)
BEGIN
    -- Check if all takes_place records have Room_Name
    IF NOT EXISTS (SELECT * FROM [takes_place] WHERE Room_Name IS NULL)
    BEGIN
        ALTER TABLE [takes_place] ALTER COLUMN Room_Name NVARCHAR(10) NOT NULL;
        PRINT 'Set Room_Name to NOT NULL in takes_place table';
    END
    ELSE
    BEGIN
        PRINT 'WARNING: Some takes_place records have NULL Room_Name. Please populate Room_Name before setting to NOT NULL.';
    END
END
ELSE
BEGIN
    PRINT 'Room_Name is already NOT NULL in takes_place table';
END
GO

-- ============================================
-- Step 7: Drop Room_ID and Building_ID columns (no longer needed)
-- ============================================

-- Drop FK constraint first if it references Room_ID or Building_ID
IF EXISTS (
    SELECT * FROM sys.foreign_keys fk
    INNER JOIN sys.foreign_key_columns fkc ON fk.object_id = fkc.constraint_object_id
    WHERE fk.parent_object_id = OBJECT_ID('takes_place')
      AND (COL_NAME(fkc.parent_object_id, fkc.parent_column_id) = 'Room_ID' 
           OR COL_NAME(fkc.parent_object_id, fkc.parent_column_id) = 'Building_ID')
)
BEGIN
    DECLARE @OldFKName NVARCHAR(128);
    SELECT TOP 1 @OldFKName = fk.name
    FROM sys.foreign_keys fk
    INNER JOIN sys.foreign_key_columns fkc ON fk.object_id = fkc.constraint_object_id
    WHERE fk.parent_object_id = OBJECT_ID('takes_place')
      AND (COL_NAME(fkc.parent_object_id, fkc.parent_column_id) = 'Room_ID' 
           OR COL_NAME(fkc.parent_object_id, fkc.parent_column_id) = 'Building_ID');
    
    IF @OldFKName IS NOT NULL
    BEGIN
        DECLARE @DropOldFKSQL NVARCHAR(MAX) = N'ALTER TABLE [takes_place] DROP CONSTRAINT ' + QUOTENAME(@OldFKName);
        EXEC sp_executesql @DropOldFKSQL;
        PRINT 'Dropped old FK constraint ' + @OldFKName;
    END
END
GO

-- Drop and recreate primary key if it includes Room_ID or Building_ID
IF EXISTS (
    SELECT * FROM sys.key_constraints kc
    INNER JOIN sys.index_columns ic ON kc.parent_object_id = ic.object_id AND kc.unique_index_id = ic.index_id
    WHERE kc.parent_object_id = OBJECT_ID('takes_place')
      AND kc.type = 'PK'
      AND (COL_NAME(ic.object_id, ic.column_id) = 'Room_ID' 
           OR COL_NAME(ic.object_id, ic.column_id) = 'Building_ID')
)
BEGIN
    -- Get primary key name
    DECLARE @PKName NVARCHAR(128);
    SELECT TOP 1 @PKName = name
    FROM sys.key_constraints
    WHERE parent_object_id = OBJECT_ID('takes_place')
      AND type = 'PK';
    
    IF @PKName IS NOT NULL
    BEGIN
        DECLARE @DropPKSQL NVARCHAR(MAX) = N'ALTER TABLE [takes_place] DROP CONSTRAINT ' + QUOTENAME(@PKName);
        EXEC sp_executesql @DropPKSQL;
        PRINT 'Dropped primary key ' + @PKName + ' to remove Room_ID/Building_ID';
        
        -- Recreate primary key with new columns
        ALTER TABLE [takes_place]
        ADD CONSTRAINT PK_Place PRIMARY KEY (Section_ID, Course_ID, Semester, Building_Name, Room_Name);
        PRINT 'Recreated primary key PK_Place with Building_Name and Room_Name';
    END
END
GO

-- Drop Room_ID column if exists
IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('takes_place') AND name = 'Room_ID')
BEGIN
    ALTER TABLE [takes_place] DROP COLUMN Room_ID;
    PRINT 'Dropped Room_ID column from takes_place table';
END
ELSE
BEGIN
    PRINT 'Room_ID column does not exist in takes_place table';
END
GO

-- Drop Building_ID column if exists
IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('takes_place') AND name = 'Building_ID')
BEGIN
    ALTER TABLE [takes_place] DROP COLUMN Building_ID;
    PRINT 'Dropped Building_ID column from takes_place table';
END
ELSE
BEGIN
    PRINT 'Building_ID column does not exist in takes_place table';
END
GO

-- ============================================
-- Step 8: Verify results
-- ============================================

PRINT '';
PRINT '========================================';
PRINT 'takes_place table structure updated successfully!';
PRINT '========================================';
PRINT '';

-- Show takes_place table structure
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE,
    CASE WHEN COLUMNPROPERTY(OBJECT_ID('takes_place'), COLUMN_NAME, 'IsPrimaryKey') = 1 THEN 'YES' ELSE 'NO' END AS IsPrimaryKey
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'takes_place'
ORDER BY ORDINAL_POSITION;

DECLARE @TotalTakesPlace INT;
SELECT @TotalTakesPlace = COUNT(*) FROM [takes_place];
DECLARE @TakesPlaceWithRoomName INT;
SELECT @TakesPlaceWithRoomName = COUNT(*) FROM [takes_place] WHERE Room_Name IS NOT NULL;

PRINT '';
PRINT 'Total takes_place records: ' + CAST(@TotalTakesPlace AS NVARCHAR(10));
PRINT 'Records with Room_Name: ' + CAST(@TakesPlaceWithRoomName AS NVARCHAR(10));
PRINT '';

-- Show sample takes_place records with Room_Name
SELECT TOP 10
    tp.Section_ID,
    tp.Course_ID,
    tp.Semester,
    tp.Building_Name,
    tp.Room_Name,
    r.Room_Name AS Room_Room_Name,
    CASE WHEN tp.Room_Name = r.Room_Name AND tp.Building_Name = r.Building_Name THEN 'MATCH' ELSE 'MISMATCH' END AS Status
FROM [takes_place] tp
LEFT JOIN [Room] r
    ON tp.Building_Name = r.Building_Name
    AND tp.Room_Name = r.Room_Name
ORDER BY tp.Semester, tp.Course_ID, tp.Section_ID;
GO

