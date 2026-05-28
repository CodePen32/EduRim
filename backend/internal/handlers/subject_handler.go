package handlers

import (
	"net/http"
	"strconv"

	"edurim/backend/internal/repositories"

	"github.com/gin-gonic/gin"
)

type SubjectHandler struct {
	repo *repositories.SubjectRepository
}

func NewSubjectHandler(repo *repositories.SubjectRepository) *SubjectHandler {
	return &SubjectHandler{repo: repo}
}

func (h *SubjectHandler) GetSubjects(c *gin.Context) {
	lpID, _ := strconv.Atoi(c.Query("learning_path_id"))
	bacID, _ := strconv.Atoi(c.Query("bac_branch_id"))

	subjects, err := h.repo.GetAll(lpID, bacID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "خطأ في جلب المواد", "error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"data": subjects})
}

func (h *SubjectHandler) GetSubjectByID(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "معرف غير صالح"})
		return
	}
	subject, err := h.repo.GetByID(id)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"message": "المادة غير موجودة"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"data": subject})
}
