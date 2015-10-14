update kalturadw_ds.staging_areas set post_transfer_aggregations = '(\'country\',\'domain\',\'entry\',\'partner\',\'uid\',\'widget\',\'domain_referrer\',\'devices\',\'users\',\'context\',\'app_devices\',\'live_entry\')' where id = 1; 

INSERT  INTO kalturadw_ds.aggr_name_resolver(aggr_name,aggr_table,aggr_id_field,dim_id_field,aggr_type,join_table,join_id_field) 
VALUES ('live_entry','dwh_hourly_events_live_entry','','entry_id','events','','');