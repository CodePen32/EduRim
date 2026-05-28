package repositories

import (
	"database/sql"
	"fmt"
)

type SearchResult struct {
	Type  string `json:"type"`
	ID    int    `json:"id"`
	Title string `json:"title"`
	Extra string `json:"extra"`
}

type SearchRepository struct {
	db *sql.DB
}

func NewSearchRepository(db *sql.DB) *SearchRepository {
	return &SearchRepository{db: db}
}

func (r *SearchRepository) Search(q string) ([]SearchResult, error) {
	if r.db == nil {
		return nil, ErrNoDB
	}
	like := fmt.Sprintf("%%%s%%", q)
	results := []SearchResult{}

	subjectRows, err := r.db.Query(
		`SELECT id, COALESCE(name_ar,''), COALESCE(name_fr,'') FROM subjects WHERE name_ar LIKE ? OR name_fr LIKE ? LIMIT 20`,
		like, like,
	)
	if err != nil {
		return nil, err
	}
	defer subjectRows.Close()
	for subjectRows.Next() {
		var id int
		var nameAr, nameFr string
		if err := subjectRows.Scan(&id, &nameAr, &nameFr); err != nil {
			continue
		}
		title := nameAr
		if title == "" {
			title = nameFr
		}
		results = append(results, SearchResult{Type: "subject", ID: id, Title: title, Extra: nameFr})
	}

	lessonRows, err := r.db.Query(
		`SELECT id, COALESCE(title,''), COALESCE(description,'') FROM lessons WHERE title LIKE ? LIMIT 20`,
		like,
	)
	if err != nil {
		return nil, err
	}
	defer lessonRows.Close()
	for lessonRows.Next() {
		var id int
		var title, desc string
		if err := lessonRows.Scan(&id, &title, &desc); err != nil {
			continue
		}
		extra := desc
		if len(extra) > 60 {
			extra = extra[:60] + "..."
		}
		results = append(results, SearchResult{Type: "lesson", ID: id, Title: title, Extra: extra})
	}

	exerciseRows, err := r.db.Query(
		`SELECT id, COALESCE(title,''), COALESCE(difficulty,'') FROM exercises WHERE title LIKE ? LIMIT 20`,
		like,
	)
	if err != nil {
		return nil, err
	}
	defer exerciseRows.Close()
	for exerciseRows.Next() {
		var id int
		var title, difficulty string
		if err := exerciseRows.Scan(&id, &title, &difficulty); err != nil {
			continue
		}
		results = append(results, SearchResult{Type: "exercise", ID: id, Title: title, Extra: difficulty})
	}

	teacherRows, err := r.db.Query(
		`SELECT id, COALESCE(full_name,''), COALESCE(bio,'') FROM teachers WHERE full_name LIKE ? LIMIT 20`,
		like,
	)
	if err != nil {
		return nil, err
	}
	defer teacherRows.Close()
	for teacherRows.Next() {
		var id int
		var name, bio string
		if err := teacherRows.Scan(&id, &name, &bio); err != nil {
			continue
		}
		extra := bio
		if len(extra) > 60 {
			extra = extra[:60] + "..."
		}
		results = append(results, SearchResult{Type: "teacher", ID: id, Title: name, Extra: extra})
	}

	return results, nil
}
