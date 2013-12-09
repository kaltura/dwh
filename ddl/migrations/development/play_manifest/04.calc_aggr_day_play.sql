DELIMITER $$

USE `kalturadw`$$

DROP PROCEDURE IF EXISTS `calc_aggr_day_play`$$

CREATE PROCEDURE `calc_aggr_day_play`(p_date_val DATE,p_hour_id INT(11), p_aggr_name VARCHAR(100))
BEGIN
	DECLARE v_aggr_table VARCHAR(100);
	DECLARE v_aggr_id_field VARCHAR(100);
	DECLARE extra VARCHAR(100);
	DECLARE v_from_archive DATE;
	DECLARE v_ignore DATE;
	DECLARE v_table_name VARCHAR(100);
	DECLARE v_join_table VARCHAR(100);
	DECLARE v_join_condition VARCHAR(200);
	DECLARE v_use_index VARCHAR(100);
    		
	SELECT DATE(NOW() - INTERVAL archive_delete_days_back DAY), DATE(archive_last_partition)
	INTO v_ignore, v_from_archive
	FROM kalturadw_ds.retention_policy
	WHERE table_name = 'dwh_fact_plays';	
	
	IF (p_date_val >= v_ignore) THEN 
		
			SELECT aggr_table, aggr_id_field
			INTO  v_aggr_table, v_aggr_id_field
			FROM kalturadw_ds.aggr_name_resolver
			WHERE aggr_name = p_aggr_name;	
			
			SET extra = CONCAT('pre_aggregation_',p_aggr_name);
			IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_NAME=extra) THEN
			    SET @ss = CONCAT('CALL ',extra,'(''', p_date_val,''',',p_hour_id,');'); 
			    PREPARE stmt1 FROM  @ss;
			    EXECUTE stmt1;
			    DEALLOCATE PREPARE stmt1;
			END IF ;
		
			IF (v_aggr_table <> '') THEN 
				SET @s = CONCAT('delete from ',v_aggr_table,' where date_id = DATE(''',p_date_val,''')*1 and hour_id = ',p_hour_id);
				PREPARE stmt FROM  @s;
				EXECUTE stmt;
				DEALLOCATE PREPARE stmt;	
			END IF;
			
			SET @s = CONCAT('INSERT INTO aggr_managment(aggr_name, date_id, hour_id, data_insert_time)
					VALUES(''',p_aggr_name,''',''',DATE(p_date_val)*1,''',',p_hour_id,',NOW())
					ON DUPLICATE KEY UPDATE data_insert_time = values(data_insert_time)');
			PREPARE stmt FROM  @s;
			EXECUTE stmt;
			DEALLOCATE PREPARE stmt;
		
			IF (p_date_val >= v_from_archive) THEN 
				SET v_table_name = 'dwh_fact_plays';
				SET v_use_index = 'USE INDEX (play_hour_id_play_date_id_partner_id)';
			ELSE
				SET v_table_name = 'dwh_fact_plays_archive';
				SET v_use_index = '';
			END IF;
			
			SELECT aggr_table, CONCAT(
							IF(aggr_id_field <> '', CONCAT(',', aggr_id_field),'') ,
							IF(dim_id_field <> '', 	CONCAT(', e.', REPLACE(dim_id_field,',',', e.')), '')
						  )
			INTO  v_aggr_table, v_aggr_id_field
			FROM kalturadw_ds.aggr_name_resolver
			WHERE aggr_name = p_aggr_name;
			
			SELECT IF(join_table <> '' , CONCAT(',', join_table), ''), IF(join_table <> '', CONCAT(' AND ev.' ,join_id_field,'=',join_table,'.',join_id_field), '')
			INTO v_join_table, v_join_condition
			FROM kalturadw_ds.aggr_name_resolver
			WHERE aggr_name = p_aggr_name;
			
			
			SET @s = CONCAT('UPDATE aggr_managment SET start_time = NOW()
					WHERE aggr_name = ''',p_aggr_name,''' AND date_id = ''',DATE(p_date_val)*1,''' AND hour_id = ',p_hour_id);
			PREPARE stmt FROM  @s;
			EXECUTE stmt;
			DEALLOCATE PREPARE stmt;
			
			IF ( v_aggr_table <> '' ) THEN
				SET @s = CONCAT('INSERT INTO ',v_aggr_table,'
					(partner_id
					,date_id
					,hour_id
					',REPLACE(v_aggr_id_field,'e.',''),' 
					,client_tag_id
					,count_plays 
					) 
				SELECT  ev.partner_id,ev.play_date_id, play_hour_id',v_aggr_id_field,',
				client_tag_id,
				count(1) count_plays
				FROM ',v_table_name,' as ev ', v_use_index, v_join_table,
					' WHERE ev.play_date_id  = DATE(''',p_date_val,''')*1
					AND ev.play_hour_id = ',p_hour_id ,v_join_condition, 
				' GROUP BY partner_id,play_date_id, play_hour_id, client_tag_id',v_aggr_id_field,';');
			
			PREPARE stmt FROM  @s;
			EXECUTE stmt;
			DEALLOCATE PREPARE stmt;
						
				
				SET extra = CONCAT('post_aggregation_',p_aggr_name);
				IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_NAME=extra) THEN
					SET @ss = CONCAT('CALL ',extra,'(''', p_date_val,''',',p_hour_id,');'); 
					PREPARE stmt1 FROM  @ss;
					EXECUTE stmt1;
					DEALLOCATE PREPARE stmt1;
				END IF ;
				
			END IF;	  
			
		
	END IF;
	
	SET @s = CONCAT('UPDATE aggr_managment SET end_time = NOW() WHERE aggr_name = ''',p_aggr_name,''' AND date_id = ''',DATE(p_date_val)*1,''' AND hour_id =',p_hour_id);
	PREPARE stmt FROM  @s;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
		
END$$

DELIMITER ;