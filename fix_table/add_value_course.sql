UPDATE Course
SET CCategory = N'Mathematics and Basic Science'
WHERE 
    Course_ID LIKE 'MT%' OR 
    Course_ID LIKE 'CH%' OR 
    Course_ID LIKE 'PH%' OR
    Course_ID IN (N'CO1007', N'CO2011');

UPDATE Course
SET CCategory = N'Core Course'
WHERE 
    Course_ID LIKE 'CO%' AND 
    Course_ID NOT IN (N'CO1007', N'CO2011') AND
    Course_ID < 'CO3000'; 

UPDATE Course
SET CCategory = N'Major Course'
WHERE 
    Course_ID LIKE 'CO%' AND 
    Course_ID >= 'CO2017' AND
    Course_ID NOT IN (N'CO4337', N'CO3335', N'CO4029');

UPDATE Course
SET CCategory = N'Graduation'
WHERE 
    Course_ID IN (N'CO4337', N'CO3335', N'CO4029');

UPDATE Course
SET CCategory = N'National Education'
WHERE Course_ID LIKE 'MI%';