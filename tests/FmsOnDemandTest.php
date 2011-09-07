<?php
require_once 'Configuration.php';
require_once 'KettleRunner.php';
require_once 'DWHInspector.php';
require_once 'MySQLRunner.php';
require_once 'KalturaTestCase.php';
require_once 'CycleProcessTestCase.php';

class FMSOnDemandTest extends CycleProcessTestCase
{
	private $illegalEntryPrefixes = array('http://', 'https://', 'rtmp://');	
	private $ignoredPartners = array(100  , -1  , -2  , 0 , 99);

	public static function SetUpBeforeClass()
	{
		parent::SetUpBeforeClass();
		parent::refreshBISourcesTables();
	}
	
	protected function getFetchParams()
	{
		global $CONF;
		return array(self::GENERATE_PARAM_FETCH_LOGS_DIR=>$CONF->FMSOnDemandStreamingLogsDir,
					self::GENERATE_PARAM_FETCH_WILD_CARD=>$CONF->FMSOnDemandStreamingFileWildcard,
					'FetchMethod' =>$CONF->FMSOnDemandStreamingFetchMethod,
					'ProcessID'=>$CONF->FMSOnDemandStreamingProcessID,
					'FetchJob'=>$CONF->EtlBasePath.'/common/fetch_files.kjb',
					'FetchFTPServer'=>$CONF->FMSOnDemandStreamingFtpHost,
					'FetchFTPPort'=>$CONF->FMSOnDemandStreamingFtpPort,
					'FetchFTPUser'=>$CONF->FMSOnDemandStreamingFtpUser,
					'FetchFTPPassword'=>$CONF->FMSOnDemandStreamingFtpPassword,
					'TempDestination'=>$CONF->ExportPath.'/dwh_inbound/fms_streaming',
					self::GENERATE_PARAM_IS_ARCHIVED=>'True');
	}

        protected function getProcessParams()
        {
                global $CONF;

                return array('ProcessID'=>$CONF->FMSOnDemandStreamingProcessID,
                             'ProcessJob'=>$CONF->EtlBasePath.'/fms_streaming/process/process_fms_events.kjb',
			     'FMSYieldMapping'=>$CONF->EtlBasePath.'/fms_streaming/process/yield_fms_ondemand_streaming_data.ktr');
        }

        protected function getTransferParams()
        {
                global $CONF;

                return array(self::TRANSFER_PARAM_PROCESS_ID=>$CONF->FMSOnDemandStreamingProcessID);
        }

	 protected function getDSTablesToFactTables()
        {
                $dsTableToFactTables = array();
                $dsTablesToFactTables["ds_fms_session_events"]="dwh_fact_fms_session_events";
                return $dsTableToFactTables;
        }


	public function testGenerate()
	{
		parent::testGenerate();
	}

	public function testProcess()
	{
		parent::testProcess();

		global $CONF;

                $cycleID = DWHInspector::getCycle('LOADED');
		
		$files = DWHInspector::getFiles($cycleID);
		foreach($files as $fileID)
		{
			$filename =  $CONF->ProcessPath."/".$cycleID.'/'.DWHInspector::getFileName($fileID);
		
			// compare rows in ds_fms_session_events to rows in file
                        $this->assertEquals(DWHInspector::countRows('kalturadw_ds.ds_fms_session_events',$fileID),$this->countRows($filename, array($this, 'validFMSLine')));
		
			// compare number of entries and number of rows per entry
			$this->AssertFMSEntity(array($this, 'countPerEntry'), $filename, $fileID, 'entry_id');
			// compare number of partners and number of rows per partner
			$this->AssertFMSEntity(array($this, 'countPerPartner'), $filename, $fileID, 'partner_id');
			// compare number of session and number of rows per session
			$this->AssertFMSEntity(array($this, 'countPerSession'), $filename, $fileID, 'session_id');
			$fullFileSessions = $this->getFullSessions($filename);
			$fullDBSessions = array_keys(DWHInspector::getFullDSFMSSessions($fileID, implode(",", $this->ignoredPartners)));
			
			// compare number of full sessions
			$this->assertEquals(count($fullFileSessions), count($fullDBSessions));
			// comapre the session IDs
			$this->assertEquals(count(array_intersect($fullFileSessions, $fullDBSessions)), count($fullFileSessions));
			
			// make sure there are very little invalid lines
                        $this->assertEquals($this->countInvalidLines($filename) , DWHInspector::countRows('kalturadw_ds.invalid_ds_lines',$fileID));	
		}
	}
	
	public function testTransfer()
	{
                $cycleID = DWHInspector::getCycle('LOADED');
		$files = DWHInspector::getFiles($cycleID);

		$dsSessions = array();
                foreach($files as $fileID)
                {
			$dsSessions[$fileID] = DWHInspector::getFullDSFMSSessions($fileID, implode(",", $this->ignoredPartners));
		}
		
		parent::testTransfer();
                foreach($files as $fileID)
                {
			$factSessions = DWHInspector::getFactFMSSessions($fileID);
			$this->assertEquals(count($dsSessions[$fileID]), count($factSessions));
			foreach ($dsSessions[$fileID] as $sessionID => $dsSessionDictionary)
			{
				$this->assertEquals($dsSessionDictionary, $factSessions[$sessionID]);
			}
		}
	}

