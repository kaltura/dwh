USE kalturadw;

ALTER TABLE kalturadw.dwh_hourly_user_usage
ADD COLUMN deleted_storage_mb DECIMAL(19,4) DEFAULT 0 AFTER added_storage_mb,
ADD COLUMN deleted_entries INT(11) DEFAULT 0 AFTER added_entries,
ADD COLUMN deleted_msecs INT(11) DEFAULT 0 AFTER added_msecs;


