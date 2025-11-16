USE [lms_system];
GO

DELETE FROM [Online];
GO

DECLARE @Platforms TABLE (Platform_ID INT);
INSERT INTO @Platforms (Platform_ID) VALUES (0), (1), (2), (3), (4);

DECLARE @Cur_Section_ID NVARCHAR(10);
DECLARE @Cur_Course_ID NVARCHAR(15);
DECLARE @Cur_Semester NVARCHAR(10);
DECLARE @Random_Platform_ID INT;

DECLARE section_cursor CURSOR FOR
SELECT Section_ID, Course_ID, Semester
FROM [Section];

OPEN section_cursor;

FETCH NEXT FROM section_cursor 
INTO @Cur_Section_ID, @Cur_Course_ID, @Cur_Semester;

WHILE @@FETCH_STATUS = 0
BEGIN

    SELECT TOP 1 @Random_Platform_ID = Platform_ID 
    FROM @Platforms
    ORDER BY NEWID(); 

    INSERT INTO [Online] (Platform_ID, Section_ID, Course_ID, Semester)
    VALUES (@Random_Platform_ID, @Cur_Section_ID, @Cur_Course_ID, @Cur_Semester);

    FETCH NEXT FROM section_cursor 
    INTO @Cur_Section_ID, @Cur_Course_ID, @Cur_Semester;
END;

CLOSE section_cursor;
DEALLOCATE section_cursor;
