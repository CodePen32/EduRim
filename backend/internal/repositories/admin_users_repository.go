package repositories

import (
	"database/sql"
	"fmt"
	"strings"
)

type AdminUser struct {
	ID               int     `json:"id"`
	FullName         string  `json:"full_name"`
	Email            string  `json:"email"`
	Phone            string  `json:"phone"`
	LearningPathID   *int    `json:"learning_path_id"`
	LearningPathName string  `json:"learning_path_name"`
	BacBranchID      *int    `json:"bac_branch_id"`
	BacBranchName    string  `json:"bac_branch_name"`
	City             string  `json:"city"`
	Gender           string  `json:"gender"`
	IsActive         bool    `json:"is_active"`
	CreatedAt        string  `json:"created_at"`
}

type AdminUserDetail struct {
	AdminUser
	CompletedLessons int     `json:"completed_lessons"`
	AverageProgress  float64 `json:"average_progress"`
	LastLessonTitle  string  `json:"last_lesson_title"`
}

type AdminUsersFilter struct {
	Search         string
	LearningPathID int
	BacBranchID    int
	IsActive       int // -1 = all, 0 = inactive, 1 = active
	Limit          int
	Offset         int
}

type AdminUsersRepository struct {
	db *sql.DB
}

func NewAdminUsersRepository(db *sql.DB) *AdminUsersRepository {
	return &AdminUsersRepository{db: db}
}

func (r *AdminUsersRepository) GetAll(f AdminUsersFilter) ([]AdminUser, int, error) {
	where := []string{}
	args := []interface{}{}

	if f.Search != "" {
		where = append(where, "(u.full_name LIKE ? OR u.email LIKE ? OR u.phone LIKE ?)")
		s := "%" + f.Search + "%"
		args = append(args, s, s, s)
	}
	if f.LearningPathID > 0 {
		where = append(where, "u.learning_path_id = ?")
		args = append(args, f.LearningPathID)
	}
	if f.BacBranchID > 0 {
		where = append(where, "u.bac_branch_id = ?")
		args = append(args, f.BacBranchID)
	}
	if f.IsActive >= 0 {
		where = append(where, "u.is_active = ?")
		args = append(args, f.IsActive)
	}

	whereSQL := ""
	if len(where) > 0 {
		whereSQL = "WHERE " + strings.Join(where, " AND ")
	}

	// Count
	var total int
	countArgs := make([]interface{}, len(args))
	copy(countArgs, args)
	r.db.QueryRow(fmt.Sprintf(`SELECT COUNT(*) FROM users u %s`, whereSQL), countArgs...).Scan(&total)

	// Limit/Offset
	limit := f.Limit
	if limit <= 0 { limit = 50 }
	offset := f.Offset
	args = append(args, limit, offset)

	query := fmt.Sprintf(`
		SELECT u.id, u.full_name, u.email, COALESCE(u.phone,''),
		       u.learning_path_id, COALESCE(lp.name_ar,''),
		       u.bac_branch_id, COALESCE(bb.name_ar,''),
		       COALESCE(u.city,''), COALESCE(u.gender,''),
		       u.is_active, DATE_FORMAT(u.created_at, '%%Y-%%m-%%d')
		FROM users u
		LEFT JOIN learning_paths lp ON lp.id = u.learning_path_id
		LEFT JOIN bac_branches bb ON bb.id = u.bac_branch_id
		%s
		ORDER BY u.created_at DESC
		LIMIT ? OFFSET ?
	`, whereSQL)

	rows, err := r.db.Query(query, args...)
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	var users []AdminUser
	for rows.Next() {
		var u AdminUser
		var lpID, bacID sql.NullInt64
		if err := rows.Scan(
			&u.ID, &u.FullName, &u.Email, &u.Phone,
			&lpID, &u.LearningPathName,
			&bacID, &u.BacBranchName,
			&u.City, &u.Gender, &u.IsActive, &u.CreatedAt,
		); err != nil {
			return nil, 0, err
		}
		if lpID.Valid { v := int(lpID.Int64); u.LearningPathID = &v }
		if bacID.Valid { v := int(bacID.Int64); u.BacBranchID = &v }
		users = append(users, u)
	}
	return users, total, rows.Err()
}

func (r *AdminUsersRepository) GetByID(id int) (*AdminUserDetail, error) {
	var u AdminUserDetail
	var lpID, bacID sql.NullInt64
	err := r.db.QueryRow(`
		SELECT u.id, u.full_name, u.email, COALESCE(u.phone,''),
		       u.learning_path_id, COALESCE(lp.name_ar,''),
		       u.bac_branch_id, COALESCE(bb.name_ar,''),
		       COALESCE(u.city,''), COALESCE(u.gender,''),
		       u.is_active, DATE_FORMAT(u.created_at, '%Y-%m-%d')
		FROM users u
		LEFT JOIN learning_paths lp ON lp.id = u.learning_path_id
		LEFT JOIN bac_branches bb ON bb.id = u.bac_branch_id
		WHERE u.id = ?`, id,
	).Scan(
		&u.ID, &u.FullName, &u.Email, &u.Phone,
		&lpID, &u.LearningPathName,
		&bacID, &u.BacBranchName,
		&u.City, &u.Gender, &u.IsActive, &u.CreatedAt,
	)
	if err != nil {
		return nil, fmt.Errorf("user not found: %w", err)
	}
	if lpID.Valid { v := int(lpID.Int64); u.LearningPathID = &v }
	if bacID.Valid { v := int(bacID.Int64); u.BacBranchID = &v }

	// Progress stats
	r.db.QueryRow(`SELECT COUNT(*) FROM progress WHERE user_id = ? AND completed = 1`, id).Scan(&u.CompletedLessons)
	r.db.QueryRow(`SELECT COALESCE(AVG(watched_percentage), 0) FROM progress WHERE user_id = ?`, id).Scan(&u.AverageProgress)
	r.db.QueryRow(`
		SELECT COALESCE(l.title, '') FROM progress p
		JOIN lessons l ON l.id = p.lesson_id
		WHERE p.user_id = ?
		ORDER BY p.updated_at DESC LIMIT 1`, id,
	).Scan(&u.LastLessonTitle)

	return &u, nil
}

func (r *AdminUsersRepository) Update(id int, fullName, email, phone, city, gender string, learningPathID, bacBranchID *int, isActive bool) error {
	var lpID, bacID interface{} = nil, nil
	if learningPathID != nil { lpID = *learningPathID }
	if bacBranchID != nil { bacID = *bacBranchID }
	_, err := r.db.Exec(`
		UPDATE users SET full_name=?, email=?, phone=?, city=?, gender=?,
		learning_path_id=?, bac_branch_id=?, is_active=?, updated_at=NOW()
		WHERE id=?`,
		fullName, email, phone, city, gender, lpID, bacID, isActive, id,
	)
	return err
}

func (r *AdminUsersRepository) ToggleActive(id int) (bool, error) {
	var current bool
	r.db.QueryRow(`SELECT is_active FROM users WHERE id = ?`, id).Scan(&current)
	newVal := !current
	_, err := r.db.Exec(`UPDATE users SET is_active=?, updated_at=NOW() WHERE id=?`, newVal, id)
	return newVal, err
}
