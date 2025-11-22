USE [lms_system];
GO

-- ============================================
-- Script insert Assessment: Assign students to sections
-- 
-- CONSTRAINTS:
-- 1. Each (section_id, course_id) pair has at least 10 university_id
-- 2. Each university_id has 3-6 (section_id, course_id) pairs per semester (241, 242)
-- ============================================

-- Step 0: Delete data in correct order
DELETE FROM [Review];
GO
DELETE FROM [Submission];
GO
DELETE FROM [Assignment];
GO
DELETE FROM [Quiz];
GO
DELETE FROM [Feedback];
GO
DELETE FROM [Assessment];
GO

-- ============================================
-- Function to assign students for a semester
-- ============================================

-- Semester 242
DECLARE @Semester NVARCHAR(10) = '242';
DECLARE @Reg_Date DATE = '2025-01-20';
DECLARE @Withdraw_Date DATE = '2025-06-15';
DECLARE @Midterm_Grade DECIMAL(4,2);
DECLARE @Final_Grade DECIMAL(4,2);
DECLARE @Quiz_Grade DECIMAL(4,2);
DECLARE @Assignment_Grade DECIMAL(4,2);
DECLARE @RandomPercent INT;

-- Create student course limits (3-6 courses per semester)
IF OBJECT_ID('tempdb..#StudentLimits') IS NOT NULL DROP TABLE #StudentLimits;
SELECT University_ID, 3 + (ABS(CHECKSUM(NEWID())) % 4) AS Course_Limit
INTO #StudentLimits
FROM [Student];

-- Create section tracking table
IF OBJECT_ID('tempdb..#SectionCounts') IS NOT NULL DROP TABLE #SectionCounts;
SELECT Section_ID, Course_ID, 0 AS Student_Count
INTO #SectionCounts
FROM [Section]
WHERE Semester = @Semester;

-- Step 1: Fill each section to at least 10 students
DECLARE @Cur_Section_ID NVARCHAR(10);
DECLARE @Cur_Course_ID NVARCHAR(15);
DECLARE @Cur_Student_ID DECIMAL(7,0);
DECLARE @NeededStudents INT;

DECLARE section_cursor CURSOR FOR
SELECT Section_ID, Course_ID FROM #SectionCounts ORDER BY Course_ID, Section_ID;

OPEN section_cursor;
FETCH NEXT FROM section_cursor INTO @Cur_Section_ID, @Cur_Course_ID;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @NeededStudents = 10;
    
    WHILE @NeededStudents > 0
    BEGIN
        SELECT TOP 1 @Cur_Student_ID = s.University_ID
        FROM [Student] s
        INNER JOIN #StudentLimits l ON s.University_ID = l.University_ID
        WHERE s.University_ID NOT IN (
            SELECT University_ID FROM [Assessment] 
            WHERE Course_ID = @Cur_Course_ID AND Semester = @Semester
        )
        AND (
            SELECT COUNT(*) FROM [Assessment] 
            WHERE University_ID = s.University_ID AND Semester = @Semester
        ) < l.Course_Limit
        ORDER BY NEWID();
        
        IF @Cur_Student_ID IS NULL BREAK;
        
        INSERT INTO [Assessment] (
            University_ID, Section_ID, Course_ID, Semester,
            Registration_Date, Potential_Withdrawal_Date, [Status],
            Midterm_Grade, Final_Grade, Quiz_Grade, Assignment_Grade
        )
        VALUES (
            @Cur_Student_ID, @Cur_Section_ID, @Cur_Course_ID, @Semester,
            @Reg_Date, @Withdraw_Date, 'Approved',
            ROUND(3.0 + (RAND() * 7.0), 1),
            ROUND(3.0 + (RAND() * 7.0), 1),
            ROUND(3.0 + (RAND() * 7.0), 1),
            ROUND(3.0 + (RAND() * 7.0), 1)
        );
        
        UPDATE #SectionCounts
        SET Student_Count = Student_Count + 1
        WHERE Section_ID = @Cur_Section_ID AND Course_ID = @Cur_Course_ID;
        
        SET @NeededStudents = @NeededStudents - 1;
    END;
    
    FETCH NEXT FROM section_cursor INTO @Cur_Section_ID, @Cur_Course_ID;
