update kalturadw_bisources.bisources_entry_media_source
set entry_media_source_name = CASE entry_media_source_id WHEN -1 THEN 'unknown' WHEN 1 THEN 'UPLOAD' ELSE entry_media_source_name END
