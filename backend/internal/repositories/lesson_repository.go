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
