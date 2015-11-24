USE `kalturadw`;

DROP TABLE IF EXISTS `dwh_daily_partner_totals`;


CREATE TABLE `dwh_daily_partner_totals` (
  `partner_id` INT NOT NULL,
  `date_id` INT NOT NULL,
  `added_entries` INT NOT NULL,
  `deleted_entries` INT NOT NULL,
  `total_entries` INT NOT NULL,
  `added_users` INT NOT NULL,
  `deleted_users` INT NOT NULL,
  `total_users` INT NOT NULL,
  PRIMARY KEY (`partner_id`,`date_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8
PARTITION BY RANGE (date_id)
(PARTITION p_201510 VALUES LESS THAN (20151101) ENGINE = InnoDB);

CALL kalturadw.add_monthly_partition_for_table('dwh_daily_partner_totals');
