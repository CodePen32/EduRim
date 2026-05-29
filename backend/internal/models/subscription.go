package models

import "time"

type SubscriptionPlan struct {
	ID             uint      `json:"id"`
	Name           string    `json:"name"`
	Description    string    `json:"description"`
	DurationDays   int       `json:"duration_days"`
	Price          float64   `json:"price"`
	LearningPathID *uint     `json:"learning_path_id"`
	BacBranchID    *uint     `json:"bac_branch_id"`
	IsActive       bool      `json:"is_active"`
	CreatedAt      time.Time `json:"created_at"`
}

type UserSubscription struct {
	ID               uint      `json:"id"`
	UserID           uint      `json:"user_id"`
	PlanID           uint      `json:"plan_id"`
	StartDate        string    `json:"start_date"`
	EndDate          string    `json:"end_date"`
	IsActive         bool      `json:"is_active"`
	Notes            string    `json:"notes"`
	CreatedAt        time.Time `json:"created_at"`
	// joined fields
	PlanName     string `json:"plan_name,omitempty"`
	UserFullName string `json:"user_full_name,omitempty"`
}

type SubscriptionRequest struct {
	ID                uint       `json:"id"`
	UserID            uint       `json:"user_id"`
	PlanID            uint       `json:"plan_id"`
	Phone             string     `json:"phone"`
	PaymentMethod     string     `json:"payment_method"`
	ReceiptImageURL   string     `json:"receipt_image_url"`
	Note              string     `json:"note"`
	Status            string     `json:"status"` // pending, approved, rejected
	AdminNote         string     `json:"admin_note"`
	ReviewedByAdminID *uint      `json:"reviewed_by_admin_id"`
	ReviewedAt        *time.Time `json:"reviewed_at"`
	CreatedAt         time.Time  `json:"created_at"`
	UpdatedAt         time.Time  `json:"updated_at"`
	// joined
	UserFullName string `json:"user_full_name,omitempty"`
	PlanName     string `json:"plan_name,omitempty"`
	DurationDays int    `json:"duration_days,omitempty"`
}

type MySubscriptionResponse struct {
	HasSubscription bool   `json:"has_subscription"`
	IsActive        bool   `json:"is_active"`
	PlanName        string `json:"plan_name"`
	StartDate       string `json:"start_date"`
	EndDate         string `json:"end_date"`
	DaysRemaining   int    `json:"days_remaining"`
}
