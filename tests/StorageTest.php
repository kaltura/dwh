<?php
require_once 'Configuration.php';
require_once 'KettleRunner.php';
require_once 'DWHInspector.php';
require_once 'MySQLRunner.php';
require_once 'KalturaTestCase.php';

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
		$this->partnerId = $this->createNewPartner();
		$this->createNewEntry($this->partnerId);
	}
	
	private function createNewPartner()
    {
		$rows = MySQLRunner::execute("SELECT ifnull(MIN(partner_id),0) - 10 as id FROM kalturadw.dwh_dim_partners");
		$partnerId = $rows[0]["id"];
		MySQLRunner::execute("INSERT INTO kalturadw.dwh_dim_partners (partner_id, partner_name) VALUES(?, 'TEST_PARTNER') ", array(0=>$partnerId),false);
		return $partnerId;
    }

	private function createNewEntry($partnerId, $count=10)
	{
		for($i = 0;$i<$count;$i++)
		{
			$entryId = "TEST_".$partnerId."_".$i;
			MySQLRunner::execute("INSERT INTO kalturadw.dwh_dim_entries (partner_id, entry_id, entry_name, entry_status_id, updated_at) VALUES(?,'?','?',2, DATE(?))", array(0=>$partnerId,1=>$entryId,2=>$entryId,3=>self::DATE_ID), false);
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
			MySQLRunner::execute("INSERT INTO kalturadw.dwh_dim_flavor_asset (partner_id, entry_id, id, updated_at) VALUES(?,'?','?', DATE(?))", array(0=>$partnerId,1=>$entryId,2=>$flavorId, 3=>self::DATE_ID), false);
			
			$fileSize = rand(100,10000);

			MySQLRunner::execute("INSERT INTO kalturadw.dwh_dim_file_sync (partner_id, object_type, object_sub_type, object_id, file_size, id, updated_at, original, status, version) 
						VALUES(?,4,1,'?',?, ?, DATE(?), 1, 2, 1)", array(0=>$partnerId,1=>$flavorId, 2=>$fileSize, 3=>($fileSyncId + $i), 4=>self::DATE_ID), false);
			
			if(!array_key_exists($entryId,$this->expected))
			{
					$this->expected[$entryId]=0;
			}
			$this->expected[$entryId] += $fileSize;
			$this->delta += $fileSize;
		}
	}
	
	public function testCalcEntrySizes()
	{
		MySQLRunner::execute("CALL kalturadw.calc_entries_sizes(?)",array(0=>self::DATE_ID), false);
		$this->compare(self::DATE_ID);
	}
	
	public function testDeleteEntry()
	{
		MySQLRunner::execute("CALL kalturadw.calc_entries_sizes(?)",array(0=>self::DATE_ID), false);
		$this->deleteEntry(self::DATE_ID+1);
		
		MySQLRunner::execute("CALL kalturadw.calc_entries_sizes(?)",array(0=>self::DATE_ID+1), false);
		$this->compare(self::DATE_ID+1);		
	}
	
	private function deleteEntry($dateId)
	{
		foreach($this->expected as $entryId=>$entrySize)
		{
			$rows = MySQLRunner::execute("SELECT sum(entry_additional_size_kb) size FROM kalturadw.dwh_fact_entries_sizes WHERE entry_id = '?'",array(0=>$entryId));
			$size = floatval($rows[0]["size"]);

			MySQLRunner::execute("UPDATE kalturadw.dwh_dim_entries SET entry_status_id = 3, modified_at=DATE(?) WHERE entry_id = '?'", array(0=>$dateId,1=>$entryId), false);
			$this->expected[$entryId] -= $size*1024;
			$this->delta = -$size*1024;
			return;
		}
	}
	
	public function testUpdateEntrySize()
	{
		MySQLRunner::execute("CALL kalturadw.calc_entries_sizes(?)",array(0=>self::DATE_ID), false);		
		$this->updateEntrySize(self::DATE_ID+2);
		
		MySQLRunner::execute("CALL kalturadw.calc_entries_sizes(?)",array(0=>self::DATE_ID+2), false);
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
						WHERE object_id = '?'", array(0=>$size, 1=>$fileSyncId, 2=>$dateId, 3=>$flavorId), false);
			$this->expected[$entryId] += $size;
			$this->delta = $size;
			$fileSyncId++;
			return;
		}
	}
	
	private function compare($dateId)
	{
		$rows = MySQLRunner::execute("SELECT entry_id, sum(entry_additional_size_kb) size FROM kalturadw.dwh_fact_entries_sizes WHERE entry_size_date_id <= ? AND partner_id = ? GROUP BY entry_id" , array(0=>$dateId, 1=>$this->partnerId));
		
		$this->assertEquals(count($this->expected), count($rows));

		$expectedTotal = 0;		
		foreach($rows as $row)
		{
			$size = floatval($row["size"]);
			echo "x:" .$this->expected[$row["entry_id"]]/1024 ." " .$size . "\n";
			$this->assertLessThan(0.01,abs($this->expected[$row["entry_id"]]/1024 - $size));
			$expectedTotal += $size;			
		}
		
		$rows = MySQLRunner::execute("SELECT sum(aggr_storage_mb) size FROM kalturadw.dwh_hourly_partner_usage WHERE date_id = ? AND partner_id = ?" , array(0=>$dateId, 1=>$this->partnerId));
		$actualTotal = floatval($rows[0]["size"]);
		echo "total: expected " .$expectedTotal/1024 ." actual " .$actualTotal . "\n";
		$this->assertLessThan(0.01,abs($expectedTotal/1024 - $actualTotal));
		
		$rows = MySQLRunner::execute("SELECT sum(count_storage_mb) size FROM kalturadw.dwh_hourly_partner_usage WHERE date_id = ? AND partner_id = ?" , array(0=>$dateId, 1=>$this->partnerId));
		$actualDelta = floatval($rows[0]["size"]);
		echo "delta: expected " .$this->delta/1024/1024 ." actual " .$actualDelta. "\n";
		$this->assertLessThan(0.01,abs($this->delta/1024/1024 - $actualDelta));

	}
}
?>

