<?php

class FileSyncRecord
{
	private $id;
	private $objectID;
	private $objectType;
	private $objectSubType;
	private $partnerID;
	private $version;
	private $fileSize;
	private $readyAt;
	private $deletedAt;

	public function __construct($id, $objectID, $objectType, $objectSubType, $partnerID, $version, $fileSize, $readyAt, $deletedAt = null)
	{
		$this->id = $id;
		$this->objectID = $objectID;
		$this->objectType = $objectType;
		$this->objectSubType = $objectSubType;
		$this->partnerID = $partnerID;
		$this->version = $version;
		$this->fileSize = $fileSize;
		$this->readyAt = $readyAt;
		$this->deletedAt = $deletedAt;
	}

	public function getID()
	{
		return $this->id;
	}

	public function getObjectID()
        {
                return $this->objectID;
        }

	public function getObjectType()
        {
                return $this->objectType;
        }

	public function getObjectSubType()
        {
                return $this->objectSubType;
        }

	public function getPartnerID()
        {
                return $this->partnerID;
        }

	public function getFileSize()
	{
		return $this->fileSize;
	}	

	public function getVersion()
	{
		return $this->version;
	}

	public function getDeletedAt()
	{
		return $this->deletedAt;
	}

	public function getReadyAt()
        {
                return $this->readyAt;
        }
	
	public function setDeletedAt($deletedAt)
	{
		$this->deletedAt = $deletedAt;
	}

	public function getFileID()
	{
		return "$this->objectID-$this->objectType-$this->objectSubType";
	}
}

?>
