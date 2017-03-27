INSERT INTO kalturadw_ds.processes (id, process_name, max_files_per_cycle) VALUE (13, 'bandwidth_usage_akamai_hls', 20);
INSERT INTO kalturadw_ds.processes (id, process_name, max_files_per_cycle) VALUE (14, 'cloudfront_bandwidth_usage', 50);
INSERT INTO kalturadw_ds.processes (id, process_name, max_files_per_cycle) VALUE (15, 'cloudfront_bandwidth_usage_live', 50);

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
        (15,      13,
         'ds_bandwidth_usage',
         2,
         NULL,
         'cycle_id',
         NULL,
        '(\'bandwidth_usage\')',
        'activity_date_id',
        'activity_hour_id');

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
        (16,      14,
         'ds_bandwidth_usage',
         2,
         NULL,
         'cycle_id',
         NULL,
        '(\'bandwidth_usage\')',
        'activity_date_id',
        'activity_hour_id');

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
        (17,      15,
         'ds_bandwidth_usage',
         2,
         NULL,
         'cycle_id',
         NULL,
        '(\'bandwidth_usage\')',
        'activity_date_id',
        'activity_hour_id');

INSERT INTO kalturadw.dwh_dim_bandwidth_source (bandwidth_source_id,bandwidth_source_name, is_live) values (11, 'akamai_hls',0), (13, 'cloudfront_http', 0), (14, 'cloudfront_http_live', 1);


CREATE TABLE kalturadw_ds.done_cycles (
  cycle_id INT(11) NOT NULL AUTO_INCREMENT,
  status VARCHAR(60) DEFAULT NULL,
  prev_status VARCHAR(60) DEFAULT NULL,
  insert_time DATETIME DEFAULT NULL,
  run_time DATETIME DEFAULT NULL,
  transfer_time DATETIME DEFAULT NULL,
  process_id INT(11) DEFAULT '1',
  assigned_server_id INT(11),
  PRIMARY KEY (cycle_id)
) ENGINE=MYISAM DEFAULT CHARSET=latin1;
