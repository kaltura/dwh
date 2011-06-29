SELECT CONCAT(lock_name, ' seized for ', TIMEDIFF(NOW(), lock_time)) stat FROM kalturadw_ds.LOCKS 
WHERE TIME_TO_SEC(TIMEDIFF(NOW(), lock_time)) > CASE lock_name WHEN 'daily_lock' THEN 36000 WHEN 'hourly_lock' THEN 14400 END
and lock_state = 1
