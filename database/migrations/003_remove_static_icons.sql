-- Migration 003: Remove dependency on static emoji icons
-- The icon column is kept in schema to avoid breaking existing data,
-- but all values are cleared so cover_image_url is the sole image source.

ALTER TABLE subjects MODIFY icon VARCHAR(100) NULL;
UPDATE subjects SET icon = NULL;
