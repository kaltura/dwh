DELIMITER $$

USE `kalturadw`$$

DROP PROCEDURE IF EXISTS `init_partner_totals_aggr`$$

CREATE PROCEDURE `init_partner_totals_aggr`(p_init_date_id INTEGER)
BEGIN
	DECLARE p_the_day_before INT;
	SET p_the_day_before = (DATE(p_init_date_id) - INTERVAL 1 DAY)*1;

	TRUNCATE kalturadw.dwh_daily_partner_totals;
	
	INSERT INTO kalturadw.dwh_daily_partner_totals(partner_id, date_id, total_entries)
	SELECT partner_id, p_the_day_before, COUNT(entry_id)
	FROM kalturadw.dwh_dim_entries
	WHERE created_at < DATE(p_init_date_id)
	AND ((entry_status_id <> 3) OR (entry_status_id = 3 AND updated_at >= DATE(p_init_date_id)))
	AND (entry_type_id = 7 OR entry_media_type_id IN (1,2,5))
	AND display_in_search <> -1
	GROUP BY partner_id;

	INSERT INTO kalturadw.dwh_daily_partner_totals(partner_id, date_id, added_entries)
	SELECT partner_id, p_the_day_before, COUNT(entry_id)
	FROM kalturadw.dwh_dim_entries
	WHERE created_at BETWEEN DATE(p_the_day_before) AND DATE(p_the_day_before) + INTERVAL 1 DAY - INTERVAL 1 SECOND 
	AND entry_status_id <> 3
	AND (entry_type_id = 7 OR entry_media_type_id IN (1,2,5))
	AND display_in_search <> -1
	GROUP BY partner_id
	ON DUPLICATE KEY UPDATE added_entries=VALUES(added_entries);

	INSERT INTO kalturadw.dwh_daily_partner_totals(partner_id, date_id, deleted_entries)
	SELECT partner_id, p_the_day_before, COUNT(entry_id)
	FROM kalturadw.dwh_dim_entries
	WHERE updated_at BETWEEN DATE(p_the_day_before) AND DATE(p_the_day_before) + INTERVAL 1 DAY - INTERVAL 1 SECOND 
	AND entry_status_id = 3
	AND (entry_type_id = 7 OR entry_media_type_id IN (1,2,5))
	AND display_in_search <> -1
	GROUP BY partner_id
	ON DUPLICATE KEY UPDATE deleted_entries=VALUES(deleted_entries);

	INSERT INTO kalturadw.dwh_daily_partner_totals(partner_id, date_id, total_users)
	SELECT partner_id, p_the_day_before, COUNT(kuser_id)
	FROM kalturadw.dwh_dim_kusers
	WHERE created_at < DATE(p_init_date_id)
	AND ((kuser_status_id <> 2) OR (kuser_status_id = 2 AND updated_at >= DATE(p_init_date_id)))
	GROUP BY partner_id
	ON DUPLICATE KEY UPDATE total_users=VALUES(total_users);

	INSERT INTO kalturadw.dwh_daily_partner_totals(partner_id, date_id, added_users)
	SELECT partner_id, p_the_day_before, COUNT(kuser_id)
	FROM kalturadw.dwh_dim_kusers
	WHERE created_at BETWEEN DATE(p_the_day_before) AND DATE(p_the_day_before) + INTERVAL 1 DAY - INTERVAL 1 SECOND 
	AND kuser_status_id <> 2
	GROUP BY partner_id
	ON DUPLICATE KEY UPDATE added_users=VALUES(added_users);

	INSERT INTO kalturadw.dwh_daily_partner_totals(partner_id, date_id, deleted_users)
	SELECT partner_id, p_the_day_before, COUNT(kuser_id)
	FROM kalturadw.dwh_dim_kusers
	WHERE updated_at BETWEEN DATE(p_the_day_before) AND DATE(p_the_day_before) + INTERVAL 1 DAY - INTERVAL 1 SECOND 
	AND kuser_status_id = 2
	GROUP BY partner_id
	ON DUPLICATE KEY UPDATE deleted_users=VALUES(deleted_users);

	
END$$

DELIMITER ;