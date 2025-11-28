SELECT SUSER_SNAME() as 'Login Admin';        
SELECT USER_NAME() as 'User';          
SELECT 
    name,
    type, 
    type_desc as 'Type Description',
    authentication_type_desc 'Authentication Type Description'
FROM sys.database_principals 
WHERE name IN ('dbo');