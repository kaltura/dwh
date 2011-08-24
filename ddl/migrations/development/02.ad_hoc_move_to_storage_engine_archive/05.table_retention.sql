USE kalturadw_ds;

DROP TABLE IF EXISTS retention_policy;
CREATE TABLE retention_policy (
	table_name varchar(256) not null,
	archive_start_days_back int default 180,
	archive_delete_days_back int default 365,
	archive_last_partition date)
ENGINE=MYISAM DEFAULT CHARSET=utf8;

INSERT INTO retention_policy VALUES 
('dwh_fact_events', 180, 365, date('01-01-2011')),
('dwh_fact_bandwidth_usage', 180, 365, date('01-01-2011')),
('dwh_fact_fms_session_events', 180, 365, date('01-01-2011')),
('dwh_fact_fms_sessions', 180, 365, date('01-01-2011'));
