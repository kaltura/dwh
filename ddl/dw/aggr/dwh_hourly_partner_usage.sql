USE `kalturadw`;

DROP TABLE IF EXISTS kalturadw.`dwh_hourly_partner_usage`;

CREATE TABLE kalturadw.`dwh_hourly_partner_usage` (
  `partner_id` INT NOT NULL,
  `date_id` INT NOT NULL,
  `hour_id` INT NOT NULL,
  `bandwidth_source_id` INT NOT NULL,
  `count_bandwidth_kb`  DECIMAL(19,4) DEFAULT 0,
  `count_storage_mb`  DECIMAL(19,4) DEFAULT 0,
  `aggr_storage_mb` DECIMAL(19,4),
  `billable_storage_mb` DECIMAL(19,4),
  PRIMARY KEY (`partner_id`,`date_id`, `hour_id`, `bandwidth_source_id`),
  KEY (`date_id`, `hour_id`)
) ENGINE=INNODB DEFAULT CHARSET=utf8
PARTITION BY RANGE (date_id)
(PARTITION p_201001 VALUES LESS THAN (20100201) ENGINE = INNODB,
 PARTITION p_201002 VALUES LESS THAN (20100301) ENGINE = INNODB,
 PARTITION p_201003 VALUES LESS THAN (20100401) ENGINE = INNODB,
 PARTITION p_201004 VALUES LESS THAN (20100501) ENGINE = INNODB,
 PARTITION p_201005 VALUES LESS THAN (20100601) ENGINE = INNODB,
 PARTITION p_201006 VALUES LESS THAN (20100701) ENGINE = INNODB,
 PARTITION p_201007 VALUES LESS THAN (20100801) ENGINE = INNODB,
 PARTITION p_201008 VALUES LESS THAN (20100901) ENGINE = INNODB,
 PARTITION p_201009 VALUES LESS THAN (20101001) ENGINE = INNODB,
 PARTITION p_201010 VALUES LESS THAN (20101101) ENGINE = INNODB,
 PARTITION p_201011 VALUES LESS THAN (20101201) ENGINE = INNODB);
 
 CALL kalturadw.add_monthly_partition_for_table('dwh_hourly_partner_usage');
