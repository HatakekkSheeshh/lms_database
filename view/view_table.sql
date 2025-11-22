USE lms_system; 
GO

/* SELECT TOP 4344
    Section_ID,
    Course_ID,
    Semester,
    Building_ID,
    Room_ID,
    Building_Name
FROM [Section]
ORDER BY Semester;
GO

PRINT '';
PRINT '========================================';
PRINT 'Script completed!';
PRINT '========================================';
GO */

/* SELECT 
    T.University_ID,
    T.NAME
FROM Tutor as T
Where T.University_ID = 1733 */ 

/* SELECT *
FROM Section */

/* declare @totalrooms int;
select @totalrooms = count(*) from [Room]
print 'Number of Rooms: ' + cast(@totalrooms as nvarchar(10))


declare @totalbuildings int;
select @totalbuildings = count(*) from [Building]
print 'Number of Buildings: ' + cast(@totalbuildings as nvarchar(10))



declare @totalSections int;
select @totalSections = count(*) 
from [Section] as S
where 
    S.Semester = '241'
print 'Number of Sections: ' + cast(@totalSections as nvarchar(10))



select @totalSections = count(*) 
from [Section] as S
where 
    S.Semester = '242'
print 'Number of Sections: ' + cast(@totalSections as nvarchar(10))


declare @nostudents int;
select @nostudents = count(*) 
from [Student] 
print 'Number of Students: ' + cast(@nostudents as nvarchar(10))



declare @course int;
select @course = count(*) 
from [Course] 
print 'Number of Courses: ' + cast(@course as nvarchar(10))



declare @ass int;
select @ass = count(*) 
from [Assessment]
print 'Number of Elements: ' + cast(@ass as nvarchar(10)) */


select *
from [Student] as S
Where S.Major = 'ComputerEngineering'