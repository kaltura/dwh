<?php
require_once 'Configuration.php';
require_once 'KettleRunner.php';
require_once 'DWHInspector.php';
require_once 'MySQLRunner.php';
require_once 'KalturaTestCase.php';
require_once 'FileSyncCollection.php';
require_once 'FileSyncRecord.php';

class StorageTest extends KalturaTestCase
{
	const DATE_ID = 20110801;
	private $partnerId;
	private $expected;
	private $delta;
	
	public function setUp()
	{
		$this->expected = array();
		$this->delta = 0;
		//$this->partnerId = DWHInspector::createNewPartner();
		//$this->createNewEntry($this->partnerId);
	}

	public function testFileSyncData()
	{
                $start = new DateTime(date("Y-m-d"));
                $start->sub(new DateInterval("P30D"));
		$fileSyncCollection = DWHInspector::getFileSyncCollection($start);

                $end = new DateTime(date("Y-m-d"));
                $end->add(new DateInterval("P1D"));
                KettleRunner::execute('/dimensions/file_sync/file_sync.kjb ', array('LastUpdatedAt'=>$start->format('Y/m/d')." 00:00:00", 'OperationalReplicationSyncedAt'=>$end->format('Y/m/d')." 00:00:00"));
		$fileSyncRecords = $fileSyncCollection->getFileSyncRecords();
		foreach ($fileSyncRecords as $fileSyncRecord)
		{	
			$this->compareFileSyncRecord($fileSyncRecord);
		}
		global $CONF;
                $dwh = new MySQLRunner($CONF->DbHostName,$CONF->DbPort, $CONF->DbUser, $CONF->DbPassword);
		$dbRecords = $dwh->run("SELECT 1 FROM kalturadw.dwh_fact_file_sync");

		$this->assertEquals(count($fileSyncRecords), count($dbRecords), "The number of loaded file sync records is ". count($dbRecords) . " while it is expected to be " . count($fileSyncRecords)); 
	}	

	public function testFileSyncDataUpdateEntriesAndFlavorStream()
	{
                MySQLRunner::execute('TRUNCATE TABLE kalturadw.dwh_fact_file_sync', array());
	
		$start = new DateTime(date("Y-m-d"));
                $start->sub(new DateInterval("P30D"));

		global $CONF;
                $opDB = new MySQLRunner($CONF->OpDbHostName,$CONF->OpDbPort, $CONF->OpDbUser, $CONF->OpDbPassword);

                $fileSyncRecords = array();
                $deletedEntries = array();
		
		$fileSyncID = -1;
		$subType = 1;
		$fileSize = 1;
		$version = 1;
		$entryObjectType = 1;
		$flavorAssetObjectType = 1;

                $rows = $opDB->run("SELECT id, partner_id, status, modified_at deleted_at FROM kaltura.entry WHERE updated_at >='".$start->format('Y-m-d')."'");
                foreach ($rows as $row)
                {
                        if ($row["status"] == "3")
                        {
                                $fileSyncRecords[] =  new FileSyncRecord(-1, $row["id"], 1, 1, $row["partner_id"], 1, 1, $start, $row["deleted_at"]);
                                $deletedEntries[$row["id"]] = $row["deleted_at"];
                        }
                        DWHInspector::writeFileSyncRecordForEntry($row["id"], $row["partner_id"]);
                }

		$rows = $opDB->run("SELECT id, partner_id, status, if(status=3,ifnull(deleted_at, updated_at), deleted_at) deleted_at, entry_id FROM kaltura.flavor_asset WHERE updated_at >='".$start->format('Y-m-d')."'");
                foreach ($rows as $row)
                {
                        if (array_key_exists($row["entry_id"], $deletedEntries))
                        {
                                $deletedAt = $row["deleted_at"] == '' ? $deletedEntries[$entryID] : $row["deleted_at"];
                                $fileSyncRecords[] = new FileSyncRecord(-1, $row["id"], 4, 1, $row["partner_id"], 1, 1, $start, $deletedAt);
                        }
                        else if ($row["status"] == "3")
                        {
                                $fileSyncRecords[] = new FileSyncRecord(-1, $row["id"], 4, 1, $row["partner_id"], 1, 1, $start, $row["deleted_at"]);
                        }
                        DWHInspector::writeFileSyncRecordForFlavorAsset($row["id"], $row["partner_id"]);
                }
		
		$end = new DateTime(date("Y-m-d"));
                $end->add(new DateInterval("P1D"));

                KettleRunner::execute('/../tests/execute_dim.ktr', array('TransformationName'=>$CONF->EtlBasePath.'/dimensions/update_flavor_asset.ktr','LastUpdatedAt'=>$start->format('Y/m/d')." 00:00:00", 'OperationalReplicationSyncedAt'=>$end->format('Y/m/d')." 00:00:00"));
                KettleRunner::execute('/../tests/execute_dim.ktr', array('TransformationName'=>$CONF->EtlBasePath.'/dimensions/update_entries.ktr','LastUpdatedAt'=>$start->format('Y/m/d')." 00:00:00", 'OperationalReplicationSyncedAt'=>$end->format('Y/m/d')." 00:00:00"));

                $dwh = new MySQLRunner($CONF->DbHostName,$CONF->DbPort, $CONF->DbUser, $CONF->DbPassword);
		$dbRecords = $dwh->run("SELECT 1 FROM kalturadw.dwh_fact_file_sync where deleted_at is not null");
		$this->assertEquals(count($fileSyncRecords), count($dbRecords), "The number of file_sync_records marked as deleted is ". count($dbRecords) . "while it's expected to be " . count($fileSyncRecords));

		foreach ($fileSyncRecords as $fileSyncRecord)
		{
                	$dbRecords = $dwh->run("SELECT 1 FROM kalturadw.dwh_fact_file_sync where partner_id = ". $fileSyncRecord->getPartnerID() . " and object_type = " . $fileSyncRecord->getObjectType() .
                                        	" and object_id = '" . $fileSyncRecord->getObjectID() . "' and deleted_at = '" . $fileSyncRecord->getDeletedAt() . "'");
                	$this->assertEquals(1, count($dbRecords), "A record didn't exist in the DWH for the following file sync record:\n". print_r($fileSyncRecord, true));
		}
	}


