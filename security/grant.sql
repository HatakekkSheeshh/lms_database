USE [lms_system];
GO

-- ============================================
-- Security Setup: Create Users and Grant Permissions
-- ============================================
-- IMPORTANT FOR AZURE SQL DATABASE:
-- 1. First run grant_azure_master.sql in MASTER database to create logins
-- 2. Then run this script in lms_system database
-- ============================================

-- Note: CREATE LOGIN must be run in master database for Azure SQL Database
-- If you see errors about logins not existing, run grant_azure_master.sql first

-- Create database user for student
-- Note: Login must exist (created in master database)
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'student')
BEGIN
    BEGIN TRY
        CREATE USER [student] FOR LOGIN [student_login];
        PRINT 'Database user student created successfully.';
    END TRY
    BEGIN CATCH
        PRINT 'ERROR: Cannot create database user student.';
        PRINT 'Make sure student_login exists. Run grant_azure_master.sql in master database first.';
        PRINT 'Error: ' + ERROR_MESSAGE();
    END CATCH
END
ELSE
BEGIN
    PRINT 'Database user student already exists.';
END
GO

-- Create database user for tutor
-- Note: Login must exist (created in master database)
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'tutor')
BEGIN
    BEGIN TRY
        CREATE USER [tutor] FOR LOGIN [tutor_login];
        PRINT 'Database user tutor created successfully.';
    END TRY
    BEGIN CATCH
        PRINT 'ERROR: Cannot create database user tutor.';
        PRINT 'Make sure tutor_login exists. Run grant_azure_master.sql in master database first.';
        PRINT 'Error: ' + ERROR_MESSAGE();
    END CATCH
END
ELSE
BEGIN
    PRINT 'Database user tutor already exists.';
END
GO

-- NOTE: We use SESSION_CONTEXT instead of UserUniversityMapping table
-- The sp_SetUserContext procedure sets University_ID in SESSION_CONTEXT
-- This allows all students/tutors to use shared logins while maintaining data isolation


-- ============================================
-- Stored Procedure to Set User Context
-- ============================================
-- Application must call this procedure after authenticating user from Account table
-- This sets the University_ID and User_Type in SESSION_CONTEXT

