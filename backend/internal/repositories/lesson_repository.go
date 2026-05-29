package repositories

import (
	"database/sql"
	"edurim/backend/internal/models"
)

type LessonRepository struct {
	db *sql.DB
}

func NewLessonRepository(db *sql.DB) *LessonRepository {
	return &LessonRepository{db: db}
}

func (r *LessonRepository) GetAll() ([]models.Lesson, error) {
	return r.GetFiltered(0, 0, 0)
}

func (r *LessonRepository) GetFiltered(subjectID, teacherID, unitID int) ([]models.Lesson, error) {
	if r.db == nil {
		return nil, ErrNoDB
	}
	query := `SELECT id, COALESCE(unit_id,0), subject_id, COALESCE(teacher_id,0),
	                 title, COALESCE(description,''),
	                 COALESCE(video_url,''), COALESCE(summary_url,''),
	                 COALESCE(cover_image_url,''),
	                 duration_minutes, is_free, sort_order, created_at
	          FROM lessons WHERE 1=1`
	args := []interface{}{}
	if subjectID > 0 {
		query += " AND subject_id = ?"
		args = append(args, subjectID)
	}
	if teacherID > 0 {
		query += " AND teacher_id = ?"
		args = append(args, teacherID)
	}
	if unitID > 0 {
		query += " AND unit_id = ?"
		args = append(args, unitID)
	}
	query += " ORDER BY subject_id, sort_order, id"

	rows, err := r.db.Query(query, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var lessons []models.Lesson
	for rows.Next() {
		var l models.Lesson
		if err := rows.Scan(
			&l.ID, &l.UnitID, &l.SubjectID, &l.TeacherID,
			&l.Title, &l.Description, &l.VideoURL, &l.SummaryURL,
			&l.CoverImageURL,
			&l.DurationMinutes, &l.IsFree, &l.SortOrder, &l.CreatedAt,
		); err != nil {
			return nil, err
		}
		lessons = append(lessons, l)
	}
	return lessons, rows.Err()
}

// GetFilteredForUser returns lessons filtered by user's learning path and bac branch.
// For learning_path_id=3 (Bac), bacBranchID must also match.
func (r *LessonRepository) GetFilteredForUser(subjectID, teacherID, unitID, learningPathID, bacBranchID int) ([]models.Lesson, error) {
	if r.db == nil {
		return nil, ErrNoDB
	}
	query := `SELECT l.id, COALESCE(l.unit_id,0), l.subject_id, COALESCE(l.teacher_id,0),
	                 l.title, COALESCE(l.description,''),
	                 COALESCE(l.video_url,''), COALESCE(l.summary_url,''),
	                 COALESCE(l.cover_image_url,''),
	                 l.duration_minutes, l.is_free, l.sort_order, l.created_at
	          FROM lessons l
	          JOIN subjects s ON s.id = l.subject_id
	          WHERE s.learning_path_id = ?`
	args := []interface{}{learningPathID}
	if learningPathID == 3 && bacBranchID > 0 {
		query += " AND s.bac_branch_id = ?"
		args = append(args, bacBranchID)
	}
	if subjectID > 0 {
		query += " AND l.subject_id = ?"
		args = append(args, subjectID)
	}
	if teacherID > 0 {
		query += " AND l.teacher_id = ?"
		args = append(args, teacherID)
	}
	if unitID > 0 {
		query += " AND l.unit_id = ?"
		args = append(args, unitID)
	}
	query += " ORDER BY l.subject_id, l.sort_order, l.id"

	rows, err := r.db.Query(query, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var lessons []models.Lesson
	for rows.Next() {
		var l models.Lesson
		if err := rows.Scan(
			&l.ID, &l.UnitID, &l.SubjectID, &l.TeacherID,
			&l.Title, &l.Description, &l.VideoURL, &l.SummaryURL,
			&l.CoverImageURL,
			&l.DurationMinutes, &l.IsFree, &l.SortOrder, &l.CreatedAt,
		); err != nil {
			return nil, err
		}
		lessons = append(lessons, l)
	}
	return lessons, rows.Err()
}

// GetByIDForUser returns a lesson only if it belongs to the user's learning path/bac branch.
func (r *LessonRepository) GetByIDForUser(id, learningPathID, bacBranchID int) (*models.Lesson, error) {
	if r.db == nil {
		return nil, ErrNoDB
	}
	query := `SELECT l.id, COALESCE(l.unit_id,0), l.subject_id, COALESCE(l.teacher_id,0),
	                 l.title, COALESCE(l.description,''),
	                 COALESCE(l.video_url,''), COALESCE(l.summary_url,''),
	                 COALESCE(l.cover_image_url,''),
	                 l.duration_minutes, l.is_free, l.sort_order, l.created_at
	          FROM lessons l
	          JOIN subjects s ON s.id = l.subject_id
	          WHERE l.id = ? AND s.learning_path_id = ?`
	args := []interface{}{id, learningPathID}
	if learningPathID == 3 && bacBranchID > 0 {
		query += " AND s.bac_branch_id = ?"
		args = append(args, bacBranchID)
	}

	var l models.Lesson
	err := r.db.QueryRow(query, args...).Scan(
		&l.ID, &l.UnitID, &l.SubjectID, &l.TeacherID,
		&l.Title, &l.Description, &l.VideoURL, &l.SummaryURL,
		&l.CoverImageURL,
		&l.DurationMinutes, &l.IsFree, &l.SortOrder, &l.CreatedAt,
	)
	if err != nil {
		return nil, err
	}
	return &l, nil
}

func (r *LessonRepository) GetByID(id int) (*models.Lesson, error) {
	if r.db == nil {
		return nil, ErrNoDB
	}
	var l models.Lesson
	err := r.db.QueryRow(
		`SELECT id, COALESCE(unit_id,0), subject_id, COALESCE(teacher_id,0),
		        title, COALESCE(description,''),
		        COALESCE(video_url,''), COALESCE(summary_url,''),
		        COALESCE(cover_image_url,''),
		        duration_minutes, is_free, sort_order, created_at
		 FROM lessons WHERE id = ?`, id,
	).Scan(
		&l.ID, &l.UnitID, &l.SubjectID, &l.TeacherID,
		&l.Title, &l.Description, &l.VideoURL, &l.SummaryURL,
		&l.CoverImageURL,
		&l.DurationMinutes, &l.IsFree, &l.SortOrder, &l.CreatedAt,
	)
	if err != nil {
		return nil, err
	}
	return &l, nil
}
