DELIMITER $$

USE `kalturadw_ds`$$

DROP PROCEDURE IF EXISTS `transfer_cycle_partition`$$

CREATE PROCEDURE `transfer_cycle_partition`(p_cycle_id VARCHAR(10))
BEGIN
	DECLARE src_table VARCHAR(45);
	DECLARE tgt_table VARCHAR(45);
	DECLARE tgt_table_id INT;
	DECLARE dup_clause VARCHAR(4000);
	DECLARE partition_field VARCHAR(45);
	DECLARE select_fields VARCHAR(4000);
	DECLARE post_transfer_sp_val VARCHAR(4000);
	DECLARE v_ignore_duplicates_on_transfer BOOLEAN;	
	DECLARE aggr_date VARCHAR(400);
	DECLARE aggr_hour VARCHAR(400);
	DECLARE aggr_names VARCHAR(4000);
	DECLARE reset_aggr_min_date DATETIME;
	DECLARE v_reaggr_percent_trigger INT;
	
	
	DECLARE done INT DEFAULT 0;
	DECLARE staging_areas_cursor CURSOR FOR SELECT 	source_table, target_table_id, fact_table_name, IFNULL(on_duplicate_clause,''),	staging_partition_field, post_transfer_sp, aggr_date_field, hour_id_field, post_transfer_aggregations, reset_aggregations_min_date, ignore_duplicates_on_transfer, reaggr_percent_trigger
											FROM staging_areas s, cycles c, fact_tables f
											WHERE s.process_id=c.process_id AND c.cycle_id = p_cycle_id AND f.fact_table_id = s.target_table_id;
											
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
	OPEN staging_areas_cursor;
	
	read_loop: LOOP
		FETCH staging_areas_cursor INTO src_table, tgt_table_id, tgt_table, dup_clause, partition_field, post_transfer_sp_val, aggr_date, aggr_hour, aggr_names, reset_aggr_min_date, v_ignore_duplicates_on_transfer, v_reaggr_percent_trigger;
		IF done THEN
			LEAVE read_loop;
		END IF;
	
		DROP TABLE IF EXISTS tmp_stats;
	
		SET @s = CONCAT('CREATE TEMPORARY TABLE tmp_stats '
				'SELECT ds.date_id, ds.hour_id, new_rows+IFNULL(uncalculated_records,0) as uncalculated_records, ',
				'IFNULL(total_records, 0) calculated_records from ',
				'(SELECT ', aggr_date, ' date_id, ', aggr_hour, ' hour_id, count(*) new_rows FROM ',src_table,
				' WHERE ', partition_field,'  = ',p_cycle_id, ' group by date_id, hour_id) ds ',
				'LEFT OUTER JOIN kalturadw_ds.fact_stats fs on ds.date_id = fs.date_id AND ds.hour_id = fs.hour_id
				AND fs.fact_table_id = ', tgt_table_id);
		PREPARE stmt FROM @s;
		EXECUTE stmt;
		DEALLOCATE PREPARE stmt;
		
		
		IF ((LENGTH(AGGR_DATE) > 0) && (LENGTH(aggr_names) > 0)) THEN
			SET @s = CONCAT('INSERT INTO kalturadw.aggr_managment(aggr_name, date_id, hour_id, data_insert_time)
					SELECT aggr_name, date_id, hour_id, now() 
					FROM kalturadw_ds.aggr_name_resolver a, tmp_stats ts
					WHERE 	aggr_name in ', aggr_names, '
					AND date_id >= date(\'',reset_aggr_min_date,'\')
					AND if(calculated_records=0,100, uncalculated_records*100/(calculated_records+uncalculated_records)) > ', v_reaggr_percent_trigger, '
					ON DUPLICATE KEY UPDATE data_insert_time = now()');
			PREPARE stmt FROM @s;
			EXECUTE stmt;
			DEALLOCATE PREPARE stmt;
		END IF;
		
		SELECT 	GROUP_CONCAT(column_name ORDER BY ordinal_position)
		INTO 	select_fields
		FROM information_schema.COLUMNS
		WHERE CONCAT(table_schema,'.',table_name) = tgt_table;
			
		SET @s = CONCAT('INSERT ', IF(v_ignore_duplicates_on_transfer=1, 'IGNORE', '') ,' INTO ',tgt_table, ' (',select_fields,') ',
						' SELECT ',select_fields,
						' FROM ',src_table,
						' WHERE ',partition_field,'  = ',p_cycle_id,
						' ',dup_clause );
		PREPARE stmt FROM @s;
		EXECUTE stmt;
		DEALLOCATE PREPARE stmt;
			
		INSERT INTO kalturadw_ds.fact_stats (fact_table_id, date_id, hour_id, total_records, uncalculated_records)
			SELECT tgt_table_id, date_id, hour_id,
				IF(calculated_records=0 OR uncalculated_records*100/(calculated_records+uncalculated_records) > v_reaggr_percent_trigger,
					calculated_records + uncalculated_records, calculated_records),
				IF(calculated_records=0 OR uncalculated_records*100/(calculated_records+uncalculated_records) > v_reaggr_percent_trigger,
					0, uncalculated_records)
			FROM tmp_stats t
		ON DUPLICATE KEY UPDATE 
			total_records = IF(t.calculated_records=0 OR t.uncalculated_records*100/(t.calculated_records+t.uncalculated_records) > v_reaggr_percent_trigger,
					t.calculated_records + t.uncalculated_records, t.calculated_records),
			uncalculated_records = IF(t.calculated_records=0 OR t.uncalculated_records*100/(t.calculated_records+t.uncalculated_records) > v_reaggr_percent_trigger,
					0, t.uncalculated_records);
	
		
		IF LENGTH(POST_TRANSFER_SP_VAL)>0 THEN
			SET @s = CONCAT('CALL ',post_transfer_sp_val,'(',p_cycle_id,')');
			PREPARE stmt FROM @s;
			EXECUTE stmt;
			DEALLOCATE PREPARE stmt;
		END IF;
	END LOOP;
	CLOSE staging_areas_cursor;
END$$

DELIMITER ;