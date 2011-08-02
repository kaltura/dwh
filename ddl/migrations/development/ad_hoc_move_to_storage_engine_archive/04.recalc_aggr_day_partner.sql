DELIMITER $$

USE `kalturadw`$$

DROP PROCEDURE IF EXISTS `recalc_aggr_day_partner`$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `recalc_aggr_day_partner`(date_val DATE)
BEGIN
	IF (date_val >= DATE(20110201)) THEN -- do not re-aggregate anything older than 6 months
	UPDATE aggr_managment SET is_calculated = 0 
	WHERE aggr_name = 'partner_usage' AND aggr_day_int = DATE(date_val)*1;
	
	DELETE FROM kalturadw.dwh_hourly_partner_usage
	WHERE date_id = DATE(date_val)*1;
	
	CALL calc_aggr_day_partner(date_val);
	END IF; -- end skip old aggregations
    
 END$$

DELIMITER ;
