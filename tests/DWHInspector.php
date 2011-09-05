<?php
require_once 'Configuration.php';
require_once 'MySQLRunner.php';

class DWHInspector
{
	public static function getCycle($status)
	{
		$res = MySQLRunner::execute("SELECT cycle_id FROM kalturadw_ds.cycles WHERE status = '?'",array(0=>$status));
		
		if(1!=count($res))
		{
			print("No cycle found in status - $status\n");
			exit(1);
		}
		
		foreach ($res as $row)
		{
			return $row["cycle_id"];
		}
	}
	
	public static function getFiles($cycleId)
	{
		$res = MySQLRunner::execute("SELECT file_id FROM kalturadw_ds.files WHERE cycle_id = ? AND file_status = 'IN_CYCLE'",array(0=>$cycleId));
		$files = array();
		foreach ($res as $row)
		{
			$files[]=$row["file_id"];
		}
		return $files;
	}	
	
	public static function getFileName($fileId)
	{
		$res = MySQLRunner::execute("SELECT file_name FROM kalturadw_ds.files WHERE file_id = ?",array(0=>$fileId));
		$files = array();
		foreach ($res as $row)
		{
			return $row["file_name"];
		}
	}
	
	public static function countRows($tableName, $fileID, $extra='')
	{
		return self::aggregateRows($tableName, $fileID, "count", "*", $extra);
	}

        public static function sumRows($tableName, $fileID, $aggregatedColumn, $extra='')
        {
                return self::aggregateRows($tableName, $fileID, "sum", $aggregatedColumn, $extra);
        }
	
        public static function countDistinct($table_name,$fileId,$select)
        {
                $res = MySQLRunner::execute("SELECT count(distinct ".$select.") amount FROM ".$table_name." WHERE file_id = ? ",array(0=>$fileId));
                foreach($res as $row)
                {
                        return (int) $row["amount"];
                }
        }


	public static function aggregateRows($table_name, $fileID, $aggregateFunction, $aggregatedColumn, $extra='')
	{
		$res = MySQLRunner::execute("SELECT ".$aggregateFunction."(".$aggregatedColumn.") amount FROM ".$table_name." WHERE file_id = ? ".$extra,array(0=>$fileID));
		foreach ($res as $row)
		{
			return $row["amount"];
		}
	}	
	
	public static function setAggregations($isCalculated)
	{
		MySQLRunner::execute("UPDATE kalturadw.aggr_managment SET is_calculated = ?",array(0=>$isCalculated), false);
	}
	
	public static function getAggregations($dateId, $hourId, $isCalculated = 0)
	{
		$rows = MySQLRunner::execute("SELECT DISTINCT aggr_name FROM kalturadw.aggr_managment WHERE aggr_day_int = ? AND hour_id = ? AND is_calculated = ?",array(0=>$dateId,1=>$hourId, 2=>$isCalculated));
		print_r(array(0=>$dateId,1=>$hourId, 2=>$isCalculated));
		
		$res = array();
		foreach ($rows as $row)
		{
			$res[] = $row["aggr_name"];
		}
		return $res;
	}
	
	public static function getAggrDatesAndHours($cycleId)
	{
		$rows = MySQLRunner::execute("SELECT DISTINCT event_date_id, event_hour_id FROM kalturadw.dwh_fact_events WHERE file_id in (SELECT file_id FROM kalturadw_ds.files WHERE cycle_id = ? AND file_status = 'IN_CYCLE')",array(0=>$cycleId));
		
		$res = array();
		foreach ($rows as $row)
		{
			$date_id = $row["event_date_id"];
			$hour_id = $row["event_hour_id"];
			if (!array_key_exists($date_id, $res))
			{
				$res[$date_id]=array();
			}
			$res[$date_id][] = $hour_id; 
		}
		return $res;
	}

	public static function getPostTransferAggregationTypes($processID)
	{
		$rows = MySQLRunner::execute("SELECT post_transfer_aggregations FROM kalturadw_ds.staging_areas WHERE process_id = ?", array(0=>$processID));
		$aggrTypes = array();
		foreach ($rows as $row)
		{
			preg_match_all("/'([^']+)'/", $row["post_transfer_aggregations"], $matches);
			foreach ($matches[1] as $aggrType)
			{
				$aggrTypes[$aggrType] = 1;
			}
		}
		return array_keys($aggrTypes);
	}
	
	public static function cleanDB()
	{
		global $CONF;
		
		putenv('KETTLE_HOME='.Configuration::$KETTLE_HOME);
		passthru($CONF->RuntimePath.'/setup/dwh_drop_databases.sh -d '.$CONF->RuntimePath.' -h '.$CONF->DbHostName);
		passthru('export KETTLE_HOME='.Configuration::$KETTLE_HOME.';'.$CONF->RuntimePath.'/setup/dwh_setup.sh -d '.$CONF->RuntimePath.' -h '.$CONF->DbHostName);
	}
	
	public static function groupBy($field,$aggrField, $table)
	{
		$rows = MySQLRunner::execute('SELECT '.$field.', sum('.$aggrField.') amount FROM '.$table.' GROUP BY '.$field);
		
		$res = array();
		foreach ($rows as $row)
		{
			$res[$row[$field]]=$row["amount"];
		}
		return $res;
	}
	
	public static function setEntryMediaType($val)
	{
		MySQLRunner::execute('update kalturadw.dwh_fact_events set entry_media_type_id = ?',array(0=>$val),false);
	}
}
?>
