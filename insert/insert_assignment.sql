USE [lms_system];
GO

DELETE FROM [Assignment];
GO

DECLARE 
    @Cur_University_ID DECIMAL(7,0),
    @Cur_Section_ID NVARCHAR(10),
    @Cur_Course_ID NVARCHAR(15),
    @Cur_Semester NVARCHAR(10),
    @Cur_Assessment_ID INT;

DECLARE @Assignment_Spec NVARCHAR(50);
DECLARE @Assignment_Deadline DATETIME;
DECLARE @Assignment_Instructions NVARCHAR(50);

SET @Assignment_Spec = N'.pdf, .docx, .zip';

DECLARE assignment_cursor CURSOR FOR
SELECT 
    University_ID, 
    Section_ID, 
    Course_ID, 
    Semester, 
    Assessment_ID
FROM [Assessment]
WHERE Assessment_ID = 2; 

OPEN assignment_cursor;

FETCH NEXT FROM assignment_cursor 
INTO @Cur_University_ID, @Cur_Section_ID, @Cur_Course_ID, @Cur_Semester, @Cur_Assessment_ID;

WHILE @@FETCH_STATUS = 0
BEGIN

    IF @Cur_Semester = '241'
    BEGIN
        SET @Assignment_Deadline = '2025-01-10 23:59:00'; 
        SET @Assignment_Instructions = N'Final Report HK241';
    END
    ELSE
    BEGIN
        SET @Assignment_Deadline = '2025-06-10 23:59:00';
        SET @Assignment_Instructions = N'Final Report HK242';
    END;

    INSERT INTO [Assignment] (
        University_ID, Section_ID, Course_ID, Semester, Assessment_ID, 
        accepted_specification, submission_deadline, instructions
    )
    VALUES (
        @Cur_University_ID, @Cur_Section_ID, @Cur_Course_ID, @Cur_Semester, @Cur_Assessment_ID,
        @Assignment_Spec,
        @Assignment_Deadline,
        @Assignment_Instructions
    );

    FETCH NEXT FROM assignment_cursor 
    INTO @Cur_University_ID, @Cur_Section_ID, @Cur_Course_ID, @Cur_Semester, @Cur_Assessment_ID;
END;

CLOSE assignment_cursor;
DEALLOCATE assignment_cursor;