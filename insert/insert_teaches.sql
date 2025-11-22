USE [lms_system];
GO

-- ============================================
-- Script insert Teaches: Assign tutors to sections
-- Each section will have 1-2 tutors:
--   - 1 Main Lecturer (required)
--   - 1 Teaching Assistant (optional, ~50% of sections)
-- ============================================

DELETE FROM [Teaches];
GO

-- ============================================
-- Step 1: Assign 1 Main Lecturer to ALL sections first (PRIORITY)
-- ============================================

DECLARE @Cur_Section_ID NVARCHAR(10);
DECLARE @Cur_Course_ID NVARCHAR(15);
DECLARE @Cur_Semester NVARCHAR(10);
DECLARE @Tutor_ID_Main DECIMAL(7,0);

-- Cursor for ALL sections
DECLARE section_cursor_main CURSOR FOR
SELECT Section_ID, Course_ID, Semester
FROM [Section]
ORDER BY Semester, Course_ID, Section_ID;

OPEN section_cursor_main;

FETCH NEXT FROM section_cursor_main 
INTO @Cur_Section_ID, @Cur_Course_ID, @Cur_Semester;

WHILE @@FETCH_STATUS = 0
BEGIN
    -- Select a random Main Lecturer (can reuse tutors across different sections)
    SELECT TOP 1 @Tutor_ID_Main = University_ID 
    FROM [Tutor] 
    WHERE University_ID NOT IN (
        -- Avoid assigning same tutor to same section
        SELECT University_ID 
        FROM [Teaches] 
        WHERE Section_ID = @Cur_Section_ID 
          AND Course_ID = @Cur_Course_ID 
          AND Semester = @Cur_Semester
    )
    ORDER BY NEWID();
    
    -- Insert Main Lecturer (ensure every section has at least 1 tutor)
    IF @Tutor_ID_Main IS NOT NULL
    BEGIN
        INSERT INTO [Teaches] (University_ID, Section_ID, Course_ID, Semester, Role_Specification, [Timestamp])
        VALUES (@Tutor_ID_Main, @Cur_Section_ID, @Cur_Course_ID, @Cur_Semester, N'Main Lecturer', GETDATE());
    END;
    
    -- Reset variable for next iteration
    SET @Tutor_ID_Main = NULL;
    
    FETCH NEXT FROM section_cursor_main 
    INTO @Cur_Section_ID, @Cur_Course_ID, @Cur_Semester;
END;

CLOSE section_cursor_main;
DEALLOCATE section_cursor_main;

PRINT 'Step 1 completed: All sections have at least 1 Main Lecturer';
GO

-- ============================================
-- Step 2: Assign Teaching Assistant to some sections (if tutors available)
-- ============================================

DECLARE @Cur_Section_ID2 NVARCHAR(10);
DECLARE @Cur_Course_ID2 NVARCHAR(15);
DECLARE @Cur_Semester2 NVARCHAR(10);
DECLARE @Tutor_ID_Assist DECIMAL(7,0);
DECLARE @Tutor_ID_Existing DECIMAL(7,0);
DECLARE @HasAssistant BIT;

-- Cursor for sections that currently have only 1 tutor
DECLARE section_cursor_assist CURSOR FOR
SELECT s.Section_ID, s.Course_ID, s.Semester
FROM [Section] s
WHERE NOT EXISTS (
    -- Only select sections that have exactly 1 tutor
    SELECT 1
    FROM [Teaches] t
    WHERE t.Section_ID = s.Section_ID
      AND t.Course_ID = s.Course_ID
      AND t.Semester = s.Semester
    GROUP BY t.Section_ID, t.Course_ID, t.Semester
    HAVING COUNT(*) >= 2
)
ORDER BY NEWID(); -- Random order to distribute assistants evenly

OPEN section_cursor_assist;

