USE `kalturadw`;

CREATE TABLE kalturadw.`dwh_hourly_events_entry` (
  `partner_id` INT DEFAULT NULL,
  `date_id` INT DEFAULT NULL,
  `hour_id` INT DEFAULT NULL,
  `entry_id` VARCHAR(20) DEFAULT NULL,
  `sum_time_viewed` DECIMAL(20,3) DEFAULT NULL,
  `count_time_viewed` INT DEFAULT NULL,
  `count_plays` INT DEFAULT NULL,
  `count_loads` INT DEFAULT NULL,
  `count_plays_25` INT DEFAULT NULL,
  `count_plays_50` INT DEFAULT NULL,
  `count_plays_75` INT DEFAULT NULL,
  `count_plays_100` INT DEFAULT NULL,
  `count_edit` INT DEFAULT NULL,
  `count_viral` INT DEFAULT NULL,
  `count_download` INT DEFAULT NULL,
  `count_report` INT DEFAULT NULL,
  `count_buf_start` INT DEFAULT NULL,
  `count_buf_end` INT DEFAULT NULL,
  `count_open_full_screen` INT DEFAULT NULL,
  `count_close_full_screen` INT DEFAULT NULL,
  `count_replay` INT DEFAULT NULL,
  `count_seek` INT DEFAULT NULL,
  `count_open_upload` INT DEFAULT NULL,
  `count_save_publish` INT DEFAULT NULL,
  `count_close_editor` INT DEFAULT NULL,    
  `count_pre_bumper_played` INT DEFAULT NULL,
  `count_post_bumper_played` INT DEFAULT NULL,
  `count_bumper_clicked` INT DEFAULT NULL,
  `count_preroll_started` INT DEFAULT NULL,
  `count_midroll_started` INT DEFAULT NULL,
  `count_postroll_started` INT DEFAULT NULL,
  `count_overlay_started` INT DEFAULT NULL,
  `count_preroll_clicked` INT DEFAULT NULL,
  `count_midroll_clicked` INT DEFAULT NULL,
  `count_postroll_clicked` INT DEFAULT NULL,
  `count_overlay_clicked` INT DEFAULT NULL,
  `count_preroll_25` INT DEFAULT NULL,
  `count_preroll_50` INT DEFAULT NULL,
  `count_preroll_75` INT DEFAULT NULL,
  `count_midroll_25` INT DEFAULT NULL,
  `count_midroll_50` INT DEFAULT NULL,
  `count_midroll_75` INT DEFAULT NULL,
  `count_postroll_25` INT DEFAULT NULL,
  `count_postroll_50` INT DEFAULT NULL,
  `count_postroll_75` INT DEFAULT NULL,
  PRIMARY KEY `partner_id` (`partner_id`,`date_id`,`hour_id`,`entry_id`),
  KEY `entry_id` (`entry_id`)
) ENGINE=MYISAM DEFAULT CHARSET=utf8
PARTITION BY RANGE (date_id)
(PARTITION p_201001 VALUES LESS THAN (20100201) ENGINE = MYISAM,
 PARTITION p_201002 VALUES LESS THAN (20100301) ENGINE = MYISAM,
 PARTITION p_201003 VALUES LESS THAN (20100401) ENGINE = MYISAM,
 PARTITION p_201004 VALUES LESS THAN (20100501) ENGINE = MYISAM,
 PARTITION p_201005 VALUES LESS THAN (20100601) ENGINE = MYISAM,
 PARTITION p_201006 VALUES LESS THAN (20100701) ENGINE = MYISAM,
 PARTITION p_201007 VALUES LESS THAN (20100801) ENGINE = MYISAM,
 PARTITION p_201008 VALUES LESS THAN (20100901) ENGINE = MYISAM,
 PARTITION p_201009 VALUES LESS THAN (20101001) ENGINE = MYISAM,
 PARTITION p_201010 VALUES LESS THAN (20101101) ENGINE = MYISAM,
 PARTITION p_201011 VALUES LESS THAN (20101201) ENGINE = MYISAM);