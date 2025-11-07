if DB_ID('lms_system') IS NOT NULL
BEGIN
    use lms_system;
END
GO

ALTER DATABASE [lms_system] COLLATE Vietnamese_100_CI_AS;