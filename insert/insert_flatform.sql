USE [lms_system];
GO

DELETE FROM [Platform];
GO

INSERT INTO [Platform] ([Name]) VALUES
(N'Microsoft Teams'),
(N'Google Meet'),
(N'Zoom Meeting'),
(N'BK-eLearning (Moodle)'),
(N'Website Khoa');