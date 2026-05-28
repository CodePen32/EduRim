package handlers

import (
	"net/http"
	"strconv"

	"edurim/backend/internal/models"
	"edurim/backend/internal/repositories"

	"github.com/gin-gonic/gin"
)

type ExerciseHandler struct {
	repo *repositories.ExerciseRepository
}

func NewExerciseHandler(repo *repositories.ExerciseRepository) *ExerciseHandler {
	return &ExerciseHandler{repo: repo}
}

func (h *ExerciseHandler) GetExercises(c *gin.Context) {
	subjectID, _ := strconv.Atoi(c.Query("subject_id"))
	lessonID, _ := strconv.Atoi(c.Query("lesson_id"))
	year, _ := strconv.Atoi(c.Query("year"))
	difficulty := c.Query("difficulty")

	exercises, err := h.repo.GetFiltered(subjectID, lessonID, year, difficulty)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "خطأ في جلب التمارين", "error": err.Error()})
		return
	}
	if exercises == nil {
		exercises = []models.Exercise{}
	}
	c.JSON(http.StatusOK, gin.H{"data": exercises})
}

func (h *ExerciseHandler) GetExerciseByID(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "معرف غير صالح"})
		return
	}
	exercise, err := h.repo.GetByID(id)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"message": "التمرين غير موجود"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"data": exercise})
}
