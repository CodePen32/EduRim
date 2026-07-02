package handlers

import (
	"net/http"
	"strconv"

	"edurim/backend/internal/cache"
	"edurim/backend/internal/repositories"

	"github.com/gin-gonic/gin"
)

type LearningPathHandler struct {
	repo    *repositories.LearningPathRepository
	bacRepo *repositories.BacBranchRepository
}

func NewLearningPathHandler(repo *repositories.LearningPathRepository, bacRepo *repositories.BacBranchRepository) *LearningPathHandler {
	return &LearningPathHandler{repo: repo, bacRepo: bacRepo}
}

func (h *LearningPathHandler) GetLearningPaths(c *gin.Context) {
	paths, err := h.repo.GetAll()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "خطأ في جلب مسارات التعلم"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"data": paths})
}

func (h *LearningPathHandler) GetBacBranches(c *gin.Context) {
	branches, err := h.bacRepo.GetAll()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "خطأ في جلب شعب الباكالوريا"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"data": branches})
}

// GET /api/admin/learning-paths — every path (enabled and disabled).
func (h *LearningPathHandler) GetAdminLearningPaths(c *gin.Context) {
	paths, err := h.repo.GetAllForAdmin()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "خطأ في جلب مسارات التعلم"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"data": paths})
}

// PATCH /api/admin/learning-paths/:id/enabled — body: {"enabled": true|false}
func (h *LearningPathHandler) SetLearningPathEnabled(c *gin.Context) {
	id, err := strconv.ParseInt(c.Param("id"), 10, 64)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "معرّف غير صالح"})
		return
	}
	var body struct {
		Enabled bool `json:"enabled"`
	}
	if err := c.ShouldBindJSON(&body); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "بيانات غير صالحة"})
		return
	}
	if err := h.repo.SetEnabled(id, body.Enabled); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "تعذر تحديث حالة المسار"})
		return
	}
	cache.LearningPaths.Clear()
	c.JSON(http.StatusOK, gin.H{"message": "تم تحديث حالة المسار"})
}
