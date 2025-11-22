USE [lms_system];
GO

-- ============================================
-- Script to change Room_Equipment: Room_ID -> Room_Name
-- PK: (Building_Name, Room_Name, Equipment_Name)
-- FK: (Building_Name, Room_Name) -> Room(Building_Name, Room_Name)
-- ============================================

PRINT '========================================';
PRINT 'Changing Room_Equipment: Room_ID -> Room_Name';
PRINT '========================================';
PRINT '';

-- ============================================
-- Step 1: Drop existing FK constraint
-- ============================================
PRINT 'Step 1: Dropping existing FK constraint...';

IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_Equipment_Room')
BEGIN
    ALTER TABLE [Room_Equipment] DROP CONSTRAINT FK_Equipment_Room;
    PRINT 'Dropped FK_Equipment_Room';
END;

IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_Equipment_Room_Name')
BEGIN
    ALTER TABLE [Room_Equipment] DROP CONSTRAINT FK_Equipment_Room_Name;
    PRINT 'Dropped FK_Equipment_Room_Name';
END;

PRINT '';
GO

-- ============================================
-- Step 2: Drop existing PK
-- ============================================
PRINT 'Step 2: Dropping existing PK...';

IF EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = 'PK_Room_Equipment')
BEGIN
    ALTER TABLE [Room_Equipment] DROP CONSTRAINT PK_Room_Equipment;
    PRINT 'Dropped PK_Room_Equipment';
END;

PRINT '';
GO

-- ============================================
-- Step 3: Add Building_Name column if not exists
-- ============================================
PRINT 'Step 3: Adding Building_Name column...';

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Room_Equipment') AND name = 'Building_Name')
BEGIN
    ALTER TABLE [Room_Equipment] ADD Building_Name NVARCHAR(10) NULL;
    PRINT 'Added Building_Name column';
END
ELSE
BEGIN
    PRINT 'Building_Name column already exists';
END;

PRINT '';
GO

-- ============================================
-- Step 4: Check Building_Name population
-- ============================================
PRINT 'Step 4: Checking Building_Name...';

IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Room_Equipment') AND name = 'Building_Name')
BEGIN
    DECLARE @HasNullBuildingName INT;
    SELECT @HasNullBuildingName = COUNT(*) FROM [Room_Equipment] WHERE Building_Name IS NULL;
    IF @HasNullBuildingName > 0
    BEGIN
        PRINT 'WARNING: ' + CAST(@HasNullBuildingName AS NVARCHAR(10)) + ' rows have NULL Building_Name';
        PRINT 'Please run insert_room_equipment.sql to populate Building_Name';
    END
    ELSE
    BEGIN
        DECLARE @WithBuildingName INT;
        SELECT @WithBuildingName = COUNT(*) FROM [Room_Equipment] WHERE Building_Name IS NOT NULL;
        PRINT 'Building_Name is populated for ' + CAST(@WithBuildingName AS NVARCHAR(10)) + ' rows';
    END;
END
ELSE
BEGIN
    PRINT 'Building_Name column does not exist';
END;

PRINT '';
GO

-- ============================================
-- Step 5: Add Room_Name column if not exists
-- ============================================
PRINT 'Step 5: Adding Room_Name column...';

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Room_Equipment') AND name = 'Room_Name')
BEGIN
    ALTER TABLE [Room_Equipment] ADD Room_Name NVARCHAR(10) NULL;
    PRINT 'Added Room_Name column';
END
ELSE
BEGIN
    PRINT 'Room_Name column already exists';
END;

PRINT '';
GO

-- ============================================
-- Step 6: Check Room_Name population
-- ============================================
PRINT 'Step 6: Checking Room_Name...';

IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Room_Equipment') AND name = 'Room_Name')
BEGIN
    DECLARE @HasNullRoomName INT;
    SELECT @HasNullRoomName = COUNT(*) FROM [Room_Equipment] WHERE Room_Name IS NULL;
    IF @HasNullRoomName > 0
    BEGIN
        PRINT 'WARNING: ' + CAST(@HasNullRoomName AS NVARCHAR(10)) + ' rows have NULL Room_Name';
        PRINT 'Please run insert_room_equipment.sql to populate Room_Name';
    END
    ELSE
    BEGIN
        DECLARE @WithRoomName INT;
        SELECT @WithRoomName = COUNT(*) FROM [Room_Equipment] WHERE Room_Name IS NOT NULL;
        PRINT 'Room_Name is populated for ' + CAST(@WithRoomName AS NVARCHAR(10)) + ' rows';
    END;
END
ELSE
BEGIN
    PRINT 'Room_Name column does not exist';
END;

PRINT '';
GO

-- ============================================
-- Step 7: Set Building_Name and Room_Name to NOT NULL
-- ============================================
PRINT 'Step 7: Setting columns to NOT NULL...';

IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Room_Equipment') AND name = 'Building_Name' AND is_nullable = 1)
BEGIN
    DECLARE @NullBuildingNameCount INT;
    SELECT @NullBuildingNameCount = COUNT(*) FROM [Room_Equipment] WHERE Building_Name IS NULL;
    
    IF @NullBuildingNameCount = 0
    BEGIN
        ALTER TABLE [Room_Equipment] ALTER COLUMN Building_Name NVARCHAR(10) NOT NULL;
        PRINT 'Set Building_Name to NOT NULL';
    END
    ELSE
    BEGIN
        PRINT 'WARNING: Cannot set Building_Name to NOT NULL. ' + CAST(@NullBuildingNameCount AS NVARCHAR(10)) + ' rows are NULL';
    END;
END;

IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Room_Equipment') AND name = 'Room_Name' AND is_nullable = 1)
BEGIN
    DECLARE @NullRoomNameCount INT;
    SELECT @NullRoomNameCount = COUNT(*) FROM [Room_Equipment] WHERE Room_Name IS NULL;
    
    IF @NullRoomNameCount = 0
    BEGIN
        ALTER TABLE [Room_Equipment] ALTER COLUMN Room_Name NVARCHAR(10) NOT NULL;
        PRINT 'Set Room_Name to NOT NULL';
    END
    ELSE
    BEGIN
        PRINT 'WARNING: Cannot set Room_Name to NOT NULL. ' + CAST(@NullRoomNameCount AS NVARCHAR(10)) + ' rows are NULL';
    END;
END;

PRINT '';
GO

-- ============================================
-- Step 8: Create new PK on (Building_Name, Room_Name, Equipment_Name)
-- ============================================
PRINT 'Step 8: Creating new PK...';

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = 'PK_Room_Equipment')
BEGIN
    IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Room_Equipment') AND name = 'Building_Name')
       AND EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Room_Equipment') AND name = 'Room_Name')
    BEGIN
        ALTER TABLE [Room_Equipment]
        ADD CONSTRAINT PK_Room_Equipment
        PRIMARY KEY (Building_Name, Room_Name, Equipment_Name);
        PRINT 'Created PK on (Building_Name, Room_Name, Equipment_Name)';
    END;
END
ELSE
BEGIN
    PRINT 'PK already exists';
END;

PRINT '';
GO

-- ============================================
-- Step 9: Create FK to Room(Building_Name, Room_Name)
-- ============================================
PRINT 'Step 9: Creating FK to Room...';

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_Equipment_Room_Name')
BEGIN
    IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Room_Equipment') AND name = 'Building_Name')
       AND EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Room_Equipment') AND name = 'Room_Name')
       AND EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Room') AND name = 'Building_Name')
       AND EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Room') AND name = 'Room_Name')
    BEGIN
        ALTER TABLE [Room_Equipment]
        ADD CONSTRAINT FK_Equipment_Room_Name
        FOREIGN KEY (Building_Name, Room_Name)
        REFERENCES [Room](Building_Name, Room_Name);
        PRINT 'Created FK_Equipment_Room_Name';
    END;
END
ELSE
BEGIN
    PRINT 'FK already exists';
END;

PRINT '';
GO

-- ============================================
-- Step 10: Drop Room_ID and Building_ID columns
-- ============================================
PRINT 'Step 10: Dropping old columns...';

IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Room_Equipment') AND name = 'Room_ID')
BEGIN
    ALTER TABLE [Room_Equipment] DROP COLUMN Room_ID;
    PRINT 'Dropped Room_ID column';
END
ELSE
BEGIN
    PRINT 'Room_ID column does not exist';
END;

IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Room_Equipment') AND name = 'Building_ID')
BEGIN
    ALTER TABLE [Room_Equipment] DROP COLUMN Building_ID;
    PRINT 'Dropped Building_ID column';
END
ELSE
BEGIN
    PRINT 'Building_ID column does not exist';
END;

PRINT '';
GO

-- ============================================
-- Summary
-- ============================================
PRINT '========================================';
PRINT 'Summary';
PRINT '========================================';

DECLARE @TotalEquipment INT;
SELECT @TotalEquipment = COUNT(*) FROM [Room_Equipment];
PRINT 'Total Room_Equipment records: ' + CAST(@TotalEquipment AS NVARCHAR(10));

IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Room_Equipment') AND name = 'Building_Name')
BEGIN
    DECLARE @WithBuildingName INT;
    SELECT @WithBuildingName = COUNT(*) FROM [Room_Equipment] WHERE Building_Name IS NOT NULL;
    PRINT 'Records with Building_Name: ' + CAST(@WithBuildingName AS NVARCHAR(10));
END;

IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Room_Equipment') AND name = 'Room_Name')
BEGIN
    DECLARE @WithRoomName INT;
    SELECT @WithRoomName = COUNT(*) FROM [Room_Equipment] WHERE Room_Name IS NOT NULL;
    PRINT 'Records with Room_Name: ' + CAST(@WithRoomName AS NVARCHAR(10));
END;

PRINT '========================================';
GO

