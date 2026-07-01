package repositories

import "database/sql"

type FeatureSuggestion struct {
	ID             int    `json:"id"`
	UserID         int    `json:"user_id"`
	Title          string `json:"title"`
	Description    string `json:"description"`
	Status         string `json:"status"`
	CreatedAt      string `json:"created_at"`
	UserFullName   string `json:"user_full_name"`
	UserPhone      string `json:"user_phone"`
	UserEmail      string `json:"user_email"`
	LearningPathID *int   `json:"learning_path_id"`
	BacBranchID    *int   `json:"bac_branch_id"`
}

type SuggestionRepository struct {
	db *sql.DB
}

func NewSuggestionRepository(db *sql.DB) *SuggestionRepository {
	return &SuggestionRepository{db: db}
}

// Create inserts a new suggestion for the given user.
func (r *SuggestionRepository) Create(userID int, title, description string) error {
	if r.db == nil {
		return ErrNoDB
	}
	_, err := r.db.Exec(
		`INSERT INTO feature_suggestions (user_id, title, description) VALUES (?, ?, ?)`,
		userID, title, description,
	)
	return err
}

// GetAll returns all suggestions (newest first) with student info. Admin use.
func (r *SuggestionRepository) GetAll() ([]FeatureSuggestion, error) {
	if r.db == nil {
		return nil, ErrNoDB
	}
	rows, err := r.db.Query(`
		SELECT fs.id, fs.user_id, fs.title, fs.description, fs.status, fs.created_at,
		       COALESCE(u.full_name,''), COALESCE(u.phone,''), COALESCE(u.email,''),
		       u.learning_path_id, u.bac_branch_id
		FROM feature_suggestions fs
		JOIN users u ON u.id = fs.user_id
		ORDER BY fs.created_at DESC`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var list []FeatureSuggestion
	for rows.Next() {
		var s FeatureSuggestion
		var lp, bac sql.NullInt64
		if err := rows.Scan(&s.ID, &s.UserID, &s.Title, &s.Description, &s.Status, &s.CreatedAt,
			&s.UserFullName, &s.UserPhone, &s.UserEmail, &lp, &bac); err != nil {
			continue
		}
		if lp.Valid {
			v := int(lp.Int64)
			s.LearningPathID = &v
		}
		if bac.Valid {
			v := int(bac.Int64)
			s.BacBranchID = &v
		}
		list = append(list, s)
	}
	if list == nil {
		list = []FeatureSuggestion{}
	}
	return list, rows.Err()
}

// UpdateStatus changes a suggestion's status.
func (r *SuggestionRepository) UpdateStatus(id int, status string) error {
	if r.db == nil {
		return ErrNoDB
	}
	_, err := r.db.Exec(`UPDATE feature_suggestions SET status = ? WHERE id = ?`, status, id)
	return err
}
