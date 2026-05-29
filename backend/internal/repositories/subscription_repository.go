package repositories

import (
	"database/sql"
	"fmt"
	"time"

	"edurim/backend/internal/models"
)

type SubscriptionRepository struct {
	db *sql.DB
}

func NewSubscriptionRepository(db *sql.DB) *SubscriptionRepository {
	return &SubscriptionRepository{db: db}
}

// GetAllPlans returns all subscription plans
func (r *SubscriptionRepository) GetAllPlans() ([]models.SubscriptionPlan, error) {
	if r.db == nil {
		return nil, ErrNoDB
	}
	rows, err := r.db.Query(`
		SELECT id, name, COALESCE(description,''), duration_days, price,
		       learning_path_id, bac_branch_id, is_active,
		       COALESCE(created_at, NOW())
		FROM subscription_plans
		ORDER BY id ASC
	`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var plans []models.SubscriptionPlan
	for rows.Next() {
		var p models.SubscriptionPlan
		var lpID, bacID sql.NullInt64
		if err := rows.Scan(&p.ID, &p.Name, &p.Description, &p.DurationDays, &p.Price,
			&lpID, &bacID, &p.IsActive, &p.CreatedAt); err != nil {
			return nil, err
		}
		if lpID.Valid {
			v := uint(lpID.Int64)
			p.LearningPathID = &v
		}
		if bacID.Valid {
			v := uint(bacID.Int64)
			p.BacBranchID = &v
		}
		plans = append(plans, p)
	}
	return plans, rows.Err()
}

// GetPlansByScope returns plans matching the given learning_path_id (and optionally bac_branch_id)
func (r *SubscriptionRepository) GetPlansByScope(learningPathID int, bacBranchID *int) ([]models.SubscriptionPlan, error) {
	if r.db == nil {
		return nil, ErrNoDB
	}
	query := `
		SELECT id, name, COALESCE(description,''), duration_days, price,
		       learning_path_id, bac_branch_id, is_active,
		       COALESCE(created_at, NOW())
		FROM subscription_plans
		WHERE is_active = 1`
	args := []interface{}{}
	if learningPathID > 0 {
		query += " AND (learning_path_id = ? OR learning_path_id IS NULL)"
		args = append(args, learningPathID)
		if bacBranchID != nil && *bacBranchID > 0 {
			query += " AND (bac_branch_id = ? OR bac_branch_id IS NULL)"
			args = append(args, *bacBranchID)
		}
	}
	query += " ORDER BY id ASC"

	rows, err := r.db.Query(query, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var plans []models.SubscriptionPlan
	for rows.Next() {
		var p models.SubscriptionPlan
		var lpID, bacID sql.NullInt64
		if err := rows.Scan(&p.ID, &p.Name, &p.Description, &p.DurationDays, &p.Price,
			&lpID, &bacID, &p.IsActive, &p.CreatedAt); err != nil {
			return nil, err
		}
		if lpID.Valid {
			v := uint(lpID.Int64)
			p.LearningPathID = &v
		}
		if bacID.Valid {
			v := uint(bacID.Int64)
			p.BacBranchID = &v
		}
		plans = append(plans, p)
	}
	return plans, rows.Err()
}

// CreatePlan inserts a new subscription plan
func (r *SubscriptionRepository) CreatePlan(p models.SubscriptionPlan) error {
	if r.db == nil {
		return ErrNoDB
	}
	var lpID, bacID interface{} = nil, nil
	if p.LearningPathID != nil {
		lpID = *p.LearningPathID
	}
	if p.BacBranchID != nil {
		bacID = *p.BacBranchID
	}
	_, err := r.db.Exec(`
		INSERT INTO subscription_plans (name, description, duration_days, price, learning_path_id, bac_branch_id, is_active)
		VALUES (?, ?, ?, ?, ?, ?, ?)`,
		p.Name, p.Description, p.DurationDays, p.Price, lpID, bacID, p.IsActive,
	)
	return err
}

// UpdatePlan updates an existing plan
func (r *SubscriptionRepository) UpdatePlan(id int, p models.SubscriptionPlan) error {
	if r.db == nil {
		return ErrNoDB
	}
	var lpID, bacID interface{} = nil, nil
	if p.LearningPathID != nil {
		lpID = *p.LearningPathID
	}
	if p.BacBranchID != nil {
		bacID = *p.BacBranchID
	}
	_, err := r.db.Exec(`
		UPDATE subscription_plans
		SET name=?, description=?, duration_days=?, price=?, learning_path_id=?, bac_branch_id=?, is_active=?
		WHERE id=?`,
		p.Name, p.Description, p.DurationDays, p.Price, lpID, bacID, p.IsActive, id,
	)
	return err
}

// DeletePlan deletes a plan by id
func (r *SubscriptionRepository) DeletePlan(id int) error {
	if r.db == nil {
		return ErrNoDB
	}
	_, err := r.db.Exec(`DELETE FROM subscription_plans WHERE id=?`, id)
	return err
}

// GetUserSubscription returns the active subscription for a user
func (r *SubscriptionRepository) GetUserSubscription(userID uint) (models.MySubscriptionResponse, error) {
	resp := models.MySubscriptionResponse{}
	if r.db == nil {
		return resp, ErrNoDB
	}

	var startDate, endDate string
	var planName string
	err := r.db.QueryRow(`
		SELECT sp.name, DATE_FORMAT(us.start_date,'%Y-%m-%d'), DATE_FORMAT(us.end_date,'%Y-%m-%d')
		FROM user_subscriptions us
		JOIN subscription_plans sp ON sp.id = us.plan_id
		WHERE us.user_id = ? AND us.is_active = 1 AND us.end_date >= CURDATE()
		ORDER BY us.end_date DESC
		LIMIT 1
	`, userID).Scan(&planName, &startDate, &endDate)

	if err == sql.ErrNoRows {
		resp.HasSubscription = false
		return resp, nil
	}
	if err != nil {
		return resp, err
	}

	end, parseErr := time.Parse("2006-01-02", endDate)
	daysRemaining := 0
	if parseErr == nil {
		daysRemaining = int(time.Until(end).Hours() / 24)
		if daysRemaining < 0 {
			daysRemaining = 0
		}
	}

	resp.HasSubscription = true
	resp.IsActive = true
	resp.PlanName = planName
	resp.StartDate = startDate
	resp.EndDate = endDate
	resp.DaysRemaining = daysRemaining
	return resp, nil
}

// HasActiveSubscription returns true if user has an active, non-expired subscription.
func (r *SubscriptionRepository) HasActiveSubscription(userID uint) bool {
	if r.db == nil {
		return false
	}
	var count int
	r.db.QueryRow(
		`SELECT COUNT(*) FROM user_subscriptions WHERE user_id = ? AND is_active = 1 AND end_date >= CURDATE()`,
		userID,
	).Scan(&count)
	return count > 0
}

// CreateUserSubscription inserts a new user subscription
func (r *SubscriptionRepository) CreateUserSubscription(sub models.UserSubscription) error {
	if r.db == nil {
		return ErrNoDB
	}
	var adminID interface{} = nil
	if sub.CreatedAt.IsZero() {
		// use default
	}
	_, err := r.db.Exec(`
		INSERT INTO user_subscriptions (user_id, plan_id, start_date, end_date, is_active, notes, created_by_admin_id)
		VALUES (?, ?, ?, ?, ?, ?, ?)`,
		sub.UserID, sub.PlanID, sub.StartDate, sub.EndDate, sub.IsActive, sub.Notes, adminID,
	)
	return err
}

// GetAllUserSubscriptions returns all user subscriptions with joined info
// GetAllUserSubscriptions مع فلترة حسب مستوى الطالب
func (r *SubscriptionRepository) GetAllUserSubscriptions(learningPathID int, bacBranchID *int) ([]models.UserSubscription, error) {
	if r.db == nil {
		return nil, ErrNoDB
	}
	query := `
		SELECT us.id, us.user_id, us.plan_id,
		       DATE_FORMAT(us.start_date,'%Y-%m-%d'),
		       DATE_FORMAT(us.end_date,'%Y-%m-%d'),
		       us.is_active,
		       COALESCE(us.notes,''),
		       COALESCE(us.created_at, NOW()),
		       COALESCE(sp.name,''),
		       COALESCE(u.full_name,'')
		FROM user_subscriptions us
		LEFT JOIN subscription_plans sp ON sp.id = us.plan_id
		JOIN users u ON u.id = us.user_id
		WHERE u.learning_path_id = ?`
	args := []interface{}{learningPathID}
	if bacBranchID != nil {
		query += " AND u.bac_branch_id = ?"
		args = append(args, *bacBranchID)
	} else {
		query += " AND u.bac_branch_id IS NULL"
	}
	query += " ORDER BY us.created_at DESC"

	rows, err := r.db.Query(query, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var subs []models.UserSubscription
	for rows.Next() {
		var s models.UserSubscription
		if err := rows.Scan(&s.ID, &s.UserID, &s.PlanID, &s.StartDate, &s.EndDate,
			&s.IsActive, &s.Notes, &s.CreatedAt, &s.PlanName, &s.UserFullName); err != nil {
			return nil, err
		}
		subs = append(subs, s)
	}
	if subs == nil {
		subs = []models.UserSubscription{}
	}
	return subs, rows.Err()
}

// UpdateUserSubscription updates a user subscription
func (r *SubscriptionRepository) UpdateUserSubscription(id int, sub models.UserSubscription) error {
	if r.db == nil {
		return ErrNoDB
	}
	_, err := r.db.Exec(`
		UPDATE user_subscriptions
		SET user_id=?, plan_id=?, start_date=?, end_date=?, is_active=?, notes=?
		WHERE id=?`,
		sub.UserID, sub.PlanID, sub.StartDate, sub.EndDate, sub.IsActive, sub.Notes, id,
	)
	return err
}

// DeleteUserSubscription deletes a user subscription
func (r *SubscriptionRepository) DeleteUserSubscription(id int) error {
	if r.db == nil {
		return ErrNoDB
	}
	_, err := r.db.Exec(`DELETE FROM user_subscriptions WHERE id=?`, id)
	return err
}

// CreateRequest - user submits a subscription request
func (r *SubscriptionRepository) CreateRequest(req models.SubscriptionRequest) error {
	if r.db == nil {
		return ErrNoDB
	}
	// منع إرسال طلب جديد إذا كان هناك طلب pending
	var count int
	_ = r.db.QueryRow(
		`SELECT COUNT(*) FROM subscription_requests WHERE user_id = ? AND status = 'pending'`,
		req.UserID,
	).Scan(&count)
	if count > 0 {
		return fmt.Errorf("لديك طلب اشتراك قيد المراجعة، يرجى انتظار مراجعته أولاً")
	}
	_, err := r.db.Exec(
		`INSERT INTO subscription_requests (user_id, plan_id, phone, payment_method, receipt_image_url, note, status) VALUES (?,?,?,?,?,?,'pending')`,
		req.UserID, req.PlanID, req.Phone, req.PaymentMethod, req.ReceiptImageURL, req.Note,
	)
	return err
}

// GetMyRequests - get requests for a user
func (r *SubscriptionRepository) GetMyRequests(userID uint) ([]models.SubscriptionRequest, error) {
	if r.db == nil {
		return nil, ErrNoDB
	}
	rows, err := r.db.Query(`
		SELECT sr.id, sr.user_id, sr.plan_id, sr.phone, sr.payment_method, sr.receipt_image_url,
		       COALESCE(sr.note,''), sr.status, COALESCE(sr.admin_note,''),
		       sr.reviewed_by_admin_id, sr.reviewed_at, sr.created_at, sr.updated_at,
		       COALESCE(sp.name,'') as plan_name
		FROM subscription_requests sr
		LEFT JOIN subscription_plans sp ON sp.id = sr.plan_id
		WHERE sr.user_id = ?
		ORDER BY sr.created_at DESC`, userID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var list []models.SubscriptionRequest
	for rows.Next() {
		var req models.SubscriptionRequest
		if err := rows.Scan(
			&req.ID, &req.UserID, &req.PlanID, &req.Phone, &req.PaymentMethod, &req.ReceiptImageURL,
			&req.Note, &req.Status, &req.AdminNote, &req.ReviewedByAdminID, &req.ReviewedAt,
			&req.CreatedAt, &req.UpdatedAt, &req.PlanName,
		); err != nil {
			return nil, err
		}
		list = append(list, req)
	}
	if list == nil {
		list = []models.SubscriptionRequest{}
	}
	return list, rows.Err()
}

// GetAllRequests - admin gets all requests
// GetAllRequests مع فلترة حسب مستوى الطالب
func (r *SubscriptionRepository) GetAllRequests(status string, learningPathID int, bacBranchID *int) ([]models.SubscriptionRequest, error) {
	if r.db == nil {
		return nil, ErrNoDB
	}
	query := `SELECT sr.id, sr.user_id, sr.plan_id, sr.phone, sr.payment_method, sr.receipt_image_url,
		       COALESCE(sr.note,''), sr.status, COALESCE(sr.admin_note,''),
		       sr.reviewed_by_admin_id, sr.reviewed_at, sr.created_at, sr.updated_at,
		       COALESCE(u.full_name,'') as user_full_name, COALESCE(sp.name,'') as plan_name, COALESCE(sp.duration_days,30) as duration_days
		FROM subscription_requests sr
		JOIN users u ON u.id = sr.user_id
		LEFT JOIN subscription_plans sp ON sp.id = sr.plan_id
		WHERE u.learning_path_id = ?`
	args := []interface{}{learningPathID}
	if bacBranchID != nil {
		query += " AND u.bac_branch_id = ?"
		args = append(args, *bacBranchID)
	} else {
		query += " AND u.bac_branch_id IS NULL"
	}
	if status != "" && status != "all" {
		query += " AND sr.status = ?"
		args = append(args, status)
	}
	query += " ORDER BY sr.created_at DESC"
	rows, err := r.db.Query(query, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var list []models.SubscriptionRequest
	for rows.Next() {
		var req models.SubscriptionRequest
		if err := rows.Scan(
			&req.ID, &req.UserID, &req.PlanID, &req.Phone, &req.PaymentMethod, &req.ReceiptImageURL,
			&req.Note, &req.Status, &req.AdminNote, &req.ReviewedByAdminID, &req.ReviewedAt,
			&req.CreatedAt, &req.UpdatedAt, &req.UserFullName, &req.PlanName, &req.DurationDays,
		); err != nil {
			return nil, err
		}
		list = append(list, req)
	}
	if list == nil {
		list = []models.SubscriptionRequest{}
	}
	return list, rows.Err()
}

// ApproveRequest - admin approves, creates subscription automatically
func (r *SubscriptionRepository) ApproveRequest(requestID uint, adminID uint, adminNote string) error {
	if r.db == nil {
		return ErrNoDB
	}
	var req models.SubscriptionRequest
	err := r.db.QueryRow(
		`SELECT id, user_id, plan_id FROM subscription_requests WHERE id = ? AND status = 'pending'`,
		requestID,
	).Scan(&req.ID, &req.UserID, &req.PlanID)
	if err != nil {
		return fmt.Errorf("طلب غير موجود أو تمت مراجعته مسبقاً")
	}

	var durationDays int
	err = r.db.QueryRow(`SELECT duration_days FROM subscription_plans WHERE id = ?`, req.PlanID).Scan(&durationDays)
	if err != nil {
		durationDays = 30
	}

	tx, err := r.db.Begin()
	if err != nil {
		return err
	}
	defer tx.Rollback()

	today := time.Now().Format("2006-01-02")
	endDate := time.Now().AddDate(0, 0, durationDays).Format("2006-01-02")

	_, err = tx.Exec(`UPDATE user_subscriptions SET is_active = 0 WHERE user_id = ?`, req.UserID)
	if err != nil {
		return err
	}

	_, err = tx.Exec(
		`INSERT INTO user_subscriptions (user_id, plan_id, start_date, end_date, is_active, notes) VALUES (?,?,?,?,1,?)`,
		req.UserID, req.PlanID, today, endDate, "تم الإنشاء تلقائياً عند قبول الطلب",
	)
	if err != nil {
		return err
	}

	_, err = tx.Exec(
		`UPDATE subscription_requests SET status = 'approved', admin_note = ?, reviewed_by_admin_id = ?, reviewed_at = NOW() WHERE id = ?`,
		adminNote, adminID, requestID,
	)
	if err != nil {
		return err
	}

	// إشعار للطالب عند القبول
	userIDInt := int(req.UserID)
	_, _ = tx.Exec(
		`INSERT INTO notifications (user_id, title, message, type, is_read) VALUES (?,?,?,?,0)`,
		userIDInt,
		"تم تفعيل الاشتراك",
		"تم تفعيل اشتراكك بنجاح، يمكنك الآن مشاهدة الدروس المدفوعة.",
		"subscription",
	)

	return tx.Commit()
}

// RejectRequest - admin rejects
func (r *SubscriptionRepository) RejectRequest(requestID uint, adminID uint, adminNote string) error {
	if r.db == nil {
		return ErrNoDB
	}
	// احضر user_id قبل التحديث
	var userID int
	_ = r.db.QueryRow(`SELECT user_id FROM subscription_requests WHERE id = ? AND status = 'pending'`, requestID).Scan(&userID)

	res, err := r.db.Exec(
		`UPDATE subscription_requests SET status = 'rejected', admin_note = ?, reviewed_by_admin_id = ?, reviewed_at = NOW() WHERE id = ? AND status = 'pending'`,
		adminNote, adminID, requestID,
	)
	if err != nil {
		return err
	}
	n, _ := res.RowsAffected()
	if n == 0 {
		return fmt.Errorf("طلب غير موجود أو تمت مراجعته مسبقاً")
	}

	// إشعار للطالب عند الرفض
	if userID > 0 {
		msg := "تم رفض طلب الاشتراك، يرجى التأكد من عملية الدفع والمحاولة مرة أخرى."
		if adminNote != "" {
			msg += " سبب الرفض: " + adminNote
		}
		_, _ = r.db.Exec(
			`INSERT INTO notifications (user_id, title, message, type, is_read) VALUES (?,?,?,?,0)`,
			userID, "تم رفض طلب الاشتراك", msg, "subscription",
		)
	}
	return nil
}

// GetPlansByUser returns active plans matching the user's learning path / bac branch
func (r *SubscriptionRepository) GetPlansByUser(userID uint) ([]models.SubscriptionPlan, error) {
	if r.db == nil {
		return nil, ErrNoDB
	}
	var learningPathID int
	var bacBranchID sql.NullInt64
	err := r.db.QueryRow(
		`SELECT COALESCE(learning_path_id,0), bac_branch_id FROM users WHERE id=?`, userID,
	).Scan(&learningPathID, &bacBranchID)
	if err != nil {
		return nil, err
	}

	// الخطط العامة (learning_path_id IS NULL) تظهر لجميع الطلاب
	// الخطط الخاصة بمستوى معين تظهر فقط لطلاب ذلك المستوى
	var rows *sql.Rows
	if bacBranchID.Valid {
		rows, err = r.db.Query(
			`SELECT id, name, COALESCE(description,''), duration_days, price, learning_path_id, bac_branch_id, is_active, COALESCE(created_at,NOW())
			 FROM subscription_plans
			 WHERE is_active=1
			   AND (learning_path_id IS NULL OR learning_path_id=?)
			   AND (bac_branch_id IS NULL OR bac_branch_id=?)
			 ORDER BY duration_days ASC`,
			learningPathID, bacBranchID.Int64,
		)
	} else {
		rows, err = r.db.Query(
			`SELECT id, name, COALESCE(description,''), duration_days, price, learning_path_id, bac_branch_id, is_active, COALESCE(created_at,NOW())
			 FROM subscription_plans
			 WHERE is_active=1
			   AND (learning_path_id IS NULL OR learning_path_id=?)
			   AND bac_branch_id IS NULL
			 ORDER BY duration_days ASC`,
			learningPathID,
		)
	}
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var plans []models.SubscriptionPlan
	for rows.Next() {
		var p models.SubscriptionPlan
		var lpID, bacID sql.NullInt64
		if err := rows.Scan(&p.ID, &p.Name, &p.Description, &p.DurationDays, &p.Price,
			&lpID, &bacID, &p.IsActive, &p.CreatedAt); err != nil {
			return nil, err
		}
		if lpID.Valid {
			v := uint(lpID.Int64)
			p.LearningPathID = &v
		}
		if bacID.Valid {
			v := uint(bacID.Int64)
			p.BacBranchID = &v
		}
		plans = append(plans, p)
	}
	if plans == nil {
		plans = []models.SubscriptionPlan{}
	}
	return plans, rows.Err()
}
