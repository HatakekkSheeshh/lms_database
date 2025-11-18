USE [lms_system];
GO

DELETE FROM [review];
GO

DECLARE 
    @Cur_Submission_No INT,
    @Cur_Student_ID DECIMAL(7,0),
    @Cur_Section_ID NVARCHAR(10),
    @Cur_Course_ID NVARCHAR(15),
    @Cur_Semester NVARCHAR(10),
    @Cur_Assessment_ID INT,
    @Reviewer_Tutor_ID DECIMAL(7,0),
    @Student_Grade_Decimal DECIMAL(4,2),
    @Review_Score INT,
    @Review_Comment NVARCHAR(500);

DECLARE review_cursor CURSOR FOR
SELECT 
    Submission_No, 
    University_ID, 
    Section_ID, 
    Course_ID, 
    Semester, 
    Assessment_ID
FROM [Submission];

OPEN review_cursor;

FETCH NEXT FROM review_cursor 
INTO @Cur_Submission_No, @Cur_Student_ID, @Cur_Section_ID, @Cur_Course_ID, @Cur_Semester, @Cur_Assessment_ID;

WHILE @@FETCH_STATUS = 0
BEGIN
    

    SELECT TOP 1 @Reviewer_Tutor_ID = University_ID
    FROM [Teaches]
    WHERE Section_ID = @Cur_Section_ID 
      AND Course_ID = @Cur_Course_ID 
      AND Semester = @Cur_Semester
      AND Role_Specification = N'Main Lecturer';

    IF @Reviewer_Tutor_ID IS NULL
    BEGIN
        SELECT TOP 1 @Reviewer_Tutor_ID = University_ID FROM [Tutor] ORDER BY NEWID();
    END;

    SELECT @Student_Grade_Decimal = 
        CASE
            WHEN Midterm_Grade BETWEEN 0 AND 10 
                AND Final_Grade IS NOT NULL 
                    THEN ROUND((Midterm_Grade * 0.4 + Final_Grade * 0.6), 2)
            ELSE 0
        END
    FROM [Assessment]
    WHERE University_ID = @Cur_Student_ID
      AND Section_ID = @Cur_Section_ID
      AND Course_ID = @Cur_Course_ID
      AND Semester = @Cur_Semester
      AND Assessment_ID = @Cur_Assessment_ID;

    SET @Review_Score = ROUND(@Student_Grade_Decimal, 0);

    IF @Review_Score >= 8
        SET @Review_Comment = N'Excellent work. Well-researched and clearly written.';
    ELSE IF @Review_Score >= 5
        SET @Review_Comment = N'Good submission. Meets requirements, but lacks some in-depth analysis.';
    ELSE
        SET @Review_Comment = N'Needs improvement. Please review the instructions carefully.';

    INSERT INTO [review] (Submission_No, University_ID, Score, Comments)
    VALUES (
        @Cur_Submission_No,
        @Reviewer_Tutor_ID,
        @Review_Score,
        @Review_Comment
    );

    FETCH NEXT FROM review_cursor 
    INTO @Cur_Submission_No, @Cur_Student_ID, @Cur_Section_ID, @Cur_Course_ID, @Cur_Semester, @Cur_Assessment_ID;
END;

CLOSE review_cursor;
DEALLOCATE review_cursor;
