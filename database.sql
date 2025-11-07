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
    Domain VARCHAR(50) NOT NULL
);

CREATE TABLE [Users] (
    University_ID DECIMAL(7,0) PRIMARY KEY,
    First_Name VARCHAR(50),
    Last_Name VARCHAR(50),
    Email VARCHAR(50) NOT NULL,
    Phone_Number VARCHAR(10) CHECK (LEN(Phone_Number) = 10),
    [Address] VARCHAR(50),
    National_ID DECIMAL(12,0) UNIQUE,
    System_name VARCHAR(50) NOT NULL,
    CONSTRAINT FK_User_System FOREIGN KEY (System_name)
        REFERENCES [System](System_name)
);

CREATE TABLE [Account] (
    University_ID DECIMAL(7,0), /* Phải là (7,0) để khớp với bảng [Users] */
    [Password] VARCHAR(50),
    CONSTRAINT PK_Account PRIMARY KEY (University_ID),
    CONSTRAINT FK_Account_User FOREIGN KEY (University_ID)
        REFERENCES [Users](University_ID)
);

CREATE TABLE [Admin] (
    University_ID DECIMAL(7,0) PRIMARY KEY,
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
    System_name VARCHAR(50) NOT NULL, 
    [timestamp] DATETIME NOT NULL DEFAULT GETDATE(),
    affected_entities VARCHAR(255), 
    section_creation VARCHAR(500),
    deadline_extensions VARCHAR(500),
    grade_updates VARCHAR(500),
    CONSTRAINT FK_AuditLog_System FOREIGN KEY (System_name)
        REFERENCES [System](System_name)
);

CREATE TABLE [Reference_To] (
    LogID INT,
    University_ID DECIMAL(7,0),
    CONSTRAINT PK_Reference PRIMARY KEY (LogID, University_ID),
    CONSTRAINT FK_Reference_Log FOREIGN KEY (LogID)
        REFERENCES [Audit_Log](LogID),
    CONSTRAINT FK_Reference_User FOREIGN KEY (University_ID)
        REFERENCES [Users](University_ID)
);

Create table [Student](
	University_ID DECIMAL(7,0) PRIMARY KEY,
	CONSTRAINT FK_Student_User FOREIGN KEY (University_ID)
        REFERENCES [Users](University_ID),
	Major VARCHAR(50) not null,
	Current_degree VARCHAR(50) DEFAULT 'Bachelor'
);

CREATE TABLE [Department] (
    Department_Name VARCHAR(50) PRIMARY KEY,
    University_ID DECIMAL(7,0) 
);
GO

