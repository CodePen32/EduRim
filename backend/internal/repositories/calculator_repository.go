package repositories

import (
	"database/sql"
	"fmt"
)

type CalculatorSubject struct {
	SubjectID       int     `json:"subject_id"`
	SubjectName     string  `json:"subject_name"`
	Coefficient     float64 `json:"coefficient"`
	MaxMark         float64 `json:"max_mark"`
	CalculationType string  `json:"calculation_type"`
	IsRequired      bool    `json:"is_required"`
}

type CalculatorRepository struct {
	db *sql.DB
}

func NewCalculatorRepository(db *sql.DB) *CalculatorRepository {
	return &CalculatorRepository{db: db}
}

func (r *CalculatorRepository) GetSubjectsForUser(userID int) ([]CalculatorSubject, error) {
	var learningPathID int
	var bacBranchID sql.NullInt64
	err := r.db.QueryRow(`SELECT COALESCE(learning_path_id, 0), bac_branch_id FROM users WHERE id = ?`, userID).
		Scan(&learningPathID, &bacBranchID)
	if err != nil {
		return nil, fmt.Errorf("user not found: %w", err)
	}

	var rows *sql.Rows
	if bacBranchID.Valid {
		rows, err = r.db.Query(`
			SELECT s.id, s.name_ar, COALESCE(sc.coefficient,0), sc.max_mark, sc.calculation_type, sc.is_required
			FROM subject_coefficients sc
			JOIN subjects s ON s.id = sc.subject_id
			WHERE sc.learning_path_id = ? AND sc.bac_branch_id = ?
			ORDER BY sc.sort_order, s.id
		`, learningPathID, bacBranchID.Int64)
	} else {
		rows, err = r.db.Query(`
			SELECT s.id, s.name_ar, COALESCE(sc.coefficient,0), sc.max_mark, sc.calculation_type, sc.is_required
			FROM subject_coefficients sc
			JOIN subjects s ON s.id = sc.subject_id
			WHERE sc.learning_path_id = ? AND sc.bac_branch_id IS NULL
			ORDER BY sc.sort_order, s.id
		`, learningPathID)
	}
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var subjects []CalculatorSubject
	for rows.Next() {
		var cs CalculatorSubject
		if err := rows.Scan(&cs.SubjectID, &cs.SubjectName, &cs.Coefficient, &cs.MaxMark, &cs.CalculationType, &cs.IsRequired); err != nil {
			return nil, err
		}
		subjects = append(subjects, cs)
	}
	return subjects, rows.Err()
}
