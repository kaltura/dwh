USE `kalturadw`;

DROP TABLE IF EXISTS `dwh_fact_plays_archive`;

CREATE TABLE `dwh_fact_plays_archive` (
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
  `browser_id` int(11)
) ENGINE=ARCHIVE DEFAULT CHARSET=utf8
/*!50100 PARTITION BY RANGE (play_date_id)
(PARTITION p_0 VALUES LESS THAN (1) ENGINE = ARCHIVE)*/

