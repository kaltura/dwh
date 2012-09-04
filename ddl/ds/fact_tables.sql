CREATE TABLE kalturadw_ds.fact_tables
	(fact_table_id INT NOT NULL,
	fact_table_name VARCHAR(50),
	UNIQUE KEY (fact_table_id));
INSERT INTO kalturadw_ds.fact_tables VALUES (1,'kalturadw.dwh_fact_events'), 
				(2,'kalturadw.dwh_fact_bandwidth_usage'),
				(3,'kalturadw.dwh_fact_fms_session_events'),
				(4,'kalturadw.dwh_fact_api_calls'),
				(5,'kalturadw.dwh_fact_incomplete_api_calls'),
				(6,'kalturadw.dwh_fact_errors');