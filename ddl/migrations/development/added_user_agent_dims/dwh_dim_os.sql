USE kalturadw;

CREATE TABLE `dwh_dim_os` (
  `id` int(11) NOT NULL,
  `device` varchar(50) DEFAULT NULL,
  `is_mobile` boolean DEFAULT NULL,
  `manufacturer` varchar(50) DEFAULT NULL,
  `group` varchar(50) DEFAULT NULL,
  `os` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `os` (`os`,`device`,`is_mobile`,`manufacturer`,`group`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
