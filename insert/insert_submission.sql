USE [lms_system];
GO

DELETE FROM [Submission];
GO

PRINT N'--------------------------------------------------';
PRINT N'Start to insert Submissions for Assignments...';
PRINT N'--------------------------------------------------';

DECLARE 
    @Cur_University_ID DECIMAL(7,0),
    @Cur_Section_ID NVARCHAR(10),
    @Cur_Course_ID NVARCHAR(15),
    @Cur_Semester NVARCHAR(10),
    @Cur_Assessment_ID INT,
    @Cur_Deadline DATETIME,
    @Cur_Spec NVARCHAR(50);

DECLARE @SubmitDate DATETIME;
DECLARE @LateFlag BIT;
DECLARE @AttachedFile NVARCHAR(50);

DECLARE submission_cursor CURSOR FOR
SELECT 
    University_ID, 
    Section_ID, 
    Course_ID, 
    Semester, 
    Assessment_ID,
    submission_deadline,
    accepted_specification
FROM [Assignment]; 

OPEN submission_cursor;

FETCH NEXT FROM submission_cursor 
INTO @Cur_University_ID, @Cur_Section_ID, @Cur_Course_ID, @Cur_Semester, @Cur_Assessment_ID, @Cur_Deadline, @Cur_Spec;

WHILE @@FETCH_STATUS = 0
BEGIN

    IF RAND() < 0.8
    BEGIN
        SET @SubmitDate = DATEADD(DAY, -2, @Cur_Deadline); 
        SET @LateFlag = 0; 
    END
    ELSE
    BEGIN
        SET @SubmitDate = DATEADD(DAY, 1, @Cur_Deadline); 
        SET @LateFlag = 1;
    END;

    SET @AttachedFile = N'FinalReport_' + CAST(@Cur_University_ID AS NVARCHAR(7)) + N'.pdf';

    INSERT INTO [Submission] (
        University_ID, Section_ID, Course_ID, Semester, Assessment_ID,
        accepted_specification,
        late_flag_indicator,
        SubmitDate,
        attached_files,
        [status]
    )
    VALUES (
        @Cur_University_ID, @Cur_Section_ID, @Cur_Course_ID, @Cur_Semester, @Cur_Assessment_ID,
        @Cur_Spec,
        @LateFlag,
        @SubmitDate,
        @AttachedFile,
        'Submitted' 
    );

    FETCH NEXT FROM submission_cursor 
    INTO @Cur_University_ID, @Cur_Section_ID, @Cur_Course_ID, @Cur_Semester, @Cur_Assessment_ID, @Cur_Deadline, @Cur_Spec;
END;

CLOSE submission_cursor;
DEALLOCATE submission_cursor;
