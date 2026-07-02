-- Phase A1: allow admins to enable/disable which learning paths (Concours,
-- BEPC, Baccalauréat) are offered to new students in the onboarding screen.
-- Safe additive column with a default that preserves current behavior
-- (everything visible) until explicitly toggled.

ALTER TABLE learning_paths
  ADD COLUMN enabled BOOLEAN NOT NULL DEFAULT TRUE AFTER cover_image_url;

-- Requested defaults: only Concours is available at launch.
UPDATE learning_paths SET enabled = TRUE  WHERE code = 'CONCOURS';
UPDATE learning_paths SET enabled = FALSE WHERE code IN ('BEPC', 'BAC');
