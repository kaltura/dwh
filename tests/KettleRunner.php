<?php
require_once 'Configuration.php';

class KettleRunner
{
	public static function execute($job, $params=array())
	{
		global $CONF;
		
		$args = ' /file ' .$CONF->EtlBasePath.$job;		
		foreach ($params as $k => $v)
		{
			$args=$args.' -param:'.$k.'='.$v;
		}
		
		$out = array();
		putenv('KETTLE_HOME='.Configuration::$KETTLE_HOME);
		exec('export KETTLE_HOME='.Configuration::$KETTLE_HOME.';/usr/local/pentaho/pdi/kitchen.sh'.$args, $out);
		print_r($out);
	}
}
?>