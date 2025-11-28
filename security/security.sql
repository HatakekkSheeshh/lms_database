-- Check connecting server
SELECT @@SERVERNAME AS Servername, SUSER_SNAME() as loginName
SELECT USER_NAME()

SELECT * FROM sys.database_principals;

SELECT 
    dp.name AS principal_name,
    dp.type_desc,
    rp.name AS role_name
FROM 
    sys.database_role_members rm
JOIN 
    sys.database_principals rp ON rm.role_principal_id = rp.principal_id
JOIN 
    sys.database_principals dp ON rm.member_principal_id = dp.principal_id;


SELECT * FROM sys.server_principals;

