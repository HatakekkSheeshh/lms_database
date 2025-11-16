USE [lms_system];
GO

-- A. MATHEMATICS AND BASIC SCIENCES (Chung cho cả 2 ngành)
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'MT1003', N'Calculus 1', 4, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'MT1005', N'Calculus 2', 4, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'MT1007', N'Linear Algebra', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'MT2013', N'Probability and Statistics', 4, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'CH1003', N'General Chemistry', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'PH1003', N'General Physics 1', 4, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'PH1007', N'General Physics Labs', 1, NULL);

-- A. MATHEMATICS AND BASIC SCIENCES (Riêng)
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'EE1007', N'Semiconductor Physics', 4, NULL); -- Ngành Đ&ĐT
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'MT1009', N'Numerical Methods', 3, NULL); -- Ngành Đ&ĐT
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'CO1007', N'Discrete Structures for Computing', 4, NULL); -- Ngành KHMT
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'CO2011', N'MaThematical Modeling', 3, NULL); -- Ngành KHMT

-- B. SOCIALS AND ECONOMICS (Chung)
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'SP1007', N'Introduction to VietNamese Law', 2, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'SP1031', N'Marxist - Leninist Philosophy', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'SP1033', N'Marxist - Leninist Political Economy', 2, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'SP1035', N'Scientific Socialism', 2, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'SP1037', N'Ho Chi Minh Ideology', 2, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'SP1039', N'History of VieTNamese Communist Party', 2, NULL);

-- C. INTRODUCTION (Riêng)
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'EE1001', N'Introduction to Electrical and Electronics Engineering', 3, NULL); -- Ngành Đ&ĐT
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'CO1005', N'Introduction to Computing', 3, NULL); -- Ngành KHMT

-- D. FOREIGN LANGUAGES (Chung)
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'LA1003', N'English 1', 2, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'LA1005', N'English 2', 2, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'LA1007', N'English 3', 2, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'LA1009', N'English 4', 2, NULL);

-- E. CORE COURSES (Ngành ĐIỆN - ĐIỆN TỬ)
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'EE1009', N'Digital Designs', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'EE2005', N'Signals and Systems', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'EE2081', N'Programming Languages', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'EE2017', N'Fundamentals of Power Engineering', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'EE2019', N'Fundamentals of Control Systems', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'EE2021', N'Fundamental of Power Electronics', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'EE2023', N'Electronic Workshop 1', 1, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'EE2025', N'Electrical Workshop 1', 1, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'EE2033', N'Electric Circuit Analysis', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'EE2035', N'Electronic Circuits', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'EE2039', N'Microprocessor', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'EE3023', N'Electrical Workshop 2', 1, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'EE3185', N'Project 1', 1, NULL);

-- F. SPECIALITY COURSES (Ngành ĐIỆN - ĐIỆN TỬ)
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'EE3005', N'Industrial Instrumentation', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'EE3007', N'Advanced Control Theory', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'EE3017', N'PC-Based Measurement and Control', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'EE3029', N'Devices and Automation Systems', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'EE3065', N'Robotics', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'EE3355', N'Internship', 2, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'EE4009', N'Project 2', 2, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'EE4357', N'Capstone Project', 4, NULL);

-- G. ELECTIVE SPECIALIZED COURSES (Ngành ĐIỆN - ĐIỆN TỬ)
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'EE3057', N'Introduction to Intelligent Control', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'EE3063', N'Artificial Intelligence', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'EE3067', N'Embedded Control Systems', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'EE3069', N'Programmable Logic Controller', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'EE3071', N'SCADA', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'EE3075', N'Pneumatic and Hydraulic Control Components and Systems', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'EE3077', N'Machine Vision', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'EE3079', N'Power Electronics and Applications', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'EE3173', N'Motion Control', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'EE3175', N'Modeling and Simulation of Industrial Systems', 3, NULL);

-- H. CORE COURSES (Ngành KHOA HỌC MÁY TÍNH)
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'CO2001', N'Professional Skills for Engineers', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'CO1023', N'Digital Systems', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'CO1027', N'Programming Fundamentals', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'CO2003', N'Data Structures and Algorithms', 4, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'CO2007', N'Computer Architecture', 4, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'CO2013', N'Database Systems', 4, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'CO2039', N'Advanced Programming', 3, NULL);

-- I. MAJOR SUBJECTS (Ngành KHOA HỌC MÁY TÍNH)
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'CO2017', N'Operating Systems', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'CO3001', N'Software Engineering', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'CO3005', N'Principles of Programming Languages', 4, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'CO3093', N'Computer Networks', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'CO3101', N'Programming Intergration Project', 1, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'CO3103', N'Programming Intergration Project', 1, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'CO3105', N'Programming Intergration Project', 1, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'CO3127', N'Programming Intergration Project - Data Engineering', 1, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'CO3119', N'Computer Networks Project', 1, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'CO3107', N'Multidisciplinary Project', 1, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'CO3109', N'Multidisciplinary Project', 1, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'CO3111', N'Multidisciplinary Project', 1, NULL);

