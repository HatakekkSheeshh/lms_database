SELECT
    fk.name AS Foreign_Key_Name,
    OBJECT_NAME(fk.parent_object_id) AS Referencing_Table, 
    COL_NAME(fkc.parent_object_id, fkc.parent_column_id) AS Referencing_Column, 
    OBJECT_NAME(fk.referenced_object_id) AS Referenced_Table,
    COL_NAME(fkc.referenced_object_id, fkc.referenced_column_id) AS Referenced_Column 
FROM
    sys.foreign_keys fk
INNER JOIN
    sys.foreign_key_columns fkc ON fk.object_id = fkc.constraint_object_id
WHERE
    OBJECT_NAME(fk.referenced_object_id) = 'Assessment' 
ORDER BY
    Referencing_Table;