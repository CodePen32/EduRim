package models

import "time"

type User struct {
	ID             uint      `json:"id"`
	FullName       string    `json:"full_name"`
	Email          string    `json:"email"`
	Phone          string    `json:"phone"`
	PasswordHash   string    `json:"-"`
	LearningPathID *uint     `json:"learning_path_id"`
	BacBranchID    *uint     `json:"bac_branch_id"`
	City           string    `json:"city"`
	Gender         string    `json:"gender"`
	CreatedAt      time.Time `json:"created_at"`
	UpdatedAt      time.Time `json:"updated_at"`
}

type RegisterRequest struct {
	FullName       string `json:"full_name" binding:"required"`
	Email          string `json:"email" binding:"required,email"`
	Phone          string `json:"phone" binding:"required"`
	Password       string `json:"password" binding:"required,min=6"`
	Gender         string `json:"gender"`
	City           string `json:"city"`
	LearningPathID *uint  `json:"learning_path_id"`
	BacBranchID    *uint  `json:"bac_branch_id"`
}

// LoginRequest يدعم identifier (email أو phone) أو email مباشرة
type LoginRequest struct {
	Identifier string `json:"identifier"`
	Email      string `json:"email"`
	Phone      string `json:"phone"`
	Password   string `json:"password" binding:"required"`
}

type AuthResponse struct {
	Token string `json:"token"`
	User  User   `json:"user"`
}
