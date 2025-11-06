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
GO

USE [lms_system];
GO

-- DROP ALL FOREIGN KEY FIRST
DECLARE @sql nvarchar(max) = N'';
SELECT @sql = @sql + N'ALTER TABLE ' 
    + QUOTENAME(OBJECT_SCHEMA_NAME(parent_object_id)) + N'.' + QUOTENAME(OBJECT_NAME(parent_object_id))
    + N' DROP CONSTRAINT ' + QUOTENAME(name) + N';' + CHAR(10)
FROM sys.foreign_keys;
EXEC sp_executesql @sql;
PRINT @sql

DROP TABLE IF EXISTS [Review];
DROP TABLE IF EXISTS [Submission];
DROP TABLE IF EXISTS [Assignment];
DROP TABLE IF EXISTS [Quiz];
DROP TABLE IF EXISTS [Link];
DROP TABLE IF EXISTS [Online];
DROP TABLE IF EXISTS [Platform];
DROP TABLE IF EXISTS [Equipment];
DROP TABLE IF EXISTS [Takes_Place];
DROP TABLE IF EXISTS [Room];
DROP TABLE IF EXISTS [Building];
DROP TABLE IF EXISTS [Feedback];
DROP TABLE IF EXISTS [Assessment];
DROP TABLE IF EXISTS [Teaches];
DROP TABLE IF EXISTS [Section];
DROP TABLE IF EXISTS [Course];
DROP TABLE IF EXISTS [Tutor];
DROP TABLE IF EXISTS [Student];
DROP TABLE IF EXISTS [Department];
DROP TABLE IF EXISTS [Reference_To];
DROP TABLE IF EXISTS [Audit_Log];
DROP TABLE IF EXISTS [Admin];
DROP TABLE IF EXISTS [Account];
DROP TABLE IF EXISTS [Users];
DROP TABLE IF EXISTS [System];

CREATE TABLE [System] (
    System_name VARCHAR(50) PRIMARY KEY,
    Domain VARCHAR(50) NOT NULL,
);

CREATE TABLE [Users] (
    University_ID DECIMAL(6,0) PRIMARY KEY,
    First_Name VARCHAR(50) NOT NULL,
    Last_Name VARCHAR(50) NOT NULL,
    Email VARCHAR(50) NOT NULL,
    Phone_Number DECIMAL(10,0) CHECK (Phone_Number >= 1000000000 AND Phone_Number <= 9999999999),
    [Address] VARCHAR(50),
    National_ID DECIMAL(12,0) UNIQUE,
    System_name VARCHAR(50) NOT NULL,
    CONSTRAINT FK_User_System FOREIGN KEY (System_name)
        REFERENCES [System](System_name)
);

CREATE TABLE [Account] (
    University_ID DECIMAL(6,0),
    [Password] VARCHAR(50),
    CONSTRAINT PK_Account PRIMARY KEY (University_ID),
    CONSTRAINT FK_Account_User FOREIGN KEY (University_ID)
        REFERENCES [Users](University_ID)
);

CREATE TABLE [Admin] (
    University_ID DECIMAL(6,0) PRIMARY KEY,
    [Type] VARCHAR(50) CHECK ([Type] IN (
        'Coordinator',
        'Office of Academic Affairs',
        'Office of Student Affairs',
        'Program Administrator'
    )),
    CONSTRAINT FK_Admin_User FOREIGN KEY (University_ID)
        REFERENCES [Users](University_ID)
);

CREATE TABLE [Audit_Log] (
    LogID INT IDENTITY(1,1) PRIMARY KEY,
    System_name VARCHAR(50),
    CONSTRAINT FK_AuditLog_System FOREIGN KEY (System_name)
        REFERENCES [System](System_name)
);

CREATE TABLE [Reference_To] (
    LogID INT,
    University_ID DECIMAL(6,0),
    CONSTRAINT PK_Reference PRIMARY KEY (LogID, University_ID),
    CONSTRAINT FK_Reference_Log FOREIGN KEY (LogID)
        REFERENCES [Audit_Log](LogID),
    CONSTRAINT FK_Reference_User FOREIGN KEY (University_ID)
        REFERENCES [Users](University_ID)
);

