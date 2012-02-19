<?php

require_once 'FileSyncRecord.php';

class FileSyncCollection
{
	private $fileIDToFileSyncRecordsDictionary;

	public function __construct()
	{
		$this->fileIDToFileSyncRecordsDictionary = array();
	}

	public function insert($fileSyncRecord)
	{
		if ($fileSyncRecord instanceof FileSyncRecord /*&& $fileSyncRecord->getFileID() == '0_5qd29c65-1-9'*/)
		{
			if (array_key_exists($fileSyncRecord->getFileID(), $this->fileIDToFileSyncRecordsDictionary))
			{
				$fileSyncRecords = &$this->fileIDToFileSyncRecordsDictionary[$fileSyncRecord->getFileID()];
				foreach ($fileSyncRecords as $version=>$existingFileSyncRecord)
				{
					#echo "\n Main Record \n";
					#print_r($fileSyncRecord);
					#echo "\n Checked Record \n";
					#print_r($existingFileSyncRecord);
					if ($version < $fileSyncRecord->getVersion() && ($existingFileSyncRecord->getDeletedAt() == null || $existingFileSyncRecord->getDeletedAt() > $fileSyncRecord->getReadyAt()))
					{
						#echo "Checked < Main and (Checked DeletedAt = null or Checked DeletedAt > Main Ready At\n";
						$existingFileSyncRecord->setDeletedAt($fileSyncRecord->getReadyAt());
					}
					else if (($version >= $fileSyncRecord->getVersion()) && (($fileSyncRecord->getDeletedAt() > $existingFileSyncRecord->getReadyAt()) || ($fileSyncRecord->getDeletedAt() == null)))
					{
						#echo "Checked >= Main and (Main DeletedAt = null or Main DeletedAt > Checked Ready At\n";
						$fileSyncRecord->setDeletedAt($existingFileSyncRecord->getReadyAt());	
					}
					#echo "\n Main Record \n";
					#print_r($fileSyncRecord);
					#echo "\n Checked Record \n";
					#print_r($existingFileSyncRecord);
				}
				$fileSyncRecords[$fileSyncRecord->getVersion()]=$fileSyncRecord;	
			}
			else 
			{
				$fileSyncRecords = array();
				$fileSyncRecords[$fileSyncRecord->getVersion()]=$fileSyncRecord;
				$this->fileIDToFileSyncRecordsDictionary[$fileSyncRecord->getFileID()]=$fileSyncRecords; 
			}
		}	
	}

	public function getFileSyncRecords()
	{
		return $this->getFlattenedFileSyncRecords();
	}

	private function getFlattenedFileSyncRecords()
	{
		$flattenedRecords = array();
		foreach ($this->fileIDToFileSyncRecordsDictionary as $fileSyncRecords)
		{
			foreach ($fileSyncRecords as $fileSyncRecord)
			{
				$flattenedRecords[] = $fileSyncRecord;	
			}
		}
		return $flattenedRecords;
	}
}

?>
