<?php
require_once 'Configuration.php';
require_once 'KettleRunner.php';
require_once 'DWHInspector.php';
require_once 'MySQLRunner.php';

class KalturaTestCase extends PHPUnit_Framework_TestCase
{
	public static function setUpBeforeClass()
	{
		global $CONF;
		
		DWHInspector::cleanDB();
		self::rrmdir($CONF->CyclePath.'/process/');
		self::rrmdir($CONF->CyclePath.'/originals/');
		
		self::register();
	}
	
	private static function rrmdir($dir) 
	{ 
		if (is_dir($dir)) 
		{		
			$objects = scandir($dir); 
			foreach ($objects as $object) 
			{ 
				if ($object != "." && $object != "..") 
				{ 
					if (filetype($dir."/".$object) == "dir")
					{
						self::rrmdir($dir."/".$object); 
						rmdir($dir."/".$object);
					} else 
					{
						unlink($dir."/".$object); 
					}
				}
			}
			if($objects!=null)
			{
				reset($objects); 			
			}
		} 		
	}
		
	public static function register()
	{
		KettleRunner::execute('/common/register_etl_server.ktr');
	}
}
?>