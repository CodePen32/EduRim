-- seed_minimal.sql
-- Minimal data required to run Edurim in production.
-- Does NOT include subjects, lessons, exercises, teachers, or any demo content.
-- All educational content is added by the admin via the Admin Panel.

SET NAMES utf8mb4;

-- Learning Paths
INSERT INTO learning_paths (code, name_ar, name_fr, description) VALUES
('CONCOURS', 'كونكور', 'Concours', 'شهادة ختم الدروس الابتدائية'),
('BEPC', 'بيبيسي', 'BEPC', 'شهادة ختم الدروس الإعدادية'),
('BAC', 'باكالوريا', 'Baccalauréat', 'الباكالوريا - الشهادة الثانوية');

-- BAC Branches
INSERT INTO bac_branches (code, name_ar, name_fr) VALUES
('C', 'شعبة الرياضيات', 'Bac C'),
('D', 'شعبة العلوم الطبيعية', 'Bac D'),
('A', 'شعبة الآداب العصرية', 'Bac A'),
('O', 'شعبة الآداب الأصلية', 'Bac O');

-- Default Admin (password: admin12345 — change immediately after first login)
-- Hash generated with bcrypt cost=10
INSERT INTO admins (full_name, email, password_hash, role) VALUES
('Super Admin', 'admin@edurim.local', '$2a$10$MSiQYB1AARdZkHyW3sjFEebJaI4BnYVtnzqH5k9n0mXuS3EirYgMC', 'super_admin');
