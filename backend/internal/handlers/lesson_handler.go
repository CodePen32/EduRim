package handlers

import (
	"net/http"
	"strconv"

	"edurim/backend/internal/models"
	"edurim/backend/internal/repositories"

	"github.com/gin-gonic/gin"
)

type LessonHandler struct {
	repo *repositories.LessonRepository
}

func NewLessonHandler(repo *repositories.LessonRepository) *LessonHandler {
	return &LessonHandler{repo: repo}
}

func (h *LessonHandler) GetLessons(c *gin.Context) {
	subjectID, _ := strconv.Atoi(c.Query("subject_id"))
	teacherID, _ := strconv.Atoi(c.Query("teacher_id"))
	unitID, _ := strconv.Atoi(c.Query("unit_id"))

	lessons, err := h.repo.GetFiltered(subjectID, teacherID, unitID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "خطأ في جلب الدروس", "error": err.Error()})
		return
	}
	if lessons == nil {
		lessons = []models.Lesson{}
	}
	c.JSON(http.StatusOK, gin.H{"data": lessons})
}

func (h *LessonHandler) GetLessonByID(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "معرف غير صالح"})
		return
	}
	lesson, err := h.repo.GetByID(id)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"message": "الدرس غير موجود"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"data": lesson})
}