Create table [Student](
	University_ID DECIMAL(6,0) PRIMARY KEY,
	CONSTRAINT FK_Student_User FOREIGN KEY (University_ID)
        REFERENCES [Users](University_ID),
	Major VARCHAR(50) not null,
	Current_degree VARCHAR(50) DEFAULT 'Bachelor',
);

CREATE TABLE [Department] (
    Department_Name VARCHAR(50) PRIMARY KEY,
    University_ID Decimal(6,0),
    CONSTRAINT FK_Department_User FOREIGN KEY (University_ID)
        REFERENCES [Users](University_ID)
);

CREATE TABLE [Tutor] (
    University_ID DECIMAL(6,0) PRIMARY KEY,
    [Name] VARCHAR(50) NOT NULL,
    Academic_Rank VARCHAR(50),
    [Details] VARCHAR(100),
    Issuance_Date DATE,
    Department_Name VARCHAR(50),
    CONSTRAINT FK_Tutor_User FOREIGN KEY (University_ID)
        REFERENCES [Users](University_ID),
    CONSTRAINT FK_Tutor_Department FOREIGN KEY (Department_Name)
        REFERENCES [Department](Department_Name)
);

CREATE TABLE [Course] (
    Course_ID INT IDENTITY(1,1) PRIMARY KEY,
    [Name] VARCHAR(50) NOT NULL UNIQUE,
    Credit INT CHECK (Credit BETWEEN 1 AND 10),
    Start_Date DATE
);

CREATE TABLE [Section] (
    Section_ID INT IDENTITY(1,1) PRIMARY KEY,
    Course_ID INT NOT NULL,
    Semester VARCHAR(10) NOT NULL,
    CONSTRAINT FK_Section_Course FOREIGN KEY (Course_ID)
        REFERENCES [Course](Course_ID)
);

CREATE TABLE [Teaches] (
    Tutor_ID DECIMAL(6,0),
    Section_ID INT,
    Course_ID INT,
    Role_Specification VARCHAR(50),
    [Timestamp] DATETIME,
    CONSTRAINT PK_Teaches PRIMARY KEY (Tutor_ID, Section_ID, Course_ID),
    CONSTRAINT FK_Teaches_Tutor FOREIGN KEY (Tutor_ID)
        REFERENCES [Tutor](University_ID),
    CONSTRAINT FK_Teaches_Section FOREIGN KEY (Section_ID)
        REFERENCES [Section](Section_ID),
    CONSTRAINT FK_Teaches_Course FOREIGN KEY (Course_ID)
        REFERENCES [Course](Course_ID)
);


CREATE TABLE [Assessment] (
    Assessment_ID INT IDENTITY(1,1) PRIMARY KEY,
    University_ID DECIMAL(6,0),
    Section_ID INT,
    Course_ID INT,
    Grade DECIMAL(2,2) CHECK (Grade BETWEEN 0 AND 10),
    Registration_Date DATE DEFAULT GETDATE(),
    Potential_Withdrawal_Date DATE,
    [Status] VARCHAR(50) DEFAULT 'Pending' CHECK ([Status] IN ('Pending', 'Approved', 'Rejected', 'Cancelled')),
    CONSTRAINT CK_Assessment_Dates CHECK (Registration_Date <= Potential_Withdrawal_Date),
	CONSTRAINT FK_Assessment_Student FOREIGN KEY (University_ID)
        REFERENCES [Student](University_ID),
    CONSTRAINT FK_Assessment_Section FOREIGN KEY (Section_ID)
        REFERENCES [Section](Section_ID),
    CONSTRAINT FK_Assessment_Course FOREIGN KEY (Course_ID)
        REFERENCES [Course](Course_ID)
);

