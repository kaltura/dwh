USE `kalturadw`;

DROP TABLE IF EXISTS kalturadw.`dwh_hourly_partner_usage`;

CREATE TABLE kalturadw.`dwh_hourly_partner_usage` (
  `partner_id` INT NOT NULL,
  `date_id` INT NOT NULL,
  `hour_id` INT NOT NULL,
  `bandwidth_source_id` INT NOT NULL,
  `count_bandwidth_kb`  DECIMAL(19,4) DEFAULT 0,
  `added_storage_mb`  DECIMAL(19,4) DEFAULT 0,
  `deleted_storage_mb`  DECIMAL(19,4) DEFAULT 0,
  `aggr_storage_mb` DECIMAL(19,4),
  `billable_storage_mb` DECIMAL(19,4),
  PRIMARY KEY (`partner_id`,`date_id`, `hour_id`, `bandwidth_source_id`),
  KEY (`date_id`, `hour_id`)
) ENGINE=INNODB DEFAULT CHARSET=utf8
PARTITION BY RANGE (date_id)
(PARTITION p_201207 VALUES LESS THAN (20120801) ENGINE = INNODB);
 
 CALL kalturadw.add_monthly_partition_for_table('dwh_hourly_partner_usage');
