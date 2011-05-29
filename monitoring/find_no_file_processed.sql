SELECT 'No EVENTS file processed yesterday!' stat
FROM (
SELECT COUNT(*) amount
FROM kalturadw_ds.files f, kalturadw_ds.cycles c WHERE c.process_id = 1
AND f.cycle_id = c.cycle_id
AND c.STATUS='DONE' AND f.insert_time > DATE(NOW())-INTERVAL 1 DAY) a
WHERE amount = 0
UNION
SELECT 'No FMS file processed yesterday!' stat
FROM (
SELECT COUNT(*) amount
FROM kalturadw_ds.files f, kalturadw_ds.cycles c WHERE c.process_id = 2
AND f.cycle_id = c.cycle_id
AND c.STATUS='DONE' AND f.insert_time > DATE(NOW())-INTERVAL 1 DAY) a
WHERE amount = 0
UNION
SELECT 'No Akamai BW file processed yesterday!' stat
FROM (
SELECT COUNT(*) amount
FROM kalturadw_ds.files f, kalturadw_ds.cycles c WHERE c.process_id = 4
AND f.cycle_id = c.cycle_id
AND c.STATUS='DONE' AND f.insert_time > DATE(NOW())-INTERVAL 1 DAY) a
WHERE amount = 0
UNION
SELECT 'No LimeLight BW file processed yesterday!' stat
FROM (
SELECT COUNT(*) amount
FROM kalturadw_ds.files f, kalturadw_ds.cycles c WHERE c.process_id = 5
AND f.cycle_id = c.cycle_id
AND c.STATUS='DONE' AND f.insert_time > DATE(NOW())-INTERVAL 1 DAY) a
WHERE amount = 0
UNION
SELECT 'No Level3 BW file processed yesterday!' stat
FROM (
SELECT COUNT(*) amount
FROM kalturadw_ds.files f, kalturadw_ds.cycles c WHERE c.process_id = 4
AND f.cycle_id = c.cycle_id
AND c.STATUS='DONE' AND f.insert_time > DATE(NOW())-INTERVAL 1 DAY) a
WHERE amount = 0