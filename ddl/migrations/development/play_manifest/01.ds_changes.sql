INSERT INTO kalturadw_ds.fact_tables
		(fact_table_id,
		fact_table_name)
VALUES
	(7,'kalturadw.dwh_fact_plays');
	

INSERT INTO kalturadw_ds.staging_areas
        (id,
        process_id,
        source_table,
        target_table_id,
        on_duplicate_clause,
        staging_partition_field,
        post_transfer_sp,
		post_transfer_aggregations,
		aggr_date_field,
		hour_id_field)
VALUES
        (13,1,
         'ds_plays',
         7,
         NULL,
         'cycle_id',
         NULL,
	'(\'plays_partner\',\'plays_entry\',\'plays_country\',\'plays_devices\')',
	'play_date_id',
	'play_hour_id');
	
INSERT INTO kalturadw_ds.retention_policy VALUES 
('dwh_fact_plays', 30, 365, DATE('2013-11-01'));

INSERT INTO kalturadw_ds.aggr_name_resolver
		(aggr_name,
		aggr_table,
		aggr_id_field,
		dim_id_field,
		aggr_type,
		join_table,
		join_id_field)
VALUES
	('plays_partner','dwh_hourly_plays_partner','','','plays',NULL,NULL),
	('plays_entry','dwh_hourly_plays_entry','entry_id','','plays',NULL,NULL),
    ('plays_country','dwh_hourly_plays_country','country_id, location_id','','plays',NULL,NULL),
	('plays_devices','dwh_hourly_plays_devices','os_id, browser_id','','plays',NULL,NULL);

	
CREATE TABLE kalturadw_ds.aggr_type (
	`aggr_name` varchar(20) NOT NULL,
    `aggr_order` int(6) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

INSERT INTO kalturadw_ds.aggr_type 
	(aggr_name,
	aggr_order)
VALUES
	('events', 1),
	('bandwidth' , 2),
	('plays' , 3);
