-- Edurim Seed Data
-- Run after schema.sql

SET NAMES utf8mb4;

-- =============================================
-- LEARNING PATHS
-- =============================================
INSERT INTO learning_paths (code, name_ar, name_fr, description) VALUES
('CONCOURS', 'كونكور', 'Concours', 'شهادة ختم الدروس الابتدائية'),
('BEPC', 'بيبيسي', 'BEPC', 'شهادة ختم الدروس الإعدادية'),
('BAC', 'باكالوريا', 'Baccalauréat', 'الباكالوريا - الشهادة الثانوية');

-- =============================================
-- BAC BRANCHES
-- =============================================
INSERT INTO bac_branches (code, name_ar, name_fr) VALUES
('C', 'شعبة الرياضيات', 'Bac C'),
('D', 'شعبة العلوم الطبيعية', 'Bac D'),
('A', 'شعبة الآداب العصرية', 'Bac A'),
('O', 'شعبة الآداب الأصلية', 'Bac O');

-- =============================================
-- SUBJECTS - CONCOURS (المسار: كونكور)
-- =============================================
INSERT INTO subjects (learning_path_id, bac_branch_id, name_ar, name_fr, icon, color, sort_order) VALUES
(1, NULL, 'الرياضيات', 'Mathématiques', '📐', '#1565C0', 1),
(1, NULL, 'اللغة العربية', 'Arabe', '📖', '#DC2626', 2),
(1, NULL, 'اللغة الفرنسية', 'Français', '🇫🇷', '#0284C7', 3),
(1, NULL, 'التربية الإسلامية', 'Éducation Islamique', '🕌', '#059669', 4),
(1, NULL, 'العلوم', 'Sciences', '🔬', '#7C3AED', 5),
(1, NULL, 'التاريخ والجغرافيا', 'Histoire-Géographie', '🏛️', '#F59E0B', 6);

-- =============================================
-- SUBJECTS - BEPC (المسار: بيبيسي)
-- =============================================
INSERT INTO subjects (learning_path_id, bac_branch_id, name_ar, name_fr, icon, color, sort_order) VALUES
(2, NULL, 'الرياضيات', 'Mathématiques', '📐', '#1565C0', 1),
(2, NULL, 'العلوم الطبيعية', 'Sciences Naturelles', '🔬', '#059669', 2),
(2, NULL, 'الفيزياء والكيمياء', 'Physique-Chimie', '⚗️', '#7C3AED', 3),
(2, NULL, 'اللغة العربية', 'Arabe', '📖', '#DC2626', 4),
(2, NULL, 'اللغة الفرنسية', 'Français', '🇫🇷', '#0284C7', 5),
(2, NULL, 'التربية الإسلامية', 'Éducation Islamique', '🕌', '#059669', 6),
(2, NULL, 'التاريخ والجغرافيا', 'Histoire-Géographie', '🏛️', '#F59E0B', 7);

-- =============================================
-- SUBJECTS - BAC C (الرياضيات)
-- =============================================
INSERT INTO subjects (learning_path_id, bac_branch_id, name_ar, name_fr, icon, color, sort_order) VALUES
(3, 1, 'الرياضيات', 'Mathématiques', '📐', '#1565C0', 1),
(3, 1, 'العلوم الطبيعية', 'Sciences Naturelles', '🔬', '#059669', 2),
(3, 1, 'الفيزياء والكيمياء', 'Physique-Chimie', '⚗️', '#7C3AED', 3),
(3, NULL, 'اللغة العربية', 'Arabe', '📖', '#DC2626', 4),
(3, NULL, 'اللغة الفرنسية', 'Français', '🇫🇷', '#0284C7', 5),
(3, NULL, 'التربية الإسلامية', 'Éducation Islamique', '🕌', '#34D399', 6),
(3, NULL, 'التاريخ والجغرافيا', 'Histoire-Géographie', '🏛️', '#F59E0B', 7);

