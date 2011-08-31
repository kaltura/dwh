/*Find aggregations in aggr_managment that cover the time frame of the day before yesterday which didn't run yet*/
SELECT aggr_name, 'Aggregate did not run' stat, DATE(NOW())-INTERVAL 2 DAY DATE
-- DATE(NOW())-INTERVAL IF(aggr_name='partner_usage',3,2) DAY
FROM kalturadw.aggr_managment
WHERE aggr_day_int = DATE(NOW())- INTERVAL 2 DAY
-- INTERVAL IF(aggr_name='partner_usage',3,2) DAY)*1
AND is_calculated = 0;

