USE [lms_system];
GO

-- ============================================
-- Script to add Building_Name and Room_Name columns to Room table
-- Room_Name is PK, Building_Name is FK to Building(Building_Name)
-- ============================================

PRINT '========================================';
PRINT 'Adding Building_Name and Room_Name to Room table';
PRINT '========================================';
PRINT '';

-- ============================================
-- Step 1: Drop existing constraints
-- ============================================
PRINT 'Step 1: Dropping existing constraints...';

IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_Equipment_Room')
BEGIN
    ALTER TABLE [Room_Equipment] DROP CONSTRAINT FK_Equipment_Room;
    PRINT 'Dropped FK_Equipment_Room';
END;

IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_Place_Room')
BEGIN
    ALTER TABLE [takes_place] DROP CONSTRAINT FK_Place_Room;
    PRINT 'Dropped FK_Place_Room';
END;

IF EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = 'PK_Room')
BEGIN
    ALTER TABLE [Room] DROP CONSTRAINT PK_Room;
    PRINT 'Dropped PK_Room';
END;

IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_Room_Building')
BEGIN
    ALTER TABLE [Room] DROP CONSTRAINT FK_Room_Building;
    PRINT 'Dropped FK_Room_Building';
END;

PRINT '';
GO

-- ============================================
-- Step 2: Add Building_Name column
-- ============================================
PRINT 'Step 2: Adding Building_Name column...';

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Room') AND name = 'Building_Name')
BEGIN
    ALTER TABLE [Room] ADD Building_Name NVARCHAR(10) NULL;
    PRINT 'Added Building_Name column';
END
ELSE
BEGIN
    PRINT 'Building_Name column already exists';
END;

PRINT '';
GO

-- ============================================
-- Step 3: Add Room_Name column
-- ============================================
PRINT 'Step 3: Adding Room_Name column...';

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Room') AND name = 'Room_Name')
BEGIN
    ALTER TABLE [Room] ADD Room_Name NVARCHAR(10) NULL;
    PRINT 'Added Room_Name column';
END
ELSE
BEGIN
    PRINT 'Room_Name column already exists';
END;

PRINT '';
GO

-- ============================================
-- Step 4: Set Building_Name to NOT NULL (after running insert_room.sql)
-- ============================================
PRINT 'Step 4: Setting Building_Name to NOT NULL...';

IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Room') AND name = 'Building_Name' AND is_nullable = 1)
BEGIN
    DECLARE @HasNullBuildingName INT;
    SELECT @HasNullBuildingName = COUNT(*) FROM [Room] WHERE Building_Name IS NULL;
    
    IF @HasNullBuildingName = 0
    BEGIN
        ALTER TABLE [Room] ALTER COLUMN Building_Name NVARCHAR(10) NOT NULL;
        PRINT 'Set Building_Name to NOT NULL';
    END
    ELSE
    BEGIN
        PRINT 'WARNING: ' + CAST(@HasNullBuildingName AS NVARCHAR(10)) + ' rooms have NULL Building_Name. Run insert_room.sql first.';
    END;
END
ELSE
BEGIN
    PRINT 'Building_Name is already NOT NULL or does not exist';
END;

PRINT '';
GO

-- ============================================
-- Step 5: Set Room_Name to NOT NULL (after running insert_room.sql)
-- ============================================
PRINT 'Step 5: Setting Room_Name to NOT NULL...';

IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Room') AND name = 'Room_Name' AND is_nullable = 1)
BEGIN
    DECLARE @HasNullRoomName INT;
    SELECT @HasNullRoomName = COUNT(*) FROM [Room] WHERE Room_Name IS NULL;
    
    IF @HasNullRoomName = 0
    BEGIN
        ALTER TABLE [Room] ALTER COLUMN Room_Name NVARCHAR(10) NOT NULL;
        PRINT 'Set Room_Name to NOT NULL';
    END
    ELSE
    BEGIN
        PRINT 'WARNING: ' + CAST(@HasNullRoomName AS NVARCHAR(10)) + ' rooms have NULL Room_Name. Run insert_room.sql first.';
    END;
