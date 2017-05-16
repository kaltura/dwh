INSERT INTO `kalturadw_ds`.`staging_areas`
               (`id`,
               `process_id`,
               `source_table`,
               `target_table_id`,
               `on_duplicate_clause`,
               `staging_partition_field`,
               `post_transfer_sp`,
               `aggr_date_field`,
               `hour_id_field`,
               `post_transfer_aggregations`,
               `ignore_duplicates_on_transfer`
               )
VALUES
               (18,
               16,
               'ds_active_users',
               8,
               NULL,
               'cycle_id',
               NULL,
               'active_user_date_id',
               NULL,
               NULL,
               1
               );

INSERT INTO `kalturadw_ds`.`processes`
               (`id`,
               `process_name`,
               `max_files_per_cycle`
               )
               VALUES
               (16,
               'active_users',
               20
               );