CREATE TABLE [Feedback] (
    Feedback_ID INT IDENTITY(1,1) PRIMARY KEY,
    Section_ID INT,
    Course_ID INT,
    Assessment_ID INT,
    University_ID DECIMAL(6,0),
    Feedback_Text VARCHAR(255),
    CONSTRAINT FK_Feedback_Assessment FOREIGN KEY (Assessment_ID)
        REFERENCES [Assessment](Assessment_ID),
    CONSTRAINT FK_Feedback_Section FOREIGN KEY (Section_ID)
        REFERENCES [Section](Section_ID),
    CONSTRAINT FK_Feedback_Course FOREIGN KEY (Course_ID)
        REFERENCES [Course](Course_ID),
    CONSTRAINT FK_Feedback_Student FOREIGN KEY (University_ID)
        REFERENCES [Student](University_ID)
);

create table [Building](
	Building_ID INT IDENTITY(1,1) PRIMARY KEY
);

create table [Room](
	Room_ID INT IDENTITY(1,1) PRIMARY KEY,
	Building_ID INT NOT NULL,
	CONSTRAINT FK_Room_Building FOREIGN KEY (Building_ID)
        REFERENCES [Building](Building_ID),
	Capacity INT DEFAULT 30 CHECK (Capacity BETWEEN 1 AND 300),
	RoomType VARCHAR(20) CHECK (RoomType IN ('Lecture', 'Lab', 'Office')),

);

create table [takes_place](
	Section_ID INT,
	Course_ID INT,
	Room_ID INT,
	Building_ID INT,
	CONSTRAINT PK_Place PRIMARY KEY (Section_ID,Course_ID,Room_ID,Building_ID),
	CONSTRAINT FK_Place_Section FOREIGN KEY (Section_ID)
        REFERENCES [Section](Section_ID),
    CONSTRAINT FK_Place_Course FOREIGN KEY (Course_ID)
        REFERENCES [Course](Course_ID),
	CONSTRAINT FK_Place_Room FOREIGN KEY (Room_ID)
        REFERENCES [Room](Room_ID),
	CONSTRAINT FK_Place_Building FOREIGN KEY (Building_ID)
        REFERENCES [Building](Building_ID),
)

create table [equipment](
	Equipment VARCHAR(50) Primary key,
	Room_ID INT,
	Building_ID INT,
	Quantity INT DEFAULT 1 CHECK (Quantity >= 0),
	CONSTRAINT FK_Equipment_Room FOREIGN KEY (Room_ID)
        REFERENCES [Room](Room_ID),
	CONSTRAINT FK_Equipment_Building FOREIGN KEY (Building_ID)
        REFERENCES [Building](Building_ID),
	 Status VARCHAR(20) DEFAULT 'Available' CHECK (Status IN ('Available','In Use','Broken')),
);

create table [Platform](
	Platform_ID INT IDENTITY(1,1) PRIMARY KEY,
	Name varchar(50),
);

create table [Online](
	Platform_ID INT,
	Section_ID INT,
	Course_ID INT,
	CONSTRAINT PK_Online PRIMARY KEY (Platform_ID,Section_ID,Course_ID),
	CONSTRAINT FK_Online_Section FOREIGN KEY (Section_ID)
        REFERENCES [Section](Section_ID),
    CONSTRAINT FK_Online_Course FOREIGN KEY (Course_ID)
        REFERENCES [Course](Course_ID),
	CONSTRAINT FK_Online_Platform FOREIGN KEY (Platform_ID)
        REFERENCES [Platform](Platform_ID),
);

create table [Link](
	link varchar(255) primary key,
	Platform_ID INT,
	CONSTRAINT FK_Link_Platform FOREIGN KEY (Platform_ID)
        REFERENCES [Platform](Platform_ID),
);

