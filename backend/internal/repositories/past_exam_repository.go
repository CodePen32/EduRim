package repositories

import (
	"database/sql"
	"fmt"
)

type PastExam struct {
	ID              int     `json:"id"`
	LearningPathID  int     `json:"learning_path_id"`
	BacBranchID     *int    `json:"bac_branch_id"`
	SubjectID       int     `json:"subject_id"`
	SubjectName     string  `json:"subject_name"`
	Title           string  `json:"title"`
	Year            int     `json:"year"`
	Description     string  `json:"description"`
	ExamFileURL     string  `json:"exam_file_url"`
	SolutionFileURL string  `json:"solution_file_url"`
	CoverImageURL   string  `json:"cover_image_url"`
	IsActive        bool    `json:"is_active"`
}

type PastExamRepository struct {
	db *sql.DB
}

func NewPastExamRepository(db *sql.DB) *PastExamRepository {
	return &PastExamRepository{db: db}
}

type PastExamFilter struct {
	SubjectID      int
	LearningPathID int
	BacBranchID    int
	Year           int
	Limit          int
	Offset         int
}

func (r *PastExamRepository) GetFiltered(f PastExamFilter) ([]PastExam, error) {
	query := `SELECT pe.id, pe.learning_path_id, pe.bac_branch_id, pe.subject_id,
		COALESCE(s.name_ar,''), pe.title, pe.year, COALESCE(pe.description,''),
		COALESCE(pe.exam_file_url,''), COALESCE(pe.solution_file_url,''), COALESCE(pe.cover_image_url,''), pe.is_active
		FROM past_exams pe
		JOIN subjects s ON s.id = pe.subject_id
		WHERE pe.is_active = 1`
	args := []interface{}{}
	if f.SubjectID > 0 {
		query += " AND pe.subject_id = ?"
		args = append(args, f.SubjectID)
	}
	if f.LearningPathID > 0 {
		query += " AND pe.learning_path_id = ?"
		args = append(args, f.LearningPathID)
	}
	if f.BacBranchID > 0 {
		query += " AND pe.bac_branch_id = ?"
		args = append(args, f.BacBranchID)
	}
	if f.Year > 0 {
		query += " AND pe.year = ?"
		args = append(args, f.Year)
	}
	query += " ORDER BY pe.year DESC, pe.id DESC"
	if f.Limit > 0 {
		query += " LIMIT ? OFFSET ?"
		args = append(args, f.Limit, f.Offset)
	}

	rows, err := r.db.Query(query, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	return scanPastExams(rows)
}

// GetBySubjectForUser returns past exams for a subject, filtered by the user's LP and BAC.
func (r *PastExamRepository) GetBySubjectForUser(subjectID, learningPathID, bacBranchID, limit, offset int) ([]PastExam, error) {
	query := `SELECT pe.id, pe.learning_path_id, pe.bac_branch_id, pe.subject_id,
		COALESCE(s.name_ar,''), pe.title, pe.year, COALESCE(pe.description,''),
		COALESCE(pe.exam_file_url,''), COALESCE(pe.solution_file_url,''), COALESCE(pe.cover_image_url,''), pe.is_active
		FROM past_exams pe JOIN subjects s ON s.id = pe.subject_id
		WHERE pe.subject_id = ? AND pe.is_active = 1
		AND pe.learning_path_id = ?`
	args := []interface{}{subjectID, learningPathID}
	if learningPathID == 3 && bacBranchID > 0 {
		query += " AND (pe.bac_branch_id = ? OR pe.bac_branch_id IS NULL)"
		args = append(args, bacBranchID)
	}
	query += " ORDER BY pe.year DESC"
	if limit > 0 {
		query += " LIMIT ? OFFSET ?"
		args = append(args, limit, offset)
	}
	rows, err := r.db.Query(query, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	return scanPastExams(rows)
}

func (r *PastExamRepository) GetBySubject(subjectID, limit, offset int) ([]PastExam, error) {
	query := `SELECT pe.id, pe.learning_path_id, pe.bac_branch_id, pe.subject_id,
		COALESCE(s.name_ar,''), pe.title, pe.year, COALESCE(pe.description,''),
		COALESCE(pe.exam_file_url,''), COALESCE(pe.solution_file_url,''), COALESCE(pe.cover_image_url,''), pe.is_active
		FROM past_exams pe JOIN subjects s ON s.id = pe.subject_id
		WHERE pe.subject_id = ? AND pe.is_active = 1 ORDER BY pe.year DESC`
	args := []interface{}{subjectID}
	if limit > 0 {
		query += " LIMIT ? OFFSET ?"
		args = append(args, limit, offset)
	}
	rows, err := r.db.Query(query, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	return scanPastExams(rows)
}

func (r *PastExamRepository) GetByID(id int) (*PastExam, error) {
	row := r.db.QueryRow(`SELECT pe.id, pe.learning_path_id, pe.bac_branch_id, pe.subject_id,
		COALESCE(s.name_ar,''), pe.title, pe.year, COALESCE(pe.description,''),
		COALESCE(pe.exam_file_url,''), COALESCE(pe.solution_file_url,''), COALESCE(pe.cover_image_url,''), pe.is_active
		FROM past_exams pe JOIN subjects s ON s.id = pe.subject_id WHERE pe.id = ?`, id)
	exams, err := scanPastExams2(row)
	if err != nil {
		return nil, err
	}
	return exams, nil
}

func (r *PastExamRepository) Create(pe *PastExam) (int, error) {
	var bacID interface{} = nil
	if pe.BacBranchID != nil {
		bacID = *pe.BacBranchID
	}
	res, err := r.db.Exec(`INSERT INTO past_exams (learning_path_id, bac_branch_id, subject_id, title, year, description, exam_file_url, solution_file_url, cover_image_url, is_active)
		VALUES (?,?,?,?,?,?,?,?,?,1)`,
		pe.LearningPathID, bacID, pe.SubjectID, pe.Title, pe.Year, pe.Description, pe.ExamFileURL, pe.SolutionFileURL, pe.CoverImageURL)
	if err != nil {
		return 0, err
	}
	id, _ := res.LastInsertId()
	return int(id), nil
}

func (r *PastExamRepository) Update(id int, pe *PastExam) error {
	var bacID interface{} = nil
	if pe.BacBranchID != nil {
		bacID = *pe.BacBranchID
	}
	_, err := r.db.Exec(`UPDATE past_exams SET learning_path_id=?, bac_branch_id=?, subject_id=?, title=?, year=?, description=?, exam_file_url=?, solution_file_url=?, cover_image_url=?, is_active=? WHERE id=?`,
		pe.LearningPathID, bacID, pe.SubjectID, pe.Title, pe.Year, pe.Description, pe.ExamFileURL, pe.SolutionFileURL, pe.CoverImageURL, pe.IsActive, id)
	return err
}

func (r *PastExamRepository) Delete(id int) error {
	_, err := r.db.Exec(`UPDATE past_exams SET is_active=0 WHERE id=?`, id)
	return err
}

func scanPastExams(rows *sql.Rows) ([]PastExam, error) {
	var exams []PastExam
	for rows.Next() {
		var pe PastExam
		var bacID sql.NullInt64
		if err := rows.Scan(&pe.ID, &pe.LearningPathID, &bacID, &pe.SubjectID, &pe.SubjectName, &pe.Title, &pe.Year,
			&pe.Description, &pe.ExamFileURL, &pe.SolutionFileURL, &pe.CoverImageURL, &pe.IsActive); err != nil {
			return nil, err
		}
		if bacID.Valid {
			v := int(bacID.Int64)
			pe.BacBranchID = &v
		}
		exams = append(exams, pe)
	}
	return exams, rows.Err()
}

func scanPastExams2(row *sql.Row) (*PastExam, error) {
	var pe PastExam
	var bacID sql.NullInt64
	err := row.Scan(&pe.ID, &pe.LearningPathID, &bacID, &pe.SubjectID, &pe.SubjectName, &pe.Title, &pe.Year,
		&pe.Description, &pe.ExamFileURL, &pe.SolutionFileURL, &pe.CoverImageURL, &pe.IsActive)
	if err != nil {
		return nil, fmt.Errorf("past exam not found: %w", err)
	}
	if bacID.Valid {
		v := int(bacID.Int64)
		pe.BacBranchID = &v
	}
	return &pe, nil
}
