USE [lms_system];
GO

-- ============================================
-- Script: Reset Room_ID identity to 0->n
-- This script resets the Room_ID identity column starting from 0
-- ============================================

-- ============================================
-- Step 1: Delete data from referencing tables first
-- ============================================

-- Delete from Room_Equipment (references Room)
DELETE FROM [Room_Equipment];
PRINT 'Deleted data from Room_Equipment table';
GO

-- Delete from Takes_Place (references Room)
DELETE FROM [Takes_Place];
PRINT 'Deleted data from Takes_Place table';
GO

-- ============================================
-- Step 2: Store Room data temporarily
-- ============================================

-- Create temporary table to store Room data
IF OBJECT_ID('tempdb..#RoomBackup') IS NOT NULL
    DROP TABLE #RoomBackup;

CREATE TABLE #RoomBackup (
    Building_Name NVARCHAR(10),
    Room_Name NVARCHAR(10),
    Capacity INT
);

-- Backup Room data
INSERT INTO #RoomBackup (Building_Name, Room_Name, Capacity)
SELECT Building_Name, Room_Name, Capacity
FROM [Room];

DECLARE @RowCount INT;
SELECT @RowCount = COUNT(*) FROM #RoomBackup;
PRINT 'Backed up ' + CAST(@RowCount AS NVARCHAR(10)) + ' rooms';
GO

-- ============================================
-- Step 3: Delete all rooms
-- ============================================

DELETE FROM [Room];
PRINT 'Deleted all rooms from Room table';
GO

-- ============================================
-- Step 4: Reset Room_ID identity to 0
-- ============================================

DBCC CHECKIDENT ('[Room]', RESEED, -1);
PRINT 'Reset Room_ID identity to start from 0';
GO

-- ============================================
-- Step 5: Re-insert Room data (Room_ID will be auto-generated: 0, 1, 2, ...)
-- ============================================

INSERT INTO [Room] (Building_Name, Room_Name, Capacity)
SELECT Building_Name, Room_Name, Capacity
FROM #RoomBackup
ORDER BY Building_Name, Room_Name;

DECLARE @InsertedCount INT;
SELECT @InsertedCount = @@ROWCOUNT;
PRINT 'Re-inserted ' + CAST(@InsertedCount AS NVARCHAR(10)) + ' rooms';
GO

-- ============================================
-- Step 6: Clean up temporary table
-- ============================================

IF OBJECT_ID('tempdb..#RoomBackup') IS NOT NULL
    DROP TABLE #RoomBackup;
GO

-- ============================================
-- Step 7: Verify results
-- ============================================

PRINT '';
PRINT '========================================';
PRINT 'Room_ID identity reset completed successfully!';
PRINT '========================================';
PRINT '';

-- Show current identity value
DECLARE @CurrentIdentity INT;
SELECT @CurrentIdentity = IDENT_CURRENT('Room');
PRINT 'Current Room_ID identity value: ' + CAST(@CurrentIdentity AS NVARCHAR(10));
PRINT '';

-- Show sample rooms with their Room_ID
SELECT TOP 10
    Room_ID,
    Building_Name,
    Room_Name,
    Capacity
FROM [Room]
ORDER BY Room_ID;

DECLARE @totalrooms int
select @totalrooms = count(*) from [Room]

PRINT '';
PRINT 'Total rooms: ' + CAST(@totalrooms AS NVARCHAR(10));
GO

