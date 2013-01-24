/*
SQLyog Community v8.7 
MySQL - 5.1.37-log : Database - kaltura
*********************************************************************
*/


/*!40101 SET NAMES utf8 */;

/*!40101 SET SQL_MODE=''*/;

/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
USE `kalturadw`;

/*Table structure for table `upload_token` */

DROP TABLE IF EXISTS `dwh_dim_upload_token`;

CREATE TABLE `dwh_dim_upload_token` (
  `dwh_id` INT(11) NOT NULL AUTO_INCREMENT,
  `id` VARCHAR(35) NOT NULL,
  `int_id` VARCHAR(11) NOT NULL,
  `partner_id` INT(11) DEFAULT NULL,
  `kuser_id` INT(11) DEFAULT NULL,
  `status_id` INT(11) DEFAULT NULL,
  `file_name` VARCHAR(256) DEFAULT NULL,
  `file_size` BIGINT(20) DEFAULT NULL,
  `uploaded_file_size` BIGINT(20) DEFAULT NULL,
  `uploaded_temp_path` VARCHAR(256) DEFAULT NULL,
  `user_ip` VARCHAR(39) DEFAULT NULL,
  `created_at` DATETIME DEFAULT NULL,
  `updated_at` DATETIME DEFAULT NULL,
  `dc` VARCHAR(2) DEFAULT NULL,
  `object_id` VARCHAR(31) DEFAULT NULL,
  `object_type` VARCHAR(127) DEFAULT NULL,
  `dwh_creation_date` TIMESTAMP NOT NULL DEFAULT '0000-00-00 00:00:00',
  `dwh_update_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `ri_ind` TINYINT(4) NOT NULL DEFAULT '0',
  PRIMARY KEY (`dwh_id`),
  UNIQUE KEY(`id`),
  KEY `dwh_update_date` (`dwh_update_date`)
) ENGINE=MYISAM AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
