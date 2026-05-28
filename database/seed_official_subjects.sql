-- seed_official_subjects.sql
-- Official subjects and coefficients for Mauritanian curriculum.
-- Run AFTER seed_minimal.sql (learning_paths and bac_branches must exist).
-- Safe to re-run (uses INSERT IGNORE).
SET NAMES utf8mb4;

-- =============================================
-- CONCOURS SUBJECTS (learning_path_id=1)
-- =============================================
INSERT IGNORE INTO subjects (learning_path_id, bac_branch_id, name_ar, name_fr, color, sort_order) VALUES
(1, NULL, 'التربية الإسلامية',   'Éducation Islamique',  '#059669', 1),
(1, NULL, 'التاريخ والجغرافيا',  'Histoire-Géographie',  '#F59E0B', 2),
(1, NULL, 'التربية المدنية',     'Éducation Civique',    '#6D28D9', 3),
(1, NULL, 'اللغة العربية',       'Arabe',                '#DC2626', 4),
(1, NULL, 'Français',            'Français',             '#0284C7', 5),
(1, NULL, 'Sciences naturelles', 'Sciences Naturelles',  '#7C3AED', 6),
(1, NULL, 'mathématiques',       'Mathématiques',        '#1565C0', 7);

-- CONCOURS coefficients (calculation_type=points, max_mark varies)
INSERT IGNORE INTO subject_coefficients
    (learning_path_id, bac_branch_id, subject_id, coefficient, max_mark, calculation_type, is_required, sort_order)
SELECT 1, NULL, s.id,
    CASE s.name_ar
        WHEN 'التربية الإسلامية'   THEN NULL
        WHEN 'التاريخ والجغرافيا'  THEN NULL
        WHEN 'التربية المدنية'     THEN NULL
        WHEN 'اللغة العربية'       THEN NULL
        WHEN 'Français'            THEN NULL
        WHEN 'Sciences naturelles' THEN NULL
        WHEN 'mathématiques'       THEN NULL
    END,
    CASE s.name_ar
        WHEN 'التربية الإسلامية'   THEN 20
        WHEN 'التاريخ والجغرافيا'  THEN 20
        WHEN 'التربية المدنية'     THEN 10
        WHEN 'اللغة العربية'       THEN 50
        WHEN 'Français'            THEN 30
        WHEN 'Sciences naturelles' THEN 20
        WHEN 'mathématiques'       THEN 50
    END,
    'points', 1, s.sort_order
FROM subjects s WHERE s.learning_path_id = 1 AND s.bac_branch_id IS NULL;

-- =============================================
-- BEPC SUBJECTS (learning_path_id=2)
-- =============================================
INSERT IGNORE INTO subjects (learning_path_id, bac_branch_id, name_ar, name_fr, color, sort_order) VALUES
(2, NULL, 'التربية الإسلامية',   'Éducation Islamique',  '#059669', 1),
(2, NULL, 'التاريخ والجغرافيا',  'Histoire-Géographie',  '#F59E0B', 2),
(2, NULL, 'التربية المدنية',     'Éducation Civique',    '#6D28D9', 3),
(2, NULL, 'اللغة العربية',       'Arabe',                '#DC2626', 4),
(2, NULL, 'Français',            'Français',             '#0284C7', 5),
(2, NULL, 'Sciences naturelles', 'Sciences Naturelles',  '#7C3AED', 6),
(2, NULL, 'mathématiques',       'Mathématiques',        '#1565C0', 7),
(2, NULL, 'الرياضة البدنية',     'Éducation Physique',   '#0891B2', 8),
(2, NULL, 'Anglais',             'Anglais',              '#BE185D', 9),
(2, NULL, 'الفيزياء',            'Physique-Chimie',      '#EA580C', 10);

INSERT IGNORE INTO subject_coefficients
    (learning_path_id, bac_branch_id, subject_id, coefficient, max_mark, calculation_type, is_required, sort_order)
