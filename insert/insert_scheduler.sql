USE [lms_system];
GO

-- ============================================
-- Script to insert scheduler for each (section_id, course_id, semester)
-- 
-- Rules:
-- 1. Each course <= 3 credits: 2 periods
-- 2. Each course >= 4 credits: 3 periods
-- 3. Random 1 day in week (Monday-Saturday, 1-6)
-- 4. No overlap if same student learns both courses
-- 5. Can overlap if no student learns both courses
-- ============================================

DELETE FROM [Scheduler];
GO

PRINT '========================================';
PRINT 'Starting to create scheduler...';
PRINT '========================================';
PRINT '';

-- ============================================
-- Step 1: Get all sections with their credits
-- ============================================
IF OBJECT_ID('tempdb..#SectionCredits') IS NOT NULL DROP TABLE #SectionCredits;
SELECT 
    s.Section_ID,
    s.Course_ID,
    s.Semester,
    c.Credit,
    CASE 
        WHEN c.Credit <= 3 THEN 2  -- 2 periods for <= 3 credits
        ELSE 3                      -- 3 periods for >= 4 credits
    END AS Period_Count
INTO #SectionCredits
FROM [Section] s
INNER JOIN [Course] c ON s.Course_ID = c.Course_ID;

PRINT 'Found ' + CAST(@@ROWCOUNT AS NVARCHAR(10)) + ' sections to schedule';
PRINT '';

-- ============================================
-- Step 2: Create conflict matrix (which sections share students)
-- Store both directions for easier lookup
-- ============================================
IF OBJECT_ID('tempdb..#SectionConflicts') IS NOT NULL DROP TABLE #SectionConflicts;
SELECT DISTINCT
    a1.Section_ID AS Section1,
    a1.Course_ID AS Course1,
    a1.Semester AS Semester1,
    a2.Section_ID AS Section2,
    a2.Course_ID AS Course2,
    a2.Semester AS Semester2
INTO #SectionConflicts
FROM [Assessment] a1
INNER JOIN [Assessment] a2 
    ON a1.University_ID = a2.University_ID
    AND a1.Semester = a2.Semester
    AND (a1.Section_ID <> a2.Section_ID OR a1.Course_ID <> a2.Course_ID)
WHERE a1.Section_ID < a2.Section_ID 
   OR (a1.Section_ID = a2.Section_ID AND a1.Course_ID < a2.Course_ID);

-- Add reverse direction for easier lookup
INSERT INTO #SectionConflicts (Section1, Course1, Semester1, Section2, Course2, Semester2)
SELECT Section2, Course2, Semester2, Section1, Course1, Semester1
FROM #SectionConflicts;

PRINT 'Found ' + CAST(@@ROWCOUNT AS NVARCHAR(10)) + ' section pairs with shared students';
PRINT '';

-- ============================================
-- Step 3: Assign schedules avoiding conflicts
-- ============================================
DECLARE @Section_ID NVARCHAR(10);
DECLARE @Course_ID NVARCHAR(15);
DECLARE @Semester NVARCHAR(10);
DECLARE @Credit INT;
DECLARE @Period_Count INT;
DECLARE @Day_of_Week INT;
DECLARE @Start_Period INT;
DECLARE @End_Period INT;
DECLARE @ConflictFound BIT;
DECLARE @Attempts INT;
DECLARE @MaxAttempts INT = 100;

DECLARE section_cursor CURSOR FOR
SELECT Section_ID, Course_ID, Semester, Credit, Period_Count
FROM #SectionCredits
ORDER BY NEWID(); -- Random order

