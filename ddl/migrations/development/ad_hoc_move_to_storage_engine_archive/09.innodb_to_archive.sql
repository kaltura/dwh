
DELIMITER $$

USE `kalturadw`$$

DROP PROCEDURE IF EXISTS `move_innodb_to_archive`$$

CREATE DEFINER=`etl`@`localhost` PROCEDURE `move_innodb_to_archive`()
BEGIN
	DECLARE v_partition varchar(256);
	DECLARE v_column varchar(256);
	DECLARE v_from_archive DATE;
	DECLARE v_date_val DATE;
	DECLARE v_table_name varchar(256);
	DECLARE v_archive_name varchar(256);
	DECLARE v_exists INT DEFAULT 0;
	DECLARE done INT DEFAULT 0;
	DECLARE c_partitions 
	CURSOR FOR 
	SELECT partition_name, table_name, CONCAT(table_name,'_archive') archive_name, partition_expression column_name, DATE(partition_description) date_id
	FROM information_schema.partitions p, kalturadw_ds.retention_policy r
	WHERE partition_description < date(now() - interval r.archive_start_days_back day)*1
	AND p.table_name = r.table_name
	ORDER BY date_id;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
	
	OPEN c_partitions;
	
	read_loop: LOOP
		FETCH c_partitions INTO v_partition, v_table_name, v_archive_name, v_column, v_date_val;
		IF done THEN
		  LEAVE read_loop;
		END IF;
		
		SELECT COUNT(*)
		into v_exists
		FROM information_schema.partitions p
		WHERE p.partition_description = v_date_val
		AND p.table_name = v_archive_name;
		ORDER BY date_id; 
		
		IF (v_exists = 0) THEN -- create partition if needed
		
			SET @s = CONCAT('ALTER TABLE ',v_archive_name,' ADD PARTITION (PARTITION ',v_partition,' VALUES LESS THAN (',v_date_val,'))');
			PREPARE stmt FROM @s;
			EXECUTE stmt;
			DEALLOCATE PREPARE stmt;
			
		END IF;
		
		SET @s = CONCAT('INSERT INTO ',v_archive_name,' SELECT * FROM ',v_table_name,' WHERE ', v_column ,' < ',v_date_val);
		PREPARE stmt FROM @s;
		EXECUTE stmt;
		DEALLOCATE PREPARE stmt;
		
		SET @s = CONCAT('ALTER TABLE ',v_table_name,' DROP PARTITION ',v_partition);
		PREPARE stmt FROM @s;
		EXECUTE stmt;
		DEALLOCATE PREPARE stmt;
		
		UPDATE kalturadw_ds.retention_policy
		SET archive_last_partition = v_date_val
		WHERE table_name = v_table_name;
		
	END LOOP;
	
END$$

DELIMITER ;
