USE [lms_system];
GO

-- ============================================
-- Script insert Assessment: Assign students to sections
-- Each section will have at least 25 students
-- Each student can register for multiple sections (5-8 sections per semester)
-- ============================================
-- ============================================
-- Step 0: Delete data in correct order (reverse of FK dependencies)
-- ============================================

-- Delete from Review (references Submission)
DELETE FROM [Review];
GO

-- Delete from Submission (references Assignment)
DELETE FROM [Submission];
GO

-- Delete from Assignment (references Assessment)
DELETE FROM [Assignment];
GO

-- Delete from Quiz (references Assessment)
DELETE FROM [Quiz];
GO

-- Delete from Feedback 
DELETE FROM [Feedback];
GO

-- Delete from Assessment (references Student and Section)
DELETE FROM [Assessment];
GO



-- ============================================
-- Step 1: Assign students to sections for semester 242 (PRIORITIZED)
-- ============================================

DECLARE @Cur_Section_ID NVARCHAR(10);
DECLARE @Cur_Course_ID NVARCHAR(15);
DECLARE @Cur_Semester NVARCHAR(10) = '242';
DECLARE @Students_Per_Section INT;
DECLARE @Cur_Student_ID DECIMAL(7,0);
DECLARE @Midterm_Grade DECIMAL(4,2);
DECLARE @Final_Grade DECIMAL(4,2);
DECLARE @Quiz_Grade DECIMAL(4,2);
DECLARE @Assignment_Grade DECIMAL(4,2);
DECLARE @Reg_Date DATE = '2025-01-20';
DECLARE @Withdraw_Date DATE = '2025-06-15';

-- Cursor for all sections in semester 242
DECLARE section_cursor_242 CURSOR FOR
SELECT Section_ID, Course_ID, Semester
FROM [Section]
WHERE Semester = '242'
ORDER BY Course_ID, Section_ID;

OPEN section_cursor_242;
FETCH NEXT FROM section_cursor_242 INTO @Cur_Section_ID, @Cur_Course_ID, @Cur_Semester;

WHILE @@FETCH_STATUS = 0
BEGIN
    -- Random number of students per section (25-50) - Priority for 242
    SET @Students_Per_Section = 25 + CAST((RAND() * 26) AS INT); -- Random between 25-50
    
    -- Get random students for this section (avoid duplicates)
    DECLARE @SelectedStudents2 TABLE (
        University_ID DECIMAL(7,0)
    );
    
    INSERT INTO @SelectedStudents2 (University_ID)
    SELECT TOP (@Students_Per_Section) University_ID
    FROM [Student]
    WHERE University_ID NOT IN (
        -- Exclude students already registered for this COURSE in this SEMESTER
        -- (not just this section, because trigger prevents multiple sections of same course)
        SELECT University_ID 
        FROM [Assessment] 
        WHERE Course_ID = @Cur_Course_ID 
          AND Semester = @Cur_Semester
    )
    ORDER BY NEWID();
    
    -- Insert assessments for selected students
    DECLARE student_cursor2 CURSOR FOR
    SELECT University_ID FROM @SelectedStudents2;
    
    OPEN student_cursor2;
    FETCH NEXT FROM student_cursor2 INTO @Cur_Student_ID;
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Generate random grades
        SET @Midterm_Grade = ROUND(3.0 + (RAND() * 7.0), 1);
        SET @Final_Grade = ROUND(3.0 + (RAND() * 7.0), 1);
        SET @Quiz_Grade = ROUND(3.0 + (RAND() * 7.0), 1);
        SET @Assignment_Grade = ROUND(3.0 + (RAND() * 7.0), 1);
        
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
        
        FETCH NEXT FROM student_cursor2 INTO @Cur_Student_ID;
    END;
    
    CLOSE student_cursor2;
    DEALLOCATE student_cursor2;
    
    DELETE FROM @SelectedStudents2;
    
    FETCH NEXT FROM section_cursor_242 INTO @Cur_Section_ID, @Cur_Course_ID, @Cur_Semester;
END;

CLOSE section_cursor_242;
DEALLOCATE section_cursor_242;

DECLARE @Count242 INT;
SELECT @Count242 = COUNT(*) FROM [Assessment] WHERE Semester = '242';
PRINT 'Completed semester 242 (PRIORITIZED): ' + CAST(@Count242 AS NVARCHAR(10)) + ' assessments';
GO

-- ============================================
-- Step 2: Assign students to sections for semester 241 (same as 242)
-- ============================================

