DELIMITER $$

USE `kalturadw`$$

DROP PROCEDURE IF EXISTS `calc_app_devices_offline`$$

CREATE DEFINER=`etl`@`localhost` PROCEDURE `calc_app_devices_offline`(p_date_id INT(11))
BEGIN
                                
                BEGIN
						DECLARE v_hour_id INT;
						SET v_hour_id = 0;
						WHILE v_hour_id  <= 23 DO
							CALL call_aggr_day(DATE(p_date_id), v_hour_id, 'app_devices');
						
						SET  v_hour_id = v_hour_id + 1;
						END WHILE;
                END;
				
END$$

DELIMITER ;