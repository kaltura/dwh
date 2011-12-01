
/*!40101 SET NAMES utf8 */;

/*!40101 SET SQL_MODE=''*/;

/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
USE `kalturadw_ds`;

/*Table structure for table `aggr_name_resolver` */

CREATE TABLE `aggr_name_resolver` (
  `aggr_name` varchar(100) NOT NULL DEFAULT '',
  `aggr_table` varchar(100) DEFAULT NULL,
  `aggr_id_field` varchar(100) DEFAULT NULL,
  `aggr_join_stmt` varchar(200) DEFAULT '',
  `aggr_type` VARCHAR(60) NOT NULL,
  PRIMARY KEY (`aggr_name`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

/*Data for the table `aggr_name_resolver` */

insert  into `aggr_name_resolver`(`aggr_name`,`aggr_table`,`aggr_id_field`,`aggr_join_stmt`,`aggr_type`) 
values  ('entry','dwh_hourly_events_entry','entry_id','','events'),
        ('domain','dwh_hourly_events_domain','domain_id','','events'),
        ('country','dwh_hourly_events_country','country_id,location_id','','events'),
        ('partner','dwh_hourly_partner','','','events'),
        ('widget','dwh_hourly_events_widget','widget_id','','events'),
        ('uid','dwh_hourly_events_uid','kuser_id','USE INDEX (event_hour_id_event_date_id_partner_id) inner join kalturadw.dwh_dim_entries as entry on(ev.entry_id = entry.entry_id)','events'),
	('domain_referrer', 'dwh_hourly_events_domain_referrer', 'domain_id, referrer_id', '','events'),
	('devices', 'dwh_hourly_events_devices', 'country_id,location_id,os_id,browser_id,ui_conf_id, entry_media_type_id','USE INDEX (event_hour_id_event_date_id_partner_id) INNER JOIN kalturadw.dwh_dim_entries AS entry ON(ev.entry_id = entry.entry_id)','events'),
	('bandwidth_usage', 'dwh_hourly_partner_usage', 'bandwidth_source_id', '', 'bandwidth'),
	('devices_bandwidth_usage', 'dwh_hourly_events_devices', 'country_id, location_id', '', 'bandwidth'),
	('api_calls','dwh_hourly_api_calls','action_id', '', 'api'),
	('errors','dwh_hourly_errors','error_code_id','','errors');

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
