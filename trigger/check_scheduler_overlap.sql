USE [lms_system];
GO

-- ============================================
-- Trigger to check scheduler overlap
-- Prevents insertion/update if it causes overlap
-- for students who learn both courses
-- ============================================

IF OBJECT_ID('trg_CheckSchedulerOverlap', 'TR') IS NOT NULL
    DROP TRIGGER trg_CheckSchedulerOverlap;
GO

CREATE TRIGGER trg_CheckSchedulerOverlap
ON [Scheduler]
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @ErrorMessages NVARCHAR(MAX) = '';
    DECLARE @ConflictCount INT = 0;
    
    -- Check for overlaps in inserted/updated records
    -- Only check conflicts within the SAME semester
    -- For UPDATE, exclude the current record being updated from conflict check
    SELECT @ConflictCount = COUNT(*)
    FROM inserted i
    INNER JOIN [Scheduler] s ON 
        i.Semester = s.Semester  -- MUST be same semester
        AND (i.Section_ID <> s.Section_ID OR i.Course_ID <> s.Course_ID)
        -- Exclude the current record if it's an UPDATE (exists in deleted table)
        AND NOT EXISTS (
            SELECT 1 FROM deleted d 
            WHERE d.Section_ID = s.Section_ID 
              AND d.Course_ID = s.Course_ID 
              AND d.Semester = s.Semester
        )
    INNER JOIN [Assessment] a1 ON 
        i.Section_ID = a1.Section_ID 
        AND i.Course_ID = a1.Course_ID 
        AND i.Semester = a1.Semester
    INNER JOIN [Assessment] a2 ON 
        s.Section_ID = a2.Section_ID 
        AND s.Course_ID = a2.Course_ID 
        AND s.Semester = a2.Semester
        AND a1.University_ID = a2.University_ID
    WHERE i.Day_of_Week = s.Day_of_Week
      AND NOT (i.End_Period < s.Start_Period OR i.Start_Period > s.End_Period);
    
    -- If conflicts found, rollback and show error
    IF @ConflictCount > 0
    BEGIN
        -- Build detailed error message
        SELECT @ErrorMessages = @ErrorMessages + 
            'Conflict detected: Section ' + i.Section_ID + ' (' + i.Course_ID + ') ' +
            'overlaps with Section ' + s.Section_ID + ' (' + s.Course_ID + ') ' +
            'on ' + 
            CASE i.Day_of_Week
                WHEN 1 THEN 'Monday'
                WHEN 2 THEN 'Tuesday'
                WHEN 3 THEN 'Wednesday'
                WHEN 4 THEN 'Thursday'
                WHEN 5 THEN 'Friday'
                WHEN 6 THEN 'Saturday'
            END + 
            ' (Periods ' + CAST(i.Start_Period AS NVARCHAR(2)) + '-' + CAST(i.End_Period AS NVARCHAR(2)) + 
            ' vs ' + CAST(s.Start_Period AS NVARCHAR(2)) + '-' + CAST(s.End_Period AS NVARCHAR(2)) + '). ' +
            'Shared students: ' + CAST(COUNT(DISTINCT a1.University_ID) AS NVARCHAR(10)) + '. ' + CHAR(13) + CHAR(10)
        FROM inserted i
        INNER JOIN [Scheduler] s ON 
            i.Semester = s.Semester  -- MUST be same semester
            AND (i.Section_ID <> s.Section_ID OR i.Course_ID <> s.Course_ID)
            -- Exclude the current record if it's an UPDATE (exists in deleted table)
            AND NOT EXISTS (
                SELECT 1 FROM deleted d 
                WHERE d.Section_ID = s.Section_ID 
                  AND d.Course_ID = s.Course_ID 
                  AND d.Semester = s.Semester
            )
        INNER JOIN [Assessment] a1 ON 
            i.Section_ID = a1.Section_ID 
            AND i.Course_ID = a1.Course_ID 
            AND i.Semester = a1.Semester
        INNER JOIN [Assessment] a2 ON 
            s.Section_ID = a2.Section_ID 
            AND s.Course_ID = a2.Course_ID 
            AND s.Semester = a2.Semester
            AND a1.University_ID = a2.University_ID
        WHERE i.Day_of_Week = s.Day_of_Week
          AND NOT (i.End_Period < s.Start_Period OR i.Start_Period > s.End_Period)
        GROUP BY i.Section_ID, i.Course_ID, i.Semester, i.Day_of_Week, i.Start_Period, i.End_Period,
                 s.Section_ID, s.Course_ID, s.Semester, s.Start_Period, s.End_Period;
        
        ROLLBACK TRANSACTION;
        
        RAISERROR('SCHEDULER OVERLAP ERROR: %s', 16, 1, @ErrorMessages);
        RETURN;
    END;
END;
GO

PRINT 'Trigger trg_CheckSchedulerOverlap created successfully';
GO

-- ============================================
-- Optional: View to check all current conflicts
-- ============================================
IF OBJECT_ID('vw_SchedulerConflicts', 'V') IS NOT NULL
    DROP VIEW vw_SchedulerConflicts;
GO

CREATE VIEW vw_SchedulerConflicts
AS
SELECT 
    s1.Section_ID AS Section1_ID,
    s1.Course_ID AS Course1_ID,
    s1.Semester AS Semester1,
    s2.Section_ID AS Section2_ID,
    s2.Course_ID AS Course2_ID,
    s2.Semester AS Semester2,
    s1.Day_of_Week,
    CASE s1.Day_of_Week
        WHEN 1 THEN 'Monday'
        WHEN 2 THEN 'Tuesday'
        WHEN 3 THEN 'Wednesday'
        WHEN 4 THEN 'Thursday'
        WHEN 5 THEN 'Friday'
        WHEN 6 THEN 'Saturday'
    END AS Day_Name,
    s1.Start_Period AS Section1_Start,
    s1.End_Period AS Section1_End,
    s2.Start_Period AS Section2_Start,
    s2.End_Period AS Section2_End,
    COUNT(DISTINCT a1.University_ID) AS Shared_Students_Count,
    STRING_AGG(CAST(a1.University_ID AS NVARCHAR(10)), ', ') AS Shared_Student_IDs
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
WHERE s1.Day_of_Week = s2.Day_of_Week
  AND NOT (s1.End_Period < s2.Start_Period OR s1.Start_Period > s2.End_Period)
GROUP BY s1.Section_ID, s1.Course_ID, s1.Semester, s1.Day_of_Week, s1.Start_Period, s1.End_Period,
         s2.Section_ID, s2.Course_ID, s2.Semester, s2.Start_Period, s2.End_Period;
GO

PRINT 'View vw_SchedulerConflicts created successfully';
GO

