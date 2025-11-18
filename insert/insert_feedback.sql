USE [lms_system];
GO
DELETE FROM [Feedback];
GO

DECLARE @Cur_Uni_ID DECIMAL(7,0);
DECLARE @Cur_Sec_ID NVARCHAR(10);
DECLARE @Cur_Cou_ID NVARCHAR(15);
DECLARE @Cur_Sem NVARCHAR(10);
DECLARE @Cur_Ass_ID INT;

DECLARE @Score_Final DECIMAL(4,2);
DECLARE @Score_Midterm DECIMAL(4,2);
DECLARE @Score_Quiz DECIMAL(4,2);
DECLARE @Score_Assign DECIMAL(4,2);
DECLARE @Average_Score DECIMAL(4,2);

DECLARE @Feedback_Text NVARCHAR(255);

DECLARE feedback_cursor CURSOR FOR
SELECT 
    University_ID, 
    Section_ID, 
    Course_ID, 
    Semester, 
    Assessment_ID,
    Final_Grade,
    Midterm_Grade,
    Quiz_Grade,
    Assignment_Grade
FROM [Assessment];

OPEN feedback_cursor;

FETCH NEXT FROM feedback_cursor 
INTO @Cur_Uni_ID, @Cur_Sec_ID, @Cur_Cou_ID, @Cur_Sem, @Cur_Ass_ID, 
     @Score_Final, @Score_Midterm, @Score_Quiz, @Score_Assign;
WHILE @@FETCH_STATUS = 0
BEGIN
    SET @Average_Score = (ISNULL(@Score_Final, 0) * 0.4) + 
                         (ISNULL(@Score_Midterm, 0) * 0.3) + 
                         (ISNULL(@Score_Quiz, 0) * 0.1) + 
                         (ISNULL(@Score_Assign, 0) * 0.2);
    IF @Average_Score >= 8.0
    BEGIN
        SET @Feedback_Text = CASE CAST(RAND() * 4 AS INT)
            WHEN 0 THEN N'Excellent performance. Keep up the great work!'
            WHEN 1 THEN N'Outstanding understanding of the course material.'
            WHEN 2 THEN N'Very impressive results. Highly commanded.'
            ELSE N'Great job! You have mastered the subject.'
        END;
    END
    ELSE IF @Average_Score >= 6.5
    BEGIN
        SET @Feedback_Text = CASE CAST(RAND() * 4 AS INT)
            WHEN 0 THEN N'Good effort. You have a solid grasp of the basics.'
            WHEN 1 THEN N'Well done. Consistent performance throughout the semester.'
            WHEN 2 THEN N'Good results, but there is still room for improvement.'
            ELSE N'Satisfactory performance. Keep pushing for higher grades.'
        END;
    END
    ELSE IF @Average_Score >= 5.0
    BEGIN
        SET @Feedback_Text = CASE CAST(RAND() * 4 AS INT)
            WHEN 0 THEN N'You passed, but you need to study harder next time.'
            WHEN 1 THEN N'Average performance. Review the material to improve.'
            WHEN 2 THEN N'Met the minimum requirements. Try to engage more in class.'
            ELSE N'You need to put in more effort to fully understand the concepts.'
        END;
    END
    ELSE
    BEGIN
        SET @Feedback_Text = CASE CAST(RAND() * 4 AS INT)
            WHEN 0 THEN N'Poor performance. Significant improvement is needed.'
            WHEN 1 THEN N'You are struggling with the course content. Please seek help.'
            WHEN 2 THEN N'Did not meet the learning outcomes. Retake recommended.'
            ELSE N'Disappointing results. You need to attend more classes.'
        END;
    END;
    INSERT INTO [Feedback] (
        feedback, 
        University_ID, Section_ID, Course_ID, Semester, Assessment_ID
    )
    VALUES (
        @Feedback_Text, 
        @Cur_Uni_ID, @Cur_Sec_ID, @Cur_Cou_ID, @Cur_Sem, @Cur_Ass_ID
    );
    FETCH NEXT FROM feedback_cursor 
    INTO @Cur_Uni_ID, @Cur_Sec_ID, @Cur_Cou_ID, @Cur_Sem, @Cur_Ass_ID, 
         @Score_Final, @Score_Midterm, @Score_Quiz, @Score_Assign;
END;

CLOSE feedback_cursor;
DEALLOCATE feedback_cursor;
