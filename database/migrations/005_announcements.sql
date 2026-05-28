CREATE TABLE IF NOT EXISTS announcements (
    id                BIGINT        NOT NULL AUTO_INCREMENT,
    title             VARCHAR(255)  NOT NULL,
    message           TEXT          NULL,
    image_url         VARCHAR(500)  NULL,
    link_url          VARCHAR(500)  NULL,
    learning_path_id  BIGINT        NULL,
    bac_branch_id     BIGINT        NULL,
    is_active         BOOLEAN       NOT NULL DEFAULT TRUE,
    starts_at         DATETIME      NULL,
    ends_at           DATETIME      NULL,
    created_at        DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at        DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    INDEX idx_learning_path (learning_path_id),
    INDEX idx_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
