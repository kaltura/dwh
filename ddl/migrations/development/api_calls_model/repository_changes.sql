INSERT INTO kalturadw_ds.processes(id, process_name, max_files_per_cycle) VALUES (8, 'api_calls',20);
INSERT INTO kalturadw_ds.staging_areas (id, process_id, source_table, target_table, on_duplicate_clause, staging_partition_field, post_transfer_sp, aggr_date_field, hour_id_field, post_transfer_aggregations)
VALUES  (3, 3, 'ds_api_calls', 'kalturadw.dwh_fact_api_calls', NULL, 'cycle_id', NULL, 'api_call_date_id', 'api_call_hour_id', 'api_calls'),
        (3, 3, 'ds_incomplete_api_calls', 'kalturadw.dwh_fact_incomplete_api_calls', NULL, 'cycle_id', NULL, '', '', '');

UPDATE kalturadw_ds.retention_policy
SET archive_delete_days_back = 2000;

INSERT INTO kalturadw_ds.retention_policy (table_name, archive_start_days_back, archive_delete_days_back, archive_last_partition)
VALUES ('dwh_fact_api_calls', 60, 2000, DATE(20110101)), ('dwh_fact_incomplete_api_calls', NULL, 3);
