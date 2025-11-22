USE [lms_system];
GO

DELETE FROM [Section];
GO

DELETE FROM [Teaches];
GO

DELETE FROM [Assessment];
GO

DELETE FROM [takes_place];
GO

DELETE FROM [Online];
GO

DELETE FROM [Course];
GO

-- A. MATHEMATICS AND BASIC SCIENCES
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'MT1003', N'Calculus 1', 4, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'MT1005', N'Calculus 2', 4, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'MT1007', N'Linear Algebra', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'MT2013', N'Probability and Statistics', 4, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'CH1003', N'General Chemistry', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'PH1003', N'General Physics 1', 4, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'PH1007', N'General Physics Labs', 1, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'MT1009', N'Numerical Methods', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'CO1007', N'Discrete Structures for Computing', 4, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'CO2011', N'MaThematical Modeling', 3, NULL);

-- B. KHOA HỌC MÁY TÍNH - CORE COURSES
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'CO1005', N'Introduction to Computing', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'CO2001', N'Professional Skills for Engineers', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'CO1023', N'Digital Systems', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'CO1027', N'Programming Fundamentals', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'CO2003', N'Data Structures and Algorithms', 4, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'CO2007', N'Computer Architecture', 4, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'CO2013', N'Database Systems', 4, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'CO2039', N'Advanced Programming', 3, NULL);

-- C. KHOA HỌC MÁY TÍNH - MAJOR SUBJECTS
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'CO2017', N'Operating Systems', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'CO3001', N'Software Engineering', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'CO3005', N'Principles of Programming Languages', 4, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'CO3093', N'Computer Networks', 3, NULL);

-- D. KHOA HỌC MÁY TÍNH - SPECIALITY COURSES (Selected important ones)
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'CO3021', N'Database Management Systems', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'CO3029', N'Data Mining', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'CO3033', N'Information System Security', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'CO3011', N'Software Project Management', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'CO3015', N'Software Testing', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'CO3017', N'Software Architecture', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'CO3049', N'Web Programming', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'CO3051', N'Mobile Systems', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'CO3061', N'Introduction to Artificial Intelligence', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'CO3117', N'Machine Learning', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'CO3133', N'Deep Learning and Its Applications', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'CO3043', N'Mobile Application Development', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'CO3069', N'Cryptography and Network Security', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'CO3137', N'Big Data', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'CO4033', N'Big Data Analytics and Business Intelligence', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'CO3057', N'Digital Image Processing and Computer Vision', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'CO3037', N'Internet of Things Application Development', 3, NULL);

-- E. KHOA HỌC MÁY TÍNH - GRADUATION
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'CO3335', N'Internship', 2, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'CO4029', N'Specialized Project', 2, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'CO4337', N'Capstone Project', 4, NULL);

-- F. NATIONAL DEFENSE EDUCATION
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'MI1003', N'Military Training', 0, NULL);

GO
