USE [lms_system];
GO


DECLARE @Cur_Section_ID NVARCHAR(10);
DECLARE @Cur_Course_ID NVARCHAR(15);
DECLARE @Cur_Semester NVARCHAR(10);
DECLARE @Tutor_ID_Main DECIMAL(7,0);
DECLARE @Tutor_ID_Assist DECIMAL(7,0);

DECLARE section_cursor CURSOR FOR
SELECT Section_ID, Course_ID, Semester
FROM [Section]
WHERE Course_ID LIKE 'CO%' OR Course_ID LIKE 'EE%';

OPEN section_cursor;

FETCH NEXT FROM section_cursor 
INTO @Cur_Section_ID, @Cur_Course_ID, @Cur_Semester;


WHILE @@FETCH_STATUS = 0
BEGIN
    


    SELECT TOP 1 @Tutor_ID_Main = University_ID 
    FROM [Tutor] 
    ORDER BY NEWID(); 
    

    SELECT TOP 1 @Tutor_ID_Assist = University_ID 
    FROM [Tutor] 
    WHERE University_ID != @Tutor_ID_Main 
    ORDER BY NEWID();

    INSERT INTO [Teaches] (University_ID, Section_ID, Course_ID, Semester, Role_Specification, [Timestamp])
    VALUES (@Tutor_ID_Main, @Cur_Section_ID, @Cur_Course_ID, @Cur_Semester, N'Main Lecturer', GETDATE());

    INSERT INTO [Teaches] (University_ID, Section_ID, Course_ID, Semester, Role_Specification, [Timestamp])
    VALUES (@Tutor_ID_Assist, @Cur_Section_ID, @Cur_Course_ID, @Cur_Semester, N'Teaching Assistant', GETDATE());

    FETCH NEXT FROM section_cursor 
    INTO @Cur_Section_ID, @Cur_Course_ID, @Cur_Semester;
END;

CLOSE section_cursor;
DEALLOCATE section_cursor;