-- Re-declare variables (needed after GO)
DECLARE @Cur_Section_ID NVARCHAR(10);
DECLARE @Cur_Course_ID NVARCHAR(15);
DECLARE @Cur_Semester NVARCHAR(10) = '241';
DECLARE @Students_Per_Section INT;
DECLARE @Cur_Student_ID DECIMAL(7,0);
DECLARE @Midterm_Grade DECIMAL(4,2);
DECLARE @Final_Grade DECIMAL(4,2);
DECLARE @Quiz_Grade DECIMAL(4,2);
DECLARE @Assignment_Grade DECIMAL(4,2);
DECLARE @Reg_Date DATE = '2024-09-05';
DECLARE @Withdraw_Date DATE = '2025-01-15';

-- Cursor for all sections in semester 241
DECLARE section_cursor_241 CURSOR FOR
SELECT Section_ID, Course_ID, Semester
FROM [Section]
WHERE Semester = '241'
ORDER BY Course_ID, Section_ID;

OPEN section_cursor_241;
FETCH NEXT FROM section_cursor_241 INTO @Cur_Section_ID, @Cur_Course_ID, @Cur_Semester;

WHILE @@FETCH_STATUS = 0
BEGIN
    -- Random number of students per section (25-50) - Same as semester 242
    SET @Students_Per_Section = 25 + CAST((RAND() * 26) AS INT); -- Random between 25-50
    
    -- Get random students for this section (avoid duplicates)
    DECLARE @SelectedStudents TABLE (
        University_ID DECIMAL(7,0)
    );
    
    INSERT INTO @SelectedStudents (University_ID)
    SELECT TOP (@Students_Per_Section) University_ID
    FROM [Student]
    WHERE University_ID NOT IN (
        -- Exclude students already registered for this COURSE in this SEMESTER
        -- (not just this section, because trigger prevents multiple sections of same course)
        SELECT University_ID 
        FROM [Assessment] 
        WHERE Course_ID = @Cur_Course_ID 
          AND Semester = @Cur_Semester
    )
    ORDER BY NEWID();
    
    -- Insert assessments for selected students
    DECLARE student_cursor CURSOR FOR
    SELECT University_ID FROM @SelectedStudents;
    
    OPEN student_cursor;
    FETCH NEXT FROM student_cursor INTO @Cur_Student_ID;
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Generate random grades
        SET @Midterm_Grade = ROUND(3.0 + (RAND() * 7.0), 1);
        SET @Final_Grade = ROUND(3.0 + (RAND() * 7.0), 1);
        SET @Quiz_Grade = ROUND(3.0 + (RAND() * 7.0), 1);
        SET @Assignment_Grade = ROUND(3.0 + (RAND() * 7.0), 1);
        
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
        
        FETCH NEXT FROM student_cursor INTO @Cur_Student_ID;
    END;
    
    CLOSE student_cursor;
    DEALLOCATE student_cursor;
    
    DELETE FROM @SelectedStudents;
    
    FETCH NEXT FROM section_cursor_241 INTO @Cur_Section_ID, @Cur_Course_ID, @Cur_Semester;
END;

CLOSE section_cursor_241;
DEALLOCATE section_cursor_241;

DECLARE @Count241 INT;
SELECT @Count241 = COUNT(*) FROM [Assessment] WHERE Semester = '241';
PRINT 'Completed semester 241: ' + CAST(@Count241 AS NVARCHAR(10)) + ' assessments';
GO

-- ============================================
-- Step 3: Verify results - Detailed statistics
-- ============================================

PRINT '';
PRINT '========================================';
PRINT 'Assessment Insertion Statistics';
PRINT '========================================';
PRINT '';

-- Total assessments
DECLARE @TotalAssessments INT;
SELECT @TotalAssessments = COUNT(*) FROM [Assessment];
PRINT 'Total assessments: ' + CAST(@TotalAssessments AS NVARCHAR(10));
PRINT '';

-- Statistics by semester
PRINT '--- Statistics by Semester ---';
SELECT 
    Semester,
    COUNT(*) AS Total_Assessments,
    COUNT(DISTINCT University_ID) AS Total_Students,
    COUNT(DISTINCT Section_ID + Course_ID) AS Sections_With_Students,
    CAST(AVG(CAST(SectionStudentCount AS FLOAT)) AS DECIMAL(10,2)) AS Avg_Students_Per_Section,
    MIN(SectionStudentCount) AS Min_Students_Per_Section,
    MAX(SectionStudentCount) AS Max_Students_Per_Section
