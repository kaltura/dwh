RENAME TABLE kalturadw.dwh_dim_api_error_codes TO kalturadw.dwh_dim_error_codes;

ALTER TABLE kalturadw.dwh_dim_error_codes
        CHANGE api_error_code_id error_code_id INT(11) AUTO_INCREMENT,
        CHANGE api_error_code_name error_code_name VARCHAR(165) NOT NULL,
        ADD sub_error_code_name VARCHAR(165) NOT NULL DEFAULT 'unknown' AFTER error_code_name,
        DROP KEY api_error_code_name,
        ADD UNIQUE KEY (error_code_name, sub_error_code_name);
