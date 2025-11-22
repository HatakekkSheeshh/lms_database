USE [lms_system];
GO

-- ============================================
-- Examples: How to use Scheduler CRUD Procedures
-- ============================================

PRINT '========================================';
PRINT 'Scheduler CRUD Procedures - Usage Examples';
PRINT '========================================';
PRINT '';

-- ============================================
-- Example 1: CREATE - Insert new scheduler
-- ============================================
PRINT 'Example 1: Creating a new scheduler...';
DECLARE @Result NVARCHAR(MAX);
DECLARE @ReturnCode INT;

EXEC @ReturnCode = sp_CreateScheduler
    @Section_ID = 'CC01',
    @Course_ID = 'CO1007',
    @Semester = '241',
    @Day_of_Week = 1,  -- Monday
    @Start_Period = 2,  -- 7 AM
    @End_Period = 3,    -- 8 AM (2 periods)
    @Result = @Result OUTPUT;

PRINT 'Return Code: ' + CAST(@ReturnCode AS NVARCHAR(10));
PRINT 'Result: ' + @Result;
PRINT '';

-- ============================================
-- Example 2: READ - Get scheduler by section
-- ============================================
PRINT 'Example 2: Reading scheduler for a specific section...';
EXEC sp_GetScheduler 
    @Section_ID = 'CC01',
    @Course_ID = 'CO1007',
    @Semester = '241';
PRINT '';

-- ============================================
-- Example 3: READ - Get all schedulers for a semester
-- ============================================
PRINT 'Example 3: Reading all schedulers for semester 241...';
EXEC sp_GetScheduler 
    @Semester = '241';
PRINT '';

-- ============================================
-- Example 4: READ - Get conflicts for a section
-- ============================================
PRINT 'Example 4: Checking conflicts for a section...';
EXEC sp_GetSchedulerConflicts
    @Section_ID = 'CC01',
    @Course_ID = 'CO1007',
    @Semester = '241';
PRINT '';

-- ============================================
-- Example 5: UPDATE - Update existing scheduler
-- ============================================
PRINT 'Example 5: Updating a scheduler...';
SET @Result = '';

EXEC @ReturnCode = sp_UpdateScheduler
    @Section_ID = 'CC01',
    @Course_ID = 'CO1007',
    @Semester = '241',
    @Day_of_Week = 2,  -- Tuesday
    @Start_Period = 3,  -- 8 AM
    @End_Period = 4,    -- 9 AM (2 periods)
    @Result = @Result OUTPUT;

PRINT 'Return Code: ' + CAST(@ReturnCode AS NVARCHAR(10));
PRINT 'Result: ' + @Result;
PRINT '';

-- ============================================
-- Example 6: DELETE - Delete scheduler
-- ============================================
PRINT 'Example 6: Deleting a scheduler...';
SET @Result = '';

EXEC @ReturnCode = sp_DeleteScheduler
    @Section_ID = 'CC01',
    @Course_ID = 'CO1007',
    @Semester = '241',
    @Result = @Result OUTPUT;

PRINT 'Return Code: ' + CAST(@ReturnCode AS NVARCHAR(10));
PRINT 'Result: ' + @Result;
PRINT '';

-- ============================================
-- Example 7: View all conflicts
-- ============================================
PRINT 'Example 7: Viewing all scheduler conflicts...';
SELECT * FROM vw_SchedulerConflicts
ORDER BY Shared_Students_Count DESC, Day_of_Week, Section1_Start;
PRINT '';

PRINT '========================================';
PRINT 'Examples completed';
PRINT '========================================';
GO

