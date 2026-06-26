package repositories

import (
	"database/sql"
	"strconv"
	"time"

	"edurim/backend/internal/cache"
)

type Announcement struct {
	ID              int64      `json:"id"`
	Title           string     `json:"title"`
	Message         string     `json:"message"`
	ImageURL        string     `json:"image_url"`
	LinkURL         string     `json:"link_url"`
	LearningPathID  *int64     `json:"learning_path_id"`
	BacBranchID     *int64     `json:"bac_branch_id"`
	IsActive        bool       `json:"is_active"`
	StartsAt        *time.Time `json:"starts_at"`
	EndsAt          *time.Time `json:"ends_at"`
	CreatedAt       time.Time  `json:"created_at"`
}

type AnnouncementRepository struct {
	db *sql.DB
}

func NewAnnouncementRepository(db *sql.DB) *AnnouncementRepository {
	return &AnnouncementRepository{db: db}
}

// GetForAdmin returns announcements filtered by scope (admin view, all active states)
func (r *AnnouncementRepository) GetForAdmin(learningPathID, bacBranchID int) ([]Announcement, error) {
	if r.db == nil {
		return nil, ErrNoDB
	}
	query := `SELECT id, title, COALESCE(message,''), COALESCE(image_url,''), COALESCE(link_url,''),
	          learning_path_id, bac_branch_id, is_active, starts_at, ends_at, created_at
	          FROM announcements WHERE 1=1`
	args := []interface{}{}
	if learningPathID > 0 {
		query += " AND learning_path_id = ?"
		args = append(args, learningPathID)
	}
	if bacBranchID > 0 {
		query += " AND bac_branch_id = ?"
		args = append(args, bacBranchID)
	}
	query += " ORDER BY id DESC"
	return r.scan(query, args...)
}

// GetActiveForUser returns active announcements visible to a student based on their LP/BAC
// GetActiveForUser — bacBranchID=-1 يعني الشعبة لم تُعيَّن بعد (BAC بدون شعبة)
func (r *AnnouncementRepository) GetActiveForUser(learningPathID, bacBranchID int) ([]Announcement, error) {
	cacheKey := strconv.Itoa(learningPathID) + ":" + strconv.Itoa(bacBranchID)
	if v, ok := cache.Announcements.Get(cacheKey); ok {
		return v.([]Announcement), nil
	}

	if r.db == nil {
		return nil, ErrNoDB
	}

	base := `SELECT id, title, COALESCE(message,''), COALESCE(image_url,''), COALESCE(link_url,''),
	          learning_path_id, bac_branch_id, is_active, starts_at, ends_at, created_at
	          FROM announcements
	          WHERE is_active = true
	            AND (starts_at IS NULL OR starts_at <= NOW())
	            AND (ends_at   IS NULL OR ends_at   >= NOW())
	            AND (learning_path_id IS NULL OR learning_path_id = ?)`

	var list []Announcement
	var err error

	// BAC بدون شعبة: أظهر فقط الإعلانات العامة
	if learningPathID == 3 && bacBranchID == -1 {
		query := base + ` AND learning_path_id IS NULL ORDER BY id DESC`
		list, err = r.scan(query, learningPathID)
	} else if learningPathID == 3 && bacBranchID > 0 {
		// BAC بشعبة: الإعلانات العامة + إعلانات BAC العامة (bac=NULL) + إعلانات الشعبة المحددة
		query := base + ` AND (bac_branch_id IS NULL OR bac_branch_id = ?) ORDER BY id DESC`
		list, err = r.scan(query, learningPathID, bacBranchID)
	} else {
		// Concours/BEPC: لا يرون إعلانات Bac
		query := base + ` AND bac_branch_id IS NULL ORDER BY id DESC`
		list, err = r.scan(query, learningPathID)
	}
	if err != nil {
		return nil, err
	}

	cache.Announcements.Set(cacheKey, list)
	return list, nil
}

func (r *AnnouncementRepository) Create(a Announcement) (int64, error) {
	if r.db == nil {
		return 0, ErrNoDB
	}
	res, err := r.db.Exec(
		`INSERT INTO announcements (title, message, image_url, link_url, learning_path_id, bac_branch_id, is_active, starts_at, ends_at)
		 VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
		a.Title, a.Message, a.ImageURL, a.LinkURL,
		a.LearningPathID, a.BacBranchID,
		a.IsActive, a.StartsAt, a.EndsAt,
	)
	if err != nil {
		return 0, err
	}
	return res.LastInsertId()
}

func (r *AnnouncementRepository) Update(id int64, a Announcement) error {
	if r.db == nil {
		return ErrNoDB
	}
	_, err := r.db.Exec(
		`UPDATE announcements SET title=?, message=?, image_url=?, link_url=?,
		 is_active=?, starts_at=?, ends_at=?, updated_at=NOW()
		 WHERE id=?`,
		a.Title, a.Message, a.ImageURL, a.LinkURL,
		a.IsActive, a.StartsAt, a.EndsAt, id,
	)
	return err
}

func (r *AnnouncementRepository) ToggleActive(id int64) error {
	if r.db == nil {
		return ErrNoDB
	}
	_, err := r.db.Exec(`UPDATE announcements SET is_active = NOT is_active, updated_at=NOW() WHERE id=?`, id)
	return err
}

func (r *AnnouncementRepository) Delete(id int64) error {
	if r.db == nil {
		return ErrNoDB
	}
	_, err := r.db.Exec(`DELETE FROM announcements WHERE id=?`, id)
	return err
}

func (r *AnnouncementRepository) scan(query string, args ...interface{}) ([]Announcement, error) {
	rows, err := r.db.Query(query, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var list []Announcement
	for rows.Next() {
		var a Announcement
		if err := rows.Scan(
			&a.ID, &a.Title, &a.Message, &a.ImageURL, &a.LinkURL,
			&a.LearningPathID, &a.BacBranchID,
			&a.IsActive, &a.StartsAt, &a.EndsAt, &a.CreatedAt,
		); err != nil {
			return nil, err
		}
		list = append(list, a)
	}
	return list, rows.Err()
}
