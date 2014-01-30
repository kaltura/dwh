DROP TABLE IF EXISTS kalturadw.dwh_dim_client_tag;

CREATE TABLE kalturadw.dwh_dim_client_tag (
  client_tag_id int(11) NOT NULL AUTO_INCREMENT,
  name varchar(100) DEFAULT NULL,
  KEY client_tag_id (client_tag_id),
  KEY name (name)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;