USE `kalturadw`;

DROP TABLE IF EXISTS `dwh_fact_plays`;

CREATE TABLE `dwh_fact_plays` (
  `file_id` INT(11) NOT NULL,
  `line_number` INT (11),
  `partner_id` INT(11) NOT NULL DEFAULT '-1',
  `entry_id` varchar(20) DEFAULT NULL,
  `play_date_id` INT(11) DEFAULT '-1',
  `play_hour_id` TINYINT(4) DEFAULT '-1',
  `client_tag_id` SMALLINT(6),
  `user_ip` VARCHAR(15) DEFAULT NULL,
  `user_ip_number` INT(10) UNSIGNED DEFAULT NULL,
  `country_id` INT(11) DEFAULT NULL,
  `location_id` INT(11) DEFAULT NULL,
  `os_id` int(11),
  `browser_id` int(11),
  UNIQUE KEY (`file_id`,`line_number`,`play_date_id`),
  KEY Entry_id (entry_id),
  KEY `play_hour_id_play_date_id_partner_id` (play_hour_id, play_date_id, partner_id)
) ENGINE=INNODB DEFAULT CHARSET=utf8
/*!50100 PARTITION BY RANGE (play_date_id)
(PARTITION p_20170430 VALUES LESS THAN (20170501) ENGINE = INNODB) */;

