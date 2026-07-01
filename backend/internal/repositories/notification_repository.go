package repositories

import "database/sql"

type Notification struct {
	ID             int    `json:"id"`
	UserID         *int   `json:"user_id"`
	LearningPathID *int   `json:"learning_path_id"`
	BacBranchID    *int   `json:"bac_branch_id"`
	Title          string `json:"title"`
	Message        string `json:"message"`
	Type           string `json:"type"`
	IsRead         bool   `json:"is_read"`
	CreatedAt      string `json:"created_at"`
}

type NotificationRepository struct {
	db *sql.DB
}

func NewNotificationRepository(db *sql.DB) *NotificationRepository {
	return &NotificationRepository{db: db}
}

func (r *NotificationRepository) GetForUser(userID int, learningPathID, bacBranchID *int, limit, offset int) ([]Notification, error) {
	if r.db == nil {
		return nil, ErrNoDB
	}

	query := `SELECT id, user_id, learning_path_id, bac_branch_id, title, message, type, is_read, created_at
	          FROM notifications
	          WHERE (user_id = ? OR user_id IS NULL)`
	args := []interface{}{userID}

	if learningPathID != nil {
		query += ` AND (learning_path_id = ? OR learning_path_id IS NULL)`
		args = append(args, *learningPathID)
		if bacBranchID != nil {
			query += ` AND (bac_branch_id = ? OR bac_branch_id IS NULL)`
			args = append(args, *bacBranchID)
		}
	}
	query += ` ORDER BY created_at DESC`
	if limit > 0 {
		query += ` LIMIT ? OFFSET ?`
		args = append(args, limit, offset)
	}

	rows, err := r.db.Query(query, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var list []Notification
	for rows.Next() {
		var n Notification
		var uid, lpID, bacID sql.NullInt64
		var isRead int
		if err := rows.Scan(&n.ID, &uid, &lpID, &bacID, &n.Title, &n.Message, &n.Type, &isRead, &n.CreatedAt); err != nil {
			continue
		}
		if uid.Valid {
			v := int(uid.Int64)
			n.UserID = &v
		}
		if lpID.Valid {
			v := int(lpID.Int64)
			n.LearningPathID = &v
		}
		if bacID.Valid {
			v := int(bacID.Int64)
			n.BacBranchID = &v
		}
		n.IsRead = isRead == 1
		list = append(list, n)
	}
	return list, nil
}

func (r *NotificationRepository) UnreadCount(userID int) (int, error) {
	if r.db == nil {
		return 0, ErrNoDB
	}
	var count int
	err := r.db.QueryRow(
		`SELECT COUNT(*) FROM notifications WHERE (user_id = ? OR user_id IS NULL) AND is_read = FALSE`,
		userID,
	).Scan(&count)
	return count, err
}

// GetFCMTokensByScope returns non-empty FCM tokens of students in a learning
// path (and bac branch when set). Never returns NULL/empty tokens. No logging of tokens.
func (r *NotificationRepository) GetFCMTokensByScope(learningPathID int, bacBranchID *int) ([]string, error) {
	if r.db == nil {
		return nil, ErrNoDB
	}
	query := `SELECT fcm_token FROM users
	          WHERE fcm_token IS NOT NULL AND fcm_token <> ''
	            AND learning_path_id = ?
	            AND ( ? IS NULL OR bac_branch_id = ? OR bac_branch_id IS NULL )`
	var bac interface{}
	if bacBranchID != nil {
		bac = *bacBranchID
	}
	rows, err := r.db.Query(query, learningPathID, bac, bac)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var tokens []string
	for rows.Next() {
		var t string
		if err := rows.Scan(&t); err != nil {
			continue
		}
		if t != "" {
			tokens = append(tokens, t)
		}
	}
	return tokens, nil
}

// GetFCMTokenByUser returns the FCM token of a single user, or empty if none.
func (r *NotificationRepository) GetFCMTokenByUser(userID int) (string, error) {
	if r.db == nil {
		return "", ErrNoDB
	}
	var tok sql.NullString
	err := r.db.QueryRow(`SELECT fcm_token FROM users WHERE id = ?`, userID).Scan(&tok)
	if err != nil {
		return "", err
	}
	if tok.Valid {
		return tok.String, nil
	}
	return "", nil
}

func (r *NotificationRepository) Create(userID *int, title, message, notifType string, learningPathID, bacBranchID *int) error {
	if r.db == nil {
		return ErrNoDB
	}
	var uid, lpID, bacID interface{}
	if userID != nil {
		uid = *userID
	}
	if learningPathID != nil {
		lpID = *learningPathID
	}
	if bacBranchID != nil {
		bacID = *bacBranchID
	}
	_, err := r.db.Exec(
		`INSERT INTO notifications (user_id, learning_path_id, bac_branch_id, title, message, type, is_read) VALUES (?,?,?,?,?,?,0)`,
		uid, lpID, bacID, title, message, notifType,
	)
	return err
}

func (r *NotificationRepository) GetAdminList(learningPathID, bacBranchID *int, limit, offset int) ([]Notification, error) {
	if r.db == nil {
		return nil, ErrNoDB
	}

	query := `SELECT id, user_id, learning_path_id, bac_branch_id, title, message, type, is_read, created_at
	          FROM notifications WHERE 1=1`
	args := []interface{}{}

	if learningPathID != nil {
		query += ` AND (learning_path_id = ? OR learning_path_id IS NULL)`
		args = append(args, *learningPathID)
		if bacBranchID != nil {
			query += ` AND (bac_branch_id = ? OR bac_branch_id IS NULL)`
			args = append(args, *bacBranchID)
		}
	}
	query += ` ORDER BY created_at DESC`
	if limit > 0 {
		query += ` LIMIT ? OFFSET ?`
		args = append(args, limit, offset)
	}

	rows, err := r.db.Query(query, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var list []Notification
	for rows.Next() {
		var n Notification
		var uid, lpID, bacID sql.NullInt64
		var isRead int
		if err := rows.Scan(&n.ID, &uid, &lpID, &bacID, &n.Title, &n.Message, &n.Type, &isRead, &n.CreatedAt); err != nil {
			continue
		}
		if uid.Valid {
			v := int(uid.Int64)
			n.UserID = &v
		}
		if lpID.Valid {
			v := int(lpID.Int64)
			n.LearningPathID = &v
		}
		if bacID.Valid {
			v := int(bacID.Int64)
			n.BacBranchID = &v
		}
		n.IsRead = isRead == 1
		list = append(list, n)
	}
	return list, nil
}

func (r *NotificationRepository) MarkRead(id, userID int) error {
	if r.db == nil {
		return ErrNoDB
	}
	_, err := r.db.Exec(
		`UPDATE notifications SET is_read = TRUE WHERE id = ? AND (user_id = ? OR user_id IS NULL)`,
		id, userID,
	)
	return err
}
