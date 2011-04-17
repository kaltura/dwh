USE `kalturadw_ds`;

CREATE TABLE version_management (
	`version` INT(11),
	`filename` VARCHAR(250) DEFAULT NULL,
	`created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO version_management(VERSION) VALUES(5999);