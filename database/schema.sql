-- Edurim Database Schema
-- Character Set: utf8mb4 (supports Arabic and all Unicode)

SET NAMES utf8mb4;
SET CHARACTER SET utf8mb4;

-- =============================================
-- LEARNING PATHS (المسارات الدراسية)
-- =============================================
CREATE TABLE IF NOT EXISTS learning_paths (
    id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    code        VARCHAR(20) NOT NULL UNIQUE,
    name_ar     VARCHAR(100) NOT NULL,
    name_fr     VARCHAR(100) NOT NULL,
    description TEXT,
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- BAC BRANCHES (شعب الباكالوريا)
-- =============================================
CREATE TABLE IF NOT EXISTS bac_branches (
    id      INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    code    VARCHAR(5) NOT NULL UNIQUE,
    name_ar VARCHAR(100) NOT NULL,
    name_fr VARCHAR(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- USERS (المستخدمون)
-- =============================================
CREATE TABLE IF NOT EXISTS users (
    id                  INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    full_name           VARCHAR(150) NOT NULL,
    email               VARCHAR(150) NOT NULL UNIQUE,
    phone               VARCHAR(20),
    password_hash       VARCHAR(255) NOT NULL,
    learning_path_id    INT UNSIGNED,
    bac_branch_id       INT UNSIGNED,
    city                VARCHAR(100),
    gender              ENUM('ذكر', 'أنثى') DEFAULT 'ذكر',
    created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (learning_path_id) REFERENCES learning_paths(id) ON DELETE SET NULL,
    FOREIGN KEY (bac_branch_id) REFERENCES bac_branches(id) ON DELETE SET NULL,
    INDEX idx_users_learning_path (learning_path_id),
    INDEX idx_users_bac_branch (bac_branch_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- SUBJECTS (المواد الدراسية)
-- =============================================
CREATE TABLE IF NOT EXISTS subjects (
    id                  INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    learning_path_id    INT UNSIGNED NOT NULL,
    bac_branch_id       INT UNSIGNED,
    name_ar             VARCHAR(100) NOT NULL,
    name_fr             VARCHAR(100) NOT NULL,
    icon                VARCHAR(10) DEFAULT '📚',
    color               VARCHAR(20) DEFAULT '#1565C0',
    sort_order          INT DEFAULT 0,
    FOREIGN KEY (learning_path_id) REFERENCES learning_paths(id) ON DELETE CASCADE,
    FOREIGN KEY (bac_branch_id) REFERENCES bac_branches(id) ON DELETE SET NULL,
    INDEX idx_subjects_learning_path (learning_path_id),
    INDEX idx_subjects_bac_branch (bac_branch_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- TEACHERS (الأساتذة)
-- =============================================
CREATE TABLE IF NOT EXISTS teachers (
    id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    full_name   VARCHAR(150) NOT NULL,
    subject_id  INT UNSIGNED,
    avatar_url  VARCHAR(255),
    bio         TEXT,
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (subject_id) REFERENCES subjects(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- UNITS (الوحدات)
-- =============================================
CREATE TABLE IF NOT EXISTS units (
    id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    subject_id  INT UNSIGNED NOT NULL,
    teacher_id  INT UNSIGNED,
    title       VARCHAR(200) NOT NULL,
    description TEXT,
    sort_order  INT DEFAULT 0,
    FOREIGN KEY (subject_id) REFERENCES subjects(id) ON DELETE CASCADE,
    FOREIGN KEY (teacher_id) REFERENCES teachers(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- LESSONS (الدروس)
-- =============================================
CREATE TABLE IF NOT EXISTS lessons (
    id                  INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    unit_id             INT UNSIGNED,
    subject_id          INT UNSIGNED NOT NULL,
    teacher_id          INT UNSIGNED,
    title               VARCHAR(250) NOT NULL,
    description         TEXT,
    video_url           VARCHAR(500),
    summary_url         VARCHAR(500),
    duration_minutes    INT DEFAULT 0,
    is_free             BOOLEAN DEFAULT FALSE,
    sort_order          INT DEFAULT 0,
    created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (unit_id) REFERENCES units(id) ON DELETE SET NULL,
    FOREIGN KEY (subject_id) REFERENCES subjects(id) ON DELETE CASCADE,
    FOREIGN KEY (teacher_id) REFERENCES teachers(id) ON DELETE SET NULL,
    INDEX idx_lessons_subject (subject_id),
    INDEX idx_lessons_teacher (teacher_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- EXERCISES (التمارين)
-- =============================================
CREATE TABLE IF NOT EXISTS exercises (
    id                  INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    subject_id          INT UNSIGNED NOT NULL,
    lesson_id           INT UNSIGNED,
    title               VARCHAR(250) NOT NULL,
    year                INT,
    difficulty          ENUM('سهل', 'متوسط', 'صعب') DEFAULT 'متوسط',
    exercise_file_url   VARCHAR(500),
    solution_file_url   VARCHAR(500),
    video_solution_url  VARCHAR(500),
    created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (subject_id) REFERENCES subjects(id) ON DELETE CASCADE,
    FOREIGN KEY (lesson_id) REFERENCES lessons(id) ON DELETE SET NULL,
    INDEX idx_exercises_subject (subject_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- FAVORITES (المفضلة)
-- =============================================
CREATE TABLE IF NOT EXISTS favorites (
    id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id     INT UNSIGNED NOT NULL,
    item_type   ENUM('lesson', 'exercise') NOT NULL,
    item_id     INT UNSIGNED NOT NULL,
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY unique_favorite (user_id, item_type, item_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- DOWNLOADS (التنزيلات)
-- =============================================
CREATE TABLE IF NOT EXISTS downloads (
    id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id     INT UNSIGNED NOT NULL,
    item_type   ENUM('lesson', 'exercise', 'summary') NOT NULL,
    item_id     INT UNSIGNED NOT NULL,
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_downloads_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- PROGRESS (التقدم)
-- =============================================
CREATE TABLE IF NOT EXISTS progress (
    id                  INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id             INT UNSIGNED NOT NULL,
    lesson_id           INT UNSIGNED NOT NULL,
    watched_percentage  INT DEFAULT 0,
    completed           BOOLEAN DEFAULT FALSE,
    updated_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY unique_progress (user_id, lesson_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (lesson_id) REFERENCES lessons(id) ON DELETE CASCADE,
    INDEX idx_progress_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- NOTIFICATIONS (الإشعارات)
-- =============================================
CREATE TABLE IF NOT EXISTS notifications (
    id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id     INT UNSIGNED,
    title       VARCHAR(200) NOT NULL,
    message     TEXT NOT NULL,
    type        ENUM('info', 'lesson', 'exercise', 'system') DEFAULT 'info',
    is_read     BOOLEAN DEFAULT FALSE,
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_notifications_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- SUBSCRIPTION PLANS (خطط الاشتراك)
-- =============================================
CREATE TABLE IF NOT EXISTS subscription_plans (
    id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name            VARCHAR(100) NOT NULL,
    price           DECIMAL(10, 2) NOT NULL,
    duration_days   INT NOT NULL,
    description     TEXT,
    is_active       BOOLEAN DEFAULT TRUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- USER SUBSCRIPTIONS (اشتراكات المستخدمين)
-- =============================================
CREATE TABLE IF NOT EXISTS user_subscriptions (
    id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id     INT UNSIGNED NOT NULL,
    plan_id     INT UNSIGNED NOT NULL,
    start_date  DATE NOT NULL,
    end_date    DATE NOT NULL,
    status      ENUM('active', 'expired', 'cancelled') DEFAULT 'active',
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (plan_id) REFERENCES subscription_plans(id),
    INDEX idx_user_subscriptions_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
