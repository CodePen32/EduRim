package models

type Subject struct {
	ID             uint    `json:"id"`
	LearningPathID uint    `json:"learning_path_id"`
	BacBranchID    *uint   `json:"bac_branch_id"`
	NameAr         string  `json:"name_ar"`
	NameFr         string  `json:"name_fr"`
	Icon           string  `json:"icon"`
	Color          string  `json:"color"`
	SortOrder      int     `json:"sort_order"`
	CoverImageURL  string  `json:"cover_image_url"`
	LessonsCount   int     `json:"lessons_count"`
}
