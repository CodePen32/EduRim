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
		c.JSON(http.StatusInternalServerError, gin.H{"message": "خطأ في جلب التمارين"})
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

// GetMyExercises — GET /api/me/exercises (JWT required)
// Returns only exercises belonging to the authenticated user's educational level.
func (h *ExerciseHandler) GetMyExercises(c *gin.Context) {
	lp, bac, ok := getUserLevel(c)
	if !ok || lp == 0 {
		c.JSON(http.StatusOK, gin.H{"data": []models.Exercise{}, "needs_path": true})
		return
	}
	if lp == 3 && bac == 0 {
		c.JSON(http.StatusOK, gin.H{"data": []models.Exercise{}, "needs_bac_branch": true})
		return
	}

	subjectID, _ := strconv.Atoi(c.Query("subject_id"))
	lessonID, _ := strconv.Atoi(c.Query("lesson_id"))
	year, _ := strconv.Atoi(c.Query("year"))
	difficulty := c.Query("difficulty")

	exercises, err := h.repo.GetFilteredForUser(subjectID, lessonID, year, difficulty, lp, bac)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "خطأ في جلب التمارين"})
		return
	}
	if exercises == nil {
		exercises = []models.Exercise{}
	}
	c.JSON(http.StatusOK, gin.H{"data": exercises})
}

// GetMyExerciseByID — GET /api/me/exercises/:id (JWT required)
// Returns an exercise only if it belongs to the authenticated user's educational level.
func (h *ExerciseHandler) GetMyExerciseByID(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "معرف غير صالح"})
		return
	}

	lp, bac, ok := getUserLevel(c)
	if !ok || lp == 0 {
		c.JSON(http.StatusNotFound, gin.H{"message": "التمرين غير موجود"})
		return
	}

	exercise, err := h.repo.GetByIDForUser(id, lp, bac)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"message": "التمرين غير موجود"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"data": exercise})
}
