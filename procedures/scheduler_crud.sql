USE [lms_system];
GO

-- ============================================
-- Scheduler CRUD Procedures
-- ============================================

-- ============================================
-- CREATE: Insert new scheduler
-- ============================================
IF OBJECT_ID('sp_CreateScheduler', 'P') IS NOT NULL
    DROP PROCEDURE sp_CreateScheduler;
GO

CREATE PROCEDURE sp_CreateScheduler
    @Section_ID NVARCHAR(10),
    @Course_ID NVARCHAR(15),
    @Semester NVARCHAR(10),
    @Day_of_Week INT,
    @Start_Period INT,
    @End_Period INT,
    @Result NVARCHAR(MAX) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- Validate inputs
        IF @Day_of_Week NOT BETWEEN 1 AND 6
        BEGIN
            SET @Result = 'ERROR: Day_of_Week must be between 1 (Monday) and 6 (Saturday)';
            RETURN -1;
        END;
        
        IF @Start_Period NOT BETWEEN 1 AND 13 OR @End_Period NOT BETWEEN 1 AND 13
        BEGIN
            SET @Result = 'ERROR: Periods must be between 1 and 13';
            RETURN -1;
        END;
        
        IF @Start_Period > @End_Period
        BEGIN
            SET @Result = 'ERROR: Start_Period cannot be greater than End_Period';
            RETURN -1;
        END;
        
        DECLARE @PeriodCount INT = @End_Period - @Start_Period + 1;
        IF @PeriodCount NOT BETWEEN 2 AND 3
        BEGIN
            SET @Result = 'ERROR: Period count must be between 2 and 3 (End_Period - Start_Period + 1)';
            RETURN -1;
        END;
        
        -- Check if section exists
        IF NOT EXISTS (SELECT 1 FROM [Section] WHERE Section_ID = @Section_ID AND Course_ID = @Course_ID AND Semester = @Semester)
        BEGIN
            SET @Result = 'ERROR: Section does not exist';
            RETURN -1;
        END;
        
        -- Check if scheduler already exists
        IF EXISTS (SELECT 1 FROM [Scheduler] WHERE Section_ID = @Section_ID AND Course_ID = @Course_ID AND Semester = @Semester)
        BEGIN
            SET @Result = 'ERROR: Scheduler already exists for this section. Use UPDATE instead.';
            RETURN -1;
        END;
        
        -- Insert scheduler
        INSERT INTO [Scheduler] (Section_ID, Course_ID, Semester, Day_of_Week, Start_Period, End_Period)
        VALUES (@Section_ID, @Course_ID, @Semester, @Day_of_Week, @Start_Period, @End_Period);
        
        SET @Result = 'SUCCESS: Scheduler created successfully';
        RETURN 0;
    END TRY
    BEGIN CATCH
        SET @Result = 'ERROR: ' + ERROR_MESSAGE();
        RETURN -1;
    END CATCH;
END;
GO

