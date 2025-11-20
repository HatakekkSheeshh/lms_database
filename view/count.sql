USE [lms_system]

/* SELECT  
    COUNT(T.University_ID)
FROM Tutor AS T */



SELECT
    *
FROM Users AS u
WHERE LEN(University_ID) = 4