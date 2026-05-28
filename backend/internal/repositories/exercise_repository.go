package repositories

import (
	"database/sql"
	"edurim/backend/internal/models"
)

type ExerciseRepository struct {
	db *sql.DB
}

func NewExerciseRepository(db *sql.DB) *ExerciseRepository {
	return &ExerciseRepository{db: db}
}

func (r *ExerciseRepository) GetAll() ([]models.Exercise, error) {
	return r.GetFiltered(0, 0, 0, "")
}

func (r *ExerciseRepository) GetFiltered(subjectID, lessonID, year int, difficulty string) ([]models.Exercise, error) {
	if r.db == nil {
		return nil, ErrNoDB
	}
	query := `SELECT id, subject_id, lesson_id,
	                 title, COALESCE(year,0), COALESCE(difficulty,'متوسط'),
	                 COALESCE(exercise_file_url,''), COALESCE(solution_file_url,''),
	                 COALESCE(video_solution_url,''), created_at
	          FROM exercises WHERE 1=1`
	args := []interface{}{}
	if subjectID > 0 {
		query += " AND subject_id = ?"
		args = append(args, subjectID)
	}
	if lessonID > 0 {
		query += " AND lesson_id = ?"
		args = append(args, lessonID)
	}
	if year > 0 {
		query += " AND year = ?"
		args = append(args, year)
	}
	if difficulty != "" {
		query += " AND difficulty = ?"
		args = append(args, difficulty)
	}
	query += " ORDER BY subject_id, year DESC, id"

	rows, err := r.db.Query(query, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var exercises []models.Exercise
	for rows.Next() {
		var e models.Exercise
		if err := rows.Scan(
			&e.ID, &e.SubjectID, &e.LessonID,
			&e.Title, &e.Year, &e.Difficulty,
			&e.ExerciseFileURL, &e.SolutionFileURL, &e.VideoSolutionURL,
			&e.CreatedAt,
		); err != nil {
			return nil, err
		}
		exercises = append(exercises, e)
	}
	return exercises, rows.Err()
}

func (r *ExerciseRepository) GetByID(id int) (*models.Exercise, error) {
	if r.db == nil {
		return nil, ErrNoDB
	}
	var e models.Exercise
	err := r.db.QueryRow(
		`SELECT id, subject_id, lesson_id,
		        title, COALESCE(year,0), COALESCE(difficulty,'متوسط'),
		        COALESCE(exercise_file_url,''), COALESCE(solution_file_url,''),
		        COALESCE(video_solution_url,''), created_at
		 FROM exercises WHERE id = ?`, id,
	).Scan(
		&e.ID, &e.SubjectID, &e.LessonID,
		&e.Title, &e.Year, &e.Difficulty,
		&e.ExerciseFileURL, &e.SolutionFileURL, &e.VideoSolutionURL,
		&e.CreatedAt,
	)
	if err != nil {
		return nil, err
	}
	return &e, nil
}
