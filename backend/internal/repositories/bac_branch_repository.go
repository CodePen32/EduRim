package repositories

import (
	"database/sql"

	"edurim/backend/internal/cache"
	"edurim/backend/internal/models"
)

type BacBranchRepository struct {
	db *sql.DB
}

func NewBacBranchRepository(db *sql.DB) *BacBranchRepository {
	return &BacBranchRepository{db: db}
}

const bacBranchesCacheKey = "all"

func (r *BacBranchRepository) GetAll() ([]models.BacBranch, error) {
	if v, ok := cache.BacBranches.Get(bacBranchesCacheKey); ok {
		return v.([]models.BacBranch), nil
	}

	if r.db == nil {
		return nil, ErrNoDB
	}
	rows, err := r.db.Query(
		`SELECT id, code, name_ar, name_fr FROM bac_branches ORDER BY id`,
	)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var branches []models.BacBranch
	for rows.Next() {
		var b models.BacBranch
		if err := rows.Scan(&b.ID, &b.Code, &b.NameAr, &b.NameFr); err != nil {
			return nil, err
		}
		branches = append(branches, b)
	}
	if err := rows.Err(); err != nil {
		return nil, err
	}

	cache.BacBranches.Set(bacBranchesCacheKey, branches)
	return branches, nil
}
