package handlers

import (
	"net/http"
	"strconv"

	"edurim/backend/internal/models"
	"edurim/backend/internal/repositories"

	"github.com/gin-gonic/gin"
)


type TeacherHandler struct {
	repo *repositories.TeacherRepository
}

func NewTeacherHandler(repo *repositories.TeacherRepository) *TeacherHandler {
	return &TeacherHandler{repo: repo}
}

func (h *TeacherHandler) GetTeachers(c *gin.Context) {
	subjectID, _ := strconv.Atoi(c.Query("subject_id"))

	teachers, err := h.repo.GetFiltered(subjectID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "خطأ في جلب الأساتذة", "error": err.Error()})
		return
	}
	if teachers == nil {
		teachers = []models.Teacher{}
	}
	c.JSON(http.StatusOK, gin.H{"data": teachers})
}

func (h *TeacherHandler) GetTeacherByID(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "معرف غير صالح"})
		return
	}
	teacher, err := h.repo.GetByID(id)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"message": "الأستاذ غير موجود"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"data": teacher})
}

// GetMyTeachers — GET /api/me/teachers (JWT required)
// Returns only teachers whose subject belongs to the authenticated user's educational level.
func (h *TeacherHandler) GetMyTeachers(c *gin.Context) {
	lp, bac, ok := getUserLevel(c)
	if !ok || lp == 0 {
		c.JSON(http.StatusOK, gin.H{"data": []models.Teacher{}, "needs_path": true})
		return
	}
	if lp == 3 && bac == 0 {
		c.JSON(http.StatusOK, gin.H{"data": []models.Teacher{}, "needs_bac_branch": true})
		return
	}

	subjectID, _ := strconv.Atoi(c.Query("subject_id"))

	teachers, err := h.repo.GetFilteredForUser(subjectID, lp, bac)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "خطأ في جلب الأساتذة", "error": err.Error()})
		return
	}
	if teachers == nil {
		teachers = []models.Teacher{}
	}
	c.JSON(http.StatusOK, gin.H{"data": teachers})
}