END;

CLOSE section_cursor;
DEALLOCATE section_cursor;

-- Step 2: Distribute remaining students to reach their course limits
DECLARE @Selected_Course_Count INT;
DECLARE @CurrentCourseCount INT;

DECLARE student_cursor CURSOR FOR
SELECT s.University_ID, l.Course_Limit
FROM [Student] s
INNER JOIN #StudentLimits l ON s.University_ID = l.University_ID
ORDER BY NEWID();

OPEN student_cursor;
FETCH NEXT FROM student_cursor INTO @Cur_Student_ID, @Selected_Course_Count;

WHILE @@FETCH_STATUS = 0
BEGIN
    SELECT @CurrentCourseCount = COUNT(*)
    FROM [Assessment]
    WHERE University_ID = @Cur_Student_ID AND Semester = @Semester;
    
    SET @NeededStudents = @Selected_Course_Count - @CurrentCourseCount;
    
    IF @NeededStudents > 0
    BEGIN
        DECLARE @SelectedCourses TABLE (Course_ID NVARCHAR(15));
        
        INSERT INTO @SelectedCourses (Course_ID)
        SELECT TOP (@NeededStudents) Course_ID
        FROM (
            SELECT DISTINCT Course_ID,
                   (SELECT COUNT(*) FROM [Assessment] WHERE Course_ID = [Section].Course_ID AND Semester = @Semester) AS StudentCount
            FROM [Section]
            WHERE Semester = @Semester
              AND Course_ID NOT IN (
                  SELECT Course_ID FROM [Assessment] 
                  WHERE University_ID = @Cur_Student_ID AND Semester = @Semester
              )
        ) AS AvailableCourses
        ORDER BY StudentCount, NEWID();
        
        DECLARE course_cursor CURSOR FOR
        SELECT Course_ID FROM @SelectedCourses;
        
        OPEN course_cursor;
        FETCH NEXT FROM course_cursor INTO @Cur_Course_ID;
        
        WHILE @@FETCH_STATUS = 0
        BEGIN
            SELECT TOP 1 @Cur_Section_ID = Section_ID
            FROM #SectionCounts
            WHERE Course_ID = @Cur_Course_ID AND Student_Count < 50
            ORDER BY Student_Count, NEWID();
            
            IF @Cur_Section_ID IS NOT NULL
            BEGIN
                -- Generate grades based on course (CO3005: 90% 1-5, 10% 5-8)
                IF @Cur_Course_ID = 'CO3005'
                BEGIN
                    SET @RandomPercent = ABS(CHECKSUM(NEWID())) % 100;
                    IF @RandomPercent < 90
                    BEGIN
                        SET @Midterm_Grade = ROUND(1.0 + (RAND() * 4.0), 1);
                        SET @Final_Grade = ROUND(1.0 + (RAND() * 4.0), 1);
                        SET @Quiz_Grade = ROUND(1.0 + (RAND() * 4.0), 1);
                        SET @Assignment_Grade = ROUND(1.0 + (RAND() * 4.0), 1);
                    END
                    ELSE
                    BEGIN
                        SET @Midterm_Grade = ROUND(5.0 + (RAND() * 3.0), 1);
                        SET @Final_Grade = ROUND(5.0 + (RAND() * 3.0), 1);
                        SET @Quiz_Grade = ROUND(5.0 + (RAND() * 3.0), 1);
                        SET @Assignment_Grade = ROUND(5.0 + (RAND() * 3.0), 1);
                    END;
                END
                ELSE
                BEGIN
                    SET @Midterm_Grade = ROUND(3.0 + (RAND() * 7.0), 1);
                    SET @Final_Grade = ROUND(3.0 + (RAND() * 7.0), 1);
                    SET @Quiz_Grade = ROUND(3.0 + (RAND() * 7.0), 1);
                    SET @Assignment_Grade = ROUND(3.0 + (RAND() * 7.0), 1);
                END;
                
                INSERT INTO [Assessment] (
                    University_ID, Section_ID, Course_ID, Semester,
                    Registration_Date, Potential_Withdrawal_Date, [Status],
                    Midterm_Grade, Final_Grade, Quiz_Grade, Assignment_Grade
                )
                VALUES (
                    @Cur_Student_ID, @Cur_Section_ID, @Cur_Course_ID, @Semester,
                    @Reg_Date, @Withdraw_Date, 'Approved',
                    @Midterm_Grade, @Final_Grade, @Quiz_Grade, @Assignment_Grade
                );
                
                UPDATE #SectionCounts
                SET Student_Count = Student_Count + 1
                WHERE Section_ID = @Cur_Section_ID AND Course_ID = @Cur_Course_ID;
            END;
            
            FETCH NEXT FROM course_cursor INTO @Cur_Course_ID;
        END;
        
        CLOSE course_cursor;
        DEALLOCATE course_cursor;
        DELETE FROM @SelectedCourses;
    END;
    
    FETCH NEXT FROM student_cursor INTO @Cur_Student_ID, @Selected_Course_Count;
