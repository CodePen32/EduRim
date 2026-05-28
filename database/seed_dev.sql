-- seed_dev.sql
-- Development/testing data for Edurim.
-- Run AFTER seed_minimal.sql.
-- DO NOT use in production.

SET NAMES utf8mb4;

-- =============================================
-- SUBJECTS - CONCOURS
-- =============================================
INSERT INTO subjects (learning_path_id, bac_branch_id, name_ar, name_fr, icon, color, sort_order) VALUES
(1, NULL, 'الرياضيات', 'Mathématiques', NULL, '#1565C0', 1),
(1, NULL, 'اللغة العربية', 'Arabe', NULL, '#DC2626', 2),
(1, NULL, 'اللغة الفرنسية', 'Français', NULL, '#0284C7', 3),
(1, NULL, 'التربية الإسلامية', 'Éducation Islamique', NULL, '#059669', 4),
(1, NULL, 'العلوم', 'Sciences', NULL, '#7C3AED', 5),
(1, NULL, 'التاريخ والجغرافيا', 'Histoire-Géographie', NULL, '#F59E0B', 6);

-- =============================================
-- SUBJECTS - BEPC
-- =============================================
INSERT INTO subjects (learning_path_id, bac_branch_id, name_ar, name_fr, icon, color, sort_order) VALUES
(2, NULL, 'الرياضيات', 'Mathématiques', NULL, '#1565C0', 1),
(2, NULL, 'العلوم الطبيعية', 'Sciences Naturelles', NULL, '#059669', 2),
(2, NULL, 'الفيزياء والكيمياء', 'Physique-Chimie', NULL, '#7C3AED', 3),
(2, NULL, 'اللغة العربية', 'Arabe', NULL, '#DC2626', 4),
(2, NULL, 'اللغة الفرنسية', 'Français', NULL, '#0284C7', 5),
(2, NULL, 'التربية الإسلامية', 'Éducation Islamique', NULL, '#059669', 6),
(2, NULL, 'التاريخ والجغرافيا', 'Histoire-Géographie', NULL, '#F59E0B', 7);

-- =============================================
-- SUBJECTS - BAC C
-- =============================================
INSERT INTO subjects (learning_path_id, bac_branch_id, name_ar, name_fr, icon, color, sort_order) VALUES
(3, 1, 'الرياضيات', 'Mathématiques', NULL, '#1565C0', 1),
(3, 1, 'العلوم الطبيعية', 'Sciences Naturelles', NULL, '#059669', 2),
(3, 1, 'الفيزياء والكيمياء', 'Physique-Chimie', NULL, '#7C3AED', 3),
(3, NULL, 'اللغة العربية', 'Arabe', NULL, '#DC2626', 4),
(3, NULL, 'اللغة الفرنسية', 'Français', NULL, '#0284C7', 5),
(3, NULL, 'التربية الإسلامية', 'Éducation Islamique', NULL, '#34D399', 6),
(3, NULL, 'التاريخ والجغرافيا', 'Histoire-Géographie', NULL, '#F59E0B', 7);

-- =============================================
-- SUBJECTS - BAC D
-- =============================================
INSERT INTO subjects (learning_path_id, bac_branch_id, name_ar, name_fr, icon, color, sort_order) VALUES
(3, 2, 'العلوم الطبيعية', 'Sciences Naturelles', NULL, '#059669', 1),
(3, 2, 'الرياضيات', 'Mathématiques', NULL, '#1565C0', 2),
(3, 2, 'الفيزياء والكيمياء', 'Physique-Chimie', NULL, '#7C3AED', 3);

-- =============================================
-- SUBJECTS - BAC A
-- =============================================
INSERT INTO subjects (learning_path_id, bac_branch_id, name_ar, name_fr, icon, color, sort_order) VALUES
(3, 3, 'الفلسفة', 'Philosophie', NULL, '#6D28D9', 1),
(3, 3, 'التاريخ والجغرافيا', 'Histoire-Géographie', NULL, '#F59E0B', 2),
(3, 3, 'اللغة الفرنسية', 'Français', NULL, '#0284C7', 3);

-- =============================================
-- SUBJECTS - BAC O
-- =============================================
INSERT INTO subjects (learning_path_id, bac_branch_id, name_ar, name_fr, icon, color, sort_order) VALUES
(3, 4, 'الفقه وأصوله', 'Fiqh', NULL, '#059669', 1),
(3, 4, 'اللغة العربية', 'Arabe', NULL, '#DC2626', 2),
(3, 4, 'التوحيد', 'Tawhid', NULL, '#F59E0B', 3);

-- =============================================
-- TEACHERS (linked to BAC C subjects — IDs may vary, adjust as needed)
-- =============================================
INSERT INTO teachers (full_name, subject_id, avatar_url, bio) VALUES
('د. أحمد ولد محمد', 15, '', 'دكتور في الرياضيات، خبرة أكثر من 15 سنة في التدريس'),
('أ. فاطمة بنت أحمد', 16, '', 'أستاذة في العلوم الطبيعية'),
('أ. إبراهيم ولد سيدي', 17, '', 'أستاذ الفيزياء والكيمياء');

-- =============================================
-- UNITS & LESSONS (sample for BAC C math)
-- =============================================
INSERT INTO units (subject_id, teacher_id, title, description, sort_order) VALUES
(15, 1, 'الوحدة الأولى: المتتاليات', 'المتتاليات العددية بأنواعها', 1);

INSERT INTO lessons (unit_id, subject_id, teacher_id, title, description, video_url, summary_url, duration_minutes, is_free, sort_order) VALUES
(1, 15, 1, 'المتتاليات العددية - المفهوم والأنواع', 'تعريف المتتاليات وأنواعها', 'https://www.youtube.com/watch?v=dQw4w9WgXcQ', '', 45, TRUE, 1),
(1, 15, 1, 'المتتاليات الحسابية', 'خصائص المتتاليات الحسابية', 'https://www.youtube.com/watch?v=dQw4w9WgXcQ', '', 38, FALSE, 2);

-- =============================================
-- EXERCISES (sample)
-- =============================================
INSERT INTO exercises (subject_id, lesson_id, title, year, difficulty, exercise_file_url, solution_file_url, video_solution_url) VALUES
(15, NULL, 'تمرين المتتاليات - باك 2023', 2023, 'صعب', '', '', '');

-- =============================================
-- NOTIFICATIONS (sample global)
-- =============================================
INSERT INTO notifications (user_id, title, message, type, is_read) VALUES
(NULL, 'مرحباً بك في Edurim', 'انضم إلى الطلاب الموريتانيين واستعد لامتحاناتك بأفضل المحتويات', 'system', FALSE);
