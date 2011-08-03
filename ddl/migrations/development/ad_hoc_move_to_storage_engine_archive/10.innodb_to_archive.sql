use kalturadw;

CREATE TABLE innodb_to_archive
AS
SELECT partition_name, table_name, partition_expression column_name, partition_description date_id, 0 is_moved, 0 is_dropped
FROM information_schema.partitions p
WHERE partition_description <= 	(SELECT max(date_value) FROM kalturadw_ds.parameters WHERE parameter_name = 'aggr_archive_cutoff_date')
AND p.table_name in('dwh_fact_events' , 'dwh_fact_fms_sessions' , 'dwh_fact_fms_session_events' ,'dwh_fact_bandwidth_usage')
ORDER BY date_id;

DELIMITER $$

USE `kalturadw`$$

DROP PROCEDURE IF EXISTS `do_innodb_to_archive`$$

CREATE DEFINER=`etl`@`localhost` PROCEDURE `do_innodb_to_archive`(p_date_val int, p_table_name varchar(256))
BEGIN
	DECLARE v_moved int;
	DECLARE v_dropped int;
	declare v_partition varchar(256);
	declare v_column varchar(256);
	
	SELECT is_moved, is_dropped, partition_name, column_name
	INTO v_moved, v_dropped, v_partition, v_column
	FROM innodb_to_archive
	WHERE date_id = p_date_val AND table_name = p_table_name;
	
	IF (v_moved=0) THEN
		SET @s = CONCAT('INSERT INTO ',p_table_name,'_archive SELECT * FROM ',p_table_name,' WHERE ', v_column ,' < ',p_date_val);
		PREPARE stmt FROM @s;
		EXECUTE stmt;
		DEALLOCATE PREPARE stmt;
		
		UPDATE innodb_to_archive SET is_moved = 1 WHERE date_id = p_date_val AND table_name = p_table_name;
	END IF;

	IF (v_dropped=0) THEN
		SET @s = CONCAT('ALTER TABLE ',p_table_name,' DROP PARTITION ',v_partition);
		PREPARE stmt FROM @s;
		EXECUTE stmt;
		DEALLOCATE PREPARE stmt;
		
		UPDATE innodb_to_archive SET is_dropped = 1 WHERE date_id = p_date_val AND table_name = p_table_name;
	
	END IF;
	
END$$

DELIMITER ;

DELIMITER $$

DROP PROCEDURE IF EXISTS `all_innodb_to_archive`$$

CREATE DEFINER=`etl`@`localhost` PROCEDURE `all_innodb_to_archive`()
BEGIN
	DECLARE done INT DEFAULT 0;
	DECLARE v_date_val INT;
	DECLARE v_table_name VARCHAR(256);
	DECLARE c_partitions 
	CURSOR FOR 
	SELECT date_id, table_name
	FROM innodb_to_archive
	ORDER BY date_id;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
	
	OPEN c_partitions;
	
	read_loop: LOOP
    FETCH c_partitions INTO v_date_val, v_table_name;
    IF done THEN
      LEAVE read_loop;
    END IF;
    
	CALL do_innodb_to_archive(v_date_val,v_table_name);
	
	
  END LOOP;

  CLOSE c_partitions;
	
END$$

DELIMITER ;
