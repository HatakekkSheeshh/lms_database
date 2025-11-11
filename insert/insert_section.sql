USE [database_systems_asm2];
GO


DECLARE @Current_Course_ID NVARCHAR(15);
DECLARE @Current_Semester NVARCHAR(10);
DECLARE @Counter INT;
DECLARE course_cursor CURSOR FOR
SELECT Course_ID FROM [Course];

OPEN course_cursor;
FETCH NEXT FROM course_cursor INTO @Current_Course_ID;
WHILE @@FETCH_STATUS = 0
BEGIN
    SET @Current_Semester = '241';
    SET @Counter = 1;
    WHILE @Counter <= 5
    BEGIN
        INSERT INTO [Section] (Section_ID, Course_ID, Semester)
        VALUES (N'CC0' + CAST(@Counter AS NVARCHAR(1)), @Current_Course_ID, @Current_Semester);
        SET @Counter = @Counter + 1;
    END;
    SET @Counter = 1;
    WHILE @Counter <= 5
    BEGIN
        INSERT INTO [Section] (Section_ID, Course_ID, Semester)
        VALUES (N'L0' + CAST(@Counter AS NVARCHAR(1)), @Current_Course_ID, @Current_Semester);
        SET @Counter = @Counter + 1;
    END;
    INSERT INTO [Section] (Section_ID, Course_ID, Semester) VALUES (N'CLC1', @Current_Course_ID, @Current_Semester);
    INSERT INTO [Section] (Section_ID, Course_ID, Semester) VALUES (N'KSTN1', @Current_Course_ID, @Current_Semester);
    SET @Current_Semester = '242';
    SET @Counter = 1;
    WHILE @Counter <= 5
    BEGIN
        INSERT INTO [Section] (Section_ID, Course_ID, Semester)
        VALUES (N'CC0' + CAST(@Counter AS NVARCHAR(1)), @Current_Course_ID, @Current_Semester);
        SET @Counter = @Counter + 1;
    END;
    SET @Counter = 1;
    WHILE @Counter <= 5
    BEGIN
        INSERT INTO [Section] (Section_ID, Course_ID, Semester)
        VALUES (N'L0' + CAST(@Counter AS NVARCHAR(1)), @Current_Course_ID, @Current_Semester);
        SET @Counter = @Counter + 1;
    END;
    INSERT INTO [Section] (Section_ID, Course_ID, Semester) VALUES (N'CLC1', @Current_Course_ID, @Current_Semester);
    INSERT INTO [Section] (Section_ID, Course_ID, Semester) VALUES (N'KSTN1', @Current_Course_ID, @Current_Semester);
    FETCH NEXT FROM course_cursor INTO @Current_Course_ID;
END;
CLOSE course_cursor;
DEALLOCATE course_cursor;
