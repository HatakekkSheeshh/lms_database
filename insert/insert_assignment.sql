USE [lms_system];
GO

DELETE FROM [Assignment];
GO

DECLARE @rand INT;
DECLARE 
    @Cur_University_ID DECIMAL(7,0),
    @Cur_Section_ID NVARCHAR(10),
    @Cur_Course_ID NVARCHAR(15),
    @Cur_Semester NVARCHAR(10),
    @Cur_Assessment_ID INT;

DECLARE @Assignment_Spec NVARCHAR(50);
DECLARE @Assignment_Deadline DATETIME;
DECLARE @Assignment_Instructions NVARCHAR(50);
DECLARE @AssessmentCount INT;
DECLARE @ErrorMsg NVARCHAR(500);

-- Check if Assessment table has records with Assignment_Grade
SELECT @AssessmentCount = COUNT(*) 
FROM [Assessment]
WHERE [Assignment_Grade] IS NOT NULL;

IF @AssessmentCount = 0
BEGIN
    PRINT 'WARNING: No Assessment records found with Assignment_Grade. Please run insert_assessment.sql first.';
    RAISERROR('No Assessment records with Assignment_Grade found. Cannot insert assignments.', 16, 1);
END;

DECLARE @Msg NVARCHAR(200);
SET @Msg = 'Found ' + CAST(@AssessmentCount AS NVARCHAR(10)) + ' Assessment records with Assignment_Grade. Starting assignment insertion...';
PRINT @Msg;

-- SET @Assignment_Spec = N'.pdf, .docx, .zip';

DECLARE assignment_cursor CURSOR FOR
SELECT 
    University_ID, 
    Section_ID, 
    Course_ID, 
    Semester, 
    Assessment_ID
FROM [Assessment]
WHERE [Assignment_Grade] IS NOT NULL; 

OPEN assignment_cursor;

FETCH NEXT FROM assignment_cursor 
INTO @Cur_University_ID, @Cur_Section_ID, @Cur_Course_ID, @Cur_Semester, @Cur_Assessment_ID;

WHILE @@FETCH_STATUS = 0
BEGIN
    BEGIN TRY
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

        SET @rand = ABS(CHECKSUM(NEWID())) % 4 + 1;
        SET @Assignment_Spec =
            CASE @rand
                WHEN 0 THEN N'.pdf, .zip'
                WHEN 1 THEN N'.docx, .zip'
                WHEN 2 THEN N'.zip'
                WHEN 3 THEN N'.pdf'
                WHEN 4 THEN N'.docx'
            END;

        INSERT INTO [Assignment] (
            University_ID, Section_ID, Course_ID, Semester, Assessment_ID, 
            accepted_specification, submission_deadline, instructions
        )
        VALUES (
            @Cur_University_ID, 
            @Cur_Section_ID, 
            @Cur_Course_ID, 
            @Cur_Semester, 
            @Cur_Assessment_ID,
            @Assignment_Spec,
            @Assignment_Deadline,
            @Assignment_Instructions
        );
    END TRY
    BEGIN CATCH
        SET @ErrorMsg = 'Error inserting assignment for Assessment_ID: ' + CAST(@Cur_Assessment_ID AS NVARCHAR(10));
        PRINT @ErrorMsg;
        SET @ErrorMsg = 'Error Message: ' + ERROR_MESSAGE();
        PRINT @ErrorMsg;
    END CATCH;

    FETCH NEXT FROM assignment_cursor 
    INTO @Cur_University_ID, @Cur_Section_ID, @Cur_Course_ID, @Cur_Semester, @Cur_Assessment_ID;
END;

CLOSE assignment_cursor;
DEALLOCATE assignment_cursor;

DECLARE @AssignmentCount INT;
DECLARE @CompletionMsg NVARCHAR(200);
SELECT @AssignmentCount = COUNT(*) FROM [Assignment];
SET @CompletionMsg = 'Assignment insertion completed. Total assignments: ' + CAST(@AssignmentCount AS NVARCHAR(10));
PRINT @CompletionMsg;
GO