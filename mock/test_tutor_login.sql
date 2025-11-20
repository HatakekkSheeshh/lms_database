USE [lms_system];
GO

-- ============================================
-- Test Script: Tutor Login (Using Shared Login)
-- ============================================
-- This demonstrates the CORRECT way to login as tutor
-- using the shared tutor_login with SESSION_CONTEXT
-- ============================================

PRINT '========================================';
PRINT 'Testing Tutor Login: University_ID = 1234567';
PRINT 'Using shared tutor_login with SESSION_CONTEXT';
PRINT '========================================';
PRINT '';

-- Step 1: Set user context (simulating login authentication)
PRINT 'Step 1: Setting user context...';
PRINT 'Calling: sp_SetUserContext @University_ID = 1234567, @Password = ''user1234567''';
PRINT '';

EXEC sp_SetUserContext @University_ID = 1234567, @Password = 'user1234567';
GO

-- Step 2: Verify context was set
PRINT '';
PRINT 'Step 2: Verifying user context...';
SELECT 
    CAST(SESSION_CONTEXT(N'University_ID') AS DECIMAL(7,0)) AS Current_University_ID,
    CAST(SESSION_CONTEXT(N'User_Type') AS NVARCHAR(20)) AS Current_User_Type;
GO

-- Step 3: View sections this tutor teaches
PRINT '';
PRINT '========================================';
PRINT 'Step 3: Viewing sections tutor teaches';
PRINT '========================================';
SELECT 
    University_ID,
    Section_ID,
    Course_ID,
    Semester,
    Role_Specification
FROM [Teaches]
WHERE University_ID = CAST(SESSION_CONTEXT(N'University_ID') AS DECIMAL(7,0))
ORDER BY Section_ID, Course_ID, Semester;
GO

-- Step 4: View Tutor Assessment (only for sections they teach)
PRINT '';
PRINT '========================================';
PRINT 'Step 4: Viewing Tutor Assessment (sections they teach)';
PRINT '========================================';
SELECT 
    University_ID,
    Section_ID,
    Course_ID,
    Semester,
    Assessment_ID,
    [Status],
    Final_Grade,
    Midterm_Grade,
    Quiz_Grade,
    Assignment_Grade
FROM vw_TutorAssessment
ORDER BY Section_ID, Course_ID, Semester, Assessment_ID;
GO

-- Step 5: View Tutor Submission
PRINT '';
PRINT '========================================';
PRINT 'Step 5: Viewing Tutor Submission';
PRINT '========================================';
SELECT 
    Submission_No,
    University_ID,
    Section_ID,
    Course_ID,
    Semester,
    Assessment_ID,
    [status],
    SubmitDate
FROM vw_TutorSubmission
ORDER BY Submission_No;
GO

-- Step 6: View Tutor Quiz
PRINT '';
PRINT '========================================';
PRINT 'Step 6: Viewing Tutor Quiz';
PRINT '========================================';
SELECT 
    University_ID,
    Section_ID,
    Course_ID,
    Semester,
    Assessment_ID,
    content,
    completion_status,
    score
FROM vw_TutorQuiz
ORDER BY Section_ID, Course_ID, Semester, Assessment_ID;
GO

-- Step 7: View Tutor Review
PRINT '';
PRINT '========================================';
PRINT 'Step 7: Viewing Tutor Review';
PRINT '========================================';
SELECT 
    Submission_No,
    University_ID,
    Score,
    Comments
FROM vw_TutorReview
ORDER BY Submission_No;
GO

-- Step 8: View Takes_Place (read-only)
PRINT '';
PRINT '========================================';
PRINT 'Step 8: Viewing Takes_Place (read-only)';
PRINT '========================================';
SELECT TOP 10
    Section_ID,
    Course_ID,
    Semester,
    Room_ID,
    Building_ID
FROM [takes_place]
ORDER BY Section_ID, Course_ID, Semester;
GO

PRINT '';
PRINT '========================================';
PRINT 'Test completed!';
PRINT '========================================';
GO

