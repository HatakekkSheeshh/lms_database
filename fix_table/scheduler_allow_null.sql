USE [lms_system];
GO

IF EXISTS (SELECT 1 FROM sys.check_constraints 
           WHERE name = 'CK_Scheduler_Period' 
           AND parent_object_id = OBJECT_ID('Scheduler'))
BEGIN
    ALTER TABLE [Scheduler]
    DROP CONSTRAINT CK_Scheduler_Period;
    PRINT 'Dropped CK_Scheduler_Period constraint';
END
GO

IF EXISTS (SELECT 1 FROM sys.check_constraints 
           WHERE name = 'CK_Scheduler_Period_Range' 
           AND parent_object_id = OBJECT_ID('Scheduler'))
BEGIN
    ALTER TABLE [Scheduler]
    DROP CONSTRAINT CK_Scheduler_Period_Range;
    PRINT 'Dropped CK_Scheduler_Period_Range constraint';
END
GO

DECLARE @sql NVARCHAR(MAX) = '';
SELECT @sql = @sql + 'ALTER TABLE [Scheduler] DROP CONSTRAINT ' + QUOTENAME(name) + ';' + CHAR(10)
FROM sys.check_constraints
WHERE parent_object_id = OBJECT_ID('Scheduler')
AND (
    name LIKE '%Day_of_Week%' 
    OR name LIKE '%Start_Period%' 
    OR name LIKE '%End_Period%'
    OR definition LIKE '%Day_of_Week%'
    OR definition LIKE '%Start_Period%'
    OR definition LIKE '%End_Period%'
);

IF LEN(@sql) > 0
BEGIN
    EXEC sp_executesql @sql;
    PRINT 'Dropped column-level CHECK constraints';
END
GO

-- Alter Day_of_Week to allow NULL
IF EXISTS (SELECT 1 FROM sys.columns 
           WHERE object_id = OBJECT_ID('Scheduler') 
           AND name = 'Day_of_Week' 
           AND is_nullable = 0)
BEGIN
    ALTER TABLE [Scheduler]
    ALTER COLUMN Day_of_Week INT NULL;
    PRINT 'Altered Day_of_Week to allow NULL';
END
ELSE
BEGIN
    PRINT 'Day_of_Week already allows NULL';
END
GO

-- Alter Start_Period to allow NULL
IF EXISTS (SELECT 1 FROM sys.columns 
           WHERE object_id = OBJECT_ID('Scheduler') 
           AND name = 'Start_Period' 
           AND is_nullable = 0)
BEGIN
    ALTER TABLE [Scheduler]
    ALTER COLUMN Start_Period INT NULL;
    PRINT 'Altered Start_Period to allow NULL';
END
ELSE
BEGIN
    PRINT 'Start_Period already allows NULL';
END
GO

-- Alter End_Period to allow NULL
IF EXISTS (SELECT 1 FROM sys.columns 
           WHERE object_id = OBJECT_ID('Scheduler') 
           AND name = 'End_Period' 
           AND is_nullable = 0)
BEGIN
    ALTER TABLE [Scheduler]
    ALTER COLUMN End_Period INT NULL;
    PRINT 'Altered End_Period to allow NULL';
END
ELSE
BEGIN
    PRINT 'End_Period already allows NULL';
END
GO

-- Recreate CK_Scheduler_Period (only check if both are NOT NULL)
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints 
               WHERE name = 'CK_Scheduler_Period' 
               AND parent_object_id = OBJECT_ID('Scheduler'))
BEGIN
    ALTER TABLE [Scheduler]
    ADD CONSTRAINT CK_Scheduler_Period 
        CHECK (Start_Period IS NULL OR End_Period IS NULL OR Start_Period <= End_Period);
    PRINT 'Recreated CK_Scheduler_Period constraint (with NULL handling)';
END
GO

-- Recreate CK_Scheduler_Period_Range (only check if both are NOT NULL)
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints 
               WHERE name = 'CK_Scheduler_Period_Range' 
               AND parent_object_id = OBJECT_ID('Scheduler'))
BEGIN
    ALTER TABLE [Scheduler]
    ADD CONSTRAINT CK_Scheduler_Period_Range 
        CHECK (
            Start_Period IS NULL 
            OR End_Period IS NULL 
            OR (End_Period - Start_Period + 1 BETWEEN 2 AND 3)
        );
    PRINT 'Recreated CK_Scheduler_Period_Range constraint (with NULL handling)';
END
GO

-- Recreate column-level CHECK constraints with NULL handling
-- Day_of_Week: 1-6 or NULL
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints 
               WHERE parent_object_id = OBJECT_ID('Scheduler')
               AND definition LIKE '%Day_of_Week%'
               AND definition LIKE '%BETWEEN 1 AND 6%')
BEGIN
    ALTER TABLE [Scheduler]
    ADD CONSTRAINT CK_Scheduler_Day_of_Week 
        CHECK (Day_of_Week IS NULL OR (Day_of_Week BETWEEN 1 AND 6));
    PRINT 'Recreated CK_Scheduler_Day_of_Week constraint (with NULL handling)';
END
GO

-- Start_Period: 1-13 or NULL
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints 
               WHERE parent_object_id = OBJECT_ID('Scheduler')
               AND definition LIKE '%Start_Period%'
               AND definition LIKE '%BETWEEN 1 AND 13%')
BEGIN
    ALTER TABLE [Scheduler]
    ADD CONSTRAINT CK_Scheduler_Start_Period 
        CHECK (Start_Period IS NULL OR (Start_Period BETWEEN 1 AND 13));
    PRINT 'Recreated CK_Scheduler_Start_Period constraint (with NULL handling)';
END
GO

-- End_Period: 1-13 or NULL
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints 
               WHERE parent_object_id = OBJECT_ID('Scheduler')
               AND definition LIKE '%End_Period%'
               AND definition LIKE '%BETWEEN 1 AND 13%')
BEGIN
    ALTER TABLE [Scheduler]
    ADD CONSTRAINT CK_Scheduler_End_Period 
        CHECK (End_Period IS NULL OR (End_Period BETWEEN 1 AND 13));
    PRINT 'Recreated CK_Scheduler_End_Period constraint (with NULL handling)';
END
GO

PRINT '';
PRINT '========================================';
PRINT 'Successfully updated Scheduler table:';
PRINT '  - Day_of_Week, Start_Period, End_Period now allow NULL';
PRINT '  - CHECK constraints updated to handle NULL values';
PRINT '========================================';
GO

