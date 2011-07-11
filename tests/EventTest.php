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
		
    public function testGenereate()
    {
		KettleRunner::execute($this->getGenereateJob(), $this->getFetchParams());

		$cycleId = DWHInspector::getCycle('GENERATED');
		$this->isFileRegistered($cycleId);
		$this->isDirExists($cycleId);
    }
	
	private function getGenereateJob()
	{
		return '/cycles/get_files_and_generate_cycle.kjb';
	}
	
	private function getFetchParams()
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
	
	private function isDirExists($cycleId, $exists = true, $path = '/process/')
	{
		global $CONF;
				
		$dir = $CONF->CyclePath.$path.$cycleId;
		if($exists)
		{
			$files = scandir($dir);
			$this->assertEquals(3, count($files)); // ., .. and file
		} else
		{
			$this->assertFalse(is_dir($dir));
		}
	}
	
	public function testProcess()
	{
		global $CONF;
		
		$cycleId = DWHInspector::getCycle('GENERATED');
		
		KettleRunner::execute($this->getProcessJob(), $this->getProcessParams());

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
	
	private function getProcessJob()
	{
		return '/cycles/process_cycle.kjb';
	}
	
	private function getProcessParams()
	{
		global $CONF;
		
		return array('ProcessID'=>$CONF->EventsProcessID,
					 'ProcessJob'=>$CONF->EtlBasePath.'/events/process/process_events.kjb');
	}
	
	private function countRows($file)
	{
		$lines = file($file);
		$counter = 0;
		foreach($lines as $line)
		{
			$line = urldecode($line);
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
			$line = urldecode($line);
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
			$line = urldecode($line);
			if(preg_match($regex, $line, $matches))
			{
				$entry = $matches[1];
				
				if(!array_key_exists($entry,$entries))
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
		return $this->countPerRegex($file, '/^.*entryId=([^& "]*).*/');
	}
	
	private function countPerPartner($file)
	{
		return $this->countPerRegex($file, '/^.*partnerId=([^& "]*).*/');
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
		$cycleId = DWHInspector::getCycle('PROCESSED');
		
		$ds_events_lines = array();
		$files = DWHInspector::getFiles($cycleId);
		foreach($files as $fileId)
		{
			$ds_events_lines[$fileId] = DWHInspector::countRows('kalturadw_ds.ds_events',$fileId);
		}
		
		DWHInspector::setAggregations(1);
		
		KettleRunner::execute($this->getTransferJob(), $this->getTransferParams());
		$this->assertEquals($cycleId,DWHInspector::getCycle('DONE'));
		$this->isDirExists($cycleId, false);
		$this->isDirExists($cycleId, true, '/originals/');		
		
		$files = DWHInspector::getFiles($cycleId);
		foreach($files as $fileId)
		{
			// compare rows in ds_events and dwh_fact_events
			$this->assertEquals($ds_events_lines[$fileId], DWHInspector::countRows('kalturadw.dwh_fact_events',$fileId));
			
			// make sure ds_events was emptied
			$this->assertEquals(0,DWHInspector::countRows('kalturadw_ds.ds_events',$fileId));		
		}
		
		// make sure aggregations are reset
		foreach(DWHInspector::getDates($cycleId) as $dateId)
		{
			$this->assertGreaterThan(0,count(DWHInspector::getAggregations($dateId)));
		}
	}

	private function getTransferJob()
	{
		return '/cycles/transfer_cycle.kjb';
	}

	private function getTransferParams()
	{
		global $CONF;
		
		return array('ProcessID'=>$CONF->EventsProcessID);
	}
	
	public function testAggregation()
	{
	}
}
?>