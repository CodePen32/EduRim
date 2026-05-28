package handlers

import (
	"net/http"
	"strconv"

	"edurim/backend/internal/repositories"

	"github.com/gin-gonic/gin"
)

type AdminUsersHandler struct {
	repo *repositories.AdminUsersRepository
}

func NewAdminUsersHandler(repo *repositories.AdminUsersRepository) *AdminUsersHandler {
	return &AdminUsersHandler{repo: repo}
}

// GET /api/admin/users
func (h *AdminUsersHandler) GetUsers(c *gin.Context) {
	f := repositories.AdminUsersFilter{IsActive: -1}
	f.Search = c.Query("search")
	if v, err := strconv.Atoi(c.Query("learning_path_id")); err == nil { f.LearningPathID = v }
	if v, err := strconv.Atoi(c.Query("bac_branch_id")); err == nil { f.BacBranchID = v }
	if v := c.Query("is_active"); v == "1" { f.IsActive = 1 } else if v == "0" { f.IsActive = 0 }
	if v, err := strconv.Atoi(c.Query("limit")); err == nil { f.Limit = v }
	if v, err := strconv.Atoi(c.Query("offset")); err == nil { f.Offset = v }

	users, total, err := h.repo.GetAll(f)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "خطأ في الخادم"})
		return
	}
	if users == nil { users = []repositories.AdminUser{} }
	c.JSON(http.StatusOK, gin.H{"users": users, "total": total})
}

// GET /api/admin/users/:id
func (h *AdminUsersHandler) GetUser(c *gin.Context) {
	id, _ := strconv.Atoi(c.Param("id"))
	user, err := h.repo.GetByID(id)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "المستخدم غير موجود"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"user": user})
}

// PUT /api/admin/users/:id
func (h *AdminUsersHandler) UpdateUser(c *gin.Context) {
	id, _ := strconv.Atoi(c.Param("id"))
	var req struct {
		FullName       string `json:"full_name"`
		Email          string `json:"email"`
		Phone          string `json:"phone"`
		City           string `json:"city"`
		Gender         string `json:"gender"`
		LearningPathID *int   `json:"learning_path_id"`
		BacBranchID    *int   `json:"bac_branch_id"`
		IsActive       bool   `json:"is_active"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "بيانات غير صالحة"})
		return
	}
	// Clear bac_branch_id if not BAC path
	if req.LearningPathID == nil || *req.LearningPathID != 3 {
		req.BacBranchID = nil
	}
	if err := h.repo.Update(id, req.FullName, req.Email, req.Phone, req.City, req.Gender, req.LearningPathID, req.BacBranchID, req.IsActive); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "تعذر التعديل"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "تم التعديل بنجاح"})
}

// PATCH /api/admin/users/:id/toggle-active
func (h *AdminUsersHandler) ToggleActive(c *gin.Context) {
	id, _ := strconv.Atoi(c.Param("id"))
	newVal, err := h.repo.ToggleActive(id)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "تعذر تغيير الحالة"})
		return
	}
	msg := "تم تفعيل الحساب"
	if !newVal { msg = "تم تعطيل الحساب" }
	c.JSON(http.StatusOK, gin.H{"message": msg, "is_active": newVal})
}
