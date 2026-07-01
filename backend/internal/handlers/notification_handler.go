package handlers

import (
	"net/http"
	"strconv"

	"edurim/backend/internal/database"
	"edurim/backend/internal/repositories"
	"edurim/backend/internal/services"

	"github.com/gin-gonic/gin"
)

type NotificationHandler struct {
	repo    *repositories.NotificationRepository
	pushSvc *services.PushService
}

func NewNotificationHandler(repo *repositories.NotificationRepository, pushSvc *services.PushService) *NotificationHandler {
	return &NotificationHandler{repo: repo, pushSvc: pushSvc}
}

func (h *NotificationHandler) GetNotifications(c *gin.Context) {
	userID := getUserID(c)

	// جلب LP و BAC من DB
	var lpID, bacID *int
	if database.DB != nil {
		var lpRaw, bacRaw interface{}
		_ = database.DB.QueryRow(`SELECT learning_path_id, bac_branch_id FROM users WHERE id = ?`, userID).Scan(&lpRaw, &bacRaw)
		if lpRaw != nil {
			if id, ok := lpRaw.(int64); ok && id > 0 {
				v := int(id)
				lpID = &v
			}
		}
		if bacRaw != nil {
			if id, ok := bacRaw.(int64); ok && id > 0 {
				v := int(id)
				bacID = &v
			}
		}
	}

	limit, offset := parsePagination(c, 50, 100)
	list, err := h.repo.GetForUser(userID, lpID, bacID, limit, offset)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to fetch notifications"})
		return
	}
	if list == nil {
		list = []repositories.Notification{}
	}
	c.JSON(http.StatusOK, gin.H{"notifications": list})
}

func (h *NotificationHandler) UnreadCount(c *gin.Context) {
	userID := getUserID(c)
	count, err := h.repo.UnreadCount(userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"count": count})
}

// POST /api/admin/notifications
func (h *NotificationHandler) CreateNotification(c *gin.Context) {
	var req struct {
		UserID         *int   `json:"user_id"`
		Title          string `json:"title" binding:"required"`
		Message        string `json:"message" binding:"required"`
		Type           string `json:"type"`
		LearningPathID *int   `json:"learning_path_id"`
		BacBranchID    *int   `json:"bac_branch_id"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "بيانات غير صالحة"})
		return
	}
	if req.Type == "" {
		req.Type = "info"
	}
	err := h.repo.Create(req.UserID, req.Title, req.Message, req.Type, req.LearningPathID, req.BacBranchID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "تعذر إنشاء الإشعار"})
		return
	}

	// Best-effort push (disabled if Firebase not configured). Never fails the request.
	if h.pushSvc != nil && h.pushSvc.Enabled() {
		var tokens []string
		if req.UserID != nil {
			// Targeted at one user.
			if t, terr := h.repo.GetFCMTokenByUser(*req.UserID); terr == nil && t != "" {
				tokens = []string{t}
			}
		} else if req.LearningPathID != nil {
			// Scoped broadcast to a learning path / bac branch.
			if ts, terr := h.repo.GetFCMTokensByScope(*req.LearningPathID, req.BacBranchID); terr == nil {
				tokens = ts
			}
		}
		if len(tokens) > 0 {
			h.pushSvc.SendToTokens(tokens, req.Title, req.Message)
		}
	}

	c.JSON(http.StatusCreated, gin.H{"message": "تم إرسال الإشعار بنجاح"})
}

// GET /api/admin/notifications
func (h *NotificationHandler) GetAdminNotifications(c *gin.Context) {
	var lpID, bacID *int
	if v := c.Query("learning_path_id"); v != "" {
		if id, err := strconv.Atoi(v); err == nil {
			lpID = &id
		}
	}
	if v := c.Query("bac_branch_id"); v != "" {
		if id, err := strconv.Atoi(v); err == nil {
			bacID = &id
		}
	}
	limit, offset := parsePagination(c, 50, 100)
	list, err := h.repo.GetAdminList(lpID, bacID, limit, offset)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed"})
		return
	}
	if list == nil {
		list = []repositories.Notification{}
	}
	c.JSON(http.StatusOK, gin.H{"notifications": list})
}

func (h *NotificationHandler) MarkRead(c *gin.Context) {
	userID := getUserID(c)
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid id"})
		return
	}
	if err := h.repo.MarkRead(id, userID); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to mark as read"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "marked as read"})
}
