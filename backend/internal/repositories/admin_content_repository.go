package repositories

import "database/sql"

type AdminStats struct {
	TotalUsers     int `json:"total_users"`
	TotalSubjects  int `json:"total_subjects"`
	TotalLessons   int `json:"total_lessons"`
	TotalExercises int `json:"total_exercises"`
	TotalPastExams int `json:"total_past_exams"`
}

type AdminContentRepository struct {
	db *sql.DB
}

func NewAdminContentRepository(db *sql.DB) *AdminContentRepository {
	return &AdminContentRepository{db: db}
}

func (r *AdminContentRepository) GetStats(learningPathID, bacBranchID int) (*AdminStats, error) {
	stats := &AdminStats{}

	lpFilter := ""
	subjectFilter := ""
	args := []interface{}{}
	subjectArgs := []interface{}{}

	if learningPathID > 0 {
		lpFilter = " WHERE learning_path_id = ?"
		subjectFilter = " WHERE s.learning_path_id = ?"
		args = append(args, learningPathID)
		subjectArgs = append(subjectArgs, learningPathID)
		if bacBranchID > 0 {
			lpFilter += " AND bac_branch_id = ?"
			subjectFilter += " AND s.bac_branch_id = ?"
			args = append(args, bacBranchID)
			subjectArgs = append(subjectArgs, bacBranchID)
		}
	}

	r.db.QueryRow(`SELECT COUNT(*) FROM users`+lpFilter, args...).Scan(&stats.TotalUsers)
	r.db.QueryRow(`SELECT COUNT(*) FROM subjects`+lpFilter, args...).Scan(&stats.TotalSubjects)
	r.db.QueryRow(`SELECT COUNT(*) FROM lessons l JOIN subjects s ON s.id=l.subject_id`+subjectFilter, subjectArgs...).Scan(&stats.TotalLessons)
	r.db.QueryRow(`SELECT COUNT(*) FROM exercises e JOIN subjects s ON s.id=e.subject_id`+subjectFilter, subjectArgs...).Scan(&stats.TotalExercises)
	if learningPathID > 0 {
		peArgs := []interface{}{learningPathID}
		peFilter := " AND learning_path_id = ?"
		if bacBranchID > 0 {
			peFilter += " AND bac_branch_id = ?"
			peArgs = append(peArgs, bacBranchID)
		}
		r.db.QueryRow(`SELECT COUNT(*) FROM past_exams WHERE is_active=1`+peFilter, peArgs...).Scan(&stats.TotalPastExams)
	} else {
		r.db.QueryRow(`SELECT COUNT(*) FROM past_exams WHERE is_active=1`).Scan(&stats.TotalPastExams)
	}
	return stats, nil
}