END
ELSE
BEGIN
    PRINT 'Room_Name is already NOT NULL or does not exist';
END;

PRINT '';
GO

-- ============================================
-- Step 6: Create unique constraint on (Building_Name, Room_Name)
-- ============================================
PRINT 'Step 6: Creating unique constraint...';

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = 'UQ_Room_Building_Name_Room_Name')
BEGIN
    IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Room') AND name = 'Building_Name')
       AND EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Room') AND name = 'Room_Name')
    BEGIN
        ALTER TABLE [Room]
        ADD CONSTRAINT UQ_Room_Building_Name_Room_Name
        UNIQUE (Building_Name, Room_Name);
        PRINT 'Created unique constraint UQ_Room_Building_Name_Room_Name';
    END;
END
ELSE
BEGIN
    PRINT 'Unique constraint already exists';
END;

PRINT '';
GO

-- ============================================
-- Step 7: Create primary key
-- ============================================
PRINT 'Step 7: Creating primary key...';

IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Room') AND name = 'Room_Name')
   AND EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Room') AND name = 'Building_Name')
BEGIN
    IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = 'PK_Room_Room_Name')
       AND NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = 'PK_Room_Building_Room')
    BEGIN
        DECLARE @TotalRooms INT;
        DECLARE @DistinctRoomNames INT;
        SELECT @TotalRooms = COUNT(*) FROM [Room];
        SELECT @DistinctRoomNames = COUNT(DISTINCT Room_Name) FROM [Room] WHERE Room_Name IS NOT NULL;
        
        IF @TotalRooms = @DistinctRoomNames AND @TotalRooms > 0
        BEGIN
            ALTER TABLE [Room]
            ADD CONSTRAINT PK_Room_Room_Name
            PRIMARY KEY (Room_Name);
            PRINT 'Created PK on Room_Name';
        END
        ELSE
        BEGIN
            ALTER TABLE [Room]
            ADD CONSTRAINT PK_Room_Building_Room
            PRIMARY KEY (Building_Name, Room_Name);
            PRINT 'Created composite PK on (Building_Name, Room_Name)';
        END;
    END
    ELSE
    BEGIN
        PRINT 'Primary key already exists';
    END;
END
ELSE
BEGIN
    PRINT 'Columns do not exist. Cannot create PK.';
END;

PRINT '';
GO

-- ============================================
-- Step 8: Ensure Building table has PK or Unique on Building_Name
-- ============================================
PRINT 'Step 8: Checking Building table constraints...';

-- Check if Building has PK on Building_Name
IF NOT EXISTS (
    SELECT 1 FROM sys.key_constraints kc
    INNER JOIN sys.index_columns ic ON kc.parent_object_id = ic.object_id AND kc.unique_index_id = ic.index_id
    INNER JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
    WHERE kc.parent_object_id = OBJECT_ID('Building')
      AND kc.type = 'PK'
      AND c.name = 'Building_Name'
)
BEGIN
    -- Check if Building has Unique constraint on Building_Name
    IF NOT EXISTS (
        SELECT 1 FROM sys.key_constraints kc
        INNER JOIN sys.index_columns ic ON kc.parent_object_id = ic.object_id AND kc.unique_index_id = ic.index_id
        INNER JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
        WHERE kc.parent_object_id = OBJECT_ID('Building')
          AND kc.type = 'UQ'
          AND c.name = 'Building_Name'
    )
    BEGIN
        -- Create PK on Building_Name if Building table exists
        IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'Building')
        BEGIN
            -- Drop existing PK if exists (might be on Building_ID)
            DECLARE @ExistingPKName NVARCHAR(128);
            SELECT TOP 1 @ExistingPKName = name 
            FROM sys.key_constraints 
            WHERE parent_object_id = OBJECT_ID('Building') AND type = 'PK';
            
            IF @ExistingPKName IS NOT NULL
            BEGIN
                DECLARE @SQL NVARCHAR(MAX) = 'ALTER TABLE [Building] DROP CONSTRAINT [' + @ExistingPKName + '];';
                EXEC sp_executesql @SQL;
                PRINT 'Dropped existing PK on Building';
            END;
            
            -- Create PK on Building_Name
            ALTER TABLE [Building]
            ADD CONSTRAINT PK_Building PRIMARY KEY (Building_Name);
            PRINT 'Created PK on Building(Building_Name)';
        END;
    END
    ELSE
    BEGIN
        PRINT 'Building already has Unique constraint on Building_Name';
    END;
