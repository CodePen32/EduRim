package repositories

import "database/sql"

type Download struct {
	ID            int    `json:"id"`
	ItemType      string `json:"item_type"`
	ItemID        int    `json:"item_id"`
	Title         string `json:"title"`
	VideoURL      string `json:"video_url"`
	SummaryURL    string `json:"summary_url"`
	CoverImageURL string `json:"cover_image_url"`
	CreatedAt     string `json:"created_at"`
}

type DownloadRepository struct {
	db *sql.DB
}

func NewDownloadRepository(db *sql.DB) *DownloadRepository {
	return &DownloadRepository{db: db}
}

func (r *DownloadRepository) GetForUser(userID int) ([]Download, error) {
	if r.db == nil {
		return nil, ErrNoDB
	}
	rows, err := r.db.Query(
		`SELECT d.id, d.item_type, d.item_id,
		        CASE d.item_type
		          WHEN 'lesson'   THEN COALESCE(l.title,'')
		          WHEN 'summary'  THEN CONCAT('ملخص: ', COALESCE(l.title,''))
		          WHEN 'exercise' THEN COALESCE(e.title,'')
		          ELSE ''
		        END AS title,
		        COALESCE(l.video_url,''), COALESCE(l.summary_url,''), COALESCE(l.cover_image_url,''),
		        d.created_at
		 FROM downloads d
		 LEFT JOIN lessons  l ON d.item_type IN ('lesson','summary') AND l.id = d.item_id
		 LEFT JOIN exercises e ON d.item_type = 'exercise'           AND e.id = d.item_id
		 WHERE d.user_id = ?
		 ORDER BY d.created_at DESC`,
		userID,
	)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var list []Download
	for rows.Next() {
		var dl Download
		if err := rows.Scan(&dl.ID, &dl.ItemType, &dl.ItemID, &dl.Title,
			&dl.VideoURL, &dl.SummaryURL, &dl.CoverImageURL, &dl.CreatedAt); err != nil {
			continue
		}
		list = append(list, dl)
	}
	return list, nil
}

func (r *DownloadRepository) Add(userID int, itemType string, itemID int) (int64, error) {
	if r.db == nil {
		return 0, ErrNoDB
	}
	// downloads allow duplicates (user can save again) — but prevent exact same record
	var exists int
	_ = r.db.QueryRow(
		`SELECT COUNT(*) FROM downloads WHERE user_id=? AND item_type=? AND item_id=?`,
		userID, itemType, itemID,
	).Scan(&exists)
	if exists > 0 {
		return 0, nil // already saved
	}
	res, err := r.db.Exec(
		`INSERT INTO downloads (user_id, item_type, item_id) VALUES (?, ?, ?)`,
		userID, itemType, itemID,
	)
	if err != nil {
		return 0, err
	}
	affected, _ := res.RowsAffected()
	return affected, nil
}

func (r *DownloadRepository) Delete(id, userID int) error {
	if r.db == nil {
		return ErrNoDB
	}
	_, err := r.db.Exec(`DELETE FROM downloads WHERE id = ? AND user_id = ?`, id, userID)
	return err
}
