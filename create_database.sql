USE master;
GO

-- Drop all connections to database first
IF DB_ID('lms_system') IS NOT NULL
BEGIN
    ALTER DATABASE [lms_system] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE [lms_system];
END
GO

-- Create the database with default paths
DECLARE @DefaultDataPath nvarchar(500) = CONVERT(nvarchar(500), SERVERPROPERTY('InstanceDefaultDataPath'))
DECLARE @DefaultLogPath nvarchar(500) = CONVERT(nvarchar(500), SERVERPROPERTY('InstanceDefaultLogPath'))

DECLARE @DataFile nvarchar(500) = @DefaultDataPath + 'lms_system.mdf'
DECLARE @LogFile nvarchar(500) = @DefaultLogPath + 'lms_system_log.ldf'

EXEC('CREATE DATABASE [lms_system]
CONTAINMENT = NONE
ON PRIMARY
(
    NAME = N''lms_system'',
    FILENAME = ''' + @DataFile + ''',
    SIZE = 8192KB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 65536KB
)
LOG ON
(
    NAME = N''lms_system_log'',
    FILENAME = ''' + @LogFile + ''',
    SIZE = 8192KB,
    MAXSIZE = 2048GB,
    FILEGROWTH = 65536KB
)
COLLATE SQL_Latin1_General_CP1_CI_AS;')
GO