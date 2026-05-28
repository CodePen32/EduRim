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

type BacBranch struct {
	ID     uint   `json:"id"`
	Code   string `json:"code"`
	NameAr string `json:"name_ar"`
	NameFr string `json:"name_fr"`
}
