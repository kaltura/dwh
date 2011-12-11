USE `kalturadw_ds`;

ALTER TABLE aggr_name_resolver DROP COLUMN aggr_join_stmt;

UPDATE aggr_name_resolver
SET aggr_id_field = 'country_id,location_id,os_id,browser_id,ui_conf_id, e.entry_media_type_id'
WHERE aggr_name = 'devices';