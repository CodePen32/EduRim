-- Migration 002: Admin Users Management
-- Adds is_active column to users table for account management

ALTER TABLE users ADD COLUMN IF NOT EXISTS is_active TINYINT(1) NOT NULL DEFAULT 1;
UPDATE users SET is_active = 1 WHERE is_active IS NULL;