FROM (
    SELECT 
        Semester,
        University_ID,
        Section_ID,
        Course_ID,
        COUNT(*) OVER (PARTITION BY Section_ID, Course_ID, Semester) AS SectionStudentCount
    FROM [Assessment]
) AS SubQuery
GROUP BY Semester
ORDER BY Semester;
PRINT '';

-- Detailed section counts by semester
PRINT '--- Section Student Count Distribution ---';
SELECT 
    Semester,
    Student_Range,
    COUNT(*) AS Section_Count
FROM (
    SELECT 
        Semester,
        CASE 
            WHEN StudentCount = 0 THEN '0 students'
            WHEN StudentCount BETWEEN 1 AND 10 THEN '1-10 students'
            WHEN StudentCount BETWEEN 11 AND 20 THEN '11-20 students'
            WHEN StudentCount BETWEEN 21 AND 30 THEN '21-30 students'
            WHEN StudentCount BETWEEN 31 AND 40 THEN '31-40 students'
            WHEN StudentCount BETWEEN 41 AND 50 THEN '41-50 students'
            WHEN StudentCount > 50 THEN '50+ students'
        END AS Student_Range,
        CASE 
            WHEN StudentCount = 0 THEN 1
            WHEN StudentCount BETWEEN 1 AND 10 THEN 2
            WHEN StudentCount BETWEEN 11 AND 20 THEN 3
            WHEN StudentCount BETWEEN 21 AND 30 THEN 4
            WHEN StudentCount BETWEEN 31 AND 40 THEN 5
            WHEN StudentCount BETWEEN 41 AND 50 THEN 6
            WHEN StudentCount > 50 THEN 7
        END AS Range_Order
    FROM (
        SELECT 
            Section_ID,
            Course_ID,
            Semester,
            COUNT(*) AS StudentCount
        FROM [Assessment]
        GROUP BY Section_ID, Course_ID, Semester
    ) AS SectionCounts
) AS RangeData
GROUP BY Semester, Student_Range, Range_Order
ORDER BY Semester, Range_Order;
PRINT '';

-- Overall summary
DECLARE @Sections241 INT;
SELECT @Sections241 = COUNT(DISTINCT Section_ID + Course_ID) FROM [Assessment] WHERE Semester = '241';

DECLARE @Sections242 INT;
SELECT @Sections242 = COUNT(DISTINCT Section_ID + Course_ID) FROM [Assessment] WHERE Semester = '242';

DECLARE @Students241 INT;
SELECT @Students241 = COUNT(DISTINCT University_ID) FROM [Assessment] WHERE Semester = '241';

DECLARE @Students242 INT;
SELECT @Students242 = COUNT(DISTINCT University_ID) FROM [Assessment] WHERE Semester = '242';

-- Create temp table for section counts
IF OBJECT_ID('tempdb..#SectionCounts') IS NOT NULL
    DROP TABLE #SectionCounts;

SELECT 
    COUNT(*) AS StudentCount
INTO #SectionCounts
FROM [Assessment]
GROUP BY Section_ID, Course_ID, Semester;

DECLARE @MinStudentsPerSection INT;
SELECT @MinStudentsPerSection = MIN(StudentCount) FROM #SectionCounts;

DECLARE @MaxStudentsPerSection INT;
SELECT @MaxStudentsPerSection = MAX(StudentCount) FROM #SectionCounts;

DECLARE @AvgStudentsPerSection DECIMAL(10,2);
SELECT @AvgStudentsPerSection = AVG(CAST(StudentCount AS FLOAT)) FROM #SectionCounts;

DROP TABLE #SectionCounts;

PRINT '--- Summary ---';
PRINT 'Total assessments: ' + CAST(@TotalAssessments AS NVARCHAR(10));
PRINT 'Sections with students (241): ' + CAST(@Sections241 AS NVARCHAR(10));
PRINT 'Sections with students (242): ' + CAST(@Sections242 AS NVARCHAR(10));
PRINT 'Total students (241): ' + CAST(@Students241 AS NVARCHAR(10));
PRINT 'Total students (242): ' + CAST(@Students242 AS NVARCHAR(10));
PRINT 'Min students per section: ' + CAST(@MinStudentsPerSection AS NVARCHAR(10));
PRINT 'Max students per section: ' + CAST(@MaxStudentsPerSection AS NVARCHAR(10));
PRINT 'Avg students per section: ' + CAST(@AvgStudentsPerSection AS NVARCHAR(10));
PRINT '';
PRINT '========================================';
PRINT '';
GO
