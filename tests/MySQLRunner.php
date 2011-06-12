<?php
require_once 'Configuration.php';

class MySQLRunner
{
	public static $link = null;
	
	public static function connect()
	{
		global $CONF;
		self::$link = mysql_connect($CONF->DbHostName.':'.$CONF->DbPort, $CONF->DbUser, $CONF->DbPassword);
		if (!self::$link) 
		{
			die('Could not connect: ' . mysql_error());
		}
	}

	public static function disconnect()
	{
		if (self::$link) 
		{
			mysql_close(self::$link);
		}
		self::$link=null;
	}
	
	public static function execute($sql, $params=array())
	{
		MySQLRunner::connect();
		
		foreach ($params as $param)
		{
			$sql = str_replace('?',$param,$sql);
		}
		
		$result = mysql_query($sql);		
		if (!$result) 
		{
			MySQLRunner::disconnect();
			die( "Could not successfully run query ($sql) from DB: " . mysql_error());
		}
		
		$rows = array();
		if (mysql_num_rows($result) == 0) 
		{
			MySQLRunner::disconnect();
			return $rows;
		}		
		
		while ($row = mysql_fetch_assoc ($result)) 
		{
			$rows.add($row);
		}		
		
		mysql_free_result($result);		
		MySQLRunner::disconnect();
		
		return $rows;
	}	
}
?>