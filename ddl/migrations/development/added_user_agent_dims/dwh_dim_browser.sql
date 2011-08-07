USE kalturadw;

CREATE TABLE `dwh_dim_browser` (
  `id` int(11) NOT NULL,
  `browser` varchar(50) DEFAULT NULL,
  `group` varchar(50) DEFAULT NULL,
  `manufacturer` varchar(50) DEFAULT NULL,
  `render_engine` varchar(50) DEFAULT NULL,
  `type` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `browser` (`browser`,`group`,`manufacturer`,`render_engine`,`type`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
