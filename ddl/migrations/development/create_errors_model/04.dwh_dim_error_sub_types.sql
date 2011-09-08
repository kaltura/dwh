USE kalturadw;

DROP TABLE IF EXISTS dwh_dim_error_sub_types;

CREATE TABLE dwh_dim_error_sub_types (
	error_type_id INT(11) NOT NULL,
	error_sub_type_id INT(11) NOT NULL AUTO_INCREMENT,
	error_sub_type_name VARCHAR(255) NOT NULL,
	PRIMARY KEY (`error_sub_type_id`,`error_type_id`),
	UNIQUE KEY (`error_sub_type_name`)
	) ENGINE=INNODB DEFAULT CHARSET=latin1;
