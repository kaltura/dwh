DELIMITER $$

USE `kalturadw`$$

DROP PROCEDURE IF EXISTS `calc_aggr_day_ingestion`$$

CREATE DEFINER=`etl`@`localhost` PROCEDURE `calc_aggr_day_ingestion`(p_date_id INT(11))
BEGIN
	DECLARE v_ignore DATE;
	DECLARE v_from_archive DATE;
    DECLARE v_table_name VARCHAR(100);
	DECLARE v_aggr_table VARCHAR(100);
	DECLARE v_aggr_id_field_str VARCHAR(100);
	
	UPDATE aggr_managment SET start_time = NOW() WHERE aggr_name = 'ingestion' AND date_id = p_date_id;
		
	            
	SET @s = CONCAT('INSERT INTO kalturadw.dwh_daily_ingestion (date_id, normal_wait_time_count, medium_wait_time_count, long_wait_time_count, extremely_long_wait_time_count,stuck_wait_time_count)'
					'SELECT created_date_id, COUNT(IF(wait_time< 5,1,null)) normal_wait_time, COUNT(IF(wait_time>5 AND wait_time < 180,1,null)) medium_wait_time, COUNT(IF(wait_time>180 AND wait_time<900,1,null)) long_wait_time,
					COUNT(IF(wait_time>900 AND wait_time < 3600,1,null)) extremely_long_wait_time_count, COUNT(IF(wait_time>3600)) stuck
					FROM kalturadw.dwh_fact_convert_job
					WHERE is_ff = 1 
					AND created_date_id = ' ,p_date_id , 
					'ON DUPLICATE KEY UPDATE	
						normal_wait_time_count=VALUES(normal_wait_time_count),
						medium_wait_time_count=VALUES(medium_wait_time_count),
						long_wait_time_count=VALUES(long_wait_time_count),
						extremely_long_wait_time_count=VALUES(extremely_long_wait_time_count),
						stuck_wait_time_count=VALUES(stuck_wait_time_count);');
	
		
	PREPARE stmt FROM  @s;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
	
	SET @s = CONCAT('INSERT INTO kalturadw.dwh_daily_ingestion (date_id, success_entries_count, failed_entries_count)'
					'SELECT COUNT(IF(entry.status_id=2, 1, NULL) entries_success, COUNT(IF(entry.status_id=-1, 1, NULL) entries_failure
					FROM kalturadw.dwh_dim_entries entry, kalturadw.dwh_dim_batch_job_sep job
					WHERE entry.entry_id = job.entry_id
					AND entry.created_date_id = ' , p_date_id,
					'AND e.entry_media_type_id IN (1,5)
					ON DUPLICATE KEY UPDATE	
						success_entries_count=VALUES(success_entries_count),
						failed_entries_count=VALUES(failed_entries_count);');
	
		
	PREPARE stmt FROM  @s;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
	
	SET @s = CONCAT('INSERT INTO kalturadw.dwh_daily_ingestion (date_id, success_conversion_job_count, failed_conversion_job_count)'
					'SELECT created_date_id, COUNT(IF(status_id=5,1,NULL)) conversion_job_success, COUNT(IF(status_id=6 OR status_id = 10,1,NULL)) conversion_job_failure 
					 FROM kalturadw.dwh_fact_convert_job
					 WHERE created_date_id = ', p_date_id,
					 'ON DUPLICATE KEY UPDATE	
						success_conversion_job_count=VALUES(success_conversion_job_count),
						failed_conversion_job_count=VALUES(failed_conversion_job_count);');
	
		
	PREPARE stmt FROM  @s;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
			
	SET @s = CONCAT('INSERT INTO kalturadw.dwh_daily_ingestion (date_id, avg_wait_time)'
					'SELECT created_date_id, AVG(wait_time)
					 FROM kalturadw.dwh_fact_convert_job
					 WHERE created_date_id = ' ,p_date_id,
					 'ON DUPLICATE KEY UPDATE	
						avg_wait_time=VALUES(avg_wait_time);');
	
		
	PREPARE stmt FROM  @s;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
		
	UPDATE aggr_managment SET end_time = NOW() WHERE aggr_name = 'ingestion' AND date_id = p_date_id;
END$$

DELIMITER ;
