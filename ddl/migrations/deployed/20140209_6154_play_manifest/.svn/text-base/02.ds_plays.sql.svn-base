USE `kalturadw_ds`;

CREATE TABLE `kalturadw_ds`.`ds_plays`(  
  `line_number` INT(10),
  `cycle_id` INT(11) NOT NULL,
  `file_id` INT(11) NOT NULL,
  `partner_id` INT(11) NOT NULL,
  `entry_id` VARCHAR(20),
  `play_date_id` INT(11),
  `play_hour_id` INT(11),
  `client_tag_id` SMALLINT(6),
  `user_ip` VARCHAR(15),
  `user_ip_number` INT(10) UNSIGNED,
  `country_id` INT(11),
  `location_id` INT(11),
  `os_id` INT(11),
  `browser_id` INT(11)
) ENGINE=INNODB DEFAULT CHARSET=utf8
PARTITION BY LIST (cycle_id)
(PARTITION p_0 VALUES IN (0) ENGINE = INNODB);