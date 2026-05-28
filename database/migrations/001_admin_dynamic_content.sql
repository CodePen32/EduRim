-- Add cover_image_url to existing tables (safe via procedure)
DROP PROCEDURE IF EXISTS add_column_if_not_exists;
DELIMITER $$
CREATE PROCEDURE add_column_if_not_exists(IN tbl VARCHAR(64), IN col VARCHAR(64), IN col_def VARCHAR(500))
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = tbl AND COLUMN_NAME = col
  ) THEN
    SET @sql = CONCAT('ALTER TABLE `', tbl, '` ADD COLUMN `', col, '` ', col_def);
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
  END IF;
END$$
DELIMITER ;

CALL add_column_if_not_exists('learning_paths', 'cover_image_url', 'VARCHAR(500) NULL');
CALL add_column_if_not_exists('subjects', 'cover_image_url', 'VARCHAR(500) NULL');
CALL add_column_if_not_exists('teachers', 'cover_image_url', 'VARCHAR(500) NULL');
CALL add_column_if_not_exists('lessons', 'cover_image_url', 'VARCHAR(500) NULL');
CALL add_column_if_not_exists('exercises', 'cover_image_url', 'VARCHAR(500) NULL');

DROP PROCEDURE IF EXISTS add_column_if_not_exists;

-- admins table
CREATE TABLE IF NOT EXISTS admins (
  id INT AUTO_INCREMENT PRIMARY KEY,
  full_name VARCHAR(255) NOT NULL,
  email VARCHAR(255) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  role ENUM('super_admin','content_manager') NOT NULL DEFAULT 'content_manager',
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- past_exams table
CREATE TABLE IF NOT EXISTS past_exams (
  id INT AUTO_INCREMENT PRIMARY KEY,
  learning_path_id INT NOT NULL,
  bac_branch_id INT NULL,
  subject_id INT NOT NULL,
  title VARCHAR(500) NOT NULL,
  year INT NOT NULL,
  description TEXT NULL,
  exam_file_url VARCHAR(500) NULL,
  solution_file_url VARCHAR(500) NULL,
  cover_image_url VARCHAR(500) NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (learning_path_id) REFERENCES learning_paths(id),
  FOREIGN KEY (subject_id) REFERENCES subjects(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
