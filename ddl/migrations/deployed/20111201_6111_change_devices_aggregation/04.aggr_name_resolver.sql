UPDATE kalturadw_ds.aggr_name_resolver
SET 	aggr_join_stmt = 'USE INDEX (event_hour_id_event_date_id_partner_id) INNER JOIN kalturadw.dwh_dim_entries AS entry ON(ev.entry_id = entry.entry_id)',
	aggr_id_field = 'country_id,location_id,os_id,browser_id,ui_conf_id, entry_media_type_id'
WHERE aggr_name = 'devices';
