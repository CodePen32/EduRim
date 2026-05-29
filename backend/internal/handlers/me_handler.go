package handlers

import (
	"database/sql"
	"net/http"

	"edurim/backend/internal/database"
	"edurim/backend/internal/repositories"

	"github.com/gin-gonic/gin"
)

type MeHandler struct {
	subjectRepo *repositories.SubjectRepository
}

func NewMeHandler(subjectRepo *repositories.SubjectRepository) *MeHandler {
	return &MeHandler{subjectRepo: subjectRepo}
}

// GetMySubjects — يرجع المواد المناسبة للمستخدم حسب learning_path_id و bac_branch_id
func (h *MeHandler) GetMySubjects(c *gin.Context) {
	userIDVal, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"message": "غير مصرح"})
		return
	}
	userID := userIDVal.(uint)

	if database.DB == nil {
		c.JSON(http.StatusServiceUnavailable, gin.H{"message": "قاعدة البيانات غير متصلة"})
		return
	}

	var lpID, bacID sql.NullInt64
	err := database.DB.QueryRow(
		`SELECT learning_path_id, bac_branch_id FROM users WHERE id = ?`, userID,
	).Scan(&lpID, &bacID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "خطأ في جلب بيانات المستخدم"})
		return
	}

	lp := 0
	bac := 0
	if lpID.Valid {
		lp = int(lpID.Int64)
	}
	// لم يختر مسارًا بعد
	if lp == 0 {
		c.JSON(http.StatusOK, gin.H{"data": []interface{}{}, "needs_path": true})
		return
	}
	// BAC بدون شعبة — طلب اختيار الشعبة
	if lp == 3 && !bacID.Valid {
		c.JSON(http.StatusOK, gin.H{"data": []interface{}{}, "needs_bac_branch": true})
		return
	}
	if lp == 3 && bacID.Valid {
		bac = int(bacID.Int64)
	}

	subjects, err := h.subjectRepo.GetAll(lp, bac)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "خطأ في جلب المواد"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"data": subjects})
}