CREATE TABLE [Tutor] (
    University_ID DECIMAL(7,0) PRIMARY KEY, 
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
GO

ALTER TABLE [Department]
ADD CONSTRAINT FK_Department_Tutor_Chair
    FOREIGN KEY (University_ID)
    REFERENCES [Tutor](University_ID);
GO

CREATE TABLE [Course] (
    Course_ID INT IDENTITY(1,1) PRIMARY KEY,
    [Name] VARCHAR(50) NOT NULL UNIQUE,
    Credit INT CHECK (Credit BETWEEN 1 AND 10),
    Start_Date DATE
);

CREATE TABLE [Section] (
    Section_ID INT NOT NULL, 
    Course_ID INT NOT NULL,
    Semester VARCHAR(10) NOT NULL,
    
    CONSTRAINT PK_Section PRIMARY KEY (Section_ID, Course_ID), 
    
    CONSTRAINT FK_Section_Course FOREIGN KEY (Course_ID)
        REFERENCES [Course](Course_ID)
);

CREATE TABLE [Teaches] (
    University_ID DECIMAL(7,0),
    Section_ID INT,
    Course_ID INT,
    Role_Specification VARCHAR(50),
    [Timestamp] DATETIME,
    
    CONSTRAINT PK_Teaches PRIMARY KEY (University_ID, Section_ID, Course_ID),
    
    CONSTRAINT FK_Teaches_Tutor FOREIGN KEY (University_ID)
        REFERENCES [Tutor](University_ID),
        
    CONSTRAINT FK_Teaches_Section FOREIGN KEY (Section_ID, Course_ID)
        REFERENCES [Section](Section_ID, Course_ID)
);

CREATE TABLE [Assessment] (
    University_ID DECIMAL(7,0) NOT NULL,
    Section_ID INT NOT NULL,
    Course_ID INT NOT NULL,
    Assessment_ID INT NOT NULL, 
    Grade DECIMAL(4,2) CHECK (Grade BETWEEN 0 AND 15), --có thể >10
    Registration_Date DATE DEFAULT GETDATE(),
    Potential_Withdrawal_Date DATE,
    [Status] VARCHAR(50) DEFAULT 'Pending' CHECK ([Status] IN ('Pending', 'Approved', 'Rejected', 'Cancelled')),
    
    CONSTRAINT PK_Assessment PRIMARY KEY (University_ID, Section_ID, Course_ID, Assessment_ID),
    
    CONSTRAINT CK_Assessment_Dates CHECK (Registration_Date <= Potential_Withdrawal_Date),
    
    CONSTRAINT FK_Assessment_Student FOREIGN KEY (University_ID)
        REFERENCES [Student](University_ID),
        
    CONSTRAINT FK_Assessment_Section FOREIGN KEY (Section_ID, Course_ID)
        REFERENCES [Section](Section_ID, Course_ID)
);

CREATE TABLE [Feedback] (
    feedback VARCHAR(255) NOT NULL,
    University_ID DECIMAL(7,0) NOT NULL,
    Section_ID INT NOT NULL,
    Course_ID INT NOT NULL,
    Assessment_ID INT NOT NULL,
    
    CONSTRAINT PK_Feedback PRIMARY KEY 
        (feedback, University_ID, Section_ID, Course_ID, Assessment_ID),
        
    CONSTRAINT FK_Feedback_Assessment FOREIGN KEY 
        (University_ID, Section_ID, Course_ID, Assessment_ID)
        REFERENCES [Assessment](University_ID, Section_ID, Course_ID, Assessment_ID)
);

create table [Building](
	Building_ID INT IDENTITY(1,1) PRIMARY KEY
);

CREATE TABLE [Room](
    Room_ID INT NOT NULL, 
    Building_ID INT NOT NULL,
    Capacity INT DEFAULT 30 CHECK (Capacity BETWEEN 1 AND 300),

    CONSTRAINT PK_Room PRIMARY KEY (Building_ID, Room_ID),
    
    CONSTRAINT FK_Room_Building FOREIGN KEY (Building_ID)
        REFERENCES [Building](Building_ID)
);


CREATE TABLE [Room_Equipment](
    Equipment_Name VARCHAR(100) NOT NULL,
    Building_ID INT NOT NULL,
    Room_ID INT NOT NULL,
    
    CONSTRAINT PK_Room_Equipment PRIMARY KEY (Building_ID, Room_ID, Equipment_Name),
    
    CONSTRAINT FK_Equipment_Room FOREIGN KEY (Building_ID, Room_ID)
        REFERENCES [Room](Building_ID, Room_ID)
);

CREATE TABLE [takes_place](
	Section_ID INT NOT NULL,
	Course_ID INT NOT NULL,
	Room_ID INT NOT NULL,
	Building_ID INT NOT NULL,
	
	CONSTRAINT PK_Place PRIMARY KEY (Section_ID, Course_ID, Room_ID, Building_ID),
	
	CONSTRAINT FK_Place_Section FOREIGN KEY (Section_ID, Course_ID)
        REFERENCES [Section](Section_ID, Course_ID),

	CONSTRAINT FK_Place_Room FOREIGN KEY (Building_ID, Room_ID)
        REFERENCES [Room](Building_ID, Room_ID)
);

CREATE TABLE [Platform](
	Platform_ID INT IDENTITY(1,1) PRIMARY KEY,
	[Name] VARCHAR(50)
);

CREATE TABLE [Platform_Link](
    Platform_ID INT NOT NULL,
    Link VARCHAR(255) NOT NULL,
    CONSTRAINT PK_Platform_Link PRIMARY KEY (Platform_ID, Link),
    CONSTRAINT FK_Link_Platform FOREIGN KEY (Platform_ID)
        REFERENCES [Platform](Platform_ID)
);

CREATE TABLE [Online](
	Platform_ID INT NOT NULL,
	Section_ID INT NOT NULL,
	Course_ID INT NOT NULL,
	
	CONSTRAINT PK_Online PRIMARY KEY (Platform_ID, Section_ID, Course_ID),
	
	CONSTRAINT FK_Online_Platform FOREIGN KEY (Platform_ID)
        REFERENCES [Platform](Platform_ID),
	
	CONSTRAINT FK_Online_Section FOREIGN KEY (Section_ID, Course_ID)
      	REFERENCES [Section](Section_ID, Course_ID)
);

CREATE TABLE [Quiz] (
    University_ID DECIMAL(7,0) NOT NULL,
    Section_ID INT NOT NULL,
    Course_ID INT NOT NULL,
    Assessment_ID INT NOT NULL,
    
    CONSTRAINT PK_Quiz PRIMARY KEY (University_ID, Section_ID, Course_ID, Assessment_ID),
    
    CONSTRAINT FK_Quiz_Assessment FOREIGN KEY (University_ID, Section_ID, Course_ID, Assessment_ID)
        REFERENCES [Assessment](University_ID, Section_ID, Course_ID, Assessment_ID),

    Grading_method VARCHAR(50) DEFAULT 'Highest Attemp' CHECK (Grading_method IN (
        'Highest Attemp',
        'Last Attemp'
    )),
    
    pass_score DECIMAL(3,1) DEFAULT 5 CHECK (pass_score BETWEEN 0 AND 10),
    
    Time_limits TIME NOT NULL,
    [Start_Date] DATETIME NOT NULL,
    End_Date DATETIME NOT NULL,
    
    CONSTRAINT CK_Quiz_Dates CHECK ([Start_Date] < End_Date),
    
    Responses VARCHAR(100),
    completion_status VARCHAR(100) DEFAULT 'Not Taken' CHECK (completion_status IN ('Not Taken', 'In Progress', 'Submitted', 'Passed', 'Failed')),
    
    score DECIMAL(4,2) DEFAULT 0 CHECK (score BETWEEN 0 AND 10),
    
    content VARCHAR(100) NOT NULL,
    [types] VARCHAR(50),
    [Weight] FLOAT CHECK (Weight >= 0),
    Correct_answer VARCHAR(50) NOT NULL
);

CREATE TABLE [Assignment] (
    University_ID DECIMAL(7,0) NOT NULL,
    Section_ID INT NOT NULL,
    Course_ID INT NOT NULL,
    Assessment_ID INT NOT NULL,
    
    CONSTRAINT PK_Assignment PRIMARY KEY (University_ID, Section_ID, Course_ID, Assessment_ID),
    
    CONSTRAINT FK_Assignment_Assessment FOREIGN KEY (University_ID, Section_ID, Course_ID, Assessment_ID)
        REFERENCES [Assessment](University_ID, Section_ID, Course_ID, Assessment_ID),

    MaxScore INT DEFAULT 10 CHECK (MaxScore BETWEEN 0 AND 10),
    accepted_specification VARCHAR(50),
    submission_deadline DATETIME NOT NULL,
    instructions VARCHAR(50)
);

CREATE TABLE [Submission] (
    Submission_No INT IDENTITY(1,1) PRIMARY KEY,
    University_ID DECIMAL(7,0) NOT NULL,
    Section_ID INT NOT NULL,
    Course_ID INT NOT NULL,
    Assessment_ID INT NOT NULL,
	accepted_specification VARCHAR(50),
	late_flag_indicator BIT DEFAULT 0,
	SubmitDate DATETIME DEFAULT GETDATE(),
	attached_files VARCHAR(50),
	[status] VARCHAR(50) DEFAULT 'Submitted' CHECK ([status] IN ('No Submission', 'Submitted')),
	
    CONSTRAINT FK_Submission_Assignment FOREIGN KEY 
        (University_ID, Section_ID, Course_ID, Assessment_ID)
        REFERENCES [Assignment](University_ID, Section_ID, Course_ID, Assessment_ID)
);

CREATE TABLE [review](
    Submission_No INT NOT NULL PRIMARY KEY,
    University_ID DECIMAL(7,0) NOT NULL,
    Score INT CHECK (Score BETWEEN 0 AND 10),
    Comments VARCHAR(500),
	
    CONSTRAINT FK_Review_Submission FOREIGN KEY (Submission_No)
        REFERENCES [Submission](Submission_No),
	CONSTRAINT FK_Review_Tutor FOREIGN KEY (University_ID)
        REFERENCES [Tutor](University_ID)
);