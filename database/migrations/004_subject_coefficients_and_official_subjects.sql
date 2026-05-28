-- Migration 004: subject_coefficients table + official subjects + calculator logic
SET NAMES utf8mb4;

-- =============================================
-- subject_coefficients table
-- =============================================
CREATE TABLE IF NOT EXISTS subject_coefficients (
    id               INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    learning_path_id INT UNSIGNED NOT NULL,
    bac_branch_id    INT UNSIGNED NULL,
    subject_id       INT UNSIGNED NOT NULL,
    coefficient      FLOAT NULL,
    max_mark         FLOAT NOT NULL DEFAULT 20,
    calculation_type ENUM('weighted_average','points') NOT NULL DEFAULT 'weighted_average',
    is_required      TINYINT(1) NOT NULL DEFAULT 1,
    sort_order       INT NOT NULL DEFAULT 0,
    FOREIGN KEY (learning_path_id) REFERENCES learning_paths(id) ON DELETE CASCADE,
    FOREIGN KEY (bac_branch_id)    REFERENCES bac_branches(id)   ON DELETE CASCADE,
    FOREIGN KEY (subject_id)       REFERENCES subjects(id)        ON DELETE CASCADE,
    UNIQUE KEY uq_coef (learning_path_id, bac_branch_id, subject_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- is_active column on users (if not exists from migration 002)
ALTER TABLE users MODIFY COLUMN gender ENUM('ذكر','أنثى') DEFAULT 'ذكر';
