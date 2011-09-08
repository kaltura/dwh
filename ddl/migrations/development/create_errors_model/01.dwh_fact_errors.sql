USE kalturadw;

DROP TABLE IF EXISTS dwh_fact_errors;

CREATE TABLE dwh_fact_errors (
	partner_id INT(11) NOT NULL,
	error_time datetime NOT NULL,
	error_date_id int NOT NULL,
	error_hour_id int NOT NULL,
	error_object_id VARCHAR(50) NOT NULL,
	error_object_type_id INT(11) NOT NULL,
	error_type_id INT(11) NOT NULL,
	error_sub_type_id INT(11) NOT NULL,
	description mediumtext DEFAULT NULL,
	PRIMARY KEY (`error_date_id`,`object_id`,`object_type_id`,`error_time`)
	) ENGINE=INNODB DEFAULT CHARSET=latin1
	/*!50100 PARTITION BY RANGE (error_date_id)
	(PARTITION p_20101231 VALUES LESS THAN (20110101) ENGINE = INNODB)*/;

CALL add_daily_partition_for_table('dwh_fact_errors');