SELECT 2, NULL, s.id,
    CASE s.name_ar
        WHEN 'التربية الإسلامية'   THEN 3
        WHEN 'التاريخ والجغرافيا'  THEN 2
        WHEN 'التربية المدنية'     THEN 1
        WHEN 'اللغة العربية'       THEN 3
        WHEN 'Français'            THEN 3
        WHEN 'Sciences naturelles' THEN 2
        WHEN 'mathématiques'       THEN 5
        WHEN 'الرياضة البدنية'     THEN 1
        WHEN 'Anglais'             THEN 1
        WHEN 'الفيزياء'            THEN 2
    END,
    20, 'weighted_average', 1, s.sort_order
FROM subjects s WHERE s.learning_path_id = 2 AND s.bac_branch_id IS NULL;

-- =============================================
-- BAC D SUBJECTS (learning_path_id=3, bac_branch_id=2)
-- =============================================
INSERT IGNORE INTO subjects (learning_path_id, bac_branch_id, name_ar, name_fr, color, sort_order) VALUES
(3, 2, 'التربية الإسلامية',   'Éducation Islamique',  '#059669', 1),
(3, 2, 'اللغة العربية',       'Arabe',                '#DC2626', 2),
(3, 2, 'Français',            'Français',             '#0284C7', 3),
(3, 2, 'Sciences naturelles', 'Sciences Naturelles',  '#7C3AED', 4),
(3, 2, 'mathématiques',       'Mathématiques',        '#1565C0', 5),
(3, 2, 'الرياضة البدنية',     'Éducation Physique',   '#0891B2', 6),
(3, 2, 'Anglais',             'Anglais',              '#BE185D', 7),
(3, 2, 'الفيزياء',            'Physique-Chimie',      '#EA580C', 8);

INSERT IGNORE INTO subject_coefficients
    (learning_path_id, bac_branch_id, subject_id, coefficient, max_mark, calculation_type, is_required, sort_order)
SELECT 3, 2, s.id,
    CASE s.name_ar
        WHEN 'التربية الإسلامية'   THEN 2
        WHEN 'اللغة العربية'       THEN 3
        WHEN 'Français'            THEN 3
        WHEN 'Sciences naturelles' THEN 8
        WHEN 'mathématiques'       THEN 6
        WHEN 'الرياضة البدنية'     THEN 1
        WHEN 'Anglais'             THEN 2
        WHEN 'الفيزياء'            THEN 4
    END,
    20, 'weighted_average', 1, s.sort_order
FROM subjects s WHERE s.learning_path_id = 3 AND s.bac_branch_id = 2;

-- =============================================
-- BAC C SUBJECTS (learning_path_id=3, bac_branch_id=1)
-- =============================================
INSERT IGNORE INTO subjects (learning_path_id, bac_branch_id, name_ar, name_fr, color, sort_order) VALUES
(3, 1, 'التربية الإسلامية',   'Éducation Islamique',  '#059669', 1),
(3, 1, 'اللغة العربية',       'Arabe',                '#DC2626', 2),
(3, 1, 'Français',            'Français',             '#0284C7', 3),
(3, 1, 'Sciences naturelles', 'Sciences Naturelles',  '#7C3AED', 4),
(3, 1, 'mathématiques',       'Mathématiques',        '#1565C0', 5),
(3, 1, 'الرياضة البدنية',     'Éducation Physique',   '#0891B2', 6),
(3, 1, 'Anglais',             'Anglais',              '#BE185D', 7),
(3, 1, 'الفيزياء',            'Physique-Chimie',      '#EA580C', 8);

INSERT IGNORE INTO subject_coefficients
    (learning_path_id, bac_branch_id, subject_id, coefficient, max_mark, calculation_type, is_required, sort_order)
SELECT 3, 1, s.id,
    CASE s.name_ar
        WHEN 'التربية الإسلامية'   THEN 2
        WHEN 'اللغة العربية'       THEN 3
        WHEN 'Français'            THEN 3
        WHEN 'Sciences naturelles' THEN 4
        WHEN 'mathématiques'       THEN 9
        WHEN 'الرياضة البدنية'     THEN 1
        WHEN 'Anglais'             THEN 2
        WHEN 'الفيزياء'            THEN 8
    END,
    20, 'weighted_average', 1, s.sort_order
FROM subjects s WHERE s.learning_path_id = 3 AND s.bac_branch_id = 1;