// Subject CRUD (full)
func (r *AdminContentRepository) GetAllSubjects(learningPathID, bacBranchID int) ([]map[string]interface{}, error) {
	query := `SELECT s.id, s.name_ar, COALESCE(s.icon,''), COALESCE(s.color,'#1565C0'), s.learning_path_id,
	           COALESCE(s.bac_branch_id,0), COALESCE(s.cover_image_url,''), lp.name_ar
	          FROM subjects s JOIN learning_paths lp ON lp.id=s.learning_path_id WHERE 1=1`
	args := []interface{}{}
	if learningPathID > 0 {
		query += " AND s.learning_path_id = ?"
		args = append(args, learningPathID)
	}
	if bacBranchID > 0 {
		query += " AND s.bac_branch_id = ?"
		args = append(args, bacBranchID)
	}
	query += " ORDER BY s.learning_path_id, s.id"
	rows, err := r.db.Query(query, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var result []map[string]interface{}
	for rows.Next() {
		var id, lpID, bacID int
		var nameAr, icon, color, coverURL, lpName string
		rows.Scan(&id, &nameAr, &icon, &color, &lpID, &bacID, &coverURL, &lpName)
		result = append(result, map[string]interface{}{
			"id": id, "name_ar": nameAr, "icon": icon, "color": color,
			"learning_path_id": lpID, "bac_branch_id": bacID,
			"cover_image_url": coverURL, "learning_path_name": lpName,
		})
	}
	return result, rows.Err()
}

func (r *AdminContentRepository) CreateSubject(nameAr, icon, color string, lpID int, bacBranchID *int, coverURL string) (int, error) {
	var bacID interface{} = nil
	if bacBranchID != nil {
		bacID = *bacBranchID
	}
	res, err := r.db.Exec(`INSERT INTO subjects (name_ar, icon, color, learning_path_id, bac_branch_id, cover_image_url) VALUES (?,?,?,?,?,?)`, nameAr, icon, color, lpID, bacID, coverURL)
	if err != nil {
		return 0, err
	}
	id, _ := res.LastInsertId()
	return int(id), nil
}

func (r *AdminContentRepository) UpdateSubject(id int, nameAr, icon, color string, lpID int, bacBranchID *int, coverURL string) error {
	var bacID interface{} = nil
	if bacBranchID != nil {
		bacID = *bacBranchID
	}
	_, err := r.db.Exec(`UPDATE subjects SET name_ar=?, icon=?, color=?, learning_path_id=?, bac_branch_id=?, cover_image_url=? WHERE id=?`, nameAr, icon, color, lpID, bacID, coverURL, id)
	return err
}

func (r *AdminContentRepository) DeleteSubject(id int) error {
	_, err := r.db.Exec(`DELETE FROM subjects WHERE id=?`, id)
	return err
}

// Lesson CRUD (full)
func (r *AdminContentRepository) GetAllLessons(learningPathID, bacBranchID int) ([]map[string]interface{}, error) {
	query := `SELECT l.id, l.title, COALESCE(l.description,''), COALESCE(l.video_url,''), COALESCE(l.summary_url,''),
	           l.duration_minutes, l.is_free, l.subject_id, COALESCE(l.cover_image_url,''),
	           COALESCE(s.name_ar,''), COALESCE(l.teacher_id,0)
	          FROM lessons l LEFT JOIN subjects s ON s.id=l.subject_id WHERE 1=1`
	args := []interface{}{}
	if learningPathID > 0 {
		query += " AND s.learning_path_id = ?"
		args = append(args, learningPathID)
	}
	if bacBranchID > 0 {
		query += " AND s.bac_branch_id = ?"
		args = append(args, bacBranchID)
	}
	query += " ORDER BY l.id DESC"
	rows, err := r.db.Query(query, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var result []map[string]interface{}
	for rows.Next() {
		var id, dur, subjID, teacherID int
		var isFree bool
		var title, desc, videoURL, summaryURL, coverURL, subjName string
		rows.Scan(&id, &title, &desc, &videoURL, &summaryURL, &dur, &isFree, &subjID, &coverURL, &subjName, &teacherID)
		result = append(result, map[string]interface{}{
			"id": id, "title": title, "description": desc, "video_url": videoURL,
			"summary_url": summaryURL, "duration_minutes": dur, "is_free": isFree,
			"subject_id": subjID, "cover_image_url": coverURL, "subject_name": subjName, "teacher_id": teacherID,
		})
	}
	return result, rows.Err()
}

func (r *AdminContentRepository) CreateLesson(title, desc, videoURL, summaryURL string, dur int, isFree bool, subjectID, teacherID int, coverURL string) (int, error) {
	var tID interface{} = nil
	if teacherID > 0 {
		tID = teacherID
	}
	res, err := r.db.Exec(`INSERT INTO lessons (title, description, video_url, summary_url, duration_minutes, is_free, subject_id, teacher_id, cover_image_url) VALUES (?,?,?,?,?,?,?,?,?)`,
		title, desc, videoURL, summaryURL, dur, isFree, subjectID, tID, coverURL)
	if err != nil {
		return 0, err
	}
	id, _ := res.LastInsertId()
	return int(id), nil
}

func (r *AdminContentRepository) UpdateLesson(id int, title, desc, videoURL, summaryURL string, dur int, isFree bool, subjectID, teacherID int, coverURL string) error {
	var tID interface{} = nil
	if teacherID > 0 {
		tID = teacherID
	}
	_, err := r.db.Exec(`UPDATE lessons SET title=?, description=?, video_url=?, summary_url=?, duration_minutes=?, is_free=?, subject_id=?, teacher_id=?, cover_image_url=? WHERE id=?`,
		title, desc, videoURL, summaryURL, dur, isFree, subjectID, tID, coverURL, id)
	return err
}

func (r *AdminContentRepository) DeleteLesson(id int) error {
	_, err := r.db.Exec(`DELETE FROM lessons WHERE id=?`, id)
	return err
}

// Exercise CRUD (full)
func (r *AdminContentRepository) GetAllExercises(learningPathID, bacBranchID int) ([]map[string]interface{}, error) {
	query := `SELECT e.id, e.title, e.subject_id, COALESCE(s.name_ar,''), COALESCE(e.year,0), COALESCE(e.difficulty,'متوسط'),
	           COALESCE(e.exercise_file_url,''), COALESCE(e.solution_file_url,''),
	           COALESCE(e.video_solution_url,''), COALESCE(e.cover_image_url,'')
	          FROM exercises e LEFT JOIN subjects s ON s.id=e.subject_id WHERE 1=1`
	args := []interface{}{}
	if learningPathID > 0 {
		query += " AND s.learning_path_id = ?"
		args = append(args, learningPathID)
	}
	if bacBranchID > 0 {
		query += " AND s.bac_branch_id = ?"
		args = append(args, bacBranchID)
	}
	query += " ORDER BY e.id DESC"
	rows, err := r.db.Query(query, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var result []map[string]interface{}
	for rows.Next() {
		var id, year, subjID int
		var title, subjName, diff, examURL, solURL, vidURL, coverURL string
		rows.Scan(&id, &title, &subjID, &subjName, &year, &diff, &examURL, &solURL, &vidURL, &coverURL)
		result = append(result, map[string]interface{}{
			"id": id, "title": title, "subject_id": subjID, "subject_name": subjName,
			"year": year, "difficulty": diff, "exercise_file_url": examURL,
			"solution_file_url": solURL, "video_solution_url": vidURL, "cover_image_url": coverURL,
		})
	}
	return result, rows.Err()
}

func (r *AdminContentRepository) CreateExercise(title string, subjectID, year int, difficulty, examURL, solURL, vidURL, coverURL string) (int, error) {
	res, err := r.db.Exec(`INSERT INTO exercises (title, subject_id, year, difficulty, exercise_file_url, solution_file_url, video_solution_url, cover_image_url) VALUES (?,?,?,?,?,?,?,?)`,
		title, subjectID, year, difficulty, examURL, solURL, vidURL, coverURL)
	if err != nil {
		return 0, err
	}
	id, _ := res.LastInsertId()
	return int(id), nil
}

func (r *AdminContentRepository) UpdateExercise(id int, title string, subjectID, year int, difficulty, examURL, solURL, vidURL, coverURL string) error {
	_, err := r.db.Exec(`UPDATE exercises SET title=?, subject_id=?, year=?, difficulty=?, exercise_file_url=?, solution_file_url=?, video_solution_url=?, cover_image_url=? WHERE id=?`,
		title, subjectID, year, difficulty, examURL, solURL, vidURL, coverURL, id)
	return err
}

func (r *AdminContentRepository) DeleteExercise(id int) error {
	_, err := r.db.Exec(`DELETE FROM exercises WHERE id=?`, id)
	return err
}

// Teacher CRUD
func (r *AdminContentRepository) GetAllTeachers(learningPathID, bacBranchID, subjectID int) ([]map[string]interface{}, error) {
	query := `SELECT t.id, t.full_name, COALESCE(t.bio,''), COALESCE(t.subject_id,0),
	           COALESCE(s.name_ar,''), COALESCE(t.avatar_url,'')
	          FROM teachers t LEFT JOIN subjects s ON s.id=t.subject_id WHERE 1=1`
	args := []interface{}{}
	if subjectID > 0 {
		query += " AND t.subject_id = ?"
		args = append(args, subjectID)
	} else {
		if learningPathID > 0 {
			query += " AND s.learning_path_id = ?"
			args = append(args, learningPathID)
		}
		if bacBranchID > 0 {
			query += " AND s.bac_branch_id = ?"
			args = append(args, bacBranchID)
		}
	}
	query += " ORDER BY t.id"
	rows, err := r.db.Query(query, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var result []map[string]interface{}
	for rows.Next() {
		var id, subjID int
		var name, bio, subjName, avatarURL string
		rows.Scan(&id, &name, &bio, &subjID, &subjName, &avatarURL)
		result = append(result, map[string]interface{}{"id": id, "full_name": name, "bio": bio, "subject_id": subjID, "subject_name": subjName, "avatar_url": avatarURL})
	}
	return result, rows.Err()
}

func (r *AdminContentRepository) CreateTeacher(name, bio string, subjectID int, avatarURL string) (int, error) {
	var sID interface{} = nil
	if subjectID > 0 {
		sID = subjectID
	}
	res, err := r.db.Exec(`INSERT INTO teachers (full_name, bio, subject_id, avatar_url) VALUES (?,?,?,?)`, name, bio, sID, avatarURL)
	if err != nil {
		return 0, err
	}
	id, _ := res.LastInsertId()
	return int(id), nil
}

func (r *AdminContentRepository) UpdateTeacher(id int, name, bio string, subjectID int, avatarURL string) error {
	var sID interface{} = nil
	if subjectID > 0 {
		sID = subjectID
	}
	_, err := r.db.Exec(`UPDATE teachers SET full_name=?, bio=?, subject_id=?, avatar_url=? WHERE id=?`, name, bio, sID, avatarURL, id)
	return err
}

func (r *AdminContentRepository) DeleteTeacher(id int) error {
	_, err := r.db.Exec(`DELETE FROM teachers WHERE id=?`, id)
	return err
}
