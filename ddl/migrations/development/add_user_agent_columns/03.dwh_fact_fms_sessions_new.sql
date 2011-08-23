USE kalturadw;

DROP TABLE IF EXISTS dwh_fact_fms_sessions_new;

CREATE TABLE `dwh_fact_fms_sessions_new` (
  `session_id` varchar(20) NOT NULL,
  `session_time` datetime NOT NULL,
  `session_date_id` int(11) unsigned DEFAULT NULL,
  `bandwidth_source_id` int(11) NOT NULL,
  `session_client_ip` varchar(15) DEFAULT NULL,
  `session_client_ip_number` int(10) unsigned DEFAULT NULL,
  `session_client_country_id` int(10) unsigned DEFAULT NULL,
  `session_client_location_id` int(10) unsigned DEFAULT NULL,
  `session_os_id` int(11),
  `session_browser_id` int(11),
  `session_partner_id` int(10) unsigned DEFAULT NULL,
  `total_bytes` bigint(20) unsigned DEFAULT NULL,
  UNIQUE KEY `session_id` (`session_id`,`session_date_id`),
  KEY `session_partner_id` (`session_partner_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1
/*!50100 PARTITION BY RANGE (session_date_id)
(PARTITION p_20091231 VALUES LESS THAN (20100101) ENGINE = InnoDB,
 PARTITION p_20100131 VALUES LESS THAN (20100201) ENGINE = InnoDB,
 PARTITION p_20100228 VALUES LESS THAN (20100301) ENGINE = InnoDB,
 PARTITION p_20100331 VALUES LESS THAN (20100401) ENGINE = InnoDB,
 PARTITION p_20100430 VALUES LESS THAN (20100501) ENGINE = InnoDB,
 PARTITION p_20100531 VALUES LESS THAN (20100601) ENGINE = InnoDB,
 PARTITION p_20100630 VALUES LESS THAN (20100701) ENGINE = InnoDB,
 PARTITION p_20100731 VALUES LESS THAN (20100801) ENGINE = InnoDB,
 PARTITION p_20100831 VALUES LESS THAN (20100901) ENGINE = InnoDB,
 PARTITION p_20100930 VALUES LESS THAN (20101001) ENGINE = InnoDB,
 PARTITION p_20101031 VALUES LESS THAN (20101101) ENGINE = InnoDB,
 PARTITION p_20101130 VALUES LESS THAN (20101201) ENGINE = InnoDB,
 PARTITION p_20101231 VALUES LESS THAN (20110101) ENGINE = InnoDB)*/;


CALL kalturadw.add_daily_partition_for_table('dwh_fact_fms_sessions_new');