IF OBJECT_ID('dbo.sp_SetUserContext', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_SetUserContext;
GO

CREATE PROCEDURE dbo.sp_SetUserContext
    @University_ID DECIMAL(7,0),
    @Password NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @StoredPassword NVARCHAR(50);
    DECLARE @UserType NVARCHAR(20) = NULL;
    
    -- Verify password from Account table
    SELECT @StoredPassword = [Password]
    FROM [Account]
    WHERE University_ID = @University_ID;
    
    IF @StoredPassword IS NULL
    BEGIN
        RAISERROR('Invalid University_ID', 16, 1);
        RETURN;
    END
    
    IF @StoredPassword <> @Password
    BEGIN
        RAISERROR('Invalid password', 16, 1);
        RETURN;
    END
    
    -- Determine if user is Student or Tutor
    IF EXISTS (SELECT 1 FROM [Student] WHERE University_ID = @University_ID)
        SET @UserType = 'Student'
    ELSE IF EXISTS (SELECT 1 FROM [Tutor] WHERE University_ID = @University_ID)
        SET @UserType = 'Tutor'
    ELSE
    BEGIN
        RAISERROR('User is not a Student or Tutor', 16, 1);
        RETURN;
    END
    
    -- Set SESSION_CONTEXT with University_ID and User_Type
    EXEC sp_set_session_context @key = 'University_ID', @value = @University_ID;
    EXEC sp_set_session_context @key = 'User_Type', @value = @UserType;
    
    PRINT 'User context set: University_ID = ' + CAST(@University_ID AS NVARCHAR(10)) + ', User_Type = ' + @UserType;
END;
GO

-- ============================================
-- Security Functions
-- ============================================
-- Note: Must DROP views first before dropping functions they depend on

-- Drop views that depend on functions first
IF OBJECT_ID('dbo.vw_StudentAssessment', 'V') IS NOT NULL
    DROP VIEW dbo.vw_StudentAssessment;
IF OBJECT_ID('dbo.vw_StudentFeedback', 'V') IS NOT NULL
    DROP VIEW dbo.vw_StudentFeedback;
IF OBJECT_ID('dbo.vw_StudentSubmission', 'V') IS NOT NULL
    DROP VIEW dbo.vw_StudentSubmission;
IF OBJECT_ID('dbo.vw_StudentQuiz', 'V') IS NOT NULL
    DROP VIEW dbo.vw_StudentQuiz;
IF OBJECT_ID('dbo.vw_TutorAssessment', 'V') IS NOT NULL
    DROP VIEW dbo.vw_TutorAssessment;
IF OBJECT_ID('dbo.vw_TutorSubmission', 'V') IS NOT NULL
    DROP VIEW dbo.vw_TutorSubmission;
IF OBJECT_ID('dbo.vw_TutorQuiz', 'V') IS NOT NULL
    DROP VIEW dbo.vw_TutorQuiz;
IF OBJECT_ID('dbo.vw_TutorReview', 'V') IS NOT NULL
    DROP VIEW dbo.vw_TutorReview;
GO

-- Function to get the current user's University_ID from SESSION_CONTEXT
IF OBJECT_ID('dbo.fn_GetCurrentUserUniversityID', 'FN') IS NOT NULL
    DROP FUNCTION dbo.fn_GetCurrentUserUniversityID;
GO

CREATE FUNCTION dbo.fn_GetCurrentUserUniversityID()
RETURNS DECIMAL(7,0)
WITH SCHEMABINDING
AS
BEGIN
    DECLARE @UniversityID DECIMAL(7,0);
    
    -- Get University_ID from SESSION_CONTEXT (set by sp_SetUserContext)
    SET @UniversityID = CAST(SESSION_CONTEXT(N'University_ID') AS DECIMAL(7,0));
    
    RETURN @UniversityID;
END;
GO

-- Function to check if current user is a tutor
IF OBJECT_ID('dbo.fn_IsCurrentUserTutor', 'FN') IS NOT NULL
    DROP FUNCTION dbo.fn_IsCurrentUserTutor;
GO

CREATE FUNCTION dbo.fn_IsCurrentUserTutor()
RETURNS BIT
WITH SCHEMABINDING
AS
BEGIN
    DECLARE @IsTutor BIT = 0;
    DECLARE @UserType NVARCHAR(20);
    
    -- Get User_Type from SESSION_CONTEXT (set by sp_SetUserContext)
    SET @UserType = CAST(SESSION_CONTEXT(N'User_Type') AS NVARCHAR(20));
    
    IF @UserType = 'Tutor'
        SET @IsTutor = 1;
    
    RETURN @IsTutor;
END;
GO

PRINT 'Security functions created.';
PRINT 'IMPORTANT: Application must call sp_SetUserContext(University_ID, Password) after authentication.';
GO


-- View for Student to see only their own Assessment records
IF OBJECT_ID('dbo.vw_StudentAssessment', 'V') IS NOT NULL
    DROP VIEW dbo.vw_StudentAssessment;
GO

CREATE VIEW dbo.vw_StudentAssessment
WITH SCHEMABINDING
AS
SELECT 
    University_ID,
    Section_ID,
    Course_ID,
    Semester,
    Assessment_ID,
    Registration_Date,
    Potential_Withdrawal_Date,
    [Status],
    Final_Grade,
    Midterm_Grade,
    Quiz_Grade,
    Assignment_Grade
FROM dbo.[Assessment]
WHERE University_ID = dbo.fn_GetCurrentUserUniversityID();
GO

-- View for Student to see only their own Feedback records
IF OBJECT_ID('dbo.vw_StudentFeedback', 'V') IS NOT NULL
    DROP VIEW dbo.vw_StudentFeedback;
GO

CREATE VIEW dbo.vw_StudentFeedback
WITH SCHEMABINDING
AS
SELECT 
    feedback,
    University_ID,
    Section_ID,
    Course_ID,
    Semester,
    Assessment_ID
FROM dbo.[Feedback]
WHERE University_ID = dbo.fn_GetCurrentUserUniversityID();
GO

-- View for Student to see only their own Submission records
IF OBJECT_ID('dbo.vw_StudentSubmission', 'V') IS NOT NULL
    DROP VIEW dbo.vw_StudentSubmission;
GO

CREATE VIEW dbo.vw_StudentSubmission
WITH SCHEMABINDING
AS
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
    attached_files,
    [status]
FROM dbo.[Submission]
WHERE University_ID = dbo.fn_GetCurrentUserUniversityID();
GO

-- View for Student to see only their own Quiz records
IF OBJECT_ID('dbo.vw_StudentQuiz', 'V') IS NOT NULL
    DROP VIEW dbo.vw_StudentQuiz;
GO

CREATE VIEW dbo.vw_StudentQuiz
WITH SCHEMABINDING
AS
SELECT 
    University_ID,
    Section_ID,
    Course_ID,
    Semester,
    Assessment_ID,
    Grading_method,
    pass_score,
    Time_limits,
    [Start_Date],
    End_Date,
    Responses,
    completion_status,
    score,
    content,
    [types],
    [Weight],
    Correct_answer
FROM dbo.[Quiz]
WHERE University_ID = dbo.fn_GetCurrentUserUniversityID();
GO

PRINT 'Student views created.';
GO

-- ============================================
-- Create Views for Tutor Access (Filtered by Teaches)
-- ============================================

-- View for Tutor to see only Assessment records for sections they teach
IF OBJECT_ID('dbo.vw_TutorAssessment', 'V') IS NOT NULL
    DROP VIEW dbo.vw_TutorAssessment;
GO

CREATE VIEW dbo.vw_TutorAssessment
WITH SCHEMABINDING
AS
SELECT 
    a.University_ID,
    a.Section_ID,
    a.Course_ID,
    a.Semester,
    a.Assessment_ID,
    a.Registration_Date,
    a.Potential_Withdrawal_Date,
    a.[Status],
    a.Final_Grade,
    a.Midterm_Grade,
    a.Quiz_Grade,
    a.Assignment_Grade
FROM dbo.[Assessment] a
INNER JOIN dbo.[Teaches] t
    ON a.Section_ID = t.Section_ID
    AND a.Course_ID = t.Course_ID
    AND a.Semester = t.Semester
WHERE t.University_ID = dbo.fn_GetCurrentUserUniversityID();
GO

-- View for Tutor to see only Submission records for sections they teach
IF OBJECT_ID('dbo.vw_TutorSubmission', 'V') IS NOT NULL
    DROP VIEW dbo.vw_TutorSubmission;
GO

CREATE VIEW dbo.vw_TutorSubmission
WITH SCHEMABINDING
AS
SELECT 
    s.Submission_No,
    s.University_ID,
    s.Section_ID,
    s.Course_ID,
    s.Semester,
    s.Assessment_ID,
    s.accepted_specification,
    s.late_flag_indicator,
    s.SubmitDate,
    s.attached_files,
    s.[status]
FROM dbo.[Submission] s
INNER JOIN dbo.[Teaches] t
    ON s.Section_ID = t.Section_ID
    AND s.Course_ID = t.Course_ID
    AND s.Semester = t.Semester
WHERE t.University_ID = dbo.fn_GetCurrentUserUniversityID();
GO

-- View for Tutor to see only Quiz records for sections they teach
IF OBJECT_ID('dbo.vw_TutorQuiz', 'V') IS NOT NULL
    DROP VIEW dbo.vw_TutorQuiz;
GO

CREATE VIEW dbo.vw_TutorQuiz
WITH SCHEMABINDING
AS
SELECT 
    q.University_ID,
    q.Section_ID,
    q.Course_ID,
    q.Semester,
    q.Assessment_ID,
    q.Grading_method,
    q.pass_score,
    q.Time_limits,
    q.[Start_Date],
    q.End_Date,
    q.Responses,
    q.completion_status,
    q.score,
    q.content,
    q.[types],
    q.[Weight],
    q.Correct_answer
FROM dbo.[Quiz] q
INNER JOIN dbo.[Teaches] t
    ON q.Section_ID = t.Section_ID
    AND q.Course_ID = t.Course_ID
    AND q.Semester = t.Semester
WHERE t.University_ID = dbo.fn_GetCurrentUserUniversityID();
GO

-- View for Tutor to see only Review records for submissions in sections they teach
IF OBJECT_ID('dbo.vw_TutorReview', 'V') IS NOT NULL
    DROP VIEW dbo.vw_TutorReview;
GO

CREATE VIEW dbo.vw_TutorReview
WITH SCHEMABINDING
AS
SELECT 
    r.Submission_No,
    r.University_ID,
    r.Score,
    r.Comments
FROM dbo.[review] r
INNER JOIN dbo.[Submission] s
    ON r.Submission_No = s.Submission_No
INNER JOIN dbo.[Teaches] t
    ON s.Section_ID = t.Section_ID
    AND s.Course_ID = t.Course_ID
    AND s.Semester = t.Semester
WHERE t.University_ID = dbo.fn_GetCurrentUserUniversityID();
GO

PRINT 'Tutor views created.';
GO

-- Grant SELECT on Course table (all records)
GRANT SELECT ON [Course] TO [student];
PRINT 'Granted SELECT on Course to student.';

-- Grant SELECT on student-specific views
GRANT SELECT ON dbo.vw_StudentAssessment TO [student];
GRANT SELECT ON dbo.vw_StudentFeedback TO [student];
GRANT SELECT ON dbo.vw_StudentSubmission TO [student];
GRANT SELECT ON dbo.vw_StudentQuiz TO [student];
PRINT 'Granted SELECT on student views to student.';

GO


-- Grant SELECT on tutor-specific views (filtered by sections they teach)
GRANT SELECT ON dbo.vw_TutorAssessment TO [tutor];
GRANT SELECT ON dbo.vw_TutorSubmission TO [tutor];
GRANT SELECT ON dbo.vw_TutorQuiz TO [tutor];
GRANT SELECT ON dbo.vw_TutorReview TO [tutor];
PRINT 'Granted SELECT on tutor views to tutor.';

-- Grant INSERT, UPDATE, DELETE on base tables
-- Note: Application should verify tutor can only modify data for sections they teach
-- (via Teaches table) to ensure security
GRANT INSERT, UPDATE, DELETE ON [Assessment] TO [tutor];
GRANT INSERT, UPDATE, DELETE ON [Submission] TO [tutor];
GRANT INSERT, UPDATE, DELETE ON [Quiz] TO [tutor];
GRANT INSERT, UPDATE, DELETE ON [review] TO [tutor];
PRINT 'Granted INSERT, UPDATE, DELETE on Assessment, Submission, Quiz, Review to tutor.';

-- Grant SELECT only on Takes_Place
GRANT SELECT ON [takes_place] TO [tutor];
PRINT 'Granted SELECT on Takes_Place to tutor.';

-- Grant SELECT only on Teaches (so tutor can see which sections they teach)
GRANT SELECT ON [Teaches] TO [tutor];
PRINT 'Granted SELECT on Teaches to tutor.';

GO

-- Grant EXECUTE on sp_SetUserContext to student and tutor
GRANT EXECUTE ON dbo.sp_SetUserContext TO [student];
GRANT EXECUTE ON dbo.sp_SetUserContext TO [tutor];
GO


PRINT '';
PRINT '============================================';
PRINT 'Security Setup Summary:';
PRINT '============================================';
PRINT 'Student User:';
PRINT '  - Can view all Course records';
PRINT '  - Can view own Assessment records (via vw_StudentAssessment)';
PRINT '  - Can view own Feedback records (via vw_StudentFeedback)';
PRINT '  - Can view own Submission records (via vw_StudentSubmission)';
PRINT '  - Can view own Quiz records (via vw_StudentQuiz)';
PRINT '';
PRINT 'Tutor User:';
PRINT '  - Can view Assessment for sections they teach (via vw_TutorAssessment)';
PRINT '  - Can view Submission for sections they teach (via vw_TutorSubmission)';
PRINT '  - Can view Quiz for sections they teach (via vw_TutorQuiz)';
PRINT '  - Can view Review for sections they teach (via vw_TutorReview)';
PRINT '  - Can edit Assessment, Submission, Quiz, Review (application should verify access)';
PRINT '  - Can view Takes_Place (read-only)';
PRINT '  - Can view Teaches (read-only)';
PRINT '============================================';
PRINT '';
PRINT 'Default Passwords for SQL Server Logins:';
PRINT '  student_login: Student@123 (shared login for all students)';
PRINT '  tutor_login: Tutor@123 (shared login for all tutors)';
PRINT '';
PRINT 'HOW IT WORKS:';
PRINT '  1. User connects to database using student_login or tutor_login';
PRINT '  2. Application authenticates user using Account table (University_ID + Password)';
PRINT '  3. Application calls: EXEC sp_SetUserContext @University_ID, @Password';
PRINT '  4. Views automatically filter data based on University_ID in SESSION_CONTEXT';
PRINT '';
PRINT 'Example usage in application:';
PRINT '  -- Step 1: User connects with student_login or tutor_login';
PRINT '  -- Step 2: After user provides University_ID and Password, call:';
PRINT '  EXEC sp_SetUserContext @University_ID = 2211073, @Password = ''user2211073'';';
PRINT '  -- Step 3: Now user can query views and see only their own data';
PRINT '  SELECT * FROM vw_StudentAssessment;';
PRINT '';
PRINT 'NOTE: You do NOT need to create individual logins for each user!';
PRINT '      All students use student_login, all tutors use tutor_login.';
PRINT '      The sp_SetUserContext procedure handles University_ID filtering.';
PRINT '============================================';
GO

