/*Find aggregations in aggr_managment that cover the time frame of the day before yesterday which didn't run yet*/
SELECT ans.aggr_name, 'Aggregate did not run' stat, DATE(NOW())-INTERVAL IF(ans.aggr_type = ('bandwidth'),3,2) DAY DATE
FROM kalturadw.aggr_managment am, kalturadw_ds.aggr_name_resolver ans
WHERE am.aggr_name = ans.aggr_name AND aggr_day_int = (DATE(NOW())-INTERVAL IF(ans.aggr_type = ('bandwidth'),3,2) DAY)*1
AND is_calculated = 0;

