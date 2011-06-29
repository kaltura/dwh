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
		$cycleId = DWHInspector::getCycle('GENERATED');
		
		KettleRunner::execute($this->getProcessJob(), $this->getProcessParmas());

		$this->assertEquals($cycleId,DWHInspector::getCycle('PROCESSED'));
		$this->isDirExists($cycleId);
		
		foreach($files as $fileId)
		{
			// compare rows in ds_events to rows in file
			$this->assertEquals(DWHInspector::countRows('kalturadw_ds.ds_events',$fileId),$this->countRows(DWHInspector::getFileName($fileId)));
			
			// compare plays in ds_events to plays in file
			$this->assertEquals(DWHInspector::countRows('kalturadw_ds.ds_events',$fileId,' and event_type_id=2'),$this->countPlays(DWHInspector::getFileName($fileId)));
			
			// compare per entry
			$entries = $this->countPerEntry(DWHInspector::getFileName($fileId));		
			$this->assertEquals(count($entires), $this->countDistinct('kalturadw_ds.ds_events',$fileId,'entry_id'));
			
			foreach($entries as $entry=>$val)
			{
				$res = DWHInspector::countRows('kalturadw_ds.ds_events',$fileId," and entry_id='".$entry."'");
				$this->assertEquals($res, $val);
			}						
			
			// compare per partner
			$partners = $this->countPerPartner(DWHInspector::getFileName($fileId));		
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
			if(strpos($line,'collectStats')>0)
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
			if(strpos($line,'eventType=2')>0)
			{
				$counter++;
			}
		}
		return $counter;
	}
	
	private function countPerEntry($file)
	{
		$lines = file($file);
		$entries = array();
		foreach($lines as $line)
		{
			$start = strpos($line,'entryId=');
			if($start>0)
			{
				$entry_id = substr($line,$start,strpos($line,'&',$start)-$start);
				
				if(!contains($entries,$entry_id))
				{
					$entries[$entry_id]=0;
				}
				$entries[$entry_id]++;
			}
		}
		return $entries;
	}
	
	private function countPerPartner($file)
	{
		$lines = file($file);
		$partners = array();
		foreach($lines as $line)
		{
			$start = strpos($line,'partnerId=');
			if($start>0)
			{
				$partner_id = substr($line,$start,strpos($line,'&',$start)-$start);
				
				if(!contains($partners,$partner_id))
				{
					$partners[$partner_id]=0;
				}
				$partners[$partner_id]++;
			}
		}
		return $partners;
	}
		
	private function countDistinct($table_name,$fileId,$select)
	{
		$res = MySQLRunner::execute("SELECT count(distinct ".$select.") amount FROM ".$table_name." WHERE file_id = ? ",array(0=>$fileId));
		foreach($res as $row)
		{
			return $row["amount"];
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