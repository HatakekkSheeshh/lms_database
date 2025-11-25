SELECT TOP (1000) * FROM [dbo].[Course]
group by CCategory, Course_ID, [Name], [Credit];