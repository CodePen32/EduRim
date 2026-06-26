package repositories

import (
	"database/sql"
	"errors"

	"edurim/backend/internal/cache"
	"edurim/backend/internal/models"
)

var ErrNoDB = errors.New("قاعدة البيانات غير متصلة")

type LearningPathRepository struct {
	db *sql.DB
}

func NewLearningPathRepository(db *sql.DB) *LearningPathRepository {
	return &LearningPathRepository{db: db}
}

const learningPathsCacheKey = "all"

func (r *LearningPathRepository) GetAll() ([]models.LearningPath, error) {
	if v, ok := cache.LearningPaths.Get(learningPathsCacheKey); ok {
		return v.([]models.LearningPath), nil
	}

	if r.db == nil {
		return nil, ErrNoDB
	}
	rows, err := r.db.Query(
		`SELECT id, code, name_ar, name_fr, COALESCE(description,''), created_at
		 FROM learning_paths ORDER BY id`,
	)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var paths []models.LearningPath
	for rows.Next() {
		var p models.LearningPath
		if err := rows.Scan(&p.ID, &p.Code, &p.NameAr, &p.NameFr, &p.Description, &p.CreatedAt); err != nil {
			return nil, err
		}
		paths = append(paths, p)
	}
	if err := rows.Err(); err != nil {
		return nil, err
	}

	cache.LearningPaths.Set(learningPathsCacheKey, paths)
	return paths, nil
}
