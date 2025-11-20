USE [lms_system];
GO

-- ============================================
-- Test Script: Student Login and View Data
-- ============================================
-- This script tests logging in as student with University_ID = 2211073
-- and viewing related tables
--
-- NOTE: To run this as student_login user, you need to:
-- 1. Connect to SQL Server using: student_login / Student@123
-- 2. Then run this script
-- ============================================

PRINT '========================================';
PRINT 'Testing Student Login: University_ID = 2211073';
PRINT '========================================';
PRINT '';

-- Step 1: Set user context (simulating login authentication)
PRINT 'Step 1: Setting user context...';
PRINT 'Calling: sp_SetUserContext @University_ID = 2211073, @Password = ''user2211073''';
PRINT '';

EXEC sp_SetUserContext @University_ID = 2211073, @Password = 'user2211073';
GO

-- Step 2: Verify context was set
PRINT '';
PRINT 'Step 2: Verifying user context...';
SELECT 
    CAST(SESSION_CONTEXT(N'University_ID') AS DECIMAL(7,0)) AS Current_University_ID,
    CAST(SESSION_CONTEXT(N'User_Type') AS NVARCHAR(20)) AS Current_User_Type;
GO

-- Step 3: Test viewing Course table (should see all courses)
PRINT '';
PRINT '========================================';
PRINT 'Step 3: Viewing Course table (all courses)';
PRINT '========================================';
SELECT TOP 10
    Course_ID,
    [Name],
    Credit,
    Start_Date
FROM [Course]
ORDER BY Course_ID;
GO

-- Step 4: Test viewing Student Assessment (should only see own records)
PRINT '';
PRINT '========================================';
PRINT 'Step 4: Viewing Student Assessment (own records only)';
PRINT '========================================';
SELECT 
    University_ID,
    Section_ID,
    Course_ID,
    Semester,
    Assessment_ID,
    Registration_Date,
    [Status],
    Final_Grade,
    Midterm_Grade,
    Quiz_Grade,
    Assignment_Grade
FROM vw_StudentAssessment
ORDER BY Section_ID, Course_ID, Semester, Assessment_ID;
GO

-- Step 5: Test viewing Student Feedback (should only see own records)
PRINT '';
PRINT '========================================';
PRINT 'Step 5: Viewing Student Feedback (own records only)';
PRINT '========================================';
SELECT 
    feedback,
    University_ID,
    Section_ID,
    Course_ID,
    Semester,
    Assessment_ID
FROM vw_StudentFeedback
ORDER BY Section_ID, Course_ID, Semester, Assessment_ID;
GO

-- Step 6: Test viewing Student Submission (should only see own records)
PRINT '';
PRINT '========================================';
PRINT 'Step 6: Viewing Student Submission (own records only)';
PRINT '========================================';
SELECT 
    Submission_No,
    University_ID,
    Section_ID,
    Course_ID,
    Semester,
    Assessment_ID,
    accepted_specification,
    late_flag_indicator,
    SubmitDate,
    [status]
FROM vw_StudentSubmission
ORDER BY Submission_No;
GO

-- Step 7: Test viewing Student Quiz (should only see own records)
PRINT '';
PRINT '========================================';
PRINT 'Step 7: Viewing Student Quiz (own records only)';
PRINT '========================================';
SELECT 
    University_ID,
    Section_ID,
    Course_ID,
    Semester,
    Assessment_ID,
    Grading_method,
    pass_score,
    completion_status,
    score,
    content
FROM vw_StudentQuiz
ORDER BY Section_ID, Course_ID, Semester, Assessment_ID;
GO

-- Step 8: Summary - Count records
PRINT '';
PRINT '========================================';
PRINT 'Step 8: Summary - Record Counts';
PRINT '========================================';
SELECT 
    (SELECT COUNT(*) FROM vw_StudentAssessment) AS Assessment_Count,
    (SELECT COUNT(*) FROM vw_StudentFeedback) AS Feedback_Count,
    (SELECT COUNT(*) FROM vw_StudentSubmission) AS Submission_Count,
    (SELECT COUNT(*) FROM vw_StudentQuiz) AS Quiz_Count,
    (SELECT COUNT(*) FROM [Course]) AS Course_Count;
GO

-- Step 9: Test security - Try to access other student's data directly
PRINT '';
PRINT '========================================';
PRINT 'Step 9: Security Test - Direct table access';
PRINT '========================================';
PRINT 'Attempting to query Assessment table directly...';
PRINT 'Should only see records for University_ID = 2211073';
SELECT 
    University_ID,
    COUNT(*) AS Record_Count
FROM [Assessment]
GROUP BY University_ID
ORDER BY University_ID;
GO

PRINT '';
PRINT '========================================';
PRINT 'Test completed!';
PRINT '========================================';
PRINT '';
PRINT 'Expected Results:';
PRINT '  - All views should only show data for University_ID = 2211073';
PRINT '  - Course table should show all courses (no filter)';
PRINT '  - Direct Assessment query should only show records for University_ID = 2211073';
PRINT '    (if user has SELECT permission on base table)';
PRINT '========================================';
GO

