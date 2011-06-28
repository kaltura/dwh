<?php
require_once 'Configuration.php';
require_once 'KettleRunner.php';
require_once 'DWHInspector.php';

class EventTest extends PHPUnit_Framework_TestCase
{
	public function setUpBeforeClass()
	{
		DWHInspector::cleanDB();
		// clear cycles dir
	}

	public function getGenereateJob()
	{
		return '/cycles/get_files_and_generate_cycle.kjb';
	}

	public function getFetchParmas()
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
	
    public function testGenereate()
    {
		KettleRunner::execute($this->getGenereateJob(), $this->getFetchParmas());

		$cycleId = DWHInspector::getGeneratedCycle();
		$this->isFileRegistered($cycleId);
		$this->isFileExists($cycleId);
    }
	
	public function isFileRegistered($cycleId)
	{
		$files = DWHInspector::getFiles($cycleId);
		$fileCount = count($files);
        $this->assertEquals(1, $fileCount);
	}
	
	public function isFileExists($cycleId)
	{
		global $CONF;
		
		$files = scandir($CONF->CyclePath.'/process/'.$cycleId);
		$this->assertGreaterThan(0, count($files));
	}
	
	public function testProcess()
	{
	}
	
	public function testTransfer()
	{
	}
	
	public function testAggregation()
	{
	}
}
?>