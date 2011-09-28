use kalturadw;

DROP PROCEDURE IF EXISTS load_tags;

DELIMITER $$

CREATE PROCEDURE load_tags()
BEGIN
    DECLARE v_id INT;
    DECLARE v_tags VARCHAR(256);
    DECLARE v_tag_name VARCHAR(256);
    DECLARE v_tag_id int;
    DECLARE v_tags_done INT;
    DECLARE v_tags_idx INT;
    DECLARE done INT DEFAULT 0;
    DECLARE assets CURSOR FOR
    SELECT id, tags 
    FROM dwh_dim_flavor_asset;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
    
    OPEN assets;
    
    read_loop: LOOP
        FETCH assets INTO v_id, v_tags;
        IF done THEN
			LEAVE read_loop;
		END IF;
        
        set v_tags_done = 0;       
        set v_tags_idx = 1;

          while not v_tags_done do

            set v_tag_name = substring(v_tags, v_tags_idx, 
            if(locate(',', v_tags, v_tags_idx) > 0, 
                locate(',', v_tags, v_tags_idx) - v_tags_idx, 
                length(v_tags)));

            set v_tag_name = trim(v_tag_name);

            if length(v_tag_name) > 0 then

                set v_tags_idx = v_tags_idx + length(v_tag_name) + 1;

                -- add the tag if it doesnt already exist
                insert ignore into dwh_dim_tags (tag_name) values (v_tag_name);

                select tag_id into v_tag_id from dwh_dim_falvor_asset_tag where tag_name = v_tag_name;

                -- add the flavor_asset tag
                insert ignore into dwh_dim_flavor_asset_tags (id, tag_id) values (v_id, v_tag_id);

            else
                set v_tags_done = 1;
            end if;

        end while;
        
        INSERT INTO dwh_dim_flavor_asset_tag;
    END LOOP;
END$$

DELIMITER;

CALL load_tags();

DROP PROCEDURE load_tags();