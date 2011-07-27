ALTER TABLE kalturadw_ds.files 
	ADD compression_suffix VARCHAR(10) NOT NULL DEFAULT '', 
	DROP KEY file_name_process_id, 
	ADD UNIQUE KEY file_name_process_id_compression_suffix (file_name, process_id, compression_suffix);

UPDATE kalturadw_ds.files SET compression_suffix = 'gz';
