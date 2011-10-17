UPDATE kalturadw_ds.staging_areas
SET post_transfer_aggregations = REPLACE(post_transfer_aggregations,'devices','devices\', \'devices_bandwidth_usage')
WHERE id in (1,3);

UPDATE kalturadw_ds.staging_areas
SET post_transfer_aggregations = REPLACE(post_transfer_aggregations,'devices','devices_bandwidth_usage')
WHERE id in (2,4,5,6,7,8);
