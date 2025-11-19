USE [lms_system]

UPDATE A
SET Final_Grade = ISNULL(Final_Grade, 0) + 0.5
FROM Assessment AS A
WHERE A.University_ID = 2211073;