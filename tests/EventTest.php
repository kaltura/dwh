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
		return '/common/fetch_files.kjb';
	}

	public function getFTPParmas()
	{
		global $FTP_SERVER;
		global $FTP_PORT;
		global $FTP_USER;
		global $FTP_PW;
		
		return array('FetchFTPServer'=>$FTP_SERVER,
					 'FetchFTPPort'=>$FTP_PORT,
					 'FetchFTPUser'=>$FTP_USER,
					 'FetchFTPPassword'=>$FTP_PW);
	}
	
    public function testGenereate()
    {
		KettleRunner::execute($this->getGenereateJob(), $this->getFTPParmas());

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
		$files = scandir($CONF->CyclePath.'/'.$cycleId);
		$this->assertEquals(1, count(files));
	}
}
?>