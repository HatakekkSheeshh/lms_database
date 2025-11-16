USE [lms_system];
GO

DELETE FROM [Quiz];
GO

DECLARE 
    @Cur_University_ID DECIMAL(7,0),
    @Cur_Section_ID NVARCHAR(10),
    @Cur_Course_ID NVARCHAR(15),
    @Cur_Semester NVARCHAR(10),
    @Cur_Assessment_ID INT,
    @Cur_Grade DECIMAL(4,2), 
    @Quiz_Time_Limit TIME,
    @Quiz_Start DATETIME,
    @Quiz_End DATETIME,
    @Quiz_Content NVARCHAR(100),
    @Quiz_Answers NVARCHAR(50),
    @Quiz_Type NVARCHAR(50),
    @Quiz_Weight FLOAT,
    @Student_Responses NVARCHAR(100),
    @Completion_Status NVARCHAR(100),
    @Pass_Score DECIMAL(3,1);

SET @Pass_Score = 5.0;

DECLARE quiz_cursor CURSOR FOR
SELECT 
    University_ID, 
    Section_ID, 
    Course_ID, 
    Semester, 
    Assessment_ID,
    Grade 
FROM [Assessment]
WHERE Assessment_ID = 1; 

OPEN quiz_cursor;

FETCH NEXT FROM quiz_cursor 
INTO @Cur_University_ID, @Cur_Section_ID, @Cur_Course_ID, @Cur_Semester, @Cur_Assessment_ID, @Cur_Grade;

WHILE @@FETCH_STATUS = 0
BEGIN

    SET @Quiz_Time_Limit = '00:45:00'; 
    SET @Quiz_Content = N'Midterm Quiz - ' + @Cur_Course_ID;
    SET @Quiz_Type = N'Multiple Choice';
    SET @Quiz_Weight = 0.3; 
    SET @Quiz_Answers = N'A,C,B,D,A,C,C,B,D,A'; 
    SET @Student_Responses = N'A,B,B,D,A,C,D,B,D,C'; 

    IF @Cur_Semester = '241'
    BEGIN
        SET @Quiz_Start = '2024-10-20 07:00:00'; 
        SET @Quiz_End = '2024-10-27 23:59:00';   
    END
    ELSE
    BEGIN
        SET @Quiz_Start = '2025-03-15 07:00:00'; 
        SET @Quiz_End = '2025-03-22 23:59:00';   
    END;

    IF @Cur_Grade >= @Pass_Score
        SET @Completion_Status = 'Passed';
    ELSE
        SET @Completion_Status = 'Failed';

    INSERT INTO [Quiz] (
        University_ID, Section_ID, Course_ID, Semester, Assessment_ID, 
        Grading_method, pass_score, Time_limits, [Start_Date], End_Date, 
        Responses, completion_status, score, 
        content, [types], [Weight], Correct_answer
    )
    VALUES (
        @Cur_University_ID, @Cur_Section_ID, @Cur_Course_ID, @Cur_Semester, @Cur_Assessment_ID,
        'Highest Attemp', @Pass_Score, @Quiz_Time_Limit, @Quiz_Start, @Quiz_End,
        @Student_Responses, @Completion_Status, @Cur_Grade, -- Lấy điểm từ [Assessment]
        @Quiz_Content, @Quiz_Type, @Quiz_Weight, @Quiz_Answers
    );

    FETCH NEXT FROM quiz_cursor 
    INTO @Cur_University_ID, @Cur_Section_ID, @Cur_Course_ID, @Cur_Semester, @Cur_Assessment_ID, @Cur_Grade;
END;


CLOSE quiz_cursor;
DEALLOCATE quiz_cursor;

