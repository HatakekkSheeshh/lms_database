CREATE TRIGGER trg_LateSubmission
ON [Submission]
AFTER INSERT, UPDATE
AS
BEGIN
    UPDATE [Submission]
    SET late_flag_indicator = 1 -- là nộp muộn
    FROM [Submission]
    JOIN inserted
        ON [Submission].Submission_No = inserted.Submission_No
    JOIN [Assignment]
        ON [Submission].University_ID = [Assignment].University_ID
       AND [Submission].Section_ID = [Assignment].Section_ID
       AND [Submission].Course_ID = [Assignment].Course_ID
       AND [Submission].Semester = [Assignment].Semester
       AND [Submission].Assessment_ID = [Assignment].Assessment_ID
    WHERE inserted.SubmitDate > [Assignment].submission_deadline;
END;
GO
