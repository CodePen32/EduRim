package repositories

import (
	"database/sql"
	"errors"
)

type Progress struct {
	ID                int    `json:"id"`
	UserID            int    `json:"user_id"`
	LessonID          int    `json:"lesson_id"`
	WatchedPercentage int    `json:"watched_percentage"`
	Completed         bool   `json:"completed"`
	UpdatedAt         string `json:"updated_at"`
}

type ProgressRepository struct {
	db *sql.DB
}

func NewProgressRepository(db *sql.DB) *ProgressRepository {
	return &ProgressRepository{db: db}
}

func (r *ProgressRepository) GetByUser(userID int) ([]Progress, error) {
	if r.db == nil {
		return nil, ErrNoDB
	}
	rows, err := r.db.Query(
		`SELECT id, user_id, lesson_id, watched_percentage, completed, updated_at FROM progress WHERE user_id = ? ORDER BY updated_at DESC`,
		userID,
	)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var list []Progress
	for rows.Next() {
		var p Progress
		var completed int
		if err := rows.Scan(&p.ID, &p.UserID, &p.LessonID, &p.WatchedPercentage, &completed, &p.UpdatedAt); err != nil {
			continue
		}
		p.Completed = completed == 1
		list = append(list, p)
	}
	return list, nil
}

func (r *ProgressRepository) GetLast(userID int) (*Progress, error) {
	if r.db == nil {
		return nil, ErrNoDB
	}
	row := r.db.QueryRow(
		`SELECT id, user_id, lesson_id, watched_percentage, completed, updated_at FROM progress WHERE user_id = ? ORDER BY updated_at DESC LIMIT 1`,
		userID,
	)
	var p Progress
	var completed int
	err := row.Scan(&p.ID, &p.UserID, &p.LessonID, &p.WatchedPercentage, &completed, &p.UpdatedAt)
	if errors.Is(err, sql.ErrNoRows) {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}
	p.Completed = completed == 1
	return &p, nil
}

type ProgressStats struct {
	CompletedLessons     int     `json:"completed_lessons"`
	TotalProgressRecords int     `json:"total_progress_records"`
	AveragePercentage    float64 `json:"average_percentage"`
	LastLessonTitle      string  `json:"last_lesson_title"`
}

func (r *ProgressRepository) GetStats(userID int) (*ProgressStats, error) {
	if r.db == nil {
		return nil, ErrNoDB
	}
	var stats ProgressStats
	err := r.db.QueryRow(
		`SELECT
		   COUNT(*) AS total,
		   SUM(CASE WHEN p.completed = 1 THEN 1 ELSE 0 END) AS completed,
		   COALESCE(AVG(p.watched_percentage), 0) AS avg_pct
		 FROM progress p WHERE p.user_id = ?`,
		userID,
	).Scan(&stats.TotalProgressRecords, &stats.CompletedLessons, &stats.AveragePercentage)
	if err != nil {
		return nil, err
	}

	// last lesson title
	row := r.db.QueryRow(
		`SELECT COALESCE(l.title, '') FROM progress p
		 LEFT JOIN lessons l ON l.id = p.lesson_id
		 WHERE p.user_id = ? ORDER BY p.updated_at DESC LIMIT 1`,
		userID,
	)
	row.Scan(&stats.LastLessonTitle)
	return &stats, nil
}

type SubjectProgress struct {
	SubjectID        int    `json:"subject_id"`
	SubjectName      string `json:"subject_name"`
	CompletedLessons int    `json:"completed_lessons"`
	TotalLessons     int    `json:"total_lessons"`
	Percentage       int    `json:"percentage"`
}

func (r *ProgressRepository) GetBySubject(userID int) ([]SubjectProgress, error) {
	if r.db == nil {
		return nil, ErrNoDB
	}
	rows, err := r.db.Query(
		`SELECT s.id, s.name_ar,
		   COUNT(DISTINCT CASE WHEN p.completed = 1 THEN l.id END) AS completed,
		   COUNT(DISTINCT l.id) AS total
		 FROM subjects s
		 LEFT JOIN lessons l ON l.subject_id = s.id
		 LEFT JOIN progress p ON p.lesson_id = l.id AND p.user_id = ?
		 GROUP BY s.id, s.name_ar
		 HAVING total > 0
		 ORDER BY s.id`,
		userID,
	)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var list []SubjectProgress
	for rows.Next() {
		var sp SubjectProgress
		if err := rows.Scan(&sp.SubjectID, &sp.SubjectName, &sp.CompletedLessons, &sp.TotalLessons); err != nil {
			continue
		}
		if sp.TotalLessons > 0 {
			sp.Percentage = sp.CompletedLessons * 100 / sp.TotalLessons
		}
		list = append(list, sp)
	}
	return list, nil
}

func (r *ProgressRepository) Upsert(userID, lessonID, watchedPercentage int, completed bool) error {
	if r.db == nil {
		return ErrNoDB
	}
	comp := 0
	if completed {
		comp = 1
	}
	_, err := r.db.Exec(
		`INSERT INTO progress (user_id, lesson_id, watched_percentage, completed)
		 VALUES (?, ?, ?, ?)
		 ON DUPLICATE KEY UPDATE watched_percentage = VALUES(watched_percentage), completed = VALUES(completed), updated_at = CURRENT_TIMESTAMP`,
		userID, lessonID, watchedPercentage, comp,
	)
	return err
}
