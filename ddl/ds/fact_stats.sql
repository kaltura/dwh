CREATE TABLE kalturadw_ds.fact_stats
	(fact_table_id int not null,
	date_id int not null,
	hour_id int not null,
	total_records int not null,
	uncalculated_records int not null default 0,
	unique key (fact_table_id, date_id, hour_id));