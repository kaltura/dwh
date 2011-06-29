SELECT aggr_name, 'Aggregate did not run' stat, (DATE(NOW())-INTERVAL IF(aggr_name='partner_usage',3,2) DAY)*1 DAY
FROM kalturadw.aggr_managment
WHERE aggr_day_int = (DATE(NOW())-INTERVAL IF(aggr_name='partner_usage',3,2) DAY)*1
AND is_calculated = 0;
