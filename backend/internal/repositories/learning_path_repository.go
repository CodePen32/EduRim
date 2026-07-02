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
	// Public listing: only paths the admin has enabled are offered to new
	// students during onboarding. Existing users keep whatever path they
	// already have regardless of this flag (enforced elsewhere, not here).
	rows, err := r.db.Query(
		`SELECT id, code, name_ar, name_fr, COALESCE(description,''), created_at
		 FROM learning_paths WHERE enabled = 1 ORDER BY id`,
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

// GetAllForAdmin returns every learning path (enabled and disabled) for the
// admin panel's management screen. Never cached — admins need to always see
// the current state.
func (r *LearningPathRepository) GetAllForAdmin() ([]models.AdminLearningPath, error) {
	if r.db == nil {
		return nil, ErrNoDB
	}
	rows, err := r.db.Query(
		`SELECT id, code, name_ar, name_fr, COALESCE(description,''), enabled, created_at
		 FROM learning_paths ORDER BY id`,
	)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var paths []models.AdminLearningPath
	for rows.Next() {
		var p models.AdminLearningPath
		if err := rows.Scan(&p.ID, &p.Code, &p.NameAr, &p.NameFr, &p.Description, &p.Enabled, &p.CreatedAt); err != nil {
			return nil, err
		}
		paths = append(paths, p)
	}
	if err := rows.Err(); err != nil {
		return nil, err
	}
	return paths, nil
}

// SetEnabled updates whether a learning path is offered to new students.
// Does not touch users already assigned to it.
func (r *LearningPathRepository) SetEnabled(id int64, enabled bool) error {
	if r.db == nil {
		return ErrNoDB
	}
	_, err := r.db.Exec(`UPDATE learning_paths SET enabled = ? WHERE id = ?`, enabled, id)
	return err
}
