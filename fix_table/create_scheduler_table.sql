USE [lms_system];
GO

-- ============================================
-- Create Scheduler table
-- ============================================

IF OBJECT_ID('Scheduler', 'U') IS NOT NULL
BEGIN
    DROP TABLE [Scheduler];
    PRINT 'Dropped existing Scheduler table';
END
GO

CREATE TABLE [Scheduler] (
    Section_ID NVARCHAR(10) NOT NULL,
    Course_ID NVARCHAR(15) NOT NULL,
    Semester NVARCHAR(10) NOT NULL,
    Day_of_Week INT NOT NULL CHECK (Day_of_Week BETWEEN 1 AND 6), -- 1=Monday, 2=Tuesday, ..., 6=Saturday
    Start_Period INT NOT NULL CHECK (Start_Period BETWEEN 1 AND 13), -- Period 1 = 6 AM, Period 13 = 18 AM
    End_Period INT NOT NULL CHECK (End_Period BETWEEN 1 AND 13),
    
    CONSTRAINT PK_Scheduler PRIMARY KEY (Section_ID, Course_ID, Semester),
    
    CONSTRAINT FK_Scheduler_Section FOREIGN KEY (Section_ID, Course_ID, Semester)
        REFERENCES [Section](Section_ID, Course_ID, Semester),
    
    CONSTRAINT CK_Scheduler_Period CHECK (Start_Period <= End_Period),
    CONSTRAINT CK_Scheduler_Period_Range CHECK (End_Period - Start_Period + 1 BETWEEN 2 AND 3)
);
GO

PRINT 'Created Scheduler table successfully';
GO

