package repositories

import (
	"database/sql"
	"errors"
)

var ErrAdminNotFound = errors.New("admin not found")

type Admin struct {
	ID           int    `json:"id"`
	FullName     string `json:"full_name"`
	Email        string `json:"email"`
	PasswordHash string `json:"-"`
	Role         string `json:"role"`
	IsActive     bool   `json:"is_active"`
}

type AdminRepository struct {
	db *sql.DB
}

func NewAdminRepository(db *sql.DB) *AdminRepository {
	return &AdminRepository{db: db}
}

func (r *AdminRepository) GetByEmail(email string) (*Admin, error) {
	admin := &Admin{}
	err := r.db.QueryRow(`SELECT id, full_name, email, password_hash, role, is_active FROM admins WHERE email = ?`, email).
		Scan(&admin.ID, &admin.FullName, &admin.Email, &admin.PasswordHash, &admin.Role, &admin.IsActive)
	if err == sql.ErrNoRows {
		return nil, ErrAdminNotFound
	}
	return admin, err
}

func (r *AdminRepository) GetByID(id int) (*Admin, error) {
	admin := &Admin{}
	err := r.db.QueryRow(`SELECT id, full_name, email, password_hash, role, is_active FROM admins WHERE id = ?`, id).
		Scan(&admin.ID, &admin.FullName, &admin.Email, &admin.PasswordHash, &admin.Role, &admin.IsActive)
	if err == sql.ErrNoRows {
		return nil, ErrAdminNotFound
	}
	return admin, err
}