	public function testAggregation()
	{
		parent::testAggregation();
                $this->compareAggregation('bandwidth_source_id', 'kalturadw.dwh_fact_fms_sessions', '(total_bytes/1024)', 'bandwidth_source_id', 'kalturadw.dwh_hourly_partner_usage', 'ifnull(count_bandwidth_kb, 0)','bandwidth_source_id = 6');
                $this->compareAggregation('session_partner_id', 'kalturadw.dwh_fact_fms_sessions', '(total_bytes/1024)', 'partner_id', 'kalturadw.dwh_hourly_partner_usage', 'ifnull(count_bandwidth_kb, 0)','bandwidth_source_id = 6');
	}	

	private function countInvalidLines($file)
	{
                $lines = file($file);
                $counter = 0;
                foreach($lines as $line)
                {
                        $line = urldecode($line);
                        if(!$this->validFMSLine($line))
                        {
                                $counter++;
                        }
                }
                return $counter;
	}
	
	public function validFMSLine($line)
	{
		if (strpos($this->getLineEvent($line), '#') === 0)
		{
			return false;
		}
		if ($this->getLinePartnerAndEntry($line, &$partnerID, &$entryID))
		{
			foreach ($this->illegalEntryPrefixes as $prefix)
	                {
                		if(strpos($entryID, $prefix) === 0)
	                        {
					return false;
				}
			}
		}
		return true;	
	}

	private function AssertFMSEntity($countPerEntityCallBack, $filename, $fileID, $tableEntityName)
	{
		$collection = call_user_func($countPerEntityCallBack, $filename);
                $this->assertEquals(count($collection), DWHInspector::countDistinct('kalturadw_ds.ds_fms_session_events', $fileID, $tableEntityName), $countPerEntityCallBack[1]);

                foreach($collection as $objectID=>$val)
                {
                	$res = DWHInspector::countRows('kalturadw_ds.ds_fms_session_events',$fileID," and $tableEntityName = '$objectID'");
                        $this->assertEquals($res, $val);
                }
	}
	
	private function countPerEntry($file)
	{
		return $this->countPerEntity($file, array($this, 'getLineEntry'));
	}

	private function countPerPartner($file)
        {
		return $this->countPerEntity($file, array($this, 'getLinePartner'));
        }

	private function countPerSession($file)
        {
		return $this->countPerEntity($file, array($this, 'getLineSession'));
        }

	private function countPerEntity($file, $objectCallback)
	{
		$collection = array();
		$lines = file($file);
                foreach($lines as $line)
                {
                        if ($this->validFMSLine($line))
			{
				$objectID = call_user_func($objectCallback, $line);
				if (!array_key_exists($objectID, $collection))
				{
					$collection[$objectID] = 0;
				}
				$collection[$objectID]++;
			}
		}
		return $collection;
	}

	private function getLinePartner($line)
	{
		$this->getLinePartnerAndEntry($line, &$partnerID, &$entryID);
		return $partnerID;
	}
	
	private function getLineEntry($line)
	{
		$this->getLinePartnerAndEntry($line, &$partnerID, &$entryID);
                return $entryID;
	}


	private function getLineEvent($line)
        {
        	$eventIDIndex = 0;
                $fmsFields = explode("\t", $line);
                return $fmsFields[$eventIDIndex];
        }

	private function getLineSession($line)
	{
		$sessionIDIndex = 23;
                $fmsFields = explode("\t", $line);
		return $fmsFields[$sessionIDIndex];
	}
	
	private function getFullSessions($file)
	{
		$lines = file($file);
		$connectedSessions = array();
		$disconnectedSessions = array();
		$withPartnerSessions = array();
		foreach ($lines as $line)
		{
			if ($this->validFMSLine($line))
			{
				$event = $this->getLineEvent($line);
				$sessionID = $this->getLineSession($line);
				if (($event == "connect") && (!in_array($sessionID, $connectedSessions)))
				{
					$connectedSessions[] = $sessionID;
				}
				if (($event == "disconnect") && (!in_array($sessionID, $disconnectedSessions)))
                                {
                                        $disconnectedSessions[] = $sessionID;
                                }
				if (!in_array($sessionID, $withPartnerSessions))
				{
					$this->getLinePartnerAndEntry($line, &$partnerID);
					if (!in_array($partnerID, $this->ignoredPartners))
					{
						$withPartnerSessions[] = $sessionID;
					}
				}	
			}
		}
		
		return array_intersect($connectedSessions, $disconnectedSessions, $withPartnerSessions);
	}
		
	private function getLinePartnerAndEntry($line, $partnerID, $entryID = null)
	{
		$partnerID = -1;
		$entryID = -1;

		$xSnameIndex = 26;
		$fmsFields = explode("\t", $line);
		if (count($fmsFields) > $xSnameIndex)
                {
			preg_match('/^\/?p\/([0-9]+)\/(.*)/', $fmsFields[$xSnameIndex], $matches);
			if (count($matches)>2)
			{
				$partnerID = $matches[1];
				preg_match('/.*\/(flavorId|entry_id)\/([01]_,?[^\.,\/]+)?(.*\/)?([01]_,?[^\.,\/]+).*/',$matches[2],$objectsMatches);
		        	if (count($objectsMatches)>4)
	        	        {
	                        	$objectType=$objectsMatches[1];
		                        $objectID = $objectsMatches[2] ? $objectsMatches[2] : $objectsMatches[4];
	       	                        $objectID = substr($objectID,2,1) == ',' ? substr($objectID,0,2) + substr($objectID,3) : $objectID;
				      	if($objectType == "flavorId")
	                        	{
                                		$entryIDResult = DWHInspector::getEntryIDByFlavorID($objectID);
						if ($entryIDResult != null)
						{
		                                	$entryID = $entryIDResult;
						} 
        		                }
                		        else
	                	        {
        	                	        $entryID = $objectID;
	                	        }
				return true;
				}
			}
		}
		return false;

	}
}
?>
