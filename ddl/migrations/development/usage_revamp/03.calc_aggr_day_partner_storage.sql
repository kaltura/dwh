DELIMITER $$

USE `kalturadw`$$

DROP PROCEDURE IF EXISTS `calc_aggr_day_partner_storage`$$

CREATE DEFINER=`etl`@`localhost` PROCEDURE `calc_aggr_day_partner_storage`(date_val DATE)
BEGIN
	DELETE FROM kalturadw.dwh_hourly_partner_usage WHERE date_id = DATE(date_val)*1 AND IFNULL(count_bandwidth_kb,0) = 0 AND (IFNULL(count_storage_mb,0) > 0 OR IFNULL(billable_storage_mb,0) > 0);
    UPDATE kalturadw.dwh_hourly_partner_usage SET count_storage_mb = NULL, billable_storage_mb=NULL WHERE date_id = DATE(date_val)*1 AND IFNULL(count_bandwidth_kb,0) > 0;
	
	DROP TABLE IF EXISTS temp_aggr_storage;
	CREATE TEMPORARY TABLE temp_aggr_storage(
		partner_id      	INT(11) NOT NULL,
		date_id     		INT(11) NOT NULL,
		hour_id	 		    TINYINT(4) NOT NULL,
		count_storage_mb	DECIMAL(19,4) NOT NULL
	) ENGINE = MEMORY;
      
	INSERT INTO 	temp_aggr_storage (partner_id, date_id, hour_id, count_storage_mb)
   	SELECT 		partner_id, MAX(entry_size_date_id), 0 hour_id, SUM(entry_additional_size_kb)/1024 count_storage_mb
	FROM 		dwh_fact_entries_sizes
	WHERE		entry_size_date_id=DATE(date_val)*1
	GROUP BY 	partner_id;
	
	DROP TABLE IF EXISTS partner_latest_total;
    CREATE TEMPORARY TABLE partner_latest_total(
        partner_id          INT(11) NOT NULL,
        aggr_storage_mb    DECIMAL(19,4) NOT NULL DEFAULT 0
    ) ENGINE = MEMORY; 
	
    ALTER TABLE partner_latest_total ADD INDEX index_1 (partner_id);
	
	INSERT INTO partner_latest_total (partner_id, aggr_storage_mb)
    SELECT u.partner_id, IFNULL(u.aggr_storage_mb,0)
    FROM dwh_hourly_partner_usage u JOIN (SELECT partner_id, MAX(date_id) AS date_id FROM dwh_hourly_partner_usage WHERE bandwidth_source_id = 1 AND hour_id = 0 GROUP BY partner_id) MAX
	      ON u.partner_id = max.partner_id AND u.date_id = max.date_id; 
	
	INSERT INTO 	kalturadw.dwh_hourly_partner_usage (partner_id, date_id, hour_id, bandwidth_source_id, count_storage_mb, aggr_storage_mb)
	SELECT		aggr.partner_id, aggr.date_id, aggr.hour_id, 1, aggr.count_storage_mb, aggr.count_storage_mb + IFNULL(partner_latest_total.aggr_storage_mb,0)
	FROM		temp_aggr_storage aggr LEFT JOIN partner_latest_total ON aggr.partner_id = partner_latest_total.partner_id
	ON DUPLICATE KEY UPDATE count_storage_mb=VALUES(count_storage_mb), aggr_storage_mb=VALUES(aggr_storage_mb) ;

END$$

DELIMITER ;