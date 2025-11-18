USE [lms_system];
GO

DELETE FROM [Assessment];
GO

DECLARE @Cur_Student_ID DECIMAL(7,0);

DECLARE student_cursor CURSOR FOR
SELECT University_ID FROM [Student];

OPEN student_cursor;
FETCH NEXT FROM student_cursor INTO @Cur_Student_ID;

WHILE @@FETCH_STATUS = 0
BEGIN

    DECLARE @StudentSections TABLE (
        Section_ID NVARCHAR(10),
        Course_ID NVARCHAR(15),
        Semester NVARCHAR(10)
    );
    
    INSERT INTO @StudentSections (Section_ID, Course_ID, Semester)
    SELECT TOP 3 Section_ID, Course_ID, Semester 
    FROM [Section] 
    WHERE Semester = '241'
    ORDER BY NEWID();

    INSERT INTO @StudentSections (Section_ID, Course_ID, Semester)
    SELECT TOP 3 Section_ID, Course_ID, Semester 
    FROM [Section] 
    WHERE Semester = '242'
    ORDER BY NEWID();

    DECLARE @Cur_Section_ID NVARCHAR(10);
    DECLARE @Cur_Course_ID NVARCHAR(15);
    DECLARE @Cur_Semester NVARCHAR(10);
    DECLARE @Midterm_Grade DECIMAL(4,2);
    DECLARE @Final_Grade DECIMAL(4,2);
    DECLARE @Quiz_Grade DECIMAL(4,2);
    DECLARE @Assignment_Grade DECIMAL(4,2);

    DECLARE @Reg_Date DATE;
    DECLARE @Withdraw_Date DATE;


    DECLARE section_cursor CURSOR FOR
    SELECT Section_ID, Course_ID, Semester FROM @StudentSections;

    OPEN section_cursor;
    FETCH NEXT FROM section_cursor INTO @Cur_Section_ID, @Cur_Course_ID, @Cur_Semester;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @Midterm_Grade = ROUND(3.0 + (RAND() * 7.0), 1);
        SET @Final_Grade = ROUND(3.0 + (RAND() * 7.0), 1);
        SET @Quiz_Grade = ROUND(3.0 + (RAND() * 7.0), 1);
        SET @Assignment_Grade = ROUND(3.0 + (RAND() * 7.0), 1);

        IF @Cur_Semester = '241'
        BEGIN
            SET @Reg_Date = '2024-09-05';
            SET @Withdraw_Date = '2025-01-15'; 
        END
        ELSE
        BEGIN
            SET @Reg_Date = '2025-01-20'; 
            SET @Withdraw_Date = '2025-06-15'; 
        END

        INSERT INTO [Assessment] (
            University_ID, 
            Section_ID, 
            Course_ID, 
            Semester, 
            Registration_Date, 
            Potential_Withdrawal_Date, 
            [Status],
            Midterm_Grade,
            Final_Grade,
            Quiz_Grade,
            Assignment_Grade
        )
        VALUES (
            @Cur_Student_ID, 
            @Cur_Section_ID, 
            @Cur_Course_ID, 
            @Cur_Semester, 
            @Reg_Date, 
            @Withdraw_Date, 
            'Approved',
            @Midterm_Grade,
            @Final_Grade,
            @Quiz_Grade,
            @Assignment_Grade
        );
        
        FETCH NEXT FROM section_cursor INTO @Cur_Section_ID, @Cur_Course_ID, @Cur_Semester;
    END;

    CLOSE section_cursor;
    DEALLOCATE section_cursor;

    DELETE FROM @StudentSections;

    FETCH NEXT FROM student_cursor INTO @Cur_Student_ID;
END;

CLOSE student_cursor;
DEALLOCATE student_cursor;
