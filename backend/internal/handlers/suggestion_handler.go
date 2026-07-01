package handlers

import (
	"net/http"
	"strconv"
	"strings"

	"edurim/backend/internal/repositories"

	"github.com/gin-gonic/gin"
)

type SuggestionHandler struct {
	repo *repositories.SuggestionRepository
}

func NewSuggestionHandler(repo *repositories.SuggestionRepository) *SuggestionHandler {
	return &SuggestionHandler{repo: repo}
}

// validStatuses mirrors the DB enum.
var validSuggestionStatus = map[string]bool{"new": true, "reviewing": true, "done": true, "rejected": true}

// POST /api/me/suggestions  { "title": "...", "description": "..." }
func (h *SuggestionHandler) Create(c *gin.Context) {
	userID := getUserID(c)
	if userID == 0 {
		c.JSON(http.StatusUnauthorized, gin.H{"message": "غير مصرح"})
		return
	}
	var req struct {
		Title       string `json:"title"`
		Description string `json:"description"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "بيانات غير صالحة"})
		return
	}
	req.Title = strings.TrimSpace(req.Title)
	req.Description = strings.TrimSpace(req.Description)
	if len([]rune(req.Title)) < 3 {
		c.JSON(http.StatusBadRequest, gin.H{"message": "العنوان يجب أن لا يقل عن 3 أحرف"})
		return
	}
	if len([]rune(req.Description)) < 10 {
		c.JSON(http.StatusBadRequest, gin.H{"message": "الوصف يجب أن لا يقل عن 10 أحرف"})
		return
	}
	if err := h.repo.Create(userID, req.Title, req.Description); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "تعذر إرسال الاقتراح"})
		return
	}
	c.JSON(http.StatusCreated, gin.H{"message": "تم إرسال اقتراحك بنجاح"})
}

// GET /api/admin/suggestions
func (h *SuggestionHandler) GetAll(c *gin.Context) {
	list, err := h.repo.GetAll()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "تعذر تحميل الاقتراحات"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"data": list})
}

// PATCH /api/admin/suggestions/:id/status  { "status": "reviewing|done|rejected|new" }
func (h *SuggestionHandler) UpdateStatus(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "معرّف غير صالح"})
		return
	}
	var req struct {
		Status string `json:"status"`
	}
	if err := c.ShouldBindJSON(&req); err != nil || !validSuggestionStatus[req.Status] {
		c.JSON(http.StatusBadRequest, gin.H{"error": "حالة غير صالحة"})
		return
	}
	if err := h.repo.UpdateStatus(id, req.Status); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "تعذر تحديث الحالة"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "تم تحديث الحالة"})
}
