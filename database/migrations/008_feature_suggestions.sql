-- =============================================
-- Migration 008: feature_suggestions
-- Stores students' development suggestions so admins can review them.
-- Safe: new table only, no changes to existing tables, no data loss.
-- =============================================

CREATE TABLE IF NOT EXISTS feature_suggestions (
    id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id     INT UNSIGNED NOT NULL,
    title       VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    status      ENUM('new', 'reviewing', 'done', 'rejected') NOT NULL DEFAULT 'new',
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_feature_suggestions_status (status),
    INDEX idx_feature_suggestions_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
