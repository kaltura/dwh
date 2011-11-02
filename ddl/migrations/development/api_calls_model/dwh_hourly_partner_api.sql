USE kalturadw;

DROP TABLE IF EXISTS `dwh_hourly_partner_api`;
CREATE TABLE `dwh_hourly_partner_api` (
  `partner_id` int(11) NOT NULL,
  `date_id` int(11) NOT NULL,
  `hour_id` int(11) NOT NULL,
  `api_action_id` int(11) NOT NULL,
  `count_calls` int(11) default null,
  `count_is_admin` int(11) default null,
  `count_is_in_multi_part` int(11) default null,
  `count_success` int(11) default null,
  `sum_duration` int(11) default null,
  PRIMARY KEY (`partner_id`,`date_id`,`hour_id`,`api_action_id`),
  KEY `date_id` (`date_id`,`hour_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8
/*!50100 PARTITION BY RANGE (date_id)
(PARTITION p_20111110 VALUES LESS THAN (20111111) ENGINE = InnoDB) */;

