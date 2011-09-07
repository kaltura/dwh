<?php
require_once 'Configuration.php';
require_once 'KettleRunner.php';
require_once 'DWHInspector.php';
require_once 'MySQLRunner.php';
require_once 'KalturaTestCase.php';
require_once 'CycleProcessTestCase.php';

class EventTest extends CycleProcessTestCase
{
	const BW_REGEX = '/^.* "GET \/p\/(\d+)\/.*" 200 (\d+) .*$/';

	protected function getFetchParams()
	{
		global $CONF;
		
		return array(self::GENERATE_PARAM_FETCH_LOGS_DIR=>$CONF->EventsLogsDir,
					self::GENERATE_PARAM_FETCH_WILD_CARD=>$CONF->EventsWildcard,
					'FetchMethod' =>$CONF->EventsFetchMethod,
					'ProcessID'=>$CONF->EventsProcessID,
					'FetchJob'=>$CONF->EtlBasePath.'/common/fetch_files.kjb',
					'FetchFTPServer'=>$CONF->EventsFTPServer,
					'FetchFTPPort'=>$CONF->EventsFTPPort,
					'FetchFTPUser'=>$CONF->EventsFTPUser,
					'FetchFTPPassword'=>$CONF->EventsFTPPassword,
					'TempDestination'=>$CONF->ExportPath.'/dwh_inbound/events',
					self::GENERATE_PARAM_IS_ARCHIVED=>'True');
	}

        protected function getProcessParams()
        {
                global $CONF;

                return array('ProcessID'=>$CONF->EventsProcessID,
                             'ProcessJob'=>$CONF->EtlBasePath.'/events/process/process_events.kjb');
        }

        protected function getTransferParams()
        {
                global $CONF;

                return array(self::TRANSFER_PARAM_PROCESS_ID=>$CONF->EventsProcessID);
        }

