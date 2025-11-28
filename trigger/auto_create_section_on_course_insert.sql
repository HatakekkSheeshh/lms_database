USE [lms_system];
GO

IF OBJECT_ID('trg_AutoCreateSectionOnCourseInsert', 'TR') IS NOT NULL
    DROP TRIGGER trg_AutoCreateSectionOnCourseInsert;
GO

CREATE TRIGGER trg_AutoCreateSectionOnCourseInsert
ON [Course]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Course_ID NVARCHAR(15);
    DECLARE @Credit INT;
    -- Default semester: latest semester (242)
    DECLARE @CurrentSemester NVARCHAR(10) = '242'; 
    DECLARE @SectionCount INT = 5;
    
    -- Cursor to iterate through inserted courses
    DECLARE course_cursor CURSOR FOR
        SELECT Course_ID, Credit
        FROM inserted;
    
    OPEN course_cursor;
    FETCH NEXT FROM course_cursor INTO @Course_ID, @Credit;
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Check if sections already exist for this course and semester
        IF NOT EXISTS (
            SELECT 1 FROM [Section] 
            WHERE Course_ID = @Course_ID 
            AND Semester = @CurrentSemester
        )
        BEGIN
            -- Insert sections
            INSERT INTO [Section] (Section_ID, Course_ID, Semester)
            VALUES 
                ('CC01', @Course_ID, @CurrentSemester),
                ('CC02', @Course_ID, @CurrentSemester),
                ('L01', @Course_ID, @CurrentSemester),
                ('L02', @Course_ID, @CurrentSemester),
                ('KSTN1', @Course_ID, @CurrentSemester);
            
            PRINT 'Auto-created 5 default sections for course: ' + @Course_ID + ' in semester ' + @CurrentSemester;
            PRINT 'Note: Scheduler records can be created separately if needed.';
            PRINT 'Note: Other tables (Teaches, Assessment, takes_place, Online) require additional info (Tutor, Student, Room, Platform) and will be populated separately';
        END
        
        FETCH NEXT FROM course_cursor INTO @Course_ID, @Credit;
    END
    
    CLOSE course_cursor;
    DEALLOCATE course_cursor;
END;
GO

PRINT 'Trigger trg_AutoCreateSectionOnCourseInsert created successfully';
PRINT 'This trigger will automatically:';
PRINT '  1. Create 5 default sections (CC01, CC02, L01, L02, KSTN1) for each new course';
PRINT 'IMPORTANT: This trigger creates sections for SEMESTER 242 (latest semester)';
PRINT '           For custom section counts, use procedure sp_CreateCourseWithSections instead';
PRINT 'Note: Scheduler records can be created separately if needed.';
PRINT 'Note: Other tables (Teaches, Assessment, takes_place, Online) require additional info';
PRINT '      and will be populated separately using their respective insert scripts.';
GO

