USE kalturadw_ds;

DROP TABLE IF EXISTS ds_active_users;

CREATE TABLE ds_active_users (
  cycle_id int(11) NOT NULL,
  partner_id int(11) NOT NULL,
  active_user_date_id` int(11) NOT NULL,
  user_id int(11) NOT NULL,
  app_type varchar(100) NOT NULL,
  domain varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1
/*!50100 PARTITION BY LIST (cycle_id)
(PARTITION p_0 VALUES IN (0) ENGINE = InnoDB) */;
