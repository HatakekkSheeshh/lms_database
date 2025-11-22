USE [lms_system];
GO

-- ============================================
-- Example Usage of Section Statistics Functions
-- ============================================

-- ============================================
-- Example 1: Get all section statistics
-- ============================================
PRINT 'Example 1: All section statistics';
PRINT '========================================';
SELECT TOP 20
    Section_ID,
    Course_ID,
    Semester,
    Course_Name,
    Student_Count,
    Tutor_Count,
    Tutor_Roles
FROM [dbo].[GetSectionStatistics]()
ORDER BY Semester, Course_ID, Section_ID;
GO

-- ============================================
-- Example 2: Get sections with at least 25 students
-- ============================================
PRINT '';
PRINT 'Example 2: Sections with at least 25 students';
PRINT '========================================';
SELECT 
    Section_ID,
    Course_ID,
    Semester,
    Course_Name,
    Student_Count,
    Tutor_Count
FROM [dbo].[GetSectionStatistics]()
WHERE Student_Count >= 25
ORDER BY Student_Count DESC;
GO

-- ============================================
-- Example 3: Get sections missing students or tutors
-- ============================================
PRINT '';
PRINT 'Example 3: Sections missing students or tutors';
PRINT '========================================';
SELECT 
    Section_ID,
    Course_ID,
    Semester,
    Course_Name,
    Student_Count,
    Tutor_Count,
    CASE 
        WHEN Student_Count = 0 AND Tutor_Count = 0 THEN 'Missing both'
        WHEN Student_Count = 0 THEN 'Missing students'
        WHEN Tutor_Count = 0 THEN 'Missing tutors'
    END AS Issue
FROM [dbo].[GetSectionStatistics]()
WHERE Student_Count = 0 OR Tutor_Count = 0
ORDER BY Semester, Course_ID, Section_ID;
GO

-- ============================================
-- Example 4: Get summary statistics by semester
-- ============================================
PRINT '';
PRINT 'Example 4: Summary statistics by semester';
PRINT '========================================';
SELECT 
    Semester,
    Total_Sections,
    Sections_With_Students,
    Sections_With_Tutors,
    Total_Students_Registered,
    Total_Tutors_Teaching,
    CAST(Avg_Students_Per_Section AS DECIMAL(10,2)) AS Avg_Students_Per_Section,
    Min_Students_Per_Section,
    Max_Students_Per_Section,
    CAST(Avg_Tutors_Per_Section AS DECIMAL(10,2)) AS Avg_Tutors_Per_Section,
    Min_Tutors_Per_Section,
    Max_Tutors_Per_Section
FROM [dbo].[GetSectionSummaryStatistics]()
ORDER BY Semester;
GO

-- ============================================
-- Example 5: Get sections grouped by student count ranges
-- ============================================
PRINT '';
PRINT 'Example 5: Sections grouped by student count ranges';
PRINT '========================================';
SELECT 
    CASE 
        WHEN Student_Count = 0 THEN '0 students'
        WHEN Student_Count BETWEEN 1 AND 10 THEN '1-10 students'
        WHEN Student_Count BETWEEN 11 AND 20 THEN '11-20 students'
        WHEN Student_Count BETWEEN 21 AND 30 THEN '21-30 students'
        WHEN Student_Count BETWEEN 31 AND 40 THEN '31-40 students'
        WHEN Student_Count >= 41 THEN '41+ students'
    END AS Student_Range,
    COUNT(*) AS Section_Count,
    AVG(CAST(Tutor_Count AS FLOAT)) AS Avg_Tutors
FROM [dbo].[GetSectionStatistics]()
GROUP BY 
    CASE 
        WHEN Student_Count = 0 THEN '0 students'
        WHEN Student_Count BETWEEN 1 AND 10 THEN '1-10 students'
        WHEN Student_Count BETWEEN 11 AND 20 THEN '11-20 students'
        WHEN Student_Count BETWEEN 21 AND 30 THEN '21-30 students'
        WHEN Student_Count BETWEEN 31 AND 40 THEN '31-40 students'
        WHEN Student_Count >= 41 THEN '41+ students'
    END
ORDER BY 
    MIN(Student_Count);
GO

-- ============================================
-- Example 6: Get sections with exactly 1 or 2 tutors
-- ============================================
PRINT '';
PRINT 'Example 6: Sections with 1 or 2 tutors';
PRINT '========================================';
SELECT 
    Tutor_Count,
    COUNT(*) AS Section_Count,
    AVG(CAST(Student_Count AS FLOAT)) AS Avg_Students
FROM [dbo].[GetSectionStatistics]()
WHERE Tutor_Count BETWEEN 1 AND 2
GROUP BY Tutor_Count
ORDER BY Tutor_Count;
GO

