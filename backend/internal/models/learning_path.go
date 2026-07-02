package models

import "time"

type LearningPath struct {
	ID          uint      `json:"id"`
	Code        string    `json:"code"`
	NameAr      string    `json:"name_ar"`
	NameFr      string    `json:"name_fr"`
	Description string    `json:"description"`
	CreatedAt   time.Time `json:"created_at"`
}

// AdminLearningPath includes the enabled flag, only exposed to the admin panel.
type AdminLearningPath struct {
	ID          uint      `json:"id"`
	Code        string    `json:"code"`
	NameAr      string    `json:"name_ar"`
	NameFr      string    `json:"name_fr"`
	Description string    `json:"description"`
	Enabled     bool      `json:"enabled"`
	CreatedAt   time.Time `json:"created_at"`
}

type BacBranch struct {
	ID     uint   `json:"id"`
	Code   string `json:"code"`
	NameAr string `json:"name_ar"`
	NameFr string `json:"name_fr"`
}