END;

CLOSE student_cursor;
DEALLOCATE student_cursor;

DROP TABLE #StudentLimits;
DROP TABLE #SectionCounts;

DECLARE @Count242 INT;
SELECT @Count242 = COUNT(*) FROM [Assessment] WHERE Semester = '242';
PRINT 'Completed semester 242: ' + CAST(@Count242 AS NVARCHAR(10)) + ' assessments';
GO

-- ============================================
-- Semester 241 (same logic)
-- ============================================

DECLARE @Semester NVARCHAR(10) = '241';
DECLARE @Reg_Date DATE = '2024-09-05';
DECLARE @Withdraw_Date DATE = '2025-01-15';
DECLARE @Midterm_Grade DECIMAL(4,2);
DECLARE @Final_Grade DECIMAL(4,2);
DECLARE @Quiz_Grade DECIMAL(4,2);
DECLARE @Assignment_Grade DECIMAL(4,2);
DECLARE @RandomPercent INT;

-- Create student course limits (3-6 courses per semester)
IF OBJECT_ID('tempdb..#StudentLimits') IS NOT NULL DROP TABLE #StudentLimits;
SELECT University_ID, 3 + (ABS(CHECKSUM(NEWID())) % 4) AS Course_Limit
INTO #StudentLimits
FROM [Student];

-- Create section tracking table
IF OBJECT_ID('tempdb..#SectionCounts') IS NOT NULL DROP TABLE #SectionCounts;
SELECT Section_ID, Course_ID, 0 AS Student_Count
INTO #SectionCounts
FROM [Section]
WHERE Semester = @Semester;

-- Step 1: Fill each section to at least 10 students
DECLARE @Cur_Section_ID NVARCHAR(10);
DECLARE @Cur_Course_ID NVARCHAR(15);
DECLARE @Cur_Student_ID DECIMAL(7,0);
DECLARE @NeededStudents INT;

DECLARE section_cursor CURSOR FOR
SELECT Section_ID, Course_ID FROM #SectionCounts ORDER BY Course_ID, Section_ID;

