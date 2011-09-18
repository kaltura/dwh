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
		MySQLRunner::execute("UPDATE kalturadw.aggr_managment SET is_calculated = ?",array(0=>$isCalculated));
	}
	
	public static function getAggregations($dateId, $hourId, $isCalculated = 0)
	{
		$rows = MySQLRunner::execute("SELECT DISTINCT aggr_name FROM kalturadw.aggr_managment WHERE aggr_day_int = ? AND hour_id = ? AND is_calculated = ?",array(0=>$dateId,1=>$hourId, 2=>$isCalculated));
		
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
	
	public static function groupBy($field,$aggrField, $table, $filter = '1=1')
	{
		$rows = MySQLRunner::execute('SELECT '.$field.', sum('.$aggrField.') amount FROM '.$table.' WHERE '. $filter .' GROUP BY '.$field);
		
		$res = array();
		foreach ($rows as $row)
		{
			$res[$row[$field]]=$row["amount"];
		}
		return $res;
	}
	
	public static function setEntryMediaType($val)
	{
		MySQLRunner::execute('update kalturadw.dwh_fact_events set entry_media_type_id = ?',array(0=>$val));
	}

	public static function purgeCycles()
	{
		MySQLRunner::execute('DELETE FROM kalturadw_ds.files', array());		
		MySQLRunner::execute('DELETE FROM kalturadw_ds.cycles', array());
	}
	
	public static function getEntryIDByFlavorID($flavorID)
	{
		$rows = MySQLRunner::execute("select entry_id from kalturadw.dwh_dim_flavor_asset where id = '?' limit 1", array(0=>$flavorID));
		if (count($rows) > 0)
		{
			return $rows[0]["entry_id"];
		}
	}
	
	public static function getFullDSFMSSessions($fileID,$illegalPartnersCSV)
	{
		$rows = MySQLRunner::execute("SELECT session_id, partner_id, (cs_dis_bytes - cs_con_bytes + sc_dis_bytes - sc_con_bytes) total_bytes FROM ( ".
						"SELECT session_id, MAX(partner_id) partner_id, ".
						"SUM(IF(event_type='connect', client_to_server_bytes, 0)) cs_con_bytes, ".
						"SUM(IF(event_type='disconnect', client_to_server_bytes, 0)) cs_dis_bytes, ".
						"SUM(IF(event_type='connect', server_to_client_bytes, 0)) sc_con_bytes, ".
						"SUM(IF(event_type='disconnect', server_to_client_bytes, 0)) sc_dis_bytes ".
						"FROM kalturadw_ds.ds_fms_session_events f, kalturadw.dwh_dim_fms_event_type dim ".
						"WHERE f.event_type_id = dim.event_type_id and file_id = ? ".
						"GROUP BY session_id ".
						"HAVING MAX(IF(event_type = 'connect', 1, 0))+MAX(IF(event_type = 'disconnect', 1, 0))+MAX(IF(partner_id NOT IN (?),1,0))=3) a ".
						"WHERE (cs_dis_bytes - cs_con_bytes + sc_dis_bytes - sc_con_bytes) > 0 ", array(0=>$fileID,1=>$illegalPartnersCSV));
		$res = array();
                foreach ($rows as $row)
                {
			$res[$row["session_id"]]["partnerID"] = $row["partner_id"];
                        $res[$row["session_id"]]["totalBytes"] = $row["total_bytes"];
                }
                return $res;
	}

	public static function getFactFMSSessions($fileID)
	{
		$rows = MySQLRunner::execute("SELECT DISTINCT s.session_id, s.session_partner_id, s.total_bytes ".
					     "FROM kalturadw.dwh_fact_fms_session_events e, kalturadw.dwh_fact_fms_sessions s ".
					     "WHERE e.session_id = s.session_id AND file_id = ?", array(0=>$fileID));
		$res = array();
                foreach ($rows as $row)
                {
                        $res[$row["session_id"]]["partnerID"] = $row["session_partner_id"];
			$res[$row["session_id"]]["totalBytes"] = $row["total_bytes"];
                }
                return $res;
	}

	public static function createNewPartner()
    	{
		$rows = MySQLRunner::execute("SELECT ifnull(MIN(partner_id),0) - 10 as id FROM kalturadw.dwh_dim_partners;");
		$partnerId = $rows[0]["id"];
		MySQLRunner::execute("INSERT INTO kalturadw.dwh_dim_partners (partner_id, partner_name) VALUES(?, 'TEST_PARTNER') ", array(0=>$partnerId));
		return $partnerId;
    	}

	public static function createNewEntry($partnerId, $entryIndex, $dateId)
	{
		$entryId = "TEST_".$partnerId."_".$entryIndex;
		MySQLRunner::execute("INSERT INTO kalturadw.dwh_dim_entries (partner_id, entry_id, entry_name, entry_status_id, entry_type_id, created_at, updated_at) VALUES(?,'?','?',2, 1, DATE(?), DATE(?))", 
					array(0=>$partnerId,1=>$entryId,2=>$entryId,3=>$dateId, 4=>$dateId));
		return $entryId;
	}

}
?>
