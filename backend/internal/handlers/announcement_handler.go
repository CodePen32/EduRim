package handlers

import (
	"database/sql"
	"net/http"
	"strconv"
	"time"

	"edurim/backend/internal/cache"
	"edurim/backend/internal/database"
	"edurim/backend/internal/repositories"

	"github.com/gin-gonic/gin"
)

type AnnouncementHandler struct {
	repo *repositories.AnnouncementRepository
}

func NewAnnouncementHandler(repo *repositories.AnnouncementRepository) *AnnouncementHandler {
	return &AnnouncementHandler{repo: repo}
}

// GET /api/admin/announcements?learning_path_id=&bac_branch_id=
func (h *AnnouncementHandler) GetAdminAnnouncements(c *gin.Context) {
	lpID, _ := strconv.Atoi(c.Query("learning_path_id"))
	bacID, _ := strconv.Atoi(c.Query("bac_branch_id"))
	list, err := h.repo.GetForAdmin(lpID, bacID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "تعذر جلب الإعلانات"})
		return
	}
	if list == nil {
		list = []repositories.Announcement{}
	}
	c.JSON(http.StatusOK, gin.H{"announcements": list})
}

// GET /api/me/announcements — returns active announcements for the authenticated student
func (h *AnnouncementHandler) GetMyAnnouncements(c *gin.Context) {
	userIDVal, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"message": "غير مصرح"})
		return
	}
	userID := userIDVal.(uint)

	if database.DB == nil {
		c.JSON(http.StatusServiceUnavailable, gin.H{"message": "قاعدة البيانات غير متصلة"})
		return
	}

	var lpID, bacID sql.NullInt64
	_ = database.DB.QueryRow(`SELECT learning_path_id, bac_branch_id FROM users WHERE id=?`, userID).
		Scan(&lpID, &bacID)

	lp := 0
	bac := -1 // -1 = لم تُعيَّن الشعبة بعد
	if lpID.Valid {
		lp = int(lpID.Int64)
	}
	if bacID.Valid {
		bac = int(bacID.Int64)
	}

	list, err := h.repo.GetActiveForUser(lp, bac)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "تعذر جلب الإعلانات"})
		return
	}
	if list == nil {
		list = []repositories.Announcement{}
	}
	c.JSON(http.StatusOK, gin.H{"data": list})
}

// POST /api/admin/announcements
func (h *AnnouncementHandler) CreateAnnouncement(c *gin.Context) {
	var req announcementRequest
	if err := c.ShouldBindJSON(&req); err != nil || req.Title == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "العنوان مطلوب"})
		return
	}
	a := req.toModel()
	id, err := h.repo.Create(a)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "تعذر إنشاء الإعلان"})
		return
	}
	cache.ClearAnnouncementCache()
	c.JSON(http.StatusCreated, gin.H{"id": id, "message": "تم إنشاء الإعلان بنجاح"})
}

// PUT /api/admin/announcements/:id
func (h *AnnouncementHandler) UpdateAnnouncement(c *gin.Context) {
	id, _ := strconv.ParseInt(c.Param("id"), 10, 64)
	var req announcementRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "بيانات غير صالحة"})
		return
	}
	if err := h.repo.Update(id, req.toModel()); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "تعذر التحديث"})
		return
	}
	cache.ClearAnnouncementCache()
	c.JSON(http.StatusOK, gin.H{"message": "تم تحديث الإعلان"})
}

// PATCH /api/admin/announcements/:id/toggle-active
func (h *AnnouncementHandler) ToggleActive(c *gin.Context) {
	id, _ := strconv.ParseInt(c.Param("id"), 10, 64)
	if err := h.repo.ToggleActive(id); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "تعذر التبديل"})
		return
	}
	cache.ClearAnnouncementCache()
	c.JSON(http.StatusOK, gin.H{"message": "تم تبديل حالة الإعلان"})
}

// DELETE /api/admin/announcements/:id
func (h *AnnouncementHandler) DeleteAnnouncement(c *gin.Context) {
	id, _ := strconv.ParseInt(c.Param("id"), 10, 64)
	if err := h.repo.Delete(id); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "تعذر الحذف"})
		return
	}
	cache.ClearAnnouncementCache()
	c.JSON(http.StatusOK, gin.H{"message": "تم حذف الإعلان"})
}

// ─── Request DTO ─────────────────────────────────────────────────────────────

type announcementRequest struct {
	Title          string  `json:"title"`
	Message        string  `json:"message"`
	ImageURL       string  `json:"image_url"`
	LinkURL        string  `json:"link_url"`
	LearningPathID *int64  `json:"learning_path_id"`
	BacBranchID    *int64  `json:"bac_branch_id"`
	IsActive       bool    `json:"is_active"`
	StartsAt       *string `json:"starts_at"`
	EndsAt         *string `json:"ends_at"`
}

func (r announcementRequest) toModel() repositories.Announcement {
	a := repositories.Announcement{
		Title:          r.Title,
		Message:        r.Message,
		ImageURL:       r.ImageURL,
		LinkURL:        r.LinkURL,
		LearningPathID: r.LearningPathID,
		BacBranchID:    r.BacBranchID,
		IsActive:       r.IsActive,
	}
	if r.StartsAt != nil && *r.StartsAt != "" {
		if t, err := time.Parse("2006-01-02T15:04", *r.StartsAt); err == nil {
			a.StartsAt = &t
		}
	}
	if r.EndsAt != nil && *r.EndsAt != "" {
		if t, err := time.Parse("2006-01-02T15:04", *r.EndsAt); err == nil {
			a.EndsAt = &t
		}
	}
	return a
}
