USE [lms_system];
GO

-- ============================================
-- Script to drop columns: building_id, room_id, room_name, building_name
-- and all related constraints/FK
-- ============================================

PRINT '========================================';
PRINT 'Starting to drop columns: building_id, room_id, room_name, building_name';
PRINT '========================================';
PRINT '';

-- ============================================
-- Step 1: Drop Foreign Key Constraints
-- ============================================
PRINT 'Step 1: Dropping Foreign Key Constraints...';

DECLARE @FKName NVARCHAR(128);
DECLARE @TableName NVARCHAR(128);
DECLARE @SQL NVARCHAR(MAX);

-- Drop FKs that reference building_id, room_id, room_name, or building_name
DECLARE fk_cursor CURSOR FOR
SELECT 
    fk.name AS FKName,
    OBJECT_NAME(fk.parent_object_id) AS TableName
FROM sys.foreign_keys fk
INNER JOIN sys.foreign_key_columns fkc ON fk.object_id = fkc.constraint_object_id
INNER JOIN sys.columns c ON fkc.parent_object_id = c.object_id AND fkc.parent_column_id = c.column_id
WHERE c.name IN ('Building_ID', 'Room_ID', 'Room_Name', 'Building_Name')
   OR EXISTS (
       SELECT 1 
       FROM sys.columns c2 
       WHERE c2.object_id = fkc.referenced_object_id 
         AND c2.column_id = fkc.referenced_column_id
         AND c2.name IN ('Building_ID', 'Room_ID', 'Room_Name', 'Building_Name')
   );

OPEN fk_cursor;
FETCH NEXT FROM fk_cursor INTO @FKName, @TableName;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @SQL = 'ALTER TABLE [' + @TableName + '] DROP CONSTRAINT [' + @FKName + '];';
    BEGIN TRY
        EXEC sp_executesql @SQL;
        PRINT 'Dropped FK constraint: ' + @FKName + ' from table: ' + @TableName;
    END TRY
    BEGIN CATCH
        PRINT 'Error dropping FK ' + @FKName + ': ' + ERROR_MESSAGE();
    END CATCH;
    
    FETCH NEXT FROM fk_cursor INTO @FKName, @TableName;
END;

CLOSE fk_cursor;
DEALLOCATE fk_cursor;

PRINT '';

-- ============================================
-- Step 2: Drop Check Constraints
-- ============================================
PRINT 'Step 2: Dropping Check Constraints...';

DECLARE @CheckConstraintName NVARCHAR(128);

DECLARE check_cursor CURSOR FOR
SELECT 
    cc.name AS ConstraintName,
    OBJECT_NAME(cc.parent_object_id) AS TableName
FROM sys.check_constraints cc
INNER JOIN sys.columns c ON cc.parent_object_id = c.object_id
WHERE c.name IN ('Building_ID', 'Room_ID', 'Room_Name', 'Building_Name');

OPEN check_cursor;
FETCH NEXT FROM check_cursor INTO @CheckConstraintName, @TableName;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @SQL = 'ALTER TABLE [' + @TableName + '] DROP CONSTRAINT [' + @CheckConstraintName + '];';
    BEGIN TRY
        EXEC sp_executesql @SQL;
        PRINT 'Dropped Check constraint: ' + @CheckConstraintName + ' from table: ' + @TableName;
    END TRY
    BEGIN CATCH
        PRINT 'Error dropping Check constraint ' + @CheckConstraintName + ': ' + ERROR_MESSAGE();
    END CATCH;
    
    FETCH NEXT FROM check_cursor INTO @CheckConstraintName, @TableName;
END;

CLOSE check_cursor;
DEALLOCATE check_cursor;

PRINT '';

-- ============================================
-- Step 3: Drop Unique Constraints
-- ============================================
PRINT 'Step 3: Dropping Unique Constraints...';

DECLARE @UniqueConstraintName NVARCHAR(128);

DECLARE unique_cursor CURSOR FOR
SELECT DISTINCT
    kc.name AS ConstraintName,
    OBJECT_NAME(kc.parent_object_id) AS TableName
FROM sys.key_constraints kc
INNER JOIN sys.index_columns ic ON kc.parent_object_id = ic.object_id AND kc.unique_index_id = ic.index_id
INNER JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
WHERE kc.type = 'UQ'
  AND c.name IN ('Building_ID', 'Room_ID', 'Room_Name', 'Building_Name');

OPEN unique_cursor;
FETCH NEXT FROM unique_cursor INTO @UniqueConstraintName, @TableName;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @SQL = 'ALTER TABLE [' + @TableName + '] DROP CONSTRAINT [' + @UniqueConstraintName + '];';
    BEGIN TRY
        EXEC sp_executesql @SQL;
        PRINT 'Dropped Unique constraint: ' + @UniqueConstraintName + ' from table: ' + @TableName;
    END TRY
    BEGIN CATCH
        PRINT 'Error dropping Unique constraint ' + @UniqueConstraintName + ': ' + ERROR_MESSAGE();
    END CATCH;
    
    FETCH NEXT FROM unique_cursor INTO @UniqueConstraintName, @TableName;
END;

CLOSE unique_cursor;
DEALLOCATE unique_cursor;

PRINT '';

