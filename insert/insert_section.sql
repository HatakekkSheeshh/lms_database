USE [lms_system];
GO

DELETE FROM [Teaches]
GO

DELETE FROM [Assessment]
GO

DELETE FROM [takes_place]
GO

DELETE FROM [Online];
GO

DELETE FROM [Section];
GO

DECLARE @Current_Course_ID NVARCHAR(15);
DECLARE @Current_Semester NVARCHAR(10);
DECLARE @Counter INT;
DECLARE @CourseCount INT;

-- Check if Course table has data
SELECT @CourseCount = COUNT(*) FROM [Course];
IF @CourseCount = 0
BEGIN
    PRINT 'WARNING: Course table is empty. Please run insert_course.sql first.';
    RAISERROR('Course table is empty. Cannot insert sections.', 16, 1);
END;

PRINT 'Found ' + CAST(@CourseCount AS NVARCHAR(10)) + ' courses. Starting section insertion...';

DECLARE course_cursor CURSOR FOR
SELECT Course_ID FROM [Course];

OPEN course_cursor;
FETCH NEXT FROM course_cursor INTO @Current_Course_ID;

WHILE @@FETCH_STATUS = 0
BEGIN
    BEGIN TRY
        SET @Current_Semester = '241';
        -- 2 CC0 sections
        INSERT INTO [Section] (Section_ID, Course_ID, Semester) VALUES (N'CC01', @Current_Course_ID, @Current_Semester);
        INSERT INTO [Section] (Section_ID, Course_ID, Semester) VALUES (N'CC02', @Current_Course_ID, @Current_Semester);
        -- 2 L0 sections
        INSERT INTO [Section] (Section_ID, Course_ID, Semester) VALUES (N'L01', @Current_Course_ID, @Current_Semester);
        INSERT INTO [Section] (Section_ID, Course_ID, Semester) VALUES (N'L02', @Current_Course_ID, @Current_Semester);
        -- 1 KSTN section
        INSERT INTO [Section] (Section_ID, Course_ID, Semester) VALUES (N'KSTN1', @Current_Course_ID, @Current_Semester);
        
        SET @Current_Semester = '242';
        -- 2 CC0 sections
        INSERT INTO [Section] (Section_ID, Course_ID, Semester) VALUES (N'CC01', @Current_Course_ID, @Current_Semester);
        INSERT INTO [Section] (Section_ID, Course_ID, Semester) VALUES (N'CC02', @Current_Course_ID, @Current_Semester);
        -- 2 L0 sections
        INSERT INTO [Section] (Section_ID, Course_ID, Semester) VALUES (N'L01', @Current_Course_ID, @Current_Semester);
        INSERT INTO [Section] (Section_ID, Course_ID, Semester) VALUES (N'L02', @Current_Course_ID, @Current_Semester);
        -- 1 KSTN section
        INSERT INTO [Section] (Section_ID, Course_ID, Semester) VALUES (N'KSTN1', @Current_Course_ID, @Current_Semester);
    END TRY
    BEGIN CATCH
        PRINT 'Error inserting sections for Course: ' + @Current_Course_ID;
        PRINT 'Error Message: ' + ERROR_MESSAGE();
    END CATCH;
    
    FETCH NEXT FROM course_cursor INTO @Current_Course_ID;
END;

CLOSE course_cursor;
DEALLOCATE course_cursor;

DECLARE @SectionCount INT;
SELECT @SectionCount = COUNT(*) FROM [Section];
PRINT 'Section insertion completed. Total sections: ' + CAST(@SectionCount AS NVARCHAR(10));
GO
