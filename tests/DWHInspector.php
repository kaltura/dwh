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
			die("No cycle found!");
		}
		
		foreach ($res as $row)
		{
			return $row["cycle_id"];
		}
	}
	
	public static function getFiles($cycleId)
	{
		$res = MySQLRunner::execute("SELECT file_id FROM kalturadw_ds.files WHERE cycle_id = ?",array(0=>$cycleId));
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
	
	public static function countRows($table_name, $fileId, $extra='')
	{
		$res = MySQLRunner::execute("SELECT count(*) amount FROM ".$table_name." WHERE file_id = ? ".$extra,array(0=>$fileId));
		foreach ($res as $row)
		{
			return $row["amount"];
		}
	}
	
	public static function cleanDB()
	{
		global $CONF;
		
		$out = array();
		putenv('KETTLE_HOME='.Configuration::$KETTLE_HOME);
		exec('sh '.$CONF->RuntimePath.'/setup/dwh_drop_databases.sh -d '.$CONF->RuntimePath.' -h '.$CONF->DbHostName);
		exec('export KETTLE_HOME='.Configuration::$KETTLE_HOME.';sh '.$CONF->RuntimePath.'/setup/dwh_setup.sh -d '.$CONF->RuntimePath.' -h '.$CONF->DbHostName);
	}
}
?>