FETCH NEXT FROM section_cursor_assist 
INTO @Cur_Section_ID2, @Cur_Course_ID2, @Cur_Semester2;

WHILE @@FETCH_STATUS = 0
BEGIN
    -- Get the existing tutor for this section
    SELECT TOP 1 @Tutor_ID_Existing = University_ID
    FROM [Teaches]
    WHERE Section_ID = @Cur_Section_ID2
      AND Course_ID = @Cur_Course_ID2
      AND Semester = @Cur_Semester2;
    
    -- Randomly decide if this section should get a Teaching Assistant (~50% chance)
    SET @HasAssistant = CASE WHEN RAND() < 0.5 THEN 1 ELSE 0 END;
    
    -- If section should have a Teaching Assistant, assign one
    IF @HasAssistant = 1
    BEGIN
        -- Select a random Teaching Assistant (different from existing tutor)
        SELECT TOP 1 @Tutor_ID_Assist = University_ID 
        FROM [Tutor] 
        WHERE University_ID != @Tutor_ID_Existing
          AND University_ID NOT IN (
              -- Avoid assigning same tutor to same section
              SELECT University_ID 
              FROM [Teaches] 
              WHERE Section_ID = @Cur_Section_ID2 
                AND Course_ID = @Cur_Course_ID2 
                AND Semester = @Cur_Semester2
          )
        ORDER BY NEWID();
        
        -- Insert Teaching Assistant if available
        IF @Tutor_ID_Assist IS NOT NULL
        BEGIN
            INSERT INTO [Teaches] (University_ID, Section_ID, Course_ID, Semester, Role_Specification, [Timestamp])
            VALUES (@Tutor_ID_Assist, @Cur_Section_ID2, @Cur_Course_ID2, @Cur_Semester2, N'Teaching Assistant', GETDATE());
        END;
    END;
    
    -- Reset variables for next iteration
    SET @Tutor_ID_Assist = NULL;
    SET @Tutor_ID_Existing = NULL;
    
    FETCH NEXT FROM section_cursor_assist 
    INTO @Cur_Section_ID2, @Cur_Course_ID2, @Cur_Semester2;
END;

CLOSE section_cursor_assist;
DEALLOCATE section_cursor_assist;

PRINT 'Step 2 completed: Teaching Assistants assigned to some sections';
GO

-- ============================================
-- Verify results
-- ============================================

DECLARE @TotalTeaches INT;
SELECT @TotalTeaches = COUNT(*) FROM [Teaches];

DECLARE @SectionsWithTutors INT;
SELECT @SectionsWithTutors = COUNT(DISTINCT Section_ID + Course_ID + Semester) FROM [Teaches];

DECLARE @SectionsWith1Tutor INT;
SELECT @SectionsWith1Tutor = COUNT(*)
FROM (
    SELECT Section_ID, Course_ID, Semester
    FROM [Teaches]
    GROUP BY Section_ID, Course_ID, Semester
    HAVING COUNT(*) = 1
) AS SingleTutorSections;

DECLARE @SectionsWith2Tutors INT;
SELECT @SectionsWith2Tutors = COUNT(*)
FROM (
    SELECT Section_ID, Course_ID, Semester
    FROM [Teaches]
    GROUP BY Section_ID, Course_ID, Semester
    HAVING COUNT(*) = 2
) AS TwoTutorSections;

PRINT '';
PRINT '========================================';
PRINT 'Teaches insertion completed!';
PRINT '========================================';
PRINT 'Total teaches records: ' + CAST(@TotalTeaches AS NVARCHAR(10));
PRINT 'Sections with tutors: ' + CAST(@SectionsWithTutors AS NVARCHAR(10));
PRINT 'Sections with 1 tutor: ' + CAST(@SectionsWith1Tutor AS NVARCHAR(10));
PRINT 'Sections with 2 tutors: ' + CAST(@SectionsWith2Tutors AS NVARCHAR(10));
PRINT '';
GO
