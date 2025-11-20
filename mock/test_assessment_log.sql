USE [lms_system];
GO

DECLARE @before INT = ISNULL((SELECT MAX(LogID) FROM Audit_Log), 0);

;WITH Target AS (
    SELECT TOP (1)
           University_ID,
           Section_ID,
           Course_ID,
           Semester,
           Assessment_ID,
           Final_Grade
    FROM Assessment
    WHERE University_ID = 2352023
      AND Final_Grade IS NOT NULL
    ORDER BY Section_ID, Course_ID, Semester, Assessment_ID
)
UPDATE A
SET Final_Grade = T.Final_Grade  
FROM Assessment AS A
JOIN Target AS T
  ON  A.University_ID = T.University_ID
  AND A.Section_ID    = T.Section_ID
  AND A.Course_ID     = T.Course_ID
  AND A.Semester      = T.Semester
  AND A.Assessment_ID = T.Assessment_ID;

SELECT *
FROM Audit_Log
WHERE LogID > @before
ORDER BY LogID;

SELECT *
FROM Reference_To
WHERE LogID > @before
ORDER BY LogID, University_ID;