OPEN section_cursor;
FETCH NEXT FROM section_cursor INTO @Cur_Section_ID, @Cur_Course_ID;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @NeededStudents = 10;
    
    WHILE @NeededStudents > 0
    BEGIN
        SELECT TOP 1 @Cur_Student_ID = s.University_ID
        FROM [Student] s
        INNER JOIN #StudentLimits l ON s.University_ID = l.University_ID
        WHERE s.University_ID NOT IN (
            SELECT University_ID FROM [Assessment] 
            WHERE Course_ID = @Cur_Course_ID AND Semester = @Semester
        )
        AND (
            SELECT COUNT(*) FROM [Assessment] 
            WHERE University_ID = s.University_ID AND Semester = @Semester
        ) < l.Course_Limit
        ORDER BY NEWID();
        
        IF @Cur_Student_ID IS NULL BREAK;
        
        -- Generate grades based on course (CO3005: 90% 1-5, 10% 5-8)
        IF @Cur_Course_ID = 'CO3005'
        BEGIN
            SET @RandomPercent = ABS(CHECKSUM(NEWID())) % 100;
            IF @RandomPercent < 90
            BEGIN
                SET @Midterm_Grade = ROUND(1.0 + (RAND() * 4.0), 1);
                SET @Final_Grade = ROUND(1.0 + (RAND() * 4.0), 1);
                SET @Quiz_Grade = ROUND(1.0 + (RAND() * 4.0), 1);
                SET @Assignment_Grade = ROUND(1.0 + (RAND() * 4.0), 1);
            END
            ELSE
            BEGIN
                SET @Midterm_Grade = ROUND(5.0 + (RAND() * 3.0), 1);
                SET @Final_Grade = ROUND(5.0 + (RAND() * 3.0), 1);
                SET @Quiz_Grade = ROUND(5.0 + (RAND() * 3.0), 1);
                SET @Assignment_Grade = ROUND(5.0 + (RAND() * 3.0), 1);
            END;
        END
        ELSE
        BEGIN
            SET @Midterm_Grade = ROUND(3.0 + (RAND() * 7.0), 1);
            SET @Final_Grade = ROUND(3.0 + (RAND() * 7.0), 1);
            SET @Quiz_Grade = ROUND(3.0 + (RAND() * 7.0), 1);
            SET @Assignment_Grade = ROUND(3.0 + (RAND() * 7.0), 1);
        END;
        
        INSERT INTO [Assessment] (
            University_ID, Section_ID, Course_ID, Semester,
            Registration_Date, Potential_Withdrawal_Date, [Status],
            Midterm_Grade, Final_Grade, Quiz_Grade, Assignment_Grade
        )
        VALUES (
            @Cur_Student_ID, @Cur_Section_ID, @Cur_Course_ID, @Semester,
            @Reg_Date, @Withdraw_Date, 'Approved',
            @Midterm_Grade, @Final_Grade, @Quiz_Grade, @Assignment_Grade
        );
        
        UPDATE #SectionCounts
        SET Student_Count = Student_Count + 1
        WHERE Section_ID = @Cur_Section_ID AND Course_ID = @Cur_Course_ID;
        
        SET @NeededStudents = @NeededStudents - 1;
    END;
    
    FETCH NEXT FROM section_cursor INTO @Cur_Section_ID, @Cur_Course_ID;
END;

CLOSE section_cursor;
DEALLOCATE section_cursor;

-- Step 2: Distribute remaining students to reach their course limits
DECLARE @Selected_Course_Count INT;
DECLARE @CurrentCourseCount INT;

DECLARE student_cursor CURSOR FOR
SELECT s.University_ID, l.Course_Limit
FROM [Student] s
INNER JOIN #StudentLimits l ON s.University_ID = l.University_ID
ORDER BY NEWID();

OPEN student_cursor;
FETCH NEXT FROM student_cursor INTO @Cur_Student_ID, @Selected_Course_Count;

