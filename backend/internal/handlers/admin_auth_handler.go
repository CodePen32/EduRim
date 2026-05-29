package handlers

import (
	"net/http"
	"time"

	"edurim/backend/internal/repositories"

	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v5"
	"golang.org/x/crypto/bcrypt"
)

type AdminAuthHandler struct {
	repo      *repositories.AdminRepository
	jwtSecret string
}

func NewAdminAuthHandler(repo *repositories.AdminRepository, jwtSecret string) *AdminAuthHandler {
	return &AdminAuthHandler{repo: repo, jwtSecret: jwtSecret}
}

// POST /api/admin/auth/login
func (h *AdminAuthHandler) Login(c *gin.Context) {
	var req struct {
		Email    string `json:"email" binding:"required"`
		Password string `json:"password" binding:"required"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "بيانات غير صالحة"})
		return
	}

	admin, err := h.repo.GetByEmail(req.Email)
	if err != nil || !admin.IsActive {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "البريد أو كلمة المرور غير صحيحة"})
		return
	}

	if err := bcrypt.CompareHashAndPassword([]byte(admin.PasswordHash), []byte(req.Password)); err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "البريد أو كلمة المرور غير صحيحة"})
		return
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"user_id": admin.ID,
		"type":    "admin",
		"role":    admin.Role,
		"exp":     time.Now().Add(24 * time.Hour).Unix(),
	})
	tokenStr, err := token.SignedString([]byte(h.jwtSecret))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "خطأ في الخادم"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"token": tokenStr,
		"admin": gin.H{
			"id":        admin.ID,
			"full_name": admin.FullName,
			"email":     admin.Email,
			"role":      admin.Role,
		},
	})
}

// GET /api/admin/auth/me
func (h *AdminAuthHandler) Me(c *gin.Context) {
	adminID, exists := c.Get("admin_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "غير مصرح"})
		return
	}
	var id float64
	switch v := adminID.(type) {
	case float64:
		id = v
	case uint:
		id = float64(v)
	default:
		c.JSON(http.StatusUnauthorized, gin.H{"error": "رمز غير صالح"})
		return
	}
	admin, err := h.repo.GetByID(int(id))
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "المسؤول غير موجود"})
		return
	}
	c.JSON(http.StatusOK, gin.H{
		"id":        admin.ID,
		"full_name": admin.FullName,
		"email":     admin.Email,
		"role":      admin.Role,
	})
}
