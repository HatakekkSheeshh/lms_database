with DuplicateAssessments as (
    SELECT 
        University_ID, 
        Section_ID,
        Course_ID,
        Semester,
        Assessment_ID,
        MIN(Assessment_ID) OVER (PARTITION BY University_ID, Section_ID, Course_ID, Semester) AS Keep_Assessment_ID
    from [Assessment]
)
select 
    Assessment_ID as ID_To_Delete
INTO 
    #AssessmentsToDelete
from 
    DuplicateAssessments
where 
    Assessment_ID <> Keep_Assessment_ID

-- Remove from Review
SELECT
    s.Submission_No
INTO
    #SubmissionsToDelete
FROM
    Submission s
INNER JOIN
    Assessment a ON s.Assessment_ID = a.Assessment_ID
WHERE
    a.Assessment_ID IN (SELECT ID_To_Delete FROM #AssessmentsToDelete);
DELETE FROM Submission
WHERE Submission_No IN (SELECT Submission_No FROM #SubmissionsToDelete);

DELETE FROM Review
WHERE
    Submission_No IN (SELECT Submission_No FROM #SubmissionsToDelete)
DROP TABLE #SubmissionsToDelete;

-- Remove from Submission
DELETE FROM Submission
WHERE
    University_ID IN (SELECT University_ID FROM #AssessmentsToDelete)
    AND Section_ID IN (SELECT Section_ID FROM #AssessmentsToDelete)
    AND Course_ID IN (SELECT Course_ID FROM #AssessmentsToDelete)
    AND Semester IN (SELECT Semester FROM #AssessmentsToDelete)
    AND Assessment_ID IN (SELECT ID_To_Delete FROM #AssessmentsToDelete);

-- Remove from Assignment
DELETE FROM Assignment
WHERE
    University_ID IN (SELECT University_ID FROM #AssessmentsToDelete)
    AND Section_ID IN (SELECT Section_ID FROM #AssessmentsToDelete)
    AND Course_ID IN (SELECT Course_ID FROM #AssessmentsToDelete)
    AND Semester IN (SELECT Semester FROM #AssessmentsToDelete)
    AND Assessment_ID IN (SELECT ID_To_Delete FROM #AssessmentsToDelete);

-- Remove from Feedback
DELETE FROM Feedback
WHERE
    University_ID IN (SELECT University_ID FROM #AssessmentsToDelete)
    AND Section_ID IN (SELECT Section_ID FROM #AssessmentsToDelete)
    AND Course_ID IN (SELECT Course_ID FROM #AssessmentsToDelete)
    AND Semester IN (SELECT Semester FROM #AssessmentsToDelete)
    AND Assessment_ID IN (SELECT ID_To_Delete FROM #AssessmentsToDelete);

-- Remove from Quiz
DELETE FROM Quiz
WHERE
    University_ID IN (SELECT University_ID FROM #AssessmentsToDelete)
    AND Section_ID IN (SELECT Section_ID FROM #AssessmentsToDelete)
    AND Course_ID IN (SELECT Course_ID FROM #AssessmentsToDelete)
    AND Semester IN (SELECT Semester FROM #AssessmentsToDelete)
    AND Assessment_ID IN (SELECT ID_To_Delete FROM #AssessmentsToDelete);

-- Remove from Assessment
DELETE FROM Assessment
WHERE Assessment_ID IN (SELECT ID_To_Delete FROM #AssessmentsToDelete);

-- Clean temp Table
DROP TABLE #AssessmentsToDelete;