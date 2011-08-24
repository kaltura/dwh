DELIMITER $$

USE `kalturadw`$$

DROP PROCEDURE IF EXISTS `post_aggregation_partner`$$

CREATE DEFINER=`etl`@`localhost` PROCEDURE `post_aggregation_devices`(date_val DATE, p_hour_id INT(11))
BEGIN
	DECLARE v_aggr_table VARCHAR(100);
	
	SELECT aggr_table INTO v_aggr_table
	FROM kalturadw_ds.aggr_name_resolver
	WHERE aggr_name = 'devices';
	
	SET @s = CONCAT('INSERT INTO ',v_aggr_table,'
    		(partner_id, 
    		date_id, 
            hour_id,
    		country_id,location_id,os_id,browser_id,ui_conf_id,
    		count_bandwidth_kb)
    	SELECT  
    		partner_id,date_id,hour_id,
			country_id,location_id,os_id,browser_id,ui_conf_id,
    		SUM(bandwidth_bytes) / 1024 count_bandwidth_kb
    	FROM dwh_fact_bandwidth_usage  b
    		WHERE (
    			b.activity_date_id = DATE(''',date_val,''')*1 
				AND b.activity_hour_id = ',p_hour_id, '
    	GROUP BY partner_id, 
    		date_id, 
            hour_id,
    		country_id,location_id,os_id,browser_id,ui_conf_id
    	ON DUPLICATE KEY UPDATE
    		count_bandwidth_kb=VALUES(count_bandwidth_kb);
    	');
	PREPARE stmt FROM  @s;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
	
END$$

DELIMITER ;