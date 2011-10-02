USE kalturadw;

INSERT IGNORE INTO kalturadw.`dwh_dim_entry_type_display` (entry_type_id , entry_media_type_id) SELECT DISTINCT entry_type_id, entry_media_type_id FROM dwh_dim_entries;
