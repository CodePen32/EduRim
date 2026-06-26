package repositories

import (
	"database/sql"
	"strconv"

	"edurim/backend/internal/cache"
	"edurim/backend/internal/models"
)

type SubjectRepository struct {
	db *sql.DB
}

func NewSubjectRepository(db *sql.DB) *SubjectRepository {
	return &SubjectRepository{db: db}
}

func subjectsCacheKey(learningPathID, bacBranchID int) string {
	return strconv.Itoa(learningPathID) + ":" + strconv.Itoa(bacBranchID)
}

func (r *SubjectRepository) GetAll(learningPathID, bacBranchID int) ([]models.Subject, error) {
	key := subjectsCacheKey(learningPathID, bacBranchID)
	if v, ok := cache.Subjects.Get(key); ok {
		return v.([]models.Subject), nil
	}

	if r.db == nil {
		return nil, ErrNoDB
	}
	query := `SELECT s.id, s.learning_path_id, s.bac_branch_id, s.name_ar, s.name_fr,
	           COALESCE(s.icon,''), COALESCE(s.color,'#1565C0'), s.sort_order, COALESCE(s.cover_image_url,''),
	           COUNT(l.id) AS lessons_count
	          FROM subjects s
	          LEFT JOIN lessons l ON l.subject_id = s.id
	          WHERE 1=1`
	args := []interface{}{}

	if learningPathID > 0 {
		query += " AND s.learning_path_id = ?"
		args = append(args, learningPathID)
	}
	if bacBranchID > 0 {
		query += " AND s.bac_branch_id = ?"
		args = append(args, bacBranchID)
	}
	query += " GROUP BY s.id ORDER BY s.sort_order, s.id"

	rows, err := r.db.Query(query, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var subjects []models.Subject
	for rows.Next() {
		var s models.Subject
		if err := rows.Scan(
			&s.ID, &s.LearningPathID, &s.BacBranchID,
			&s.NameAr, &s.NameFr, &s.Icon, &s.Color, &s.SortOrder, &s.CoverImageURL,
			&s.LessonsCount,
		); err != nil {
			return nil, err
		}
		subjects = append(subjects, s)
	}
	if err := rows.Err(); err != nil {
		return nil, err
	}

	cache.Subjects.Set(key, subjects)
	return subjects, nil
}

func (r *SubjectRepository) GetByID(id int) (*models.Subject, error) {
	if r.db == nil {
		return nil, ErrNoDB
	}
	var s models.Subject
	err := r.db.QueryRow(
		`SELECT s.id, s.learning_path_id, s.bac_branch_id, s.name_ar, s.name_fr,
		        COALESCE(s.icon,''), COALESCE(s.color,'#1565C0'), s.sort_order, COALESCE(s.cover_image_url,''),
		        COUNT(l.id) AS lessons_count
		 FROM subjects s
		 LEFT JOIN lessons l ON l.subject_id = s.id
		 WHERE s.id = ?
		 GROUP BY s.id`, id,
	).Scan(&s.ID, &s.LearningPathID, &s.BacBranchID,
		&s.NameAr, &s.NameFr, &s.Icon, &s.Color, &s.SortOrder, &s.CoverImageURL,
		&s.LessonsCount)
	if err != nil {
		return nil, err
	}
	return &s, nil
}
