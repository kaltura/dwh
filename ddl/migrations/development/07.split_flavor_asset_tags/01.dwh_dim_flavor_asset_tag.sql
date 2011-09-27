/*
SQLyog Community v8.7 
MySQL - 5.1.37-log 
*********************************************************************
*/

use kalturadw;

drop table if exists `dwh_dim_flavor_asset_tag`;

create table `dwh_dim_flavor_asset_tag` (
	`tag_id` int(11) NOT NULL AUTO_INCREMENT,
    `tag_name` varchar(50) NOT NULL,
	`dwh_creation_date` TIMESTAMP  NOT NULL DEFAULT '0000-00-00 00:00:00',
	`dwh_update_date` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	`ri_ind` TINYINT(4)  NOT NULL DEFAULT 0 ,
	PRIMARY (`tag_id`), UNIQUE(tag_name)
) ENGINE=MYISAM; 