-- ============================================
-- Step 4: Drop Primary Key Constraints (if they include these columns)
-- ============================================
PRINT 'Step 4: Checking and dropping Primary Key Constraints if needed...';

DECLARE @PKName NVARCHAR(128);
DECLARE @PKColumns NVARCHAR(MAX);
DECLARE @HasTargetColumn BIT;

DECLARE pk_cursor CURSOR FOR
SELECT DISTINCT
    kc.name AS PKName,
    OBJECT_NAME(kc.parent_object_id) AS TableName
FROM sys.key_constraints kc
INNER JOIN sys.index_columns ic ON kc.parent_object_id = ic.object_id AND kc.unique_index_id = ic.index_id
INNER JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
WHERE kc.type = 'PK'
  AND c.name IN ('Building_ID', 'Room_ID', 'Room_Name', 'Building_Name');

OPEN pk_cursor;
FETCH NEXT FROM pk_cursor INTO @PKName, @TableName;

WHILE @@FETCH_STATUS = 0
BEGIN
    -- Check if PK has other columns besides the ones we want to drop
    SET @HasTargetColumn = 0;
    SELECT @HasTargetColumn = 1
    FROM sys.index_columns ic
    INNER JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
    WHERE ic.object_id = OBJECT_ID(@TableName)
      AND ic.index_id = (SELECT unique_index_id FROM sys.key_constraints WHERE name = @PKName AND parent_object_id = OBJECT_ID(@TableName))
      AND c.name NOT IN ('Building_ID', 'Room_ID', 'Room_Name', 'Building_Name');
    
    IF @HasTargetColumn = 0
    BEGIN
        -- PK only contains columns we want to drop, need to drop it
        SET @SQL = 'ALTER TABLE [' + @TableName + '] DROP CONSTRAINT [' + @PKName + '];';
        BEGIN TRY
            EXEC sp_executesql @SQL;
            PRINT 'Dropped PK constraint: ' + @PKName + ' from table: ' + @TableName;
        END TRY
        BEGIN CATCH
            PRINT 'Error dropping PK ' + @PKName + ': ' + ERROR_MESSAGE();
        END CATCH;
    END
    ELSE
    BEGIN
        PRINT 'WARNING: PK ' + @PKName + ' in table ' + @TableName + ' contains other columns. Manual review needed.';
    END;
    
    FETCH NEXT FROM pk_cursor INTO @PKName, @TableName;
END;

CLOSE pk_cursor;
DEALLOCATE pk_cursor;

PRINT '';

-- ============================================
-- Step 5: Drop Default Constraints
-- ============================================
PRINT 'Step 5: Dropping Default Constraints...';

DECLARE @DefaultConstraintName NVARCHAR(128);

DECLARE default_cursor CURSOR FOR
SELECT 
    dc.name AS ConstraintName,
    OBJECT_NAME(dc.parent_object_id) AS TableName
FROM sys.default_constraints dc
INNER JOIN sys.columns c ON dc.parent_object_id = c.object_id AND dc.parent_column_id = c.column_id
WHERE c.name IN ('Building_ID', 'Room_ID', 'Room_Name', 'Building_Name');

OPEN default_cursor;
FETCH NEXT FROM default_cursor INTO @DefaultConstraintName, @TableName;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @SQL = 'ALTER TABLE [' + @TableName + '] DROP CONSTRAINT [' + @DefaultConstraintName + '];';
    BEGIN TRY
        EXEC sp_executesql @SQL;
        PRINT 'Dropped Default constraint: ' + @DefaultConstraintName + ' from table: ' + @TableName;
    END TRY
    BEGIN CATCH
        PRINT 'Error dropping Default constraint ' + @DefaultConstraintName + ': ' + ERROR_MESSAGE();
    END CATCH;
    
    FETCH NEXT FROM default_cursor INTO @DefaultConstraintName, @TableName;
END;

CLOSE default_cursor;
DEALLOCATE default_cursor;

PRINT '';

-- ============================================
-- Step 6: Drop the Columns
-- ============================================
PRINT 'Step 6: Dropping Columns...';

DECLARE @ColumnName NVARCHAR(128);

DECLARE column_cursor CURSOR FOR
SELECT DISTINCT
    c.name AS ColumnName,
    OBJECT_NAME(c.object_id) AS TableName
FROM sys.columns c
WHERE c.name IN ('Building_ID', 'Room_ID', 'Room_Name', 'Building_Name')
  AND OBJECTPROPERTY(c.object_id, 'IsUserTable') = 1;

OPEN column_cursor;
FETCH NEXT FROM column_cursor INTO @ColumnName, @TableName;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @SQL = 'ALTER TABLE [' + @TableName + '] DROP COLUMN [' + @ColumnName + '];';
    BEGIN TRY
        EXEC sp_executesql @SQL;
        PRINT 'Dropped column: ' + @ColumnName + ' from table: ' + @TableName;
    END TRY
    BEGIN CATCH
        PRINT 'Error dropping column ' + @ColumnName + ' from ' + @TableName + ': ' + ERROR_MESSAGE();
    END CATCH;
    
    FETCH NEXT FROM column_cursor INTO @ColumnName, @TableName;
END;

CLOSE column_cursor;
DEALLOCATE column_cursor;

PRINT '';
PRINT '========================================';
PRINT 'Completed dropping columns and constraints';
PRINT '========================================';
GO