-- J. SPECIALITY COURSES (Ngành KHOA HỌC MÁY TÍNH - Nhiều chuyên ngành)
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'CO3021', N'Database Management Systems', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'CO3027', N'Electronic Commerce', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'CO3029', N'Data Mining', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'CO3033', N'Information System Security', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'CO3115', N'Systems Analysis and Design', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'CO4031', N'Data Warehouses and Decision Support Systems', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'CO4033', N'Big Data Analytics and Business Intelligence', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'CO4035', N'Enterprise Resource Planning Systems', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'CO4037', N'Management Information Systems', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'CO4039', N'Biometric Security', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'CO3139', N'Digital transformation', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'CO3137', N'Big Data', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'CO3011', N'Software Project Management', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'CO3129', N'Software Security', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'CO3131', N'Next-gen Software Engineering', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'CO3015', N'Software Testing', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'CO3017', N'Software Architecture', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'CO3065', N'Advanced Software Engineering', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'CO3041', N'Intelligent Systems', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'CO3049', N'Web Programming', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'CO3135', N'Programming for Artificial Intelligence and Data Science', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'CO3089', N'Selected Topics in High Performance Computing', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'CO3151', N'Network management', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'CO3051', N'Mobile Systems', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'CO3069', N'Cryptography and Network Security', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'CO3153', N'Computer Network Security Assessment', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'CO3061', N'Introduction to Artificial Intelligence', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'CO3117', N'Machine Learning', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'CO3133', N'Deep Learning and Its Applications', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'CO3085', N'Natural Language Processing', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'CO3057', N'Digital Image Processing and Computer Vision', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'CO3045', N'Game Programming', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'CO3059', N'Computer Graphics', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'CO3067', N'Parallel Computing', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'CO3037', N'Internet of Things Application Development', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'CO3043', N'Mobile Application Development', 3, NULL);

-- K. GRADUATION (Ngành KHOA HỌC MÁY TÍNH)
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'CO3335', N'Internship', 2, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'CO4029', N'Specialized Project', 2, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'CO4337', N'Capstone Project', 4, NULL);

-- L. ELECTIVE MANAGEMENT / ENVIRONMENT (Chung)
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'IM1023', N'Production and Operations Management for Engineers', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'IM1025', N'Project Management for Engineers', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'IM3001', N'Business Administration for Engineers', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'IM1031', N'Entrepreneurship and Innovation', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'EN1003', N'Humans and The Environment', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, [Start_Date]) VALUES (N'ME1019', N'Quality and Productivity Management', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'IM1013', N'Economics', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'IM1027', N'Engineering Economics', 3, NULL);

-- M. NATIONAL DEFENSE EDUCATION (Chung)
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'MI1003', N'Military Training', 0, NULL);

-- N. PHYSICAL EDUCATION (Chung)
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'PE1009', N'Football', 0, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'PE1011', N'Volleyball', 0, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'PE1013', N'Table tennis', 0, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'PE1021', N'Aerobic', 0, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'PE1015', N'Basketball', 0, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'PE1017', N'Badminton', 0, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'PE1025', N'Athletics', 0, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'PE1019', N'Swimming', 0, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'PE1027', N'Tennis', 0, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'PE1053', N'Chess (study part 1)', 0, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'PE1057', N'Bowling (Part 1)', 0, NULL); 
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'PE1061', N'Pickleball (Part 1)', 0, NULL); 
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'PE1037', N'Table tennis', 0, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'PE1041', N'Badminton', 0, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'PE1033', N'Football', 0, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'PE1045', N'Aerobic', 0, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'PE1043', N'Swimming', 0, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'PE1039', N'Basketball', 0, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'PE1035', N'Volleyball', 0, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'PE1049', N'Athletics', 0, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'PE1051', N'Tennis', 0, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'PE1S55', N'Chess (study part 2)', 0, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'PE1063', N'Pickleball (Part 2)', 0, NULL); 
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'PE1059', N'Bowling (Part 2)', 0, NULL); 

-- O. GRADUATION REQUIREMENTS (Chung)
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'SA4001', N'Student Activities', 0, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'ENG GC', N'English Requirement for Graduation', 0, NULL);

--Additional
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'ME1009', N'Operations Management', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'ME2045', N'Engineering Economy', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'ME2049', N'Computer Applications for Industrial Engineering', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'ME2051', N'Operations Research', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'ME2123', N'Systems Engineering', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'ME2141', N'Forecasting Engineering', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'ME2151', N'Supply Chain Management', 4, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'ME2148', N'Professional Practice - Field Trips in Industrial Systems', 2, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'ME2157', N'Quality Management and Control', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'ME2319', N'Logistics Engineering and Management', 4, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'ME2321', N'Quantitative Methods in Logistics Implementation Project', 2, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'ME2113', N'Procurement Management', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'ME3253', N'Facility Planning', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'ME3257', N'Decision Making Models in Supply Chain', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'ME4021', N'Freight Transportation', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'ME4023', N'Planning and Scheduling in Supply Chain', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'ME4025', N'Inventory Management in Supply Chain', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'ME3345', N'Warehousing Design and Operations', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'IU1001', N'Introduction to Engineering', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'IU4025', N'Maintenance Costs', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'IU4027', N'Total Productive Maintenance - TPM', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'ME2173', N'Industry 4.0 Technologies in Quality and Productivity Management', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'IU3015', N'Safety and Environment in Maintenance', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'IU1015', N'Engineering Drawing for Maintenance', 2, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'CE2003', N'Fluid Mechanics', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'ME2013', N'Thermodynamics and Heat Transfer', 4, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'IU2035', N'Electrical Technology in Maintenance', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'IU2037', N'Mechanics of Materials', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'IU2043', N'Mechanical Technology 1', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'IU3061', N'Mechanical Technology 2', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'IU3115', N'Organization and Management of Maintenance', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'IU2011', N'Electronic Engineering', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'IU3017', N'Digital System Technology', 3, NULL);
INSERT INTO [Course] (Course_ID, [Name], Credit, Start_Date) VALUES (N'IU2039', N'Mechanical Practice', 1, NULL);
