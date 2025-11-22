USE [lms_system];
GO

DELETE FROM [takes_place];
GO

DECLARE @Cur_Section_ID NVARCHAR(10);
DECLARE @Cur_Course_ID NVARCHAR(15);
DECLARE @Cur_Semester NVARCHAR(10);

DECLARE @Rand_Room_ID INT;
DECLARE @Rand_Building_Name NVARCHAR(10);

DECLARE section_cursor CURSOR FOR
SELECT Section_ID, Course_ID, Semester
FROM [Section];

OPEN section_cursor;

FETCH NEXT FROM section_cursor 
INTO @Cur_Section_ID, @Cur_Course_ID, @Cur_Semester;

WHILE @@FETCH_STATUS = 0
BEGIN

    SELECT TOP 1 
        @Rand_Building_Name = Building_Name, 
        @Rand_Room_ID = Room_ID
    FROM [Room]
    ORDER BY NEWID(); 

    INSERT INTO [takes_place] (
        Section_ID, Course_ID, Semester, 
        Room_ID, Building_Name
    )
    VALUES (
        @Cur_Section_ID, @Cur_Course_ID, @Cur_Semester,
        @Rand_Room_ID, @Rand_Building_Name  
    );

    FETCH NEXT FROM section_cursor 
    INTO @Cur_Section_ID, @Cur_Course_ID, @Cur_Semester;
END;

CLOSE section_cursor;
DEALLOCATE section_cursor;
