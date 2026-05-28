package repositories

import (
	"database/sql"
	"edurim/backend/internal/models"
)

type TeacherRepository struct {
	db *sql.DB
}

func NewTeacherRepository(db *sql.DB) *TeacherRepository {
	return &TeacherRepository{db: db}
}

func (r *TeacherRepository) GetAll() ([]models.Teacher, error) {
	return r.GetFiltered(0)
}

func (r *TeacherRepository) GetFiltered(subjectID int) ([]models.Teacher, error) {
	if r.db == nil {
		return nil, ErrNoDB
	}
	query := `SELECT id, full_name, COALESCE(subject_id,0),
	                 COALESCE(avatar_url,''), COALESCE(bio,''), created_at
	          FROM teachers WHERE 1=1`
	args := []interface{}{}
	if subjectID > 0 {
		query += " AND subject_id = ?"
		args = append(args, subjectID)
	}
	query += " ORDER BY id"

	rows, err := r.db.Query(query, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var teachers []models.Teacher
	for rows.Next() {
		var t models.Teacher
		if err := rows.Scan(
			&t.ID, &t.FullName, &t.SubjectID,
			&t.AvatarURL, &t.Bio, &t.CreatedAt,
		); err != nil {
			return nil, err
		}
		teachers = append(teachers, t)
	}
	return teachers, rows.Err()
}

func (r *TeacherRepository) GetByID(id int) (*models.Teacher, error) {
	if r.db == nil {
		return nil, ErrNoDB
	}
	var t models.Teacher
	err := r.db.QueryRow(
		`SELECT id, full_name, COALESCE(subject_id,0),
		        COALESCE(avatar_url,''), COALESCE(bio,''), created_at
		 FROM teachers WHERE id = ?`, id,
	).Scan(&t.ID, &t.FullName, &t.SubjectID, &t.AvatarURL, &t.Bio, &t.CreatedAt)
	if err != nil {
		return nil, err
	}
	return &t, nil
}
