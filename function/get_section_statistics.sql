USE [lms_system];
GO

-- ============================================
-- Function 1: Get detailed statistics for each section
-- Returns: Section_ID, Course_ID, Semester, Student_Count, Tutor_Count
-- ============================================

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GetSectionStatistics]') AND type IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
    DROP FUNCTION [dbo].[GetSectionStatistics];
GO

CREATE FUNCTION [dbo].[GetSectionStatistics]()
RETURNS TABLE
AS
RETURN
(
    SELECT 
        s.Section_ID,
        s.Course_ID,
        s.Semester,
        c.[Name] AS Course_Name,
        -- Count students registered for this section
        ISNULL(StudentCount.Student_Count, 0) AS Student_Count,
        -- Count tutors teaching this section
        ISNULL(TutorCount.Tutor_Count, 0) AS Tutor_Count,
        -- List of tutor roles (compatible with older SQL Server versions)
        ISNULL(STUFF((
            SELECT ', ' + Role_Specification
            FROM [Teaches] t2
            WHERE t2.Section_ID = s.Section_ID
              AND t2.Course_ID = s.Course_ID
              AND t2.Semester = s.Semester
            FOR XML PATH(''), TYPE
        ).value('.', 'NVARCHAR(MAX)'), 1, 2, ''), '') AS Tutor_Roles
    FROM [Section] s
    LEFT JOIN [Course] c 
        ON s.Course_ID = c.Course_ID
    LEFT JOIN (
        SELECT 
            Section_ID, 
            Course_ID, 
            Semester,
            COUNT(DISTINCT University_ID) AS Student_Count
        FROM [Assessment]
        GROUP BY Section_ID, Course_ID, Semester
    ) StudentCount
        ON s.Section_ID = StudentCount.Section_ID
        AND s.Course_ID = StudentCount.Course_ID
        AND s.Semester = StudentCount.Semester
    LEFT JOIN (
        SELECT 
            Section_ID, 
            Course_ID, 
            Semester,
            COUNT(DISTINCT University_ID) AS Tutor_Count
        FROM [Teaches]
        GROUP BY Section_ID, Course_ID, Semester
    ) TutorCount
        ON s.Section_ID = TutorCount.Section_ID
        AND s.Course_ID = TutorCount.Course_ID
        AND s.Semester = TutorCount.Semester
);
GO

-- ============================================
-- Function 2: Get summary statistics by semester
-- Returns: Semester, Total_Sections, Sections_With_Students, Sections_With_Tutors, etc.
-- ============================================

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GetSectionSummaryStatistics]') AND type IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
    DROP FUNCTION [dbo].[GetSectionSummaryStatistics];
GO

CREATE FUNCTION [dbo].[GetSectionSummaryStatistics]()
RETURNS TABLE
AS
RETURN
(
    SELECT 
        stats.Semester,
        stats.Total_Sections,
        stats.Sections_With_Students,
        stats.Sections_With_Tutors,
        ISNULL(student_totals.Total_Students_Registered, 0) AS Total_Students_Registered,
        ISNULL(tutor_totals.Total_Tutors_Teaching, 0) AS Total_Tutors_Teaching,
        stats.Avg_Students_Per_Section,
        stats.Min_Students_Per_Section,
        stats.Max_Students_Per_Section,
        stats.Avg_Tutors_Per_Section,
        stats.Min_Tutors_Per_Section,
        stats.Max_Tutors_Per_Section
    FROM (
        SELECT 
            s.Semester,
            COUNT(DISTINCT s.Section_ID + s.Course_ID) AS Total_Sections,
            COUNT(DISTINCT CASE WHEN a.Section_ID IS NOT NULL THEN s.Section_ID + s.Course_ID END) AS Sections_With_Students,
            COUNT(DISTINCT CASE WHEN t.Section_ID IS NOT NULL THEN s.Section_ID + s.Course_ID END) AS Sections_With_Tutors,
            AVG(CAST(ISNULL(a.StudentCount, 0) AS FLOAT)) AS Avg_Students_Per_Section,
            MIN(ISNULL(a.StudentCount, 0)) AS Min_Students_Per_Section,
            MAX(ISNULL(a.StudentCount, 0)) AS Max_Students_Per_Section,
            AVG(CAST(ISNULL(t.TutorCount, 0) AS FLOAT)) AS Avg_Tutors_Per_Section,
            MIN(ISNULL(t.TutorCount, 0)) AS Min_Tutors_Per_Section,
            MAX(ISNULL(t.TutorCount, 0)) AS Max_Tutors_Per_Section
        FROM [Section] s
        LEFT JOIN (
            SELECT 
                Section_ID, 
                Course_ID, 
                Semester,
                COUNT(DISTINCT University_ID) AS StudentCount
            FROM [Assessment]
            GROUP BY Section_ID, Course_ID, Semester
        ) a 
            ON s.Section_ID = a.Section_ID 
            AND s.Course_ID = a.Course_ID 
            AND s.Semester = a.Semester
        LEFT JOIN (
            SELECT 
                Section_ID, 
                Course_ID, 
                Semester,
                COUNT(DISTINCT University_ID) AS TutorCount
            FROM [Teaches]
            GROUP BY Section_ID, Course_ID, Semester
        ) t 
            ON s.Section_ID = t.Section_ID 
            AND s.Course_ID = t.Course_ID 
            AND s.Semester = t.Semester
        GROUP BY s.Semester
    ) stats
    LEFT JOIN (
        SELECT 
            Semester,
            COUNT(DISTINCT University_ID) AS Total_Students_Registered
        FROM [Assessment]
        GROUP BY Semester
    ) student_totals
        ON stats.Semester = student_totals.Semester
    LEFT JOIN (
        SELECT 
            Semester,
            COUNT(DISTINCT University_ID) AS Total_Tutors_Teaching
        FROM [Teaches]
        GROUP BY Semester
    ) tutor_totals
        ON stats.Semester = tutor_totals.Semester
);
GO

-- ============================================
-- Example usage:
-- ============================================

PRINT 'Functions created successfully!';
PRINT '';
PRINT 'Usage examples:';
PRINT '1. Get all section statistics:';
PRINT '   SELECT * FROM [dbo].[GetSectionStatistics]() ORDER BY Semester, Course_ID, Section_ID;';
PRINT '';
PRINT '2. Get sections with specific student count:';
PRINT '   SELECT * FROM [dbo].[GetSectionStatistics]() WHERE Student_Count >= 25 ORDER BY Student_Count DESC;';
PRINT '';
PRINT '3. Get summary statistics by semester:';
PRINT '   SELECT * FROM [dbo].[GetSectionSummaryStatistics]();';
PRINT '';
PRINT '4. Get sections missing students or tutors:';
PRINT '   SELECT * FROM [dbo].[GetSectionStatistics]() WHERE Student_Count = 0 OR Tutor_Count = 0;';
GO

