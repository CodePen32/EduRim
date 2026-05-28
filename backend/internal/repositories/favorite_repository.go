package repositories

import "database/sql"

type Favorite struct {
	ID        int    `json:"id"`
	ItemType  string `json:"item_type"`
	ItemID    int    `json:"item_id"`
	Title     string `json:"title"`
	Subtitle  string `json:"subtitle"`
	CreatedAt string `json:"created_at"`
}

type FavoriteRepository struct {
	db *sql.DB
}

func NewFavoriteRepository(db *sql.DB) *FavoriteRepository {
	return &FavoriteRepository{db: db}
}

func (r *FavoriteRepository) GetForUser(userID int) ([]Favorite, error) {
	if r.db == nil {
		return nil, ErrNoDB
	}
	rows, err := r.db.Query(
		`SELECT f.id, f.item_type, f.item_id,
		        CASE f.item_type
		          WHEN 'lesson'   THEN COALESCE(l.title,'')
		          WHEN 'exercise' THEN COALESCE(e.title,'')
		          ELSE ''
		        END AS title,
		        CASE f.item_type
		          WHEN 'lesson'   THEN COALESCE(l.description,'')
		          WHEN 'exercise' THEN COALESCE(e.difficulty,'')
		          ELSE ''
		        END AS subtitle,
		        f.created_at
		 FROM favorites f
		 LEFT JOIN lessons  l ON f.item_type = 'lesson'   AND l.id = f.item_id
		 LEFT JOIN exercises e ON f.item_type = 'exercise' AND e.id = f.item_id
		 WHERE f.user_id = ?
		 ORDER BY f.created_at DESC`,
		userID,
	)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var list []Favorite
	for rows.Next() {
		var fav Favorite
		if err := rows.Scan(&fav.ID, &fav.ItemType, &fav.ItemID, &fav.Title, &fav.Subtitle, &fav.CreatedAt); err != nil {
			continue
		}
		list = append(list, fav)
	}
	return list, nil
}

func (r *FavoriteRepository) Add(userID int, itemType string, itemID int) (int64, error) {
	if r.db == nil {
		return 0, ErrNoDB
	}
	res, err := r.db.Exec(
		`INSERT IGNORE INTO favorites (user_id, item_type, item_id) VALUES (?, ?, ?)`,
		userID, itemType, itemID,
	)
	if err != nil {
		return 0, err
	}
	affected, _ := res.RowsAffected()
	return affected, nil
}

func (r *FavoriteRepository) Delete(id, userID int) error {
	if r.db == nil {
		return ErrNoDB
	}
	_, err := r.db.Exec(`DELETE FROM favorites WHERE id = ? AND user_id = ?`, id, userID)
	return err
}
