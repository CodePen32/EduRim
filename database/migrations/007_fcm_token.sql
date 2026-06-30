-- =============================================
-- Migration 007: FCM push token (MVP)
-- Adds a single FCM token column to users for Push Notifications.
-- One token per user (multi-device deferred to a later phase).
-- Safe: nullable column, no data loss, no changes to existing rows.
-- =============================================

ALTER TABLE users
    ADD COLUMN fcm_token VARCHAR(255) NULL AFTER updated_at;
