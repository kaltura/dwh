USE kalturadw;

INSERT INTO kalturadw.`dwh_dim_entry_type_display` 
(
    entry_type_id ,
    entry_media_type_id ,
    display  
)
SELECT DISTINCT t.entry_type_id, m.entry_media_type_id, CONCAT(t.entry_type_name,'-',m.entry_media_type_name)
FROM dwh_dim_entries e, dwh_dim_entry_type t, dwh_dim_entry_media_type m
WHERE e.entry_type_id = t.entry_type_id AND e.entry_media_type_id = m.entry_media_type_id;