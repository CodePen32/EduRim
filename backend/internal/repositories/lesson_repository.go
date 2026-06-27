package repositories

import (
	"database/sql"
	"edurim/backend/internal/models"
)

type LessonRepository struct {
	db *sql.DB
}

func NewLessonRepository(db *sql.DB) *LessonRepository {
	return &LessonRepository{db: db}
}

func (r *LessonRepository) GetAll() ([]models.Lesson, error) {
	return r.GetFiltered(0, 0, 0, 0, 0)
}

func (r *LessonRepository) GetFiltered(subjectID, teacherID, unitID, limit, offset int) ([]models.Lesson, error) {
	if r.db == nil {
		return nil, ErrNoDB
	}
	query := `SELECT id, COALESCE(unit_id,0), subject_id, COALESCE(teacher_id,0),
	                 title, COALESCE(description,''),
	                 COALESCE(video_url,''), COALESCE(summary_url,''),
	                 COALESCE(cover_image_url,''),
	                 duration_minutes, is_free, sort_order, created_at
	          FROM lessons WHERE 1=1`
	args := []interface{}{}
	if subjectID > 0 {
		query += " AND subject_id = ?"
		args = append(args, subjectID)
	}
	if teacherID > 0 {
		query += " AND teacher_id = ?"
		args = append(args, teacherID)
	}
	if unitID > 0 {
		query += " AND unit_id = ?"
		args = append(args, unitID)
	}
	query += " ORDER BY subject_id, sort_order, id"
	if limit > 0 {
		query += " LIMIT ? OFFSET ?"
		args = append(args, limit, offset)
	}

	rows, err := r.db.Query(query, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var lessons []models.Lesson
	for rows.Next() {
		var l models.Lesson
		if err := rows.Scan(
			&l.ID, &l.UnitID, &l.SubjectID, &l.TeacherID,
			&l.Title, &l.Description, &l.VideoURL, &l.SummaryURL,
			&l.CoverImageURL,
			&l.DurationMinutes, &l.IsFree, &l.SortOrder, &l.CreatedAt,
		); err != nil {
			return nil, err
		}
		lessons = append(lessons, l)
	}
	return lessons, rows.Err()
}

// GetFilteredForUser returns lessons filtered by user's learning path and bac branch.
// For learning_path_id=3 (Bac), bacBranchID must also match.
func (r *LessonRepository) GetFilteredForUser(subjectID, teacherID, unitID, learningPathID, bacBranchID, limit, offset int) ([]models.Lesson, error) {
	if r.db == nil {
		return nil, ErrNoDB
	}
	query := `SELECT l.id, COALESCE(l.unit_id,0), l.subject_id, COALESCE(l.teacher_id,0),
	                 l.title, COALESCE(l.description,''),
	                 COALESCE(l.video_url,''), COALESCE(l.summary_url,''),
	                 COALESCE(l.cover_image_url,''),
	                 l.duration_minutes, l.is_free, l.sort_order, l.created_at
	          FROM lessons l
	          JOIN subjects s ON s.id = l.subject_id
	          WHERE s.learning_path_id = ?`
	args := []interface{}{learningPathID}
	if learningPathID == 3 && bacBranchID > 0 {
		query += " AND s.bac_branch_id = ?"
		args = append(args, bacBranchID)
	}
	if subjectID > 0 {
		query += " AND l.subject_id = ?"
		args = append(args, subjectID)
	}
	if teacherID > 0 {
		query += " AND l.teacher_id = ?"
		args = append(args, teacherID)
	}
	if unitID > 0 {
		query += " AND l.unit_id = ?"
		args = append(args, unitID)
	}
	query += " ORDER BY l.subject_id, l.sort_order, l.id"
	if limit > 0 {
		query += " LIMIT ? OFFSET ?"
		args = append(args, limit, offset)
	}

	rows, err := r.db.Query(query, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var lessons []models.Lesson
	for rows.Next() {
		var l models.Lesson
		if err := rows.Scan(
			&l.ID, &l.UnitID, &l.SubjectID, &l.TeacherID,
			&l.Title, &l.Description, &l.VideoURL, &l.SummaryURL,
			&l.CoverImageURL,
			&l.DurationMinutes, &l.IsFree, &l.SortOrder, &l.CreatedAt,
		); err != nil {
			return nil, err
		}
		lessons = append(lessons, l)
	}
	return lessons, rows.Err()
}

// MyLessonsResult distinguishes the three states GetMyLessons needs to
// respond to, all resolved from a single round-trip: the user hasn't
// chosen a learning path yet, the user is on the Bac path but hasn't
// chosen a branch yet, or the user is fully set up (Lessons may still be
// empty if no lessons match — that's a normal, distinct outcome from the
// other two).
type MyLessonsResult struct {
	NeedsPath      bool
	NeedsBacBranch bool
	Lessons        []models.Lesson
}

// GetFilteredForUserByID resolves the user's learning_path_id/bac_branch_id
// and fetches their matching lessons in a single SQL round-trip, instead of
// a separate "SELECT learning_path_id, bac_branch_id FROM users" query
// followed by the lessons query. The query starts from `users` with LEFT
// JOINs so the user's row (and thus their lp/bac state) is always present
// even when zero lessons match — this is what lets Go tell "no path set"
// apart from "path set but no matching lessons".
func (r *LessonRepository) GetFilteredForUserByID(userID, subjectID, teacherID, unitID, limit, offset int) (*MyLessonsResult, error) {
	if r.db == nil {
		return nil, ErrNoDB
	}

	query := `SELECT u.learning_path_id, u.bac_branch_id,
	                 l.id, l.unit_id, l.subject_id, l.teacher_id,
	                 l.title, l.description,
	                 l.video_url, l.summary_url,
	                 l.cover_image_url,
	                 l.duration_minutes, l.is_free, l.sort_order, l.created_at
	          FROM users u
	          LEFT JOIN subjects s ON s.learning_path_id = u.learning_path_id
	                              AND (u.learning_path_id != 3 OR s.bac_branch_id = u.bac_branch_id)
	          LEFT JOIN lessons l ON l.subject_id = s.id`
	args := []interface{}{}
	if subjectID > 0 {
		query += " AND l.subject_id = ?"
		args = append(args, subjectID)
	}
	if teacherID > 0 {
		query += " AND l.teacher_id = ?"
		args = append(args, teacherID)
	}
	if unitID > 0 {
		query += " AND l.unit_id = ?"
		args = append(args, unitID)
	}
	query += " WHERE u.id = ?"
	args = append(args, userID)
	query += " ORDER BY l.subject_id, l.sort_order, l.id"
	if limit > 0 {
		query += " LIMIT ? OFFSET ?"
		args = append(args, limit, offset)
	}

	rows, err := r.db.Query(query, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	result := &MyLessonsResult{}
	first := true
	for rows.Next() {
		var lpID, bacID sql.NullInt64
		var lID, unitID, subjectID, teacherID sql.NullInt64
		var title, description, videoURL, summaryURL, coverImageURL sql.NullString
		var durationMinutes sql.NullInt64
		var isFree sql.NullBool
		var sortOrder sql.NullInt64
		var createdAt sql.NullTime

		if err := rows.Scan(
			&lpID, &bacID,
			&lID, &unitID, &subjectID, &teacherID,
			&title, &description, &videoURL, &summaryURL, &coverImageURL,
			&durationMinutes, &isFree, &sortOrder, &createdAt,
		); err != nil {
			return nil, err
		}

		if first {
			first = false
			lp := 0
			if lpID.Valid {
				lp = int(lpID.Int64)
			}
			if lp == 0 {
				result.NeedsPath = true
				return result, nil
			}
			if lp == 3 && !bacID.Valid {
				result.NeedsBacBranch = true
				return result, nil
			}
		}

		// No matching lesson row for this user (LEFT JOIN produced NULLs) —
		// the user's lp/bac is valid, they just have zero lessons.
		if !lID.Valid {
			continue
		}

		result.Lessons = append(result.Lessons, models.Lesson{
			ID:              uint(lID.Int64),
			UnitID:          uint(unitID.Int64),
			SubjectID:       uint(subjectID.Int64),
			TeacherID:       uint(teacherID.Int64),
			Title:           title.String,
			Description:     description.String,
			VideoURL:        videoURL.String,
			SummaryURL:      summaryURL.String,
			CoverImageURL:   coverImageURL.String,
			DurationMinutes: int(durationMinutes.Int64),
			IsFree:          isFree.Bool,
			SortOrder:       int(sortOrder.Int64),
			CreatedAt:       createdAt.Time,
		})
	}
	if err := rows.Err(); err != nil {
		return nil, err
	}

	// Zero rows at all means the user row itself wasn't found (deleted
	// between auth and this query) — treat the same as "no path set" since
	// there's nothing else sensible to return.
	if first {
		result.NeedsPath = true
	}

	return result, nil
}

// GetByIDForUser returns a lesson only if it belongs to the user's learning path/bac branch.
func (r *LessonRepository) GetByIDForUser(id, learningPathID, bacBranchID int) (*models.Lesson, error) {
	if r.db == nil {
		return nil, ErrNoDB
	}
	query := `SELECT l.id, COALESCE(l.unit_id,0), l.subject_id, COALESCE(l.teacher_id,0),
	                 l.title, COALESCE(l.description,''),
	                 COALESCE(l.video_url,''), COALESCE(l.summary_url,''),
	                 COALESCE(l.cover_image_url,''),
	                 l.duration_minutes, l.is_free, l.sort_order, l.created_at
	          FROM lessons l
	          JOIN subjects s ON s.id = l.subject_id
	          WHERE l.id = ? AND s.learning_path_id = ?`
	args := []interface{}{id, learningPathID}
	if learningPathID == 3 && bacBranchID > 0 {
		query += " AND s.bac_branch_id = ?"
		args = append(args, bacBranchID)
	}

	var l models.Lesson
	err := r.db.QueryRow(query, args...).Scan(
		&l.ID, &l.UnitID, &l.SubjectID, &l.TeacherID,
		&l.Title, &l.Description, &l.VideoURL, &l.SummaryURL,
		&l.CoverImageURL,
		&l.DurationMinutes, &l.IsFree, &l.SortOrder, &l.CreatedAt,
	)
	if err != nil {
		return nil, err
	}
	return &l, nil
}

func (r *LessonRepository) GetByID(id int) (*models.Lesson, error) {
	if r.db == nil {
		return nil, ErrNoDB
	}
	var l models.Lesson
	err := r.db.QueryRow(
		`SELECT id, COALESCE(unit_id,0), subject_id, COALESCE(teacher_id,0),
		        title, COALESCE(description,''),
		        COALESCE(video_url,''), COALESCE(summary_url,''),
		        COALESCE(cover_image_url,''),
		        duration_minutes, is_free, sort_order, created_at
		 FROM lessons WHERE id = ?`, id,
	).Scan(
		&l.ID, &l.UnitID, &l.SubjectID, &l.TeacherID,
		&l.Title, &l.Description, &l.VideoURL, &l.SummaryURL,
		&l.CoverImageURL,
		&l.DurationMinutes, &l.IsFree, &l.SortOrder, &l.CreatedAt,
	)
	if err != nil {
		return nil, err
	}
	return &l, nil
}