-- =============================================
-- SUBJECTS - BAC D (العلوم الطبيعية)
-- =============================================
INSERT INTO subjects (learning_path_id, bac_branch_id, name_ar, name_fr, icon, color, sort_order) VALUES
(3, 2, 'العلوم الطبيعية', 'Sciences Naturelles', '🔬', '#059669', 1),
(3, 2, 'الرياضيات', 'Mathématiques', '📐', '#1565C0', 2),
(3, 2, 'الفيزياء والكيمياء', 'Physique-Chimie', '⚗️', '#7C3AED', 3);

-- =============================================
-- SUBJECTS - BAC A (الآداب العصرية)
-- =============================================
INSERT INTO subjects (learning_path_id, bac_branch_id, name_ar, name_fr, icon, color, sort_order) VALUES
(3, 3, 'الفلسفة', 'Philosophie', '🤔', '#6D28D9', 1),
(3, 3, 'التاريخ والجغرافيا', 'Histoire-Géographie', '🏛️', '#F59E0B', 2),
(3, 3, 'اللغة الفرنسية', 'Français', '🇫🇷', '#0284C7', 3);

-- =============================================
-- SUBJECTS - BAC O (الآداب الأصلية)
-- =============================================
INSERT INTO subjects (learning_path_id, bac_branch_id, name_ar, name_fr, icon, color, sort_order) VALUES
(3, 4, 'الفقه وأصوله', 'Fiqh', '🕌', '#059669', 1),
(3, 4, 'اللغة العربية', 'Arabe', '📖', '#DC2626', 2),
(3, 4, 'التوحيد', 'Tawhid', '📿', '#F59E0B', 3);

-- =============================================
-- TEACHERS
-- =============================================
INSERT INTO teachers (full_name, subject_id, avatar_url, bio) VALUES
('د. أحمد ولد محمد', 15, '', 'دكتور في الرياضيات، خبرة أكثر من 15 سنة في التدريس'),
('أ. فاطمة بنت أحمد', 16, '', 'أستاذة في العلوم الطبيعية، متخصصة في الأحياء الجزيئية'),
('أ. إبراهيم ولد سيدي', 17, '', 'أستاذ الفيزياء والكيمياء، حاصل على ماجستير في الفيزياء'),
('أ. مريم بنت عبدالله', 18, '', 'أستاذة اللغة العربية وآدابها'),
('أ. محمد ولد يحيى', 19, '', 'أستاذ اللغة الفرنسية وآدابها'),
('أ. خديجة بنت محمد', 21, '', 'أستاذة التاريخ والجغرافيا');

-- =============================================
-- UNITS
-- =============================================
INSERT INTO units (subject_id, teacher_id, title, description, sort_order) VALUES
(15, 1, 'الوحدة الأولى: المتتاليات', 'المتتاليات العددية بأنواعها', 1),
(15, 1, 'الوحدة الثانية: الاشتقاق', 'حساب التفاضل والتكامل', 2),
(15, 1, 'الوحدة الثالثة: التكامل', 'التكامل والمساحات', 3);

-- =============================================
-- LESSONS
-- =============================================
INSERT INTO lessons (unit_id, subject_id, teacher_id, title, description, video_url, summary_url, duration_minutes, is_free, sort_order) VALUES
(1, 15, 1, 'المتتاليات العددية - المفهوم والأنواع', 'تعريف المتتاليات وأنواعها الأساسية والتمييز بين المتتاليات المحدودة وغير المحدودة مع أمثلة تطبيقية', 'https://www.youtube.com/watch?v=dQw4w9WgXcQ', 'https://www.w3.org/WAI/WCAG21/Techniques/pdf/PDF1', 45, TRUE, 1),
(1, 15, 1, 'المتتاليات الحسابية', 'تعريف وخصائص المتتاليات الحسابية وحساب الحد العام والمجموع الجزئي', 'https://www.youtube.com/watch?v=dQw4w9WgXcQ', 'https://www.w3.org/WAI/WCAG21/Techniques/pdf/PDF2', 38, TRUE, 2),
(1, 15, 1, 'المتتاليات الهندسية', 'تعريف وخصائص المتتاليات الهندسية وحساب المجموع إلى ما لا نهاية', 'https://www.youtube.com/watch?v=dQw4w9WgXcQ', '', 42, FALSE, 3),
(1, 15, 1, 'حساب الحد العام للمتتاليات', 'طرق حساب الحد العام وتطبيقات على مسائل الباكالوريا', '', 'https://www.w3.org/WAI/WCAG21/Techniques/pdf/PDF3', 35, FALSE, 4),
(2, 15, 1, 'مفهوم الاشتقاق', 'التعريف الأساسي للاشتقاق ومفهوم المشتق وقواعد الاشتقاق الأساسية', 'https://www.youtube.com/watch?v=dQw4w9WgXcQ', 'https://www.w3.org/WAI/WCAG21/Techniques/pdf/PDF4', 50, FALSE, 1),
(3, 15, 1, 'مفهوم التكامل', 'مقدمة في التكامل وعلاقته بالاشتقاق وتطبيقات على حساب المساحات', 'https://www.youtube.com/watch?v=dQw4w9WgXcQ', '', 48, FALSE, 1);

