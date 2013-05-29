DELIMITER $$

USE `kalturadw`$$

DROP PROCEDURE IF EXISTS `update_location_details`$$

CREATE PROCEDURE `update_location_details`()

BEGIN

				DECLARE v_location_id INT;
                DECLARE v_location_name VARCHAR(60);
                DECLARE v_country_name VARCHAR(60);
                DECLARE done INT DEFAULT 0;
				
                DECLARE location_details CURSOR FOR 
                SELECT location_id, location_name, country_name FROM kalturadw.dwh_dim_locations;
                DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
                                
                OPEN location_details;
								
                read_loop: LOOP
								FETCH location_details INTO v_location_id, v_location_name, v_country_name;
                                IF done THEN
												LEAVE read_loop;
                                END IF;
												
								UPDATE kalturadw.dwh_dim_ip_ranges SET country_id = v_location_id, location_id = v_location_id, country_name = v_country_name WHERE country_code = v_location_name;
                END LOOP;
								
                CLOSE location_details;
END$$

DELIMITER ;

call kalturadw.update_location_details();
DROP PROCEDURE IF EXISTS update_location_details;
                
        