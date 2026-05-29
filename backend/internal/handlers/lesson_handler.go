package handlers

import (
	"database/sql"
	"net/http"
	"strconv"

	"edurim/backend/internal/database"
	"edurim/backend/internal/models"
	"edurim/backend/internal/repositories"

	"github.com/gin-gonic/gin"
)

type LessonHandler struct {
	repo     *repositories.LessonRepository
	subRepo  *repositories.SubscriptionRepository
}

func NewLessonHandler(repo *repositories.LessonRepository, subRepo *repositories.SubscriptionRepository) *LessonHandler {
	return &LessonHandler{repo: repo, subRepo: subRepo}
}

// getUserLevel reads learning_path_id and bac_branch_id for the authenticated user.
// Returns (learningPathID, bacBranchID, ok). If any error occurs, ok=false.
func getUserLevel(c *gin.Context) (lp int, bac int, ok bool) {
	userID := getUserID(c)
	if userID == 0 || database.DB == nil {
		return 0, 0, false
	}
	var lpID, bacID sql.NullInt64
	err := database.DB.QueryRow(
		`SELECT learning_path_id, bac_branch_id FROM users WHERE id = ?`, userID,
	).Scan(&lpID, &bacID)
	if err != nil {
		return 0, 0, false
	}
	if lpID.Valid {
		lp = int(lpID.Int64)
	}
	if bacID.Valid {
		bac = int(bacID.Int64)
	}
	return lp, bac, true
}

func (h *LessonHandler) GetLessons(c *gin.Context) {
	subjectID, _ := strconv.Atoi(c.Query("subject_id"))
	teacherID, _ := strconv.Atoi(c.Query("teacher_id"))
	unitID, _ := strconv.Atoi(c.Query("unit_id"))

	lessons, err := h.repo.GetFiltered(subjectID, teacherID, unitID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "خطأ في جلب الدروس"})
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

// GetMyLessons — GET /api/me/lessons (JWT required)
// Returns only lessons belonging to the authenticated user's educational level.
func (h *LessonHandler) GetMyLessons(c *gin.Context) {
	lp, bac, ok := getUserLevel(c)
	if !ok || lp == 0 {
		c.JSON(http.StatusOK, gin.H{"data": []models.Lesson{}, "needs_path": true})
		return
	}
	if lp == 3 && bac == 0 {
		c.JSON(http.StatusOK, gin.H{"data": []models.Lesson{}, "needs_bac_branch": true})
		return
	}

	subjectID, _ := strconv.Atoi(c.Query("subject_id"))
	teacherID, _ := strconv.Atoi(c.Query("teacher_id"))
	unitID, _ := strconv.Atoi(c.Query("unit_id"))

	lessons, err := h.repo.GetFilteredForUser(subjectID, teacherID, unitID, lp, bac)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "خطأ في جلب الدروس"})
		return
	}
	if lessons == nil {
		lessons = []models.Lesson{}
	}
	c.JSON(http.StatusOK, gin.H{"data": lessons})
}

// GetMyLessonByID — GET /api/me/lessons/:id (JWT required)
// Returns a lesson only if it belongs to the authenticated user's educational level.
func (h *LessonHandler) GetMyLessonByID(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "معرف غير صالح"})
		return
	}

	lp, bac, ok := getUserLevel(c)
	if !ok || lp == 0 {
		c.JSON(http.StatusNotFound, gin.H{"message": "الدرس غير موجود"})
		return
	}

	lesson, err := h.repo.GetByIDForUser(id, lp, bac)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"message": "الدرس غير موجود"})
		return
	}

	// Paid content protection: strip URLs if user has no active subscription
	if !lesson.IsFree && h.subRepo != nil {
		userID := getUserID(c)
		if !h.subRepo.HasActiveSubscription(uint(userID)) {
			lesson.VideoURL = ""
			lesson.SummaryURL = ""
			c.JSON(http.StatusOK, gin.H{"data": lesson, "requires_subscription": true})
			return
		}
	}

	c.JSON(http.StatusOK, gin.H{"data": lesson})
}
