USE [lms_system];
GO

-- ============================================
-- Script: Add Room_Name column to Room table
-- Room_Name pattern: [1-9][0-9][1-9] (e.g., 101, 102, ..., 606)
-- ============================================

-- ============================================
-- Step 1: Add Room_Name column if not exists
-- ============================================

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Room') AND name = 'Room_Name')
BEGIN
    ALTER TABLE [Room] ADD Room_Name NVARCHAR(10) NULL;
    PRINT 'Added Room_Name column to Room table';
END
ELSE
BEGIN
    PRINT 'Room_Name column already exists in Room table';
END
GO

-- ============================================
-- Step 2: Add CHECK constraint for Room_Name pattern [1-9][0-9][1-9]
-- ============================================

-- Drop existing constraint if exists
IF EXISTS (SELECT * FROM sys.check_constraints WHERE name = 'CK_Room_Name_Pattern')
BEGIN
    ALTER TABLE [Room] DROP CONSTRAINT CK_Room_Name_Pattern;
    PRINT 'Dropped existing CK_Room_Name_Pattern constraint';
END
GO

-- Add CHECK constraint: pattern [1-9][0-9][1-9]
-- First digit: 1-9, Second digit: 0-9, Third digit: 1-9
ALTER TABLE [Room] 
ADD CONSTRAINT CK_Room_Name_Pattern 
CHECK (
    LEN(Room_Name) = 3 
    AND Room_Name LIKE '[1-9][0-9][1-9]'
);
GO

PRINT 'Added CHECK constraint CK_Room_Name_Pattern';
PRINT 'Room_Name must follow pattern [1-9][0-9][1-9] (e.g., 101, 102, 206, 601)';
GO

-- ============================================
-- Step 3a: Drop FK constraint from takes_place (must be done first)
-- ============================================

-- Drop FK constraint from takes_place if exists (it depends on Room_Name column)
IF EXISTS (
    SELECT * FROM sys.foreign_keys 
    WHERE name = 'FK_Place_Room'
      AND parent_object_id = OBJECT_ID('takes_place')
)
BEGIN
    ALTER TABLE [takes_place] DROP CONSTRAINT FK_Place_Room;
    PRINT 'Dropped FK constraint FK_Place_Room temporarily';
END
-- Also check if FK references Room table (in case name is different)
ELSE IF EXISTS (
    SELECT * FROM sys.foreign_keys fk
    WHERE fk.parent_object_id = OBJECT_ID('takes_place')
      AND fk.referenced_object_id = OBJECT_ID('Room')
)
BEGIN
    DECLARE @FKName NVARCHAR(128);
    SELECT TOP 1 @FKName = fk.name
    FROM sys.foreign_keys fk
    WHERE fk.parent_object_id = OBJECT_ID('takes_place')
      AND fk.referenced_object_id = OBJECT_ID('Room');
    
    IF @FKName IS NOT NULL
    BEGIN
        DECLARE @DropFKSQL NVARCHAR(MAX) = N'ALTER TABLE [takes_place] DROP CONSTRAINT ' + QUOTENAME(@FKName);
        EXEC sp_executesql @DropFKSQL;
        PRINT 'Dropped FK constraint ' + @FKName + ' temporarily';
    END
END
GO

-- ============================================
-- Step 3b: Make Room_Name NOT NULL (after data is populated)
-- ============================================

IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Room') AND name = 'Room_Name' AND is_nullable = 1)
BEGIN
    -- Check if all rooms have Room_Name
    IF NOT EXISTS (SELECT * FROM [Room] WHERE Room_Name IS NULL)
    BEGIN
        -- Drop unique constraint if exists (it depends on Room_Name column)
        IF EXISTS (
            SELECT * FROM sys.indexes 
            WHERE object_id = OBJECT_ID('Room') 
              AND name = 'UQ_Room_Building_Name_Room_Name'
        )
        BEGIN
            ALTER TABLE [Room] DROP CONSTRAINT UQ_Room_Building_Name_Room_Name;
            PRINT 'Dropped unique constraint UQ_Room_Building_Name_Room_Name temporarily';
        END
        
        -- Set Room_Name to NOT NULL
        ALTER TABLE [Room] ALTER COLUMN Room_Name NVARCHAR(10) NOT NULL;
        PRINT 'Set Room_Name to NOT NULL in Room table';
        
        -- Recreate unique constraint
        IF NOT EXISTS (
            SELECT * FROM sys.indexes 
            WHERE object_id = OBJECT_ID('Room') 
              AND name = 'UQ_Room_Building_Name_Room_Name'
        )
        BEGIN
            ALTER TABLE [Room]
            ADD CONSTRAINT UQ_Room_Building_Name_Room_Name
            UNIQUE (Building_Name, Room_Name);
            PRINT 'Recreated unique constraint UQ_Room_Building_Name_Room_Name on Room table';
        END
    END
    ELSE
    BEGIN
        PRINT 'WARNING: Some rooms have NULL Room_Name. Please populate Room_Name before setting to NOT NULL.';
    END
END
ELSE
BEGIN
    PRINT 'Room_Name is already NOT NULL in Room table';
END
GO

-- ============================================
-- Step 3c: Recreate FK constraint
-- ============================================

-- Recreate FK constraint
IF NOT EXISTS (
    SELECT * FROM sys.foreign_keys 
    WHERE name = 'FK_Place_Room'
      AND parent_object_id = OBJECT_ID('takes_place')
)
BEGIN
    ALTER TABLE [takes_place]
    ADD CONSTRAINT FK_Place_Room
    FOREIGN KEY (Building_Name, Room_Name)
    REFERENCES [Room](Building_Name, Room_Name);
    PRINT 'Recreated FK constraint FK_Place_Room';
END
ELSE
BEGIN
    PRINT 'FK constraint FK_Place_Room already exists';
END
GO

-- ============================================
-- Step 4: Verify results
-- ============================================

PRINT '';
PRINT '========================================';
PRINT 'Room table structure updated successfully!';
PRINT '========================================';
PRINT '';

-- Show Room table structure
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE,
    CASE WHEN COLUMNPROPERTY(OBJECT_ID('Room'), COLUMN_NAME, 'IsPrimaryKey') = 1 THEN 'YES' ELSE 'NO' END AS IsPrimaryKey
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Room'
ORDER BY ORDINAL_POSITION;

DECLARE @TotalRooms INT
SELECT @TotalRooms = COUNT(*) FROM [Room]
DECLARE @RoomNotNull INT 
SELECT @RoomNotNull = COUNT(*) FROM [Room] WHERE Room_Name IS NOT NULL
PRINT '';
PRINT 'Total rooms: ' + CAST(@TotalRooms as NVARCHAR(10));
PRINT 'Rooms with Room_Name: ' + CAST(@RoomNotNull AS NVARCHAR(10));
PRINT '';

-- Show sample room names
SELECT TOP 10
    Building_Name,
    Room_Name,
    Capacity
FROM [Room]
WHERE Room_Name IS NOT NULL
ORDER BY Building_Name, Room_Name;
GO

