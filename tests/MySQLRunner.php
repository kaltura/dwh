<?php
require_once 'Configuration.php';

class MySQLRunner
{
	public static function execute($sql, $params=array(), $returnResults=true)
	{
		global $CONF;
		$db = new MySQLRunner($CONF->DbHostName,$CONF->DbPort, $CONF->DbUser, $CONF->DbPassword);
		return $db->run($sql, $params, $returnResults);
	}

	public function __construct($host, $port, $user, $password)
	{
		$this->host = $host;
		$this->port = $port;
		$this->user = $user;
		$this->password = $password;
	}
	
	private $link = null;
	private $host = 'localhost';
	private $port = 3306;
	private $user = '';
	private $password = '';
	
	private function connect()
	{
		$this->link = mysql_pconnect($this->host.':'.$this->port, $this->user, $this->password);
		if (!$this->link) 
		{
			print('Could not connect: ' . mysql_error());
			exit(1);
		}
	}

	private function disconnect()
	{
		if ($this->link) 
		{
			mysql_close($this->link);
		}
		$this->link=null;
	}
	
	public function run($sql, $params=array(), $returnResults=true)
	{
		$this->connect();
		mysql_query("SET query_cache_type=0");		


		foreach ($params as $param)
		{
			$sql = preg_replace('/\?/', $param, $sql, 1);
			#$sql = str_replace('?', $param, $sql, 1);
		}
		
		$result = mysql_query($sql);		
		if (!$result) 
		{
			$this->disconnect();
			print( "Could not successfully run query ($sql) from DB: " . mysql_error());
			exit(1);
		}
		
		$rows = array();
		if (!$returnResults || mysql_num_rows($result) == 0) 
		{
			$this->disconnect();
			return $rows;
		}		
		
		while ($row = mysql_fetch_assoc ($result)) 
		{
			$rows[]=$row;
		}		
		
		mysql_free_result($result);		
		$this->disconnect();
		return $rows;
	}	
}
?>
