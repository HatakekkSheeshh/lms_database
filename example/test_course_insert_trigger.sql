USE [lms_system];
GO

PRINT '========================================';
PRINT 'Testing Course Insert Trigger';
PRINT 'Course: Game Programming (CO3045)';
PRINT 'Credits: 3';
PRINT 'Category: Major Course';
PRINT '========================================';
PRINT '';

PRINT 'Step 1: Checking if course CO3045 already exists...';
IF EXISTS (SELECT 1 FROM [Course] WHERE Course_ID = 'CO3045')
BEGIN
    PRINT '  Course CO3045 already exists. Deleting it first...';
    -- Delete related records first (due to foreign keys)
    DELETE FROM [Scheduler] WHERE Course_ID = 'CO3045';
    DELETE FROM [Section] WHERE Course_ID = 'CO3045';
    DELETE FROM [Course] WHERE Course_ID = 'CO3045';
    PRINT '  Deleted existing course and related records.';
END
ELSE
BEGIN
    PRINT '  Course CO3045 does not exist. Proceeding with insert.';
END
PRINT '';

PRINT 'Step 2: Current state before insert:';
PRINT '  Sections for CO3045:';
SELECT COUNT(*) AS Section_Count
FROM [Section]
WHERE Course_ID = 'CO3045';
PRINT '  Scheduler records for CO3045:';
SELECT COUNT(*) AS Scheduler_Count
FROM [Scheduler]
WHERE Course_ID = 'CO3045';
PRINT '';

-- Step 3: Insert new course
PRINT 'Step 3: Inserting new course CO3045 (Game Programming)...';
INSERT INTO [Course] (Course_ID, [Name], Credit)
VALUES ('CO3045', 'Game Programming', 3);
PRINT '  Course inserted successfully!';
PRINT '';

-- Step 4: Verify trigger execution
PRINT 'Step 4: Verifying trigger execution...';
PRINT '';

-- Check if sections were created
PRINT '  Sections created:';
SELECT 
    Section_ID,
    Course_ID,
    Semester
FROM [Section]
WHERE Course_ID = 'CO3045'
ORDER BY Section_ID;
PRINT '';

DECLARE @SectionCount INT;
SELECT @SectionCount = COUNT(*)
FROM [Section]
WHERE Course_ID = 'CO3045';

IF @SectionCount = 5
BEGIN
    PRINT '  ✓ SUCCESS: 5 sections created as expected (CC01, CC02, L01, L02, KSTN1)';
END
ELSE
BEGIN
    PRINT '  ✗ ERROR: Expected 5 sections, but found ' + CAST(@SectionCount AS NVARCHAR(10));
END
PRINT '';

-- Check if Scheduler records were created
PRINT '  Scheduler records created:';
SELECT 
    Section_ID,
    Course_ID,
    Semester,
    Day_of_Week,
    Start_Period,
    End_Period
FROM [Scheduler]
WHERE Course_ID = 'CO3045'
ORDER BY Section_ID;
PRINT '';

DECLARE @SchedulerCount INT;
SELECT @SchedulerCount = COUNT(*)
FROM [Scheduler]
WHERE Course_ID = 'CO3045';

IF @SchedulerCount = 5
BEGIN
    PRINT '  ✓ SUCCESS: 5 Scheduler records created as expected';
END
ELSE
BEGIN
    PRINT '  ✗ ERROR: Expected 5 Scheduler records, but found ' + CAST(@SchedulerCount AS NVARCHAR(10));
END
PRINT '';

-- Check if Day_of_Week, Start_Period, End_Period are NULL
DECLARE @NullCount INT;
SELECT @NullCount = COUNT(*)
FROM [Scheduler]
WHERE Course_ID = 'CO3045'
AND Day_of_Week IS NULL
AND Start_Period IS NULL
AND End_Period IS NULL;

IF @NullCount = 5
BEGIN
    PRINT '  ✓ SUCCESS: All Scheduler records have NULL values for Day_of_Week, Start_Period, End_Period';
    PRINT '            (These can be updated later)';
END
ELSE
BEGIN
    PRINT '  ⚠ WARNING: Some Scheduler records have non-NULL values';
END
PRINT '';

-- Step 5: Display summary
PRINT 'Step 5: Summary:';
PRINT '========================================';
PRINT 'Course Information:';
SELECT 
    Course_ID,
    [Name] AS Course_Name,
    Credit
FROM [Course]
WHERE Course_ID = 'CO3045';
PRINT '';

PRINT 'Sections Created:';
SELECT 
    Section_ID,
    Course_ID,
    Semester
FROM [Section]
WHERE Course_ID = 'CO3045'
ORDER BY Section_ID;
PRINT '';

PRINT 'Scheduler Records Created:';
SELECT 
    Section_ID,
    Course_ID,
    Semester,
    CASE 
        WHEN Day_of_Week IS NULL THEN 'NULL'
        ELSE CAST(Day_of_Week AS NVARCHAR(10))
    END AS Day_of_Week,
    CASE 
        WHEN Start_Period IS NULL THEN 'NULL'
        ELSE CAST(Start_Period AS NVARCHAR(10))
    END AS Start_Period,
    CASE 
        WHEN End_Period IS NULL THEN 'NULL'
        ELSE CAST(End_Period AS NVARCHAR(10))
    END AS End_Period
FROM [Scheduler]
WHERE Course_ID = 'CO3045'
ORDER BY Section_ID;
PRINT '';


