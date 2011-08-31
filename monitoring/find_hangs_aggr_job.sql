/* Find aggregations from aggr_managment that have been running for more than an hour*/
SELECT 	
	aggr_name, 
	aggr_day, 
	is_calculated, 
	start_time, 
	end_time
	 
	FROM 
	kalturadw.aggr_managment 
	WHERE  aggr_day < DATE(NOW())
	       AND start_time < NOW() - INTERVAL 1 HOUR
		AND (end_time  < start_time OR end_time IS NULL)
	       AND is_calculated = 0
