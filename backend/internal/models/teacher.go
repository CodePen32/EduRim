package models

import "time"

type Teacher struct {
	ID        uint      `json:"id"`
	FullName  string    `json:"full_name"`
	SubjectID uint      `json:"subject_id"`
	AvatarURL string    `json:"avatar_url"`
	Bio       string    `json:"bio"`
	CreatedAt time.Time `json:"created_at"`
}
