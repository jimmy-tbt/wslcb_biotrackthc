CREATE PROCEDURE usp_drop_index_if_exists (
  IN the_table varchar(128),
  IN the_index_name varchar(128)
)
BEGIN
  IF((SELECT COUNT(*) AS INDEX_EXISTS FROM INFORMATION_SCHEMA.STATISTICS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = the_table AND INDEX_NAME = the_index_name) > 0) THEN
  SET @s = CONCAT('DROP INDEX ' , the_index_name , ' ON ' , the_table);
  PREPARE stmt FROM @s;
  EXECUTE stmt;
  END IF;
END;
