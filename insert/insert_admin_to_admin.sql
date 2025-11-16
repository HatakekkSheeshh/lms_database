USE [lms_system];
GO

DELETE FROM [Admin];
GO

INSERT INTO [Admin] (University_ID, [Type])
VALUES
(9001, N'Coordinator'),
(9002, N'Office of Academic Affairs'),
(9003, N'Office of Student Affairs'),
(9004, N'Program Administrator');
GO
