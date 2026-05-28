package models

import "time"

type Lesson struct {
	ID              uint      `json:"id"`
	UnitID          uint      `json:"unit_id"`
	SubjectID       uint      `json:"subject_id"`
	TeacherID       uint      `json:"teacher_id"`
	Title           string    `json:"title"`
	Description     string    `json:"description"`
	VideoURL        string    `json:"video_url"`
	SummaryURL      string    `json:"summary_url"`
	CoverImageURL   string    `json:"cover_image_url"`
	DurationMinutes int       `json:"duration_minutes"`
	IsFree          bool      `json:"is_free"`
	SortOrder       int       `json:"sort_order"`
	CreatedAt       time.Time `json:"created_at"`
}
