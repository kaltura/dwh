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

DROP TABLE IF EXISTS `dwh_daily_ingestion`;


CREATE TABLE `dwh_daily_ingestion` (
  `date_id` int(11) NOT NULL,
  `normal_wait_time_count` int(11) NOT NULL,
  `medium_wait_time_count` int(11) NOT NULL,
  `long_wait_time_count` int(11) NOT NULL,
  `extremely_long_wait_time_count` int(11) NOT NULL,
  `stuck_wait_time_count` int(11) NOT NULL,
  `success_entries_count` int(11) NOT NULL,
  `failed_entries_count` int(11) NOT NULL,
  `success_convert_job_count` int(11) NOT NULL,
  `failed_convert_job_count` int(11) NOT NULL,
  `all_conversion_job_entries_count` int(11) NOT NULL,
  `failed_conversion_job_entries_count` int(11) NOT NULL,
  `total_wait_time_sec` bigint(22) DEFAULT '0',
  `total_ff_wait_time_sec` bigint(22) DEFAULT NULL,
  `convert_jobs_count` int(11) NOT NULL,
  `median_ff_wait_time_sec` bigint(22) DEFAULT '0',
  PRIMARY KEY (`date_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8
/*!50100 PARTITION BY RANGE (date_id)
(PARTITION p_201301 VALUES LESS THAN (20130201) ENGINE = InnoDB) */

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;