USE `kalturadw`;

CREATE TABLE kalturadw.`dwh_hourly_events_live_entry` (
  `partner_id` INT DEFAULT NULL,
  `date_id` INT DEFAULT NULL,
  `hour_id` INT DEFAULT NULL,
  `entry_id` VARCHAR(20) DEFAULT NULL,
  `count_plays` INT DEFAULT NULL,
  `count_loads` INT DEFAULT NULL,
  PRIMARY KEY `partner_id` (`partner_id`,`date_id`,`hour_id`,`entry_id`),
  KEY (`date_id`,`hour_id`),
  KEY `entry_id` (`entry_id`)
) ENGINE=INNODB DEFAULT CHARSET=utf8
PARTITION BY RANGE (date_id)
(PARTITION p_201403 VALUES LESS THAN (20140401) ENGINE = INNODB);
 
