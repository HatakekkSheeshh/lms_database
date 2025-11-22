USE [lms_system];
GO

DELETE FROM [takes_place];
GO

DECLARE @Cur_Section_ID NVARCHAR(10);
DECLARE @Cur_Course_ID NVARCHAR(15);
DECLARE @Cur_Semester NVARCHAR(10);

DECLARE @Rand_Building_Name NVARCHAR(10);
DECLARE @Rand_Room_Name NVARCHAR(10);

DECLARE section_cursor CURSOR FOR
SELECT Section_ID, Course_ID, Semester
FROM [Section]
ORDER BY Semester, Course_ID, Section_ID;

OPEN section_cursor;

FETCH NEXT FROM section_cursor 
INTO @Cur_Section_ID, @Cur_Course_ID, @Cur_Semester;

WHILE @@FETCH_STATUS = 0
BEGIN
    -- Select a random room with Building_Name and Room_Name
    SELECT TOP 1 
        @Rand_Building_Name = Building_Name, 
        @Rand_Room_Name = Room_Name
    FROM [Room]
    WHERE Room_Name IS NOT NULL
      AND Building_Name IS NOT NULL
    ORDER BY NEWID(); 

    -- Insert into takes_place with Building_Name and Room_Name
    INSERT INTO [takes_place] (
        Section_ID, Course_ID, Semester, 
        Building_Name, Room_Name
    )
    VALUES (
        @Cur_Section_ID, @Cur_Course_ID, @Cur_Semester,
        @Rand_Building_Name, @Rand_Room_Name
    );

    -- Reset variables
    SET @Rand_Building_Name = NULL;
    SET @Rand_Room_Name = NULL;

    FETCH NEXT FROM section_cursor 
    INTO @Cur_Section_ID, @Cur_Course_ID, @Cur_Semester;
END;

CLOSE section_cursor;
DEALLOCATE section_cursor;

-- ============================================
-- Verify results
-- ============================================

DECLARE @TotalTakesPlace INT;
SELECT @TotalTakesPlace = COUNT(*) FROM [takes_place];

DECLARE @TakesPlaceWithRoomName INT;
SELECT @TakesPlaceWithRoomName = COUNT(*) FROM [takes_place] WHERE Room_Name IS NOT NULL;

PRINT '';
PRINT '========================================';
PRINT 'takes_place insertion completed!';
PRINT '========================================';
PRINT 'Total takes_place records: ' + CAST(@TotalTakesPlace AS NVARCHAR(10));
PRINT 'Records with Room_Name: ' + CAST(@TakesPlaceWithRoomName AS NVARCHAR(10));
PRINT '';
GO