CREATE TABLE [Quiz] (
    University_ID DECIMAL(6,0),
    Section_ID INT,
    Course_ID INT,
    Assessment_ID INT,
    CONSTRAINT PK_Quiz PRIMARY KEY (University_ID, Section_ID, Course_ID, Assessment_ID),
    
	CONSTRAINT FK_Quiz_University FOREIGN KEY (University_ID)
        REFERENCES [Users](University_ID),
    CONSTRAINT FK_Quiz_Section FOREIGN KEY (Section_ID)
        REFERENCES [Section](Section_ID),
    CONSTRAINT FK_Quiz_Course FOREIGN KEY (Course_ID)
        REFERENCES [Course](Course_ID),
    CONSTRAINT FK_Quiz_Assessment FOREIGN KEY (Assessment_ID)
        REFERENCES [Assessment](Assessment_ID),
	Grading_method Varchar(50) Default 'Highest Attemp' CHECK (Grading_method IN (
        'Highest Attemp',
        'Last Attemp'
    )),
	pass_score decimal(2,1) Default 5 CHECK (Pass_score BETWEEN 0 AND 10),
	Time_limits TIME NOT NULL,
    Start_Date DATETIME NOT NULL,
    End_Date DATETIME NOT NULL,
    CONSTRAINT CK_Quiz_Dates CHECK (Start_Date < End_Date),
	CONSTRAINT CK_Quiz_Time CHECK (DATEDIFF(MINUTE, Start_Date, End_Date) > 0),
	
	Responses VARCHAR(100),
	completion_status varchar(100) default 'Not Taken' CHECK (completion_status IN ('Not Taken', 'In Progress', 'Submitted', 'Passed', 'Failed')),
	score decimal(10,2) Default 0 CHECK (score BETWEEN 0 AND 10),
	content varchar(100) NOT NULL,
	[types] varchar(50),
	Weight FLOAT CHECK (Weight >= 0),
	Correct_answer varchar(50) NOT NULL
);

CREATE TABLE [Assignment] (
    University_ID DECIMAL(6,0),
    Section_ID INT,
    Course_ID INT,
    Assessment_ID INT,
    CONSTRAINT PK_Assignment PRIMARY KEY (University_ID, Section_ID, Course_ID, Assessment_ID),
    CONSTRAINT FK_Assignment_University FOREIGN KEY (University_ID)
        REFERENCES [Users](University_ID),
    CONSTRAINT FK_Assignment_Section FOREIGN KEY (Section_ID)
        REFERENCES [Section](Section_ID),
    CONSTRAINT FK_Assignment_Course FOREIGN KEY (Course_ID)
        REFERENCES [Course](Course_ID),
    CONSTRAINT FK_Assignment_Assessment FOREIGN KEY (Assessment_ID)
        REFERENCES [Assessment](Assessment_ID),
	MaxScore INT Default 10 CHECK (MaxScore BETWEEN 0 AND 10),
	accepted_specification varchar(50),
	submission_deadline datetime not null,
	instructions varchar(50),
	
);

CREATE TABLE [Submission] (
    University_ID DECIMAL(6,0),
    Section_ID INT,
    Course_ID INT,
    Assessment_ID INT,
    CONSTRAINT FK_Submission_University FOREIGN KEY (University_ID)
        REFERENCES [Users](University_ID),
    CONSTRAINT FK_Submission_Section FOREIGN KEY (Section_ID)
        REFERENCES [Section](Section_ID),
    CONSTRAINT FK_Submission_Course FOREIGN KEY (Course_ID)
        REFERENCES [Course](Course_ID),
    CONSTRAINT FK_Submission_Assessment FOREIGN KEY (Assessment_ID)
        REFERENCES [Assessment](Assessment_ID),
	Submission_No INT IDENTITY(1,1) PRIMARY KEY,
	accepted_specification varchar(50),
	late_flag_indicator BIT DEFAULT 0,
	SubmitDate DATETIME DEFAULT GETDATE(),
	attached_files varchar(50),
	[status] varchar(50) default 'Submitted' CHECK ([status] IN ('No Submission', 'Submitted')),
);

create table [review](
	Review_ID INT IDENTITY(1,1) PRIMARY KEY,
	Submission_No INT NOT NULL,
	University_ID DECIMAL(6,0),
	CONSTRAINT FK_Review_Submission FOREIGN KEY (Submission_No)
        REFERENCES [Submission](Submission_No),
	CONSTRAINT FK_Review_University FOREIGN KEY (University_ID)
        REFERENCES [Tutor](University_ID),
	Score INT CHECK (Score BETWEEN 0 AND 10),
	Comments VARCHAR(500),
);