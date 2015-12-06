DELIMITER $$

USE `kalturadw`$$

DROP PROCEDURE IF EXISTS `calc_aggr_day_partner_totals`$$

CREATE PROCEDURE `calc_aggr_day_partner_totals`(calc_date_id INT)
BEGIN
	UPDATE aggr_managment SET start_time = NOW() WHERE aggr_name = 'totals' AND date_id = calc_date_id;
	DELETE FROM kalturadw.dwh_daily_partner_totals WHERE date_id = calc_date_id;
	
	DROP TABLE IF EXISTS temp_totals;
	CREATE TEMPORARY TABLE temp_totals(
		partner_id      	INT(11) NOT NULL PRIMARY KEY,
		added_entries		INT(11) NOT NULL,
		deleted_entries      	INT(11) NOT NULL,
		added_users             INT(11) NOT NULL,
		deleted_users           INT(11) NOT NULL
	) ENGINE = MEMORY;
      
	INSERT INTO 	temp_totals (partner_id, added_entries)
   	SELECT 		partner_id, COUNT(entry_id)
	FROM 		dwh_dim_entries
	WHERE		created_at BETWEEN DATE(calc_date_id) AND (DATE(calc_date_id) + INTERVAL 1 DAY - INTERVAL 1 SECOND)
	AND         (entry_type_id = 7 OR entry_media_type_id IN (1,2,5))
	AND         display_in_search <> -1
	GROUP BY 	partner_id;
	
	INSERT INTO 	temp_totals (partner_id, deleted_entries)
   	SELECT 		partner_id, COUNT(entry_id)
	FROM 		dwh_dim_entries
	WHERE		updated_at BETWEEN DATE(calc_date_id) AND (DATE(calc_date_id) + INTERVAL 1 DAY - INTERVAL 1 SECOND)
	AND         entry_status_id = 3
	AND         (entry_type_id = 7 OR entry_media_type_id IN (1,2,5))
	AND         display_in_search <> -1
	GROUP BY 	partner_id
	ON DUPLICATE KEY UPDATE deleted_entries=VALUES(deleted_entries);
	
	INSERT INTO 	temp_totals (partner_id, added_users)
   	SELECT 		partner_id, COUNT(kuser_id)
	FROM 		dwh_dim_kusers
	WHERE		created_at BETWEEN DATE(calc_date_id) AND (DATE(calc_date_id) + INTERVAL 1 DAY - INTERVAL 1 SECOND)
	GROUP BY 	partner_id
	ON DUPLICATE KEY UPDATE added_users=VALUES(added_users);
	
	INSERT INTO 	temp_totals (partner_id, deleted_users)
   	SELECT 		partner_id, COUNT(kuser_id)
	FROM 		dwh_dim_kusers
	WHERE		updated_at BETWEEN DATE(calc_date_id) AND (DATE(calc_date_id) + INTERVAL 1 DAY - INTERVAL 1 SECOND)
	AND             kuser_status_id = 2
	GROUP BY 	partner_id
	ON DUPLICATE KEY UPDATE deleted_users=VALUES(deleted_users);
	
	INSERT INTO 	kalturadw.dwh_daily_partner_totals (partner_id, date_id, added_entries, deleted_entries, total_entries, added_users, deleted_users, total_users)
	SELECT		partner_id, calc_date_id, 0, 0, total_entries, 0, 0, total_users
	FROM            kalturadw.dwh_daily_partner_totals
	WHERE           date_id = (DATE(calc_date_id) - INTERVAL 1 DAY)*1
	ON DUPLICATE KEY UPDATE added_entries=VALUES(added_entries), deleted_entries=VALUES(deleted_entries), total_entries=VALUES(total_entries),
				added_users=VALUES(added_users), deleted_users=VALUES(deleted_users), total_users = VALUES(total_users);
	
	
	INSERT INTO 	kalturadw.dwh_daily_partner_totals (partner_id, date_id, added_entries, deleted_entries, total_entries, added_users, deleted_users, total_users)
	SELECT		aggr.partner_id, calc_date_id, aggr.added_entries, aggr.deleted_entries, aggr.added_entries - aggr.deleted_entries,
			aggr.added_users, aggr.deleted_users, aggr.added_users - aggr.deleted_users
	FROM		temp_totals aggr 
	ON DUPLICATE KEY UPDATE added_entries=VALUES(added_entries), deleted_entries=VALUES(deleted_entries), total_entries=total_entries + VALUES(total_entries),
				added_users=VALUES(added_users), deleted_users=VALUES(deleted_users), total_users=total_users + VALUES(total_users);
				
	UPDATE aggr_managment SET end_time = NOW() WHERE aggr_name = 'totals' AND date_id = calc_date_id;
	
END$$

DELIMITER ;