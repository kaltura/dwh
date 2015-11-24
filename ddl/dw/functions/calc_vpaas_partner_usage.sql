DELIMITER $$

USE `kalturadw`$$

DROP PROCEDURE IF EXISTS `calc_vpaas_partner_usage`$$

CREATE PROCEDURE `calc_vpaas_partner_usage`(p_partner_id INTEGER, p_from_date_id INTEGER, p_to_date_id INTEGER, p_time_shift INTEGER, p_order_by VARCHAR(30))
BEGIN
	DROP TABLE IF EXISTS tmp_vpaas_partner_usage;
	
	CREATE TEMPORARY TABLE tmp_vpaas_partner_usage (
		month_id INT,
		total_plays INT DEFAULT 0,
		bandwidth_gb DECIMAL(19,4) DEFAULT 0,
		avg_storage_gb DECIMAL(19,4) DEFAULT 0,
		transcoding_gb DECIMAL(19,4) DEFAULT 0,
		total_media_entries INT DEFAULT 0,
		total_end_users INT DEFAULT 0) 
	ENGINE = MEMORY;
	
	INSERT INTO tmp_vpaas_partner_usage (month_id) 
	SELECT DISTINCT(month_id)
	FROM kalturadw.dwh_dim_time
	WHERE day_id BETWEEN p_from_date_id AND p_to_date_id;
		
	UPDATE tmp_vpaas_partner_usage u
	LEFT JOIN (SELECT FLOOR(date_id/100) month_id, SUM(count_plays) plays
			FROM kalturadw.dwh_hourly_partner
			WHERE date_id BETWEEN IF(p_time_shift>0,(DATE(p_from_date_id) - INTERVAL 1 DAY)*1, p_from_date_id)  
    			AND     IF(p_time_shift<=0,(DATE(p_to_date_id) + INTERVAL 1 DAY)*1, p_to_date_id)
			AND hour_id >= IF (date_id = IF(p_time_shift>0,(DATE(p_from_date_id) - INTERVAL 1 DAY)*1, p_from_date_id), IF(p_time_shift>0, 24 - p_time_shift, ABS(p_time_shift)), 0)
			AND hour_id < IF (date_id = IF(p_time_shift<=0,(DATE(p_to_date_id) + INTERVAL 1 DAY)*1, p_to_date_id), IF(p_time_shift>0, 24 - p_time_shift, ABS(p_time_shift)), 24)
			AND count_plays > 0 
			AND partner_id = p_partner_id
			GROUP BY month_id
			) p ON
		u.month_id = p.month_id
	SET
		total_plays = IFNULL(plays, 0);
		
	
	
	UPDATE tmp_vpaas_partner_usage u
	LEFT JOIN (SELECT FLOOR(date_id/100) month_id, 
			SUM(count_bandwidth_kb)/1024/1024 bandwidth_gb,
			SUM(count_transcoding_mb)/1024 transcoding_gb
			FROM kalturadw.dwh_hourly_partner_usage
			WHERE date_id BETWEEN p_from_date_id AND p_to_date_id
			AND partner_id = p_partner_id
			GROUP BY month_id
			) p ON 
		u.month_id = p.month_id
	SET
		u.bandwidth_gb = IFNULL(p.bandwidth_gb, 0),
		u.transcoding_gb = IFNULL(p.transcoding_gb, 0);
		
		
	UPDATE tmp_vpaas_partner_usage u
	LEFT JOIN (SELECT FLOOR(date_id/100) month_id, 
			SUM(aggr_storage_mb)/COUNT(1)/1024 avg_storage
			FROM kalturadw.dwh_hourly_partner_usage
			WHERE date_id BETWEEN p_from_date_id AND p_to_date_id
			AND bandwidth_source_id = 1
			AND partner_id = p_partner_id
			GROUP BY month_id
			) s ON
		u.month_id = s.month_id
	SET
		u.avg_storage_gb = IFNULL(s.avg_storage, 0);

	
	
	UPDATE tmp_vpaas_partner_usage u
	LEFT JOIN (SELECT month_id, total_entries, total_users
			FROM kalturadw.dwh_daily_partner_totals t,
			(SELECT FLOOR(date_id/100) month_id, MAX(date_id) date_id
			FROM kalturadw.dwh_daily_partner_totals
			WHERE date_id BETWEEN p_from_date_id AND p_to_date_id
			AND partner_id = p_partner_id
			GROUP BY month_id) eom_dates
			WHERE t.date_id = eom_dates.date_id
			AND partner_id = p_partner_id) t ON
		u.month_id = t.month_id
	SET 
		total_media_entries = t.total_entries,
		total_end_users = t.total_users;

	
	SET @s = CONCAT('SELECT * from tmp_vpaas_partner_usage order by ',p_order_by, ';'); 
	PREPARE stmt 
	FROM @s;

	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
    	
	
END$$

DELIMITER ;