<?php
require_once 'Configuration.php';
require_once 'KettleRunner.php';
require_once 'DWHInspector.php';
require_once 'MySQLRunner.php';

class EventTest extends PHPUnit_Framework_TestCase
{
	public static function setUpBeforeClass()
	{
		global $CONF;
		
		DWHInspector::cleanDB();
		self::rrmdir($CONF->CyclePath.'/generate/events/');
		self::rrmdir($CONF->CyclePath.'/process/');
		self::rrmdir($CONF->CyclePath.'/originals/');
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
		} 
		reset($objects); 
	}
	
	public function getGenereateJob()
	{
		return '/cycles/get_files_and_generate_cycle.kjb';
	}
	
	public function getProcessJob()
	{
		return '/cycles/process_cycle.kjb';
	}
	
    public function testGenereate()
    {
		KettleRunner::execute($this->getGenereateJob(), $this->getFetchParmas());

		$cycleId = DWHInspector::getCycle('GENERATED');
		$this->isFileRegistered($cycleId);
		$this->isDirExists($cycleId);
    }
	
	
	private function getFetchParmas()
	{
		global $CONF;
		
		return array('FetchLogsDir'=>$CONF->EventsLogsDir,
					 'FetchWildcard'=>$CONF->EventsWildcard,
					 'FetchMethod'=>$CONF->EventsFetchMethod,
					 'ProcessID'=>$CONF->EventsProcessID,
					 'FetchJob'=>$CONF->EtlBasePath.'/common/fetch_files.kjb',
					 'FetchFTPServer'=>$CONF->EventsFTPServer,
					 'FetchFTPPort'=>$CONF->EventsFTPPort,
					 'FetchFTPUser'=>$CONF->EventsFTPUser,
					 'FetchFTPPassword'=>$CONF->EventsFTPPassword,
					 'TempDestination'=>$CONF->ExportPath.'/dwh_inbound/events',
					 'IsArchived'=>'True');
	}
	
	private function isFileRegistered($cycleId)
	{
		$files = DWHInspector::getFiles($cycleId);
		$fileCount = count($files);
        $this->assertEquals(1, $fileCount);
	}
	
	private function isDirExists($cycleId)
	{
		global $CONF;
		
		$files = scandir($CONF->CyclePath.'/process/'.$cycleId);
		$this->assertEquals(3, count($files)); // ., .. and file
	}
	
	public function testProcess()
	{
		global $CONF;
		
		$cycleId = DWHInspector::getCycle('GENERATED');
		
		KettleRunner::execute($this->getProcessJob(), $this->getProcessParmas());

		$this->assertEquals($cycleId,DWHInspector::getCycle('PROCESSED'));
		$this->isDirExists($cycleId);
		
		$files = DWHInspector::getFiles($cycleId);
		foreach($files as $fileId)
		{
			$filename =  $CONF->CyclePath.'/process/'.$cycleId.'/'.DWHInspector::getFileName($fileId);
		
			// compare rows in ds_events to rows in file
			$this->assertEquals(DWHInspector::countRows('kalturadw_ds.ds_events',$fileId),$this->countRows($filename));
			
			// compare plays in ds_events to plays in file
			$this->assertEquals(DWHInspector::countRows('kalturadw_ds.ds_events',$fileId,' and event_type_id=3'),$this->countPlays($filename));
			
			// compare per entry
			$entries = $this->countPerEntry($filename);		
			$this->assertEquals(count($entries), $this->countDistinct('kalturadw_ds.ds_events',$fileId,'entry_id'));
			
			foreach($entries as $entry=>$val)
			{
				$res = DWHInspector::countRows('kalturadw_ds.ds_events',$fileId," and entry_id='".$entry."'");
				$this->assertEquals($res, $val);
			}						
			
			// compare per partner
			$partners = $this->countPerPartner($filename);		
			$this->assertEquals(count($partners), $this->countDistinct('kalturadw_ds.ds_events',$fileId,'partner_id'));
			
			foreach($partners as $partner=>$val)
			{
				$res = DWHInspector::countRows('kalturadw_ds.ds_events',$fileId," and partner_id='".$partner."'");
				$this->assertEquals($res, $val);
			}									
			
			// make sure there are very little invalid lines
			$this->assertEquals(0, DWHInspector::countRows('kalturadw_ds.invalid_event_lines',$fileId));
		}
	}
	
	private function getProcessParmas()
	{
		global $CONF;
		
		return array('ProcessID'=>$CONF->EventsProcessID,
					 'ProcessJob'=>$CONF->EtlBasePath.'/events/process/process_events.kjb');
	}
	
	private function isCycleDirRemoved($cycleId)
	{
		global $CONF;
		
		$files = scandir($CONF->CyclePath.'/process/'.$cycleId);
		$this->assertEquals(0, count($files));
	}
	
	private function countRows($file)
	{
		$lines = file($file);
		$counter = 0;
		foreach($lines as $line)
		{
			if ((strpos($line,'service=stats')!==false && strpos($line,'action=collect')!==false) || (strpos($line,'collectstats')!==false))
			{
				$counter++;
			}
		}
		return $counter;
	}
	
	private function countPlays($file)
	{
		$lines = file($file);
		$counter = 0;
		foreach($lines as $line)
		{
			if(strpos($line,'eventType=3')!==false)
			{
				$counter++;
			}
		}
		return $counter;
	}
	
	private function countPerRegex($file, $regex)
	{
		$lines = file($file);
		$entries = array();
		foreach($lines as $line)
		{
			if(preg_match($regex, $line, $matches))
			{
				$entry = $matches[1];
				
				if(!in_array($entry,$entries))
				{
					$entries[$entry]=0;
				}
				$entries[$entry]++;
			}
		}
		return $entries;
	}
		
	private function countPerEntry($file)
	{
		return countPerRegex($file, '/^.*entryId=([^& "]*).*/');
	}
	
	private function countPerPartner($file)
	{
		return countPerRegex($file, '/^.*partnerId=([^& "]*).*/');
	}
	
	private function countDistinct($table_name,$fileId,$select)
	{
		$res = MySQLRunner::execute("SELECT count(distinct ".$select.") amount FROM ".$table_name." WHERE file_id = ? ",array(0=>$fileId));
		foreach($res as $row)
		{
			return (int) $row["amount"];
		}
	}
	
	public function testTransfer()
	{
	}
	
	public function testAggregation()
	{
	}
}
?>