WHILE @@FETCH_STATUS = 0
BEGIN
    SELECT @CurrentCourseCount = COUNT(*)
    FROM [Assessment]
    WHERE University_ID = @Cur_Student_ID AND Semester = @Semester;
    
    SET @NeededStudents = @Selected_Course_Count - @CurrentCourseCount;
    
    IF @NeededStudents > 0
    BEGIN
        DECLARE @SelectedCourses TABLE (Course_ID NVARCHAR(15));
        
        INSERT INTO @SelectedCourses (Course_ID)
        SELECT TOP (@NeededStudents) Course_ID
        FROM (
            SELECT DISTINCT Course_ID,
                   (SELECT COUNT(*) FROM [Assessment] WHERE Course_ID = [Section].Course_ID AND Semester = @Semester) AS StudentCount
            FROM [Section]
            WHERE Semester = @Semester
              AND Course_ID NOT IN (
                  SELECT Course_ID FROM [Assessment] 
                  WHERE University_ID = @Cur_Student_ID AND Semester = @Semester
              )
        ) AS AvailableCourses
        ORDER BY StudentCount, NEWID();
        
        DECLARE course_cursor CURSOR FOR
        SELECT Course_ID FROM @SelectedCourses;
        
        OPEN course_cursor;
        FETCH NEXT FROM course_cursor INTO @Cur_Course_ID;
        
        WHILE @@FETCH_STATUS = 0
        BEGIN
            SELECT TOP 1 @Cur_Section_ID = Section_ID
            FROM #SectionCounts
            WHERE Course_ID = @Cur_Course_ID AND Student_Count < 50
            ORDER BY Student_Count, NEWID();
            
            IF @Cur_Section_ID IS NOT NULL
            BEGIN
                -- Generate grades based on course (CO3005: 90% 1-5, 10% 5-8)
                IF @Cur_Course_ID = 'CO3005'
                BEGIN
                    SET @RandomPercent = ABS(CHECKSUM(NEWID())) % 100;
                    IF @RandomPercent < 90
                    BEGIN
                        SET @Midterm_Grade = ROUND(1.0 + (RAND() * 4.0), 1);
                        SET @Final_Grade = ROUND(1.0 + (RAND() * 4.0), 1);
                        SET @Quiz_Grade = ROUND(1.0 + (RAND() * 4.0), 1);
                        SET @Assignment_Grade = ROUND(1.0 + (RAND() * 4.0), 1);
                    END
                    ELSE
                    BEGIN
                        SET @Midterm_Grade = ROUND(5.0 + (RAND() * 3.0), 1);
                        SET @Final_Grade = ROUND(5.0 + (RAND() * 3.0), 1);
                        SET @Quiz_Grade = ROUND(5.0 + (RAND() * 3.0), 1);
                        SET @Assignment_Grade = ROUND(5.0 + (RAND() * 3.0), 1);
                    END;
                END
                ELSE
                BEGIN
                    SET @Midterm_Grade = ROUND(3.0 + (RAND() * 7.0), 1);
                    SET @Final_Grade = ROUND(3.0 + (RAND() * 7.0), 1);
                    SET @Quiz_Grade = ROUND(3.0 + (RAND() * 7.0), 1);
                    SET @Assignment_Grade = ROUND(3.0 + (RAND() * 7.0), 1);
                END;
                
                INSERT INTO [Assessment] (
                    University_ID, Section_ID, Course_ID, Semester,
                    Registration_Date, Potential_Withdrawal_Date, [Status],
                    Midterm_Grade, Final_Grade, Quiz_Grade, Assignment_Grade
                )
                VALUES (
                    @Cur_Student_ID, @Cur_Section_ID, @Cur_Course_ID, @Semester,
                    @Reg_Date, @Withdraw_Date, 'Approved',
                    @Midterm_Grade, @Final_Grade, @Quiz_Grade, @Assignment_Grade
                );
                
                UPDATE #SectionCounts
                SET Student_Count = Student_Count + 1
                WHERE Section_ID = @Cur_Section_ID AND Course_ID = @Cur_Course_ID;
            END;
            
            FETCH NEXT FROM course_cursor INTO @Cur_Course_ID;
        END;
        
        CLOSE course_cursor;
        DEALLOCATE course_cursor;
        DELETE FROM @SelectedCourses;
    END;
    
    FETCH NEXT FROM student_cursor INTO @Cur_Student_ID, @Selected_Course_Count;
END;

CLOSE student_cursor;
DEALLOCATE student_cursor;

DROP TABLE #StudentLimits;
DROP TABLE #SectionCounts;

DECLARE @Count241 INT;
SELECT @Count241 = COUNT(*) FROM [Assessment] WHERE Semester = '241';
PRINT 'Completed semester 241: ' + CAST(@Count241 AS NVARCHAR(10)) + ' assessments';
GO

-- ============================================
-- Step 3: Verify results
-- ============================================

PRINT '';
PRINT '========================================';
PRINT 'Assessment Insertion Statistics';
PRINT '========================================';
PRINT '';

DECLARE @TotalAssessments INT;
SELECT @TotalAssessments = COUNT(*) FROM [Assessment];
PRINT 'Total assessments: ' + CAST(@TotalAssessments AS NVARCHAR(10));
PRINT '';

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
            Section_ID, Course_ID, Semester,
            COUNT(*) AS StudentCount
        FROM [Assessment]
        GROUP BY Section_ID, Course_ID, Semester
    ) AS SectionCounts
) AS RangeData
GROUP BY Semester, Student_Range, Range_Order
ORDER BY Semester, Range_Order;
PRINT '';
PRINT '========================================';
PRINT '';
GO
