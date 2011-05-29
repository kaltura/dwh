SELECT 'too many invalid event lines' stat, COUNT(*) amount, (DATE(NOW())-INTERVAL 1 DAY)*1 DATE
FROM kalturadw_ds.invalid_event_lines
WHERE date_id = (DATE(NOW())-INTERVAL 1 DAY)*1
HAVING COUNT(*) > 100000
UNION ALL 
SELECT 'too many invalid fms lines' stat, COUNT(*) amount, (DATE(NOW())-INTERVAL 1 DAY)*1 DATE
FROM kalturadw_ds.invalid_fms_event_lines
WHERE date_id = (DATE(NOW())-INTERVAL 1 DAY)*1
HAVING COUNT(*) > 100000;