-- ============================================
-- READ: Get scheduler by section
-- ============================================
IF OBJECT_ID('sp_GetScheduler', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetScheduler;
GO

CREATE PROCEDURE sp_GetScheduler
    @Section_ID NVARCHAR(10) = NULL,
    @Course_ID NVARCHAR(15) = NULL,
    @Semester NVARCHAR(10) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        s.Section_ID,
        s.Course_ID,
        s.Semester,
        s.Day_of_Week,
        CASE s.Day_of_Week
            WHEN 1 THEN 'Monday'
            WHEN 2 THEN 'Tuesday'
            WHEN 3 THEN 'Wednesday'
            WHEN 4 THEN 'Thursday'
            WHEN 5 THEN 'Friday'
            WHEN 6 THEN 'Saturday'
        END AS Day_Name,
        s.Start_Period,
        s.End_Period,
        CASE s.Start_Period
            WHEN 1 THEN '6 AM'
            WHEN 2 THEN '7 AM'
            WHEN 3 THEN '8 AM'
            WHEN 4 THEN '9 AM'
            WHEN 5 THEN '10 AM'
            WHEN 6 THEN '11 AM'
            WHEN 7 THEN '12 PM'
            WHEN 8 THEN '1 PM'
            WHEN 9 THEN '2 PM'
            WHEN 10 THEN '3 PM'
            WHEN 11 THEN '4 PM'
            WHEN 12 THEN '5 PM'
            WHEN 13 THEN '6 PM'
        END AS Start_Time,
        CASE s.End_Period
            WHEN 1 THEN '6 AM'
            WHEN 2 THEN '7 AM'
            WHEN 3 THEN '8 AM'
            WHEN 4 THEN '9 AM'
            WHEN 5 THEN '10 AM'
            WHEN 6 THEN '11 AM'
            WHEN 7 THEN '12 PM'
            WHEN 8 THEN '1 PM'
            WHEN 9 THEN '2 PM'
            WHEN 10 THEN '3 PM'
            WHEN 11 THEN '4 PM'
            WHEN 12 THEN '5 PM'
            WHEN 13 THEN '6 PM'
        END AS End_Time,
        (s.End_Period - s.Start_Period + 1) AS Period_Count,
        c.[Name] AS Course_Name,
        c.Credit
    FROM [Scheduler] s
    INNER JOIN [Course] c ON s.Course_ID = c.Course_ID
    WHERE (@Section_ID IS NULL OR s.Section_ID = @Section_ID)
      AND (@Course_ID IS NULL OR s.Course_ID = @Course_ID)
      AND (@Semester IS NULL OR s.Semester = @Semester)
    ORDER BY s.Semester, s.Day_of_Week, s.Start_Period;
END;
GO

-- ============================================
-- READ: Get scheduler conflicts for a section
-- ============================================
IF OBJECT_ID('sp_GetSchedulerConflicts', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetSchedulerConflicts;
GO

CREATE PROCEDURE sp_GetSchedulerConflicts
    @Section_ID NVARCHAR(10),
    @Course_ID NVARCHAR(15),
    @Semester NVARCHAR(10)
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        s2.Section_ID AS Conflicting_Section_ID,
        s2.Course_ID AS Conflicting_Course_ID,
        s2.Semester AS Conflicting_Semester,
        s2.Day_of_Week,
        CASE s2.Day_of_Week
            WHEN 1 THEN 'Monday'
            WHEN 2 THEN 'Tuesday'
            WHEN 3 THEN 'Wednesday'
            WHEN 4 THEN 'Thursday'
            WHEN 5 THEN 'Friday'
            WHEN 6 THEN 'Saturday'
        END AS Day_Name,
        s2.Start_Period,
        s2.End_Period,
        COUNT(DISTINCT a1.University_ID) AS Shared_Students_Count
    FROM [Scheduler] s1
    INNER JOIN [Scheduler] s2 ON 
        s1.Semester = s2.Semester  -- MUST be same semester
        AND (s1.Section_ID <> s2.Section_ID OR s1.Course_ID <> s2.Course_ID)
    INNER JOIN [Assessment] a1 ON 
        s1.Section_ID = a1.Section_ID 
        AND s1.Course_ID = a1.Course_ID 
        AND s1.Semester = a1.Semester
    INNER JOIN [Assessment] a2 ON 
        s2.Section_ID = a2.Section_ID 
        AND s2.Course_ID = a2.Course_ID 
        AND s2.Semester = a2.Semester
        AND a1.University_ID = a2.University_ID
    WHERE s1.Section_ID = @Section_ID
      AND s1.Course_ID = @Course_ID
      AND s1.Semester = @Semester
      AND s1.Day_of_Week = s2.Day_of_Week
      AND NOT (s1.End_Period < s2.Start_Period OR s1.Start_Period > s2.End_Period)
    GROUP BY s2.Section_ID, s2.Course_ID, s2.Semester, s2.Day_of_Week, s2.Start_Period, s2.End_Period
    ORDER BY Shared_Students_Count DESC;
END;
GO

-- ============================================
-- UPDATE: Update existing scheduler
-- ============================================
IF OBJECT_ID('sp_UpdateScheduler', 'P') IS NOT NULL
    DROP PROCEDURE sp_UpdateScheduler;
GO

CREATE PROCEDURE sp_UpdateScheduler
    @Section_ID NVARCHAR(10),
    @Course_ID NVARCHAR(15),
    @Semester NVARCHAR(10),
    @Day_of_Week INT,
    @Start_Period INT,
    @End_Period INT,
    @Result NVARCHAR(MAX) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- Validate inputs
        IF @Day_of_Week NOT BETWEEN 1 AND 6
        BEGIN
            SET @Result = 'ERROR: Day_of_Week must be between 1 (Monday) and 6 (Saturday)';
            RETURN -1;
        END;
        
        IF @Start_Period NOT BETWEEN 1 AND 13 OR @End_Period NOT BETWEEN 1 AND 13
        BEGIN
            SET @Result = 'ERROR: Periods must be between 1 and 13';
            RETURN -1;
        END;
        
        IF @Start_Period > @End_Period
        BEGIN
            SET @Result = 'ERROR: Start_Period cannot be greater than End_Period';
            RETURN -1;
        END;
        
        DECLARE @PeriodCount INT = @End_Period - @Start_Period + 1;
        IF @PeriodCount NOT BETWEEN 2 AND 3
        BEGIN
            SET @Result = 'ERROR: Period count must be between 2 and 3 (End_Period - Start_Period + 1)';
            RETURN -1;
        END;
        
        -- Check if scheduler exists
        IF NOT EXISTS (SELECT 1 FROM [Scheduler] WHERE Section_ID = @Section_ID AND Course_ID = @Course_ID AND Semester = @Semester)
        BEGIN
            SET @Result = 'ERROR: Scheduler does not exist. Use CREATE instead.';
            RETURN -1;
        END;
        
        -- Update scheduler
        UPDATE [Scheduler]
        SET Day_of_Week = @Day_of_Week,
            Start_Period = @Start_Period,
            End_Period = @End_Period
        WHERE Section_ID = @Section_ID
          AND Course_ID = @Course_ID
          AND Semester = @Semester;
        
        SET @Result = 'SUCCESS: Scheduler updated successfully';
        RETURN 0;
    END TRY
    BEGIN CATCH
        SET @Result = 'ERROR: ' + ERROR_MESSAGE();
        RETURN -1;
    END CATCH;
END;
GO

-- ============================================
-- DELETE: Delete scheduler
-- ============================================
IF OBJECT_ID('sp_DeleteScheduler', 'P') IS NOT NULL
    DROP PROCEDURE sp_DeleteScheduler;
GO

CREATE PROCEDURE sp_DeleteScheduler
    @Section_ID NVARCHAR(10),
    @Course_ID NVARCHAR(15),
    @Semester NVARCHAR(10),
    @Result NVARCHAR(MAX) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- Check if scheduler exists
        IF NOT EXISTS (SELECT 1 FROM [Scheduler] WHERE Section_ID = @Section_ID AND Course_ID = @Course_ID AND Semester = @Semester)
        BEGIN
            SET @Result = 'ERROR: Scheduler does not exist';
            RETURN -1;
        END;
        
        -- Delete scheduler
        DELETE FROM [Scheduler]
        WHERE Section_ID = @Section_ID
          AND Course_ID = @Course_ID
          AND Semester = @Semester;
        
        SET @Result = 'SUCCESS: Scheduler deleted successfully';
        RETURN 0;
    END TRY
    BEGIN CATCH
        SET @Result = 'ERROR: ' + ERROR_MESSAGE();
        RETURN -1;
    END CATCH;
END;
GO

PRINT 'Scheduler CRUD procedures created successfully';
GO

