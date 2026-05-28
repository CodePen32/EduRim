package handlers

import (
	"net/http"
	"strconv"

	"edurim/backend/internal/repositories"

	"github.com/gin-gonic/gin"
)

type PastExamHandler struct {
	repo *repositories.PastExamRepository
}

func NewPastExamHandler(repo *repositories.PastExamRepository) *PastExamHandler {
	return &PastExamHandler{repo: repo}
}

// GET /api/past-exams
func (h *PastExamHandler) GetPastExams(c *gin.Context) {
	f := repositories.PastExamFilter{}
	if v, err := strconv.Atoi(c.Query("subject_id")); err == nil {
		f.SubjectID = v
	}
	if v, err := strconv.Atoi(c.Query("learning_path_id")); err == nil {
		f.LearningPathID = v
	}
	if v, err := strconv.Atoi(c.Query("bac_branch_id")); err == nil {
		f.BacBranchID = v
	}
	if v, err := strconv.Atoi(c.Query("year")); err == nil {
		f.Year = v
	}

	exams, err := h.repo.GetFiltered(f)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "خطأ في الخادم"})
		return
	}
	if exams == nil {
		exams = []repositories.PastExam{}
	}
	c.JSON(http.StatusOK, gin.H{"past_exams": exams})
}

// GET /api/subjects/:id/past-exams
func (h *PastExamHandler) GetBySubject(c *gin.Context) {
	subjectID, _ := strconv.Atoi(c.Param("id"))
	exams, err := h.repo.GetBySubject(subjectID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "خطأ في الخادم"})
		return
	}
	if exams == nil {
		exams = []repositories.PastExam{}
	}
	c.JSON(http.StatusOK, gin.H{"past_exams": exams})
}
