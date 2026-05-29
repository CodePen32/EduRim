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

// GET /api/past-exams  (public — kept for backward compat but requires explicit LP filter)
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

// GET /api/me/past-exams  (JWT required — filters by user's LP and BAC)
func (h *PastExamHandler) GetMyPastExams(c *gin.Context) {
	lp, bac, ok := getUserLevel(c)
	if !ok || lp == 0 {
		c.JSON(http.StatusOK, gin.H{"past_exams": []repositories.PastExam{}, "needs_path": true})
		return
	}
	if lp == 3 && bac == 0 {
		c.JSON(http.StatusOK, gin.H{"past_exams": []repositories.PastExam{}, "needs_bac_branch": true})
		return
	}

	f := repositories.PastExamFilter{
		LearningPathID: lp,
		BacBranchID:    bac,
	}
	if v, err := strconv.Atoi(c.Query("subject_id")); err == nil {
		f.SubjectID = v
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

// GET /api/me/subjects/:id/past-exams  (JWT required — validates subject ownership)
func (h *PastExamHandler) GetMyPastExamsBySubject(c *gin.Context) {
	lp, bac, ok := getUserLevel(c)
	if !ok || lp == 0 {
		c.JSON(http.StatusOK, gin.H{"past_exams": []repositories.PastExam{}})
		return
	}
	if lp == 3 && bac == 0 {
		c.JSON(http.StatusOK, gin.H{"past_exams": []repositories.PastExam{}})
		return
	}

	subjectID, _ := strconv.Atoi(c.Param("id"))
	exams, err := h.repo.GetBySubjectForUser(subjectID, lp, bac)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "خطأ في الخادم"})
		return
	}
	if exams == nil {
		exams = []repositories.PastExam{}
	}
	c.JSON(http.StatusOK, gin.H{"past_exams": exams})
}

// GET /api/subjects/:id/past-exams  (public — kept for backward compat)
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
