USE kalturadw;

DROP TABLE IF EXISTS `dwh_billing`;

CREATE TABLE `dwh_billing` (
  `partner_id` INT(11) NOT NULL DEFAULT '0',
  `partner_parent_id` INT(11),
  `month_id` INT(11) NOT NULL DEFAULT '0',
  `storage_gb` DECIMAL (19,4) NOT NULL,
  `bandwidth_gb` DECIMAL (19,4) NOT NULL,
  `livestreaming_gb` DECIMAL (19,4) NOT NULL,
  `plays` INT(11) DEFAULT '0',
  `entries` INT(11) DEFAULT '0',
  PRIMARY KEY (`partner_id`,`month_id`)
) ENGINE=MYISAM DEFAULT CHARSET=utf8;

