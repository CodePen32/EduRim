package handlers

import (
	"net/http"

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
		c.JSON(http.StatusInternalServerError, gin.H{"message": "خطأ في جلب مسارات التعلم", "error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"data": paths})
}

func (h *LearningPathHandler) GetBacBranches(c *gin.Context) {
	branches, err := h.bacRepo.GetAll()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "خطأ في جلب شعب الباكالوريا", "error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"data": branches})
}