	 protected function getDSTablesToFactTables()
        {
                $dsTableToFactTables = array();
                $dsTablesToFactTables["ds_events"]="dwh_fact_events";
                $dsTablesToFactTables["ds_bandwidth_usage"]="dwh_fact_bandwidth_usage";
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
		
			// compare rows in ds_events to rows in file
                        $this->assertEquals(DWHInspector::countRows('kalturadw_ds.ds_events',$fileID),$this->countRows($filename, array($this, 'validKDPLine')));

                        // compare plays in ds_events to plays in file
                        $this->assertEquals(DWHInspector::countRows('kalturadw_ds.ds_events',$fileID,' and event_type_id=3'),$this->countPlays($filename));
						
                        // compare per entry
                        $entries = $this->countPerEntry($filename);
                        $this->assertEquals(count($entries), DWHInspector::countDistinct('kalturadw_ds.ds_events',$fileID,'entry_id'));

                        foreach($entries as $entry=>$val)
                        {
                                $res = DWHInspector::countRows('kalturadw_ds.ds_events',$fileID," and entry_id='".$entry."'");
                                $this->assertEquals($res, $val);
                        }

                        // compare kdp events per partner
                        $kdpEventsPartners = $this->countKDPEventsPerPartner($filename);     
                        $this->assertEquals(count($kdpEventsPartners), DWHInspector::countDistinct('kalturadw_ds.ds_events',$fileID,'partner_id'));

                        foreach($kdpEventsPartners as $partner=>$val)
                        {
                                $res = DWHInspector::countRows('kalturadw_ds.ds_events',$fileID," and partner_id='".$partner."'");
                                $this->assertEquals($res, $val);
                        }

			// compare rows in ds_bandwidth_usage to rows in file
                        $this->assertEquals(DWHInspector::countRows('kalturadw_ds.ds_bandwidth_usage',$fileID),$this->countRows($filename, array($this, 'validBWLine')));

                        // compare bandwidth_bytes in ds_bandwidth_usage to bandwidth bytes consumed in file
                        $this->assertEquals(DWHInspector::sumRows('kalturadw_ds.ds_bandwidth_usage',$fileID,"bandwidth_bytes"),$this->sumBytes($filename, array($this, 'validBWLine'), self::BW_REGEX));

			// compare bw consumption per partner
                        $bwPartners = $this->countBWEventsPerPartner($filename); 
                        $this->assertEquals(count($bwPartners), DWHInspector::countDistinct('kalturadw_ds.ds_bandwidth_usage',$fileID,'partner_id'));

                        foreach($bwPartners as $partner=>$val)
                        {
                                $res = DWHInspector::sumRows('kalturadw_ds.ds_bandwidth_usage',$fileID,'bandwidth_bytes', ' and partner_id=\''.$partner.'\'');
                                $this->assertEquals($res, $val);
                        }	

			// make sure there are very little invalid lines
			$this->assertEquals(0, DWHInspector::countRows('kalturadw_ds.invalid_ds_lines',$fileID));
		}
	}
	
	public function validKDPLine($line)
	{
		return (strpos($line,'service=stats')!==false && strpos($line,'action=collect')!==false) || (strpos($line,'collectstats')!==false);
	}

	public function validBWLine($line)
        {
                return (preg_match(self::BW_REGEX, $line) > 0);
        }	
	
	private function countPlays($file)
	{
		$lines = file($file);
		$counter = 0;
		foreach($lines as $line)
		{
			$line = urldecode($line);
			if($this->validKDPLine($line) && strpos($line,'eventType=3')!==false)
			{
				$counter++;
			}
		}
		return $counter;
	}
	
	private function countPerEntry($file)
	{
		return $this->countPerRegex($file, '/^.*entryId=([^& "]*).*/',array($this, 'validKDPLine'));
	}
	
	private function countKDPEventsPerPartner($file)
	{
		return $this->countPerRegex($file, '/^.*partnerId=([^& "]*).*/',array($this, 'validKDPLine'));
	}
	
	private function countBWEventsPerPartner($file)
        {
                return $this->countPerRegex($file, self::BW_REGEX,array($this, 'validBWLine'));
        }

	public function testTransfer()
	{
		parent::testTransfer();
	}

	public function testAggregation()
	{
		// fake entry media type for aggregations
		DWHInspector::setEntryMediaType(1);

		parent::testAggregation();
		
		$this->compareAggregation('partner_id', 'kalturadw.dwh_fact_events', 'if(event_type_id=3,1,0)', 'partner_id', 'kalturadw.dwh_hourly_partner', 'ifnull(count_plays, 0)');
		$this->compareAggregation('entry_id', 'kalturadw.dwh_fact_events', 'if(event_type_id=3,1,0)', 'entry_id', 'kalturadw.dwh_hourly_events_entry', 'ifnull(count_plays, 0)');
		$this->compareAggregation('domain_id', 'kalturadw.dwh_fact_events', 'if(event_type_id=3,1,0)', 'domain_id', 'kalturadw.dwh_hourly_events_domain', 'ifnull(count_plays, 0)');
		$this->compareAggregation('referrer_id', 'kalturadw.dwh_fact_events', 'if(event_type_id=3,1,0)', 'referrer_id', 'kalturadw.dwh_hourly_events_domain_referrer', 'ifnull(count_plays, 0)');
		$this->compareAggregation('location_id', 'kalturadw.dwh_fact_events', 'if(event_type_id=3,1,0)', 'location_id', 'kalturadw.dwh_hourly_events_country', 'ifnull(count_plays, 0)');
		$this->compareAggregation('widget_id', 'kalturadw.dwh_fact_events', 'if(event_type_id=3,1,0)', 'widget_id', 'kalturadw.dwh_hourly_events_widget', 'ifnull(count_plays, 0)');

                $this->compareAggregation('partner_id', 'kalturadw.dwh_fact_bandwidth_usage', '(bandwidth_bytes/1024)', 'partner_id', 'kalturadw.dwh_hourly_partner_usage', 'ifnull(count_bandwidth_kb, 0)');
                $this->compareAggregation('bandwidth_source_id', 'kalturadw.dwh_fact_bandwidth_usage', '(bandwidth_bytes/1024)', 'bandwidth_source_id', 'kalturadw.dwh_hourly_partner_usage', 'ifnull(count_bandwidth_kb, 0)');
	}	

}
?>
