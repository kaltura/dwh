USE `kalturadw`;

DROP TABLE IF EXISTS `dwh_fact_plays`;

CREATE TABLE `dwh_fact_active_users` (
  `partner_id` INT(11) NOT NULL,
  `active_user_date_id` INT(11) NOT NULL,
  `user_id` INT(11) NOT NULL,
  `app_type` VARCHAR(50) NOT NULL,
  `domain` VARCHAR(50) NOT NULL,
  PRIMARY KEY (`partner_id`,`active_user_date_id`,`user_id`,`app_type`,`domain`)
) ENGINE=INNODB DEFAULT CHARSET=latin1
/*!50100 PARTITION BY RANGE (active_user_date_id)
(PARTITION p_20170515 VALUES LESS THAN (20170516) ENGINE = InnoDB) */
