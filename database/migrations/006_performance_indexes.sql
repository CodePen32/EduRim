-- Migration 006: performance indexes for Phase 1 scaling (500-1000 concurrent users)
-- Adds indexes on foreign-key columns used as WHERE/JOIN filters in hot-path queries
-- (lessons, exercises, subjects, notifications, progress, downloads, user_subscriptions, past_exams).
-- No data is modified or deleted by this migration.
SET NAMES utf8mb4;

-- subjects — filtered by learning_path_id/bac_branch_id on every /subjects, /me/subjects,
-- and joined from lessons/exercises "for user" queries.
ALTER TABLE subjects
    ADD INDEX idx_subjects_learning_path (learning_path_id),
    ADD INDEX idx_subjects_bac_branch (bac_branch_id);

-- lessons — filtered by subject_id/teacher_id on /lessons, /me/lessons.
ALTER TABLE lessons
    ADD INDEX idx_lessons_subject (subject_id),
    ADD INDEX idx_lessons_teacher (teacher_id);

-- exercises — filtered by subject_id on /exercises, /me/exercises.
ALTER TABLE exercises
    ADD INDEX idx_exercises_subject (subject_id);

-- notifications — filtered by user_id on every /notifications and unread-count call.
ALTER TABLE notifications
    ADD INDEX idx_notifications_user (user_id);

-- progress — filtered by user_id on /progress and admin user stats.
ALTER TABLE progress
    ADD INDEX idx_progress_user (user_id);

-- downloads — filtered by user_id on /downloads.
ALTER TABLE downloads
    ADD INDEX idx_downloads_user (user_id);

-- user_subscriptions — filtered by user_id on every paid-content check (HasActiveSubscription).
ALTER TABLE user_subscriptions
    ADD INDEX idx_user_subscriptions_user (user_id);

-- past_exams — filtered by learning_path_id/bac_branch_id/subject_id on /past-exams, /me/past-exams.
ALTER TABLE past_exams
    ADD INDEX idx_past_exams_learning_path (learning_path_id),
    ADD INDEX idx_past_exams_bac_branch (bac_branch_id),
    ADD INDEX idx_past_exams_subject (subject_id);

-- users — filtered by learning_path_id/bac_branch_id indirectly (getUserLevel runs on every
-- protected /me/* request, and these columns are read on login/profile-update too).
ALTER TABLE users
    ADD INDEX idx_users_learning_path (learning_path_id),
    ADD INDEX idx_users_bac_branch (bac_branch_id);

-- announcements.learning_path_id and is_active are already indexed by migration 005
-- (idx_learning_path, idx_active) — no action needed here.
