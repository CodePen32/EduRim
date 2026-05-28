INSERT IGNORE INTO admins (full_name, email, password_hash, role, is_active) VALUES
('Super Admin', 'admin@edurim.local', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lheO', 'super_admin', 1);

INSERT IGNORE INTO past_exams (learning_path_id, bac_branch_id, subject_id, title, year, description, is_active) VALUES
(2, NULL, 7,  'موضوع البيبيسي - الرياضيات', 2023, 'موضوع امتحان البيبيسي في الرياضيات لسنة 2023', 1),
(2, NULL, 8,  'موضوع البيبيسي - العلوم الطبيعية', 2022, 'موضوع امتحان البيبيسي في العلوم الطبيعية لسنة 2022', 1),
(3, 2,    15, 'موضوع الباكالوريا د - العلوم الطبيعية', 2023, 'موضوع امتحان الباكالوريا شعبة العلوم الطبيعية 2023', 1),
(1, NULL, 1,  'موضوع الكونكور - الرياضيات', 2023, 'موضوع امتحان الكونكور في الرياضيات لسنة 2023', 1);
