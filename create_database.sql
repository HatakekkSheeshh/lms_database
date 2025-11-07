USE master;
GO

IF DB_ID('lms_system') IS NULL
BEGIN
    CREATE DATABASE [lms_system]
    CONTAINMENT = NONE
    ON PRIMARY
    (
        NAME = N'lms_system',
        FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\lms_system.mdf',
        SIZE = 8192KB,
        MAXSIZE = UNLIMITED,
        FILEGROWTH = 65536KB
    )
    LOG ON
    (
        NAME = N'lms_system_log',
        FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\lms_system_log.ldf',
        SIZE = 8192KB,
        MAXSIZE = 2048GB,
        FILEGROWTH = 65536KB
    )
    COLLATE SQL_Latin1_General_CP1_CI_AS;
END