	private function compareFileSyncRecord($fileSyncRecord)
	{
		global $CONF;
                $dwh = new MySQLRunner($CONF->DbHostName,$CONF->DbPort, $CONF->DbUser, $CONF->DbPassword);
		$deletedAtFilter = $fileSyncRecord->getDeletedAt() == null ? "IS NULL" : " = '" . $fileSyncRecord->getDeletedAt() . "'";
                $dbRecords = $dwh->run("SELECT 1 FROM kalturadw.dwh_fact_file_sync where id = " . $fileSyncRecord->getID() . 
					" and partner_id = ". $fileSyncRecord->getPartnerID() . " and object_type = " . $fileSyncRecord->getObjectType() . 
					" and object_id = '" . $fileSyncRecord->getObjectID() . "' and version = " . $fileSyncRecord->getVersion() . 
					" and object_sub_type = " . $fileSyncRecord->getObjectSubType() . " and ready_at = '" . $fileSyncRecord->getReadyAt() .	"'" . 
					" and file_size = " . $fileSyncRecord->getFileSize() . " and deleted_at " . $deletedAtFilter);
                $this->assertEquals(1, count($dbRecords), "A record didn't exist in the DWH for the following file sync record ". print_r($fileSyncRecord, true));
	}

	/*private function createNewEntry($partnerId, $count=10)
	{
		for($i = 0;$i<$count;$i++)
		{
			$entryId = DWHInspector::createNewEntry($this->partnerId, $i, self::DATE_ID);
			$this->createNewFlavor($partnerId, $entryId);
		}
	}
	
	private function createNewFlavor($partnerId, $entryId, $count=10)
	{
		$rows = MySQLRunner::execute("SELECT ifnull(MAX(id) + 2,0) as id FROM kalturadw.dwh_dim_file_sync");
		$fileSyncId = floatval($rows[0]["id"]);

		for($i = 0;$i<$count;$i++)
		{
			$flavorId = $entryId."_".$i;
			MySQLRunner::execute("INSERT INTO kalturadw.dwh_dim_flavor_asset (partner_id, entry_id, id, updated_at) VALUES(?,'?','?', DATE(?))", array(0=>$partnerId,1=>$entryId,2=>$flavorId, 3=>self::DATE_ID));
			
			$fileSize = rand(100,10000);

			MySQLRunner::execute("INSERT INTO kalturadw.dwh_dim_file_sync (partner_id, object_type, object_sub_type, object_id, file_size, id, updated_at, original, status, version) 
						VALUES(?,4,1,'?',?, ?, DATE(?), 1, 2, 1)", array(0=>$partnerId,1=>$flavorId, 2=>$fileSize, 3=>($fileSyncId + $i), 4=>self::DATE_ID));
			
			if(!array_key_exists($entryId,$this->expected))
			{
					$this->expected[$entryId]=0;
			}
			$this->expected[$entryId] += $fileSize;
			$this->delta += $fileSize;
		}
	}
	
	public function xtestCalcEntrySizes()
	{
		MySQLRunner::execute("CALL kalturadw.calc_entries_sizes(?)",array(0=>self::DATE_ID));
		$this->compare(self::DATE_ID);
	}
	
	public function xtestDeleteEntry()
	{
		MySQLRunner::execute("CALL kalturadw.calc_entries_sizes(?)",array(0=>self::DATE_ID));
		$this->deleteEntry(self::DATE_ID+1);
		
		MySQLRunner::execute("CALL kalturadw.calc_entries_sizes(?)",array(0=>self::DATE_ID+1));
		$this->compare(self::DATE_ID+1);		
	}
	
	private function deleteEntry($dateId)
	{
		foreach($this->expected as $entryId=>$entrySize)
		{
			$rows = MySQLRunner::execute("SELECT sum(entry_additional_size_kb) size FROM kalturadw.dwh_fact_entries_sizes WHERE entry_id = '?'",array(0=>$entryId));
			$size = floatval($rows[0]["size"]);

			echo "delete " .$entryId . " with size " . $size . "\n";

			MySQLRunner::execute("UPDATE kalturadw.dwh_dim_entries SET entry_status_id = 3, modified_at=DATE(?) WHERE entry_id = '?'", array(0=>$dateId,1=>$entryId));
			$this->expected[$entryId] = 0;
			$this->delta = -$size*1024;
			return;
		}
	}
	
	public function xtestUpdateEntrySize()
	{
		MySQLRunner::execute("CALL kalturadw.calc_entries_sizes(?)",array(0=>self::DATE_ID));		
		$this->updateEntrySize(self::DATE_ID+2);
		
		MySQLRunner::execute("CALL kalturadw.calc_entries_sizes(?)",array(0=>self::DATE_ID+2));
		$this->compare(self::DATE_ID+2);

	}
	
	private function updateEntrySize($dateId)
	{
		$rows = MySQLRunner::execute("SELECT MAX(id) + 2 as id FROM kalturadw.dwh_dim_file_sync");
		$fileSyncId = floatval($rows[0]["id"]);
		
		foreach($this->expected as $entryId=>$entrySize)
		{
			$size = 4096;
			$flavorId = $entryId."_0";
			
			MySQLRunner::execute("INSERT INTO kalturadw.dwh_dim_file_sync (partner_id, object_type, object_sub_type, object_id, file_size, id, updated_at, original, status, version) 
						SELECT partner_id, object_type, object_sub_type, object_id, file_size + ? , ?, DATE(?), original, status, 2 FROM kalturadw.dwh_dim_file_sync
						WHERE object_id = '?'", array(0=>$size, 1=>$fileSyncId, 2=>$dateId, 3=>$flavorId));
			$this->expected[$entryId] += $size;
			$this->delta = $size;
			$fileSyncId++;

			MySQLRunner::execute("UPDATE kalturadw.dwh_dim_flavor_asset SET updated_at = DATE(?) WHERE id = '?'", array(0=>$dateId, 1=>$flavorId));
			return;
		}
	}
	
	private function compare($dateId)
	{
		echo "Partner : ".$this->partnerId." Date : ".$dateId."\n";
		$rows = MySQLRunner::execute("SELECT entry_id, sum(entry_additional_size_kb) size FROM kalturadw.dwh_fact_entries_sizes WHERE entry_size_date_id <= ? AND partner_id = ? GROUP BY entry_id" , array(0=>$dateId, 1=>$this->partnerId));
		
		$this->assertEquals(count($this->expected), count($rows));

		$expectedTotal = 0;		
		foreach($rows as $row)
		{
			$size = floatval($row["size"]);
			echo "x:" .$row["entry_id"]." ".round($this->expected[$row["entry_id"]]/1024,3) ." " .$size . "\n";
			$this->assertLessThan(0.01,abs(round($this->expected[$row["entry_id"]]/1024,3) - $size));
			$expectedTotal += $size;			
		}
		
		$rows = MySQLRunner::execute("SELECT sum(billable_storage_mb) size FROM kalturadw.dwh_hourly_partner_usage WHERE date_id = ? AND partner_id = ?" , array(0=>$dateId, 1=>$this->partnerId));
		$actualTotal = floatval($rows[0]["size"]);
		echo "total: expected " .round($expectedTotal/1024/31,3) ." actual " .$actualTotal . "\n";
		$this->assertLessThan(0.01,abs(round($expectedTotal/1024/31,3) - $actualTotal));
		
		$rows = MySQLRunner::execute("SELECT sum(count_storage_mb) size FROM kalturadw.dwh_hourly_partner_usage WHERE date_id = ? AND partner_id = ?" , array(0=>$dateId, 1=>$this->partnerId));
		$actualDelta = floatval($rows[0]["size"]);
		echo "delta: expected " .round($this->delta/1024/1024,3) ." actual " .$actualDelta. "\n";
		$this->assertLessThan(0.01,abs(round($this->delta/1024/1024,3) - $actualDelta));

	}*/
}
?>

