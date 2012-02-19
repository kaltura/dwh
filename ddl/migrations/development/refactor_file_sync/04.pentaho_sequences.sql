UPDATE kalturadw_ds.pentaho_sequences a, kalturadw_ds.pentaho_sequences b
set b.job_number = b.job_number - 1,
	a.job_number = NULL
where b.job_number > a.job_number
and a.job_name = 'dimensions/update_file_sync.ktr';

DELETE FROM kalturadw_ds.pentaho_sequences
WHERE job_name = 'dimensions/update_file_sync.ktr';
