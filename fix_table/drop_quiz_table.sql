IF OBJECT_ID('[dbo].[vw_StudentQuiz]', 'V') IS NOT NULL
BEGIN
    DROP VIEW [dbo].[vw_StudentQuiz];
END

IF OBJECT_ID('[dbo].[vw_TutorQuiz]', 'V') IS NOT NULL
BEGIN
    DROP VIEW [dbo].[vw_TutorQuiz];
END


DROP TABLE [Quiz]