END
ELSE
BEGIN
    PRINT 'Building already has PK on Building_Name';
END;

PRINT '';
GO

-- ============================================
-- Step 9: Create foreign key from Building_Name to Building(Building_Name)
-- ============================================
PRINT 'Step 9: Creating foreign key...';

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_Room_Building_Name')
BEGIN
    IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Room') AND name = 'Building_Name')
    BEGIN
        ALTER TABLE [Room]
        ADD CONSTRAINT FK_Room_Building_Name
        FOREIGN KEY (Building_Name)
        REFERENCES [Building](Building_Name);
        PRINT 'Created FK_Room_Building_Name';
    END;
END
ELSE
BEGIN
    PRINT 'Foreign key already exists';
END;

PRINT '';
GO

-- ============================================
-- Step 10: Recreate FK constraints for Room_Equipment and takes_place
-- ============================================
PRINT 'Step 10: Recreating FK constraints...';


IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Room_Equipment') AND name = 'Building_Name')
   AND EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Room_Equipment') AND name = 'Room_Name')
BEGIN
    IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_Equipment_Room_Name')
    BEGIN
        ALTER TABLE [Room_Equipment]
        ADD CONSTRAINT FK_Equipment_Room_Name
        FOREIGN KEY (Building_Name, Room_Name)
        REFERENCES [Room](Building_Name, Room_Name);
        PRINT 'Created FK_Equipment_Room_Name';
    END;
END;

IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('takes_place') AND name = 'Building_Name')
   AND EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('takes_place') AND name = 'Room_Name')
BEGIN
    IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_Place_Room_Name')
    BEGIN
        ALTER TABLE [takes_place]
        ADD CONSTRAINT FK_Place_Room_Name
        FOREIGN KEY (Building_Name, Room_Name)
        REFERENCES [Room](Building_Name, Room_Name);
        PRINT 'Created FK_Place_Room_Name';
    END;
END;

PRINT '';
GO

-- ============================================
-- Summary
-- ============================================
PRINT '========================================';
PRINT 'Summary';
PRINT '========================================';

DECLARE @RoomCount INT;
SELECT @RoomCount = COUNT(*) FROM [Room];
PRINT 'Total rooms: ' + CAST(@RoomCount AS NVARCHAR(10));

IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Room') AND name = 'Building_Name')
BEGIN
    DECLARE @BuildingNameCount INT;
    SELECT @BuildingNameCount = COUNT(*) FROM [Room] WHERE Building_Name IS NOT NULL;
    PRINT 'Rooms with Building_Name: ' + CAST(@BuildingNameCount AS NVARCHAR(10));
END;

IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Room') AND name = 'Room_Name')
BEGIN
    DECLARE @RoomNameCount INT;
    SELECT @RoomNameCount = COUNT(*) FROM [Room] WHERE Room_Name IS NOT NULL;
    PRINT 'Rooms with Room_Name: ' + CAST(@RoomNameCount AS NVARCHAR(10));
END;

PRINT '';
PRINT 'NOTE: Run insert_room.sql to populate Building_Name and Room_Name';
PRINT '========================================';
GO
