package handlers

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"edurim/backend/internal/repositories"
)

type ProgressHandler struct {
	repo *repositories.ProgressRepository
}

func NewProgressHandler(repo *repositories.ProgressRepository) *ProgressHandler {
	return &ProgressHandler{repo: repo}
}

func getUserID(c *gin.Context) int {
	if v, ok := c.Get("user_id"); ok {
		switch id := v.(type) {
		case uint:
			return int(id)
		case int:
			return id
		case float64:
			return int(id)
		}
	}
	return 0
}

func (h *ProgressHandler) GetProgress(c *gin.Context) {
	userID := getUserID(c)
	list, err := h.repo.GetByUser(userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to fetch progress"})
		return
	}
	if list == nil {
		list = []repositories.Progress{}
	}
	c.JSON(http.StatusOK, gin.H{"progress": list})
}

func (h *ProgressHandler) GetLastProgress(c *gin.Context) {
	userID := getUserID(c)
	p, err := h.repo.GetLast(userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to fetch progress"})
		return
	}
	if p == nil {
		c.JSON(http.StatusOK, gin.H{"progress": nil})
		return
	}
	c.JSON(http.StatusOK, gin.H{"progress": p})
}

type progressRequest struct {
	LessonID          int  `json:"lesson_id" binding:"required"`
	WatchedPercentage int  `json:"watched_percentage"`
	Completed         bool `json:"completed"`
}

func (h *ProgressHandler) GetStats(c *gin.Context) {
	userID := getUserID(c)
	stats, err := h.repo.GetStats(userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to fetch stats"})
		return
	}
	c.JSON(http.StatusOK, stats)
}

func (h *ProgressHandler) GetBySubject(c *gin.Context) {
	userID := getUserID(c)
	list, err := h.repo.GetBySubject(userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to fetch subject progress"})
		return
	}
	if list == nil {
		list = []repositories.SubjectProgress{}
	}
	c.JSON(http.StatusOK, gin.H{"subjects": list})
}

func (h *ProgressHandler) SaveProgress(c *gin.Context) {
	userID := getUserID(c)
	var req progressRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid request"})
		return
	}
	if err := h.repo.Upsert(userID, req.LessonID, req.WatchedPercentage, req.Completed); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to save progress"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "progress saved"})
}
