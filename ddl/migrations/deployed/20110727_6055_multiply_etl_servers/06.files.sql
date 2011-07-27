insert ignore into kalturadw_ds.files (file_name, process_id, compression_suffix, file_size_kb, file_status, insert_time)
select distinct substr(file_name,7, length(file_name) -9) file_name, process_id, compression_suffix, sum(file_size_kb) file_size_kb , 'SPOOF_FILE' file_status, now() insert_time from kalturadw_ds.files  
where SUBSTR(file_name,1, 6) = 'split_'
group by SUBSTR(file_name,7, LENGTH(file_name) -9), process_id, compression_suffix;