-- =============================================
-- EXERCISES
-- =============================================
INSERT INTO exercises (subject_id, lesson_id, title, year, difficulty, exercise_file_url, solution_file_url, video_solution_url) VALUES
(15, NULL, 'تمرين المتتاليات - باك 2023', 2023, 'صعب', 'https://www.w3.org/WAI/WCAG21/Techniques/pdf/PDF1', 'https://www.w3.org/WAI/WCAG21/Techniques/pdf/PDF2', 'https://www.youtube.com/watch?v=dQw4w9WgXcQ'),
(15, NULL, 'تمرين الاشتقاق - باك 2022', 2022, 'متوسط', 'https://www.w3.org/WAI/WCAG21/Techniques/pdf/PDF3', 'https://www.w3.org/WAI/WCAG21/Techniques/pdf/PDF4', 'https://www.youtube.com/watch?v=dQw4w9WgXcQ'),
(15, NULL, 'تمرين التكامل - باك 2022', 2022, 'صعب', 'https://www.w3.org/WAI/WCAG21/Techniques/pdf/PDF1', '', ''),
(15, NULL, 'تمرين تطبيقي - المتتاليات', 2021, 'سهل', '', 'https://www.w3.org/WAI/WCAG21/Techniques/pdf/PDF2', ''),
(16, NULL, 'تمرين الخلية وأجهزتها - باك 2023', 2023, 'متوسط', 'https://www.w3.org/WAI/WCAG21/Techniques/pdf/PDF1', 'https://www.w3.org/WAI/WCAG21/Techniques/pdf/PDF2', 'https://www.youtube.com/watch?v=dQw4w9WgXcQ'),
(17, NULL, 'تمرين قوانين نيوتن - باك 2022', 2022, 'صعب', 'https://www.w3.org/WAI/WCAG21/Techniques/pdf/PDF1', '', '');

-- =============================================
-- SUBSCRIPTION PLANS
-- =============================================
INSERT INTO subscription_plans (name, price, duration_days, description, is_active) VALUES
('مجاني', 0.00, 36500, 'الوصول للدروس المجانية فقط', TRUE),
('شهري', 500.00, 30, 'وصول كامل لجميع المحتوى لمدة شهر', TRUE),
('فصلي', 1200.00, 90, 'وصول كامل لجميع المحتوى لمدة 3 أشهر', TRUE),
('سنوي', 3500.00, 365, 'وصول كامل لجميع المحتوى لمدة سنة كاملة', TRUE);

-- =============================================
-- GLOBAL NOTIFICATIONS
-- =============================================
INSERT INTO notifications (user_id, title, message, type, is_read) VALUES
(NULL, 'مرحباً بك في Edurim', 'انضم إلى آلاف الطلاب الموريتانيين واستعد لامتحاناتك بأفضل المحتويات', 'system', FALSE),
(NULL, 'دروس جديدة متاحة', 'تم إضافة دروس جديدة في مادة الرياضيات لباك C', 'lesson', FALSE);
