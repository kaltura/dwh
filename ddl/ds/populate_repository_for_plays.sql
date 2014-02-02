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


