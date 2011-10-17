UPDATE kalturadw_ds.staging_areas
SET post_transfer_aggregations = REPLACE(post_transfer_aggregations,'devices','devices_bandwidth_usage')
