<?php
require_once 'MySQLRunner.php';

class DWHInspector
{
	public static function getGeneratedCycle()
	{
		$res = MySQLRunner::execute("SELECT cycle_id FROM kalturadw_ds.cycles WHERE status = 'GENERATED'");
		
		if(1!=count($res))
		{
			die("No cycle created!");
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
	
	public static function cleanDB()
	{
		// drop DB
		// create DB
	}
}
?>