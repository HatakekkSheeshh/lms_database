PRINT '========================================';
PRINT 'Creating Logins in Master Database';
PRINT 'Current Database: ' + DB_NAME();
PRINT '========================================';
PRINT '';

-- Verify we're in master database
IF DB_NAME() <> 'master'
BEGIN
    PRINT 'ERROR: This script must be run in master database!';
    PRINT 'Please connect directly to master database and run this script again.';
    RETURN;
END
GO

-- Create login for student role
-- Note: In Azure SQL Database, use sys.server_principals instead of sys.sql_logins
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'student_login' AND type = 'S')
BEGIN
    BEGIN TRY
        CREATE LOGIN student_login WITH PASSWORD = 'Student@123';
        PRINT 'Login student_login created successfully.';
    END TRY
    BEGIN CATCH
        PRINT 'ERROR creating student_login: ' + ERROR_MESSAGE();
    END CATCH
END
ELSE
BEGIN
    PRINT 'Login student_login already exists.';
END
GO

-- Create login for tutor role
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'tutor_login' AND type = 'S')
BEGIN
    BEGIN TRY
        CREATE LOGIN tutor_login WITH PASSWORD = 'Tutor@123';
        PRINT 'Login tutor_login created successfully.';
    END TRY
    BEGIN CATCH
        PRINT 'ERROR creating tutor_login: ' + ERROR_MESSAGE();
    END CATCH
END
ELSE
BEGIN
    PRINT 'Login tutor_login already exists.';
END
GO

-- Verify logins were created
PRINT '';
PRINT '========================================';
PRINT 'Verification: Checking created logins';
PRINT '========================================';
SELECT 
    name AS LoginName,
    type_desc AS LoginType,
    create_date AS CreatedDate
FROM sys.server_principals
WHERE name IN ('student_login', 'tutor_login')
ORDER BY name;
GO

PRINT '';
PRINT '========================================';
PRINT 'Next Steps:';
PRINT '1. Connect to lms_system database';
PRINT '2. Run security/grant.sql';
PRINT '========================================';
GO

