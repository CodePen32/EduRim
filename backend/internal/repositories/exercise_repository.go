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

// GetFilteredForUser returns exercises filtered by user's learning path and bac branch.
func (r *ExerciseRepository) GetFilteredForUser(subjectID, lessonID, year int, difficulty string, learningPathID, bacBranchID int) ([]models.Exercise, error) {
	if r.db == nil {
		return nil, ErrNoDB
	}
	query := `SELECT e.id, e.subject_id, e.lesson_id,
	                 e.title, COALESCE(e.year,0), COALESCE(e.difficulty,'متوسط'),
	                 COALESCE(e.exercise_file_url,''), COALESCE(e.solution_file_url,''),
	                 COALESCE(e.video_solution_url,''), e.created_at
	          FROM exercises e
	          JOIN subjects s ON s.id = e.subject_id
	          WHERE s.learning_path_id = ?`
	args := []interface{}{learningPathID}
	if learningPathID == 3 && bacBranchID > 0 {
		query += " AND s.bac_branch_id = ?"
		args = append(args, bacBranchID)
	}
	if subjectID > 0 {
		query += " AND e.subject_id = ?"
		args = append(args, subjectID)
	}
	if lessonID > 0 {
		query += " AND e.lesson_id = ?"
		args = append(args, lessonID)
	}
	if year > 0 {
		query += " AND e.year = ?"
		args = append(args, year)
	}
	if difficulty != "" {
		query += " AND e.difficulty = ?"
		args = append(args, difficulty)
	}
	query += " ORDER BY e.subject_id, e.year DESC, e.id"

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

// GetByIDForUser returns an exercise only if it belongs to the user's level.
func (r *ExerciseRepository) GetByIDForUser(id, learningPathID, bacBranchID int) (*models.Exercise, error) {
	if r.db == nil {
		return nil, ErrNoDB
	}
	query := `SELECT e.id, e.subject_id, e.lesson_id,
	                 e.title, COALESCE(e.year,0), COALESCE(e.difficulty,'متوسط'),
	                 COALESCE(e.exercise_file_url,''), COALESCE(e.solution_file_url,''),
	                 COALESCE(e.video_solution_url,''), e.created_at
	          FROM exercises e
	          JOIN subjects s ON s.id = e.subject_id
	          WHERE e.id = ? AND s.learning_path_id = ?`
	args := []interface{}{id, learningPathID}
	if learningPathID == 3 && bacBranchID > 0 {
		query += " AND s.bac_branch_id = ?"
		args = append(args, bacBranchID)
	}

	var e models.Exercise
	err := r.db.QueryRow(query, args...).Scan(
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
