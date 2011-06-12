<?php
require_once 'Configuration.php';

class KettleRunner
{
	public static function execute($job, $params=array())
	{
		global $CONF;
		$cmd = $CONF->EtlBasePath.$job;
		foreach ($params as $k => $v)
		{
			$cmd = $cmd.' -param:'.$k.'='.$v;
		}
		exec('/usr/local/pentaho/pdi/kitchen.sh /file '.$cmd);
	}
	
	public static function getFiles($cycleId)
	{
		$res = MySQLRunner::execute("SELECT cycle_id FROM kalturadw_ds.files WHERE cycle_id = ?",array(0=>$cycleId));
		$files = array();
		foreach ($res as $row)
		{
			$files.add($row["id"]);
		}
		return $files;
	}	
}
?>