OPEN section_cursor;
FETCH NEXT FROM section_cursor INTO @Section_ID, @Course_ID, @Semester, @Credit, @Period_Count;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @ConflictFound = 1;
    SET @Attempts = 0;
    
    -- Try to find a valid schedule
    WHILE @ConflictFound = 1 AND @Attempts < @MaxAttempts
    BEGIN
        -- Random day (1-6: Monday to Saturday)
        SET @Day_of_Week = 1 + (ABS(CHECKSUM(NEWID())) % 6);
        
        -- Random start period (must allow for Period_Count periods)
        -- Max start period = 13 - Period_Count + 1
        SET @Start_Period = 1 + (ABS(CHECKSUM(NEWID())) % (13 - @Period_Count + 1));
        SET @End_Period = @Start_Period + @Period_Count - 1;
        
        -- Check for conflicts with already scheduled sections that share students
        SET @ConflictFound = 0;
        
        SELECT @ConflictFound = 1
        FROM [Scheduler] sch
        WHERE EXISTS (
            SELECT 1 
            FROM #SectionConflicts conf
            WHERE conf.Section1 = @Section_ID 
              AND conf.Course1 = @Course_ID 
              AND conf.Semester1 = @Semester
              AND conf.Section2 = sch.Section_ID 
              AND conf.Course2 = sch.Course_ID 
              AND conf.Semester2 = sch.Semester
        )
        AND sch.Day_of_Week = @Day_of_Week
        AND NOT (
            -- No overlap: either this ends before that starts, or this starts after that ends
            @End_Period < sch.Start_Period OR @Start_Period > sch.End_Period
        );
        
        SET @Attempts = @Attempts + 1;
    END;
    
    -- If found valid schedule, insert it
    IF @ConflictFound = 0
    BEGIN
        INSERT INTO [Scheduler] (Section_ID, Course_ID, Semester, Day_of_Week, Start_Period, End_Period)
        VALUES (@Section_ID, @Course_ID, @Semester, @Day_of_Week, @Start_Period, @End_Period);
    END
    ELSE
    BEGIN
        -- If couldn't find non-conflicting schedule, assign anyway (will have conflict)
        -- This should be rare, but we need to assign something
        SET @Day_of_Week = 1 + (ABS(CHECKSUM(NEWID())) % 6);
        SET @Start_Period = 1 + (ABS(CHECKSUM(NEWID())) % (13 - @Period_Count + 1));
        SET @End_Period = @Start_Period + @Period_Count - 1;
        
        INSERT INTO [Scheduler] (Section_ID, Course_ID, Semester, Day_of_Week, Start_Period, End_Period)
        VALUES (@Section_ID, @Course_ID, @Semester, @Day_of_Week, @Start_Period, @End_Period);
        
        PRINT 'WARNING: Could not avoid conflict for Section: ' + @Section_ID + ', Course: ' + @Course_ID + ', Semester: ' + @Semester;
    END;
    
    FETCH NEXT FROM section_cursor INTO @Section_ID, @Course_ID, @Semester, @Credit, @Period_Count;
END;

CLOSE section_cursor;
DEALLOCATE section_cursor;

DROP TABLE #SectionCredits;
DROP TABLE #SectionConflicts;

-- ============================================
-- Step 4: Display statistics
-- ============================================
PRINT '';
PRINT '========================================';
PRINT 'Scheduler creation completed';
PRINT '========================================';
PRINT '';

DECLARE @TotalScheduled INT;
SELECT @TotalScheduled = COUNT(*) FROM [Scheduler];
PRINT 'Total sections scheduled: ' + CAST(@TotalScheduled AS NVARCHAR(10));
PRINT '';

-- Check for conflicts
PRINT '--- Conflict Check ---';
SELECT 
    COUNT(*) AS Conflicting_Pairs
FROM [Scheduler] s1
INNER JOIN [Scheduler] s2 ON s1.Section_ID <> s2.Section_ID OR s1.Course_ID <> s2.Course_ID OR s1.Semester <> s2.Semester
INNER JOIN [Assessment] a1 ON s1.Section_ID = a1.Section_ID AND s1.Course_ID = a1.Course_ID AND s1.Semester = a1.Semester
INNER JOIN [Assessment] a2 ON s2.Section_ID = a2.Section_ID AND s2.Course_ID = a2.Course_ID AND s2.Semester = a2.Semester
WHERE a1.University_ID = a2.University_ID
  AND s1.Day_of_Week = s2.Day_of_Week
  AND NOT (s1.End_Period < s2.Start_Period OR s1.Start_Period > s2.End_Period);

PRINT '';
PRINT '--- Schedule Distribution by Day ---';
SELECT 
    Day_of_Week,
    CASE Day_of_Week
        WHEN 1 THEN 'Monday'
        WHEN 2 THEN 'Tuesday'
        WHEN 3 THEN 'Wednesday'
        WHEN 4 THEN 'Thursday'
        WHEN 5 THEN 'Friday'
        WHEN 6 THEN 'Saturday'
    END AS Day_Name,
    COUNT(*) AS Section_Count
FROM [Scheduler]
GROUP BY Day_of_Week
ORDER BY Day_of_Week;

PRINT '';
PRINT '--- Schedule Distribution by Period ---';
SELECT 
    Start_Period,
    End_Period,
    COUNT(*) AS Section_Count
FROM [Scheduler]
GROUP BY Start_Period, End_Period
ORDER BY Start_Period, End_Period;

PRINT '';
PRINT '========================================';
GO

