package handlers

import (
	"net/http"
	"strconv"

	"edurim/backend/internal/repositories"

	"github.com/gin-gonic/gin"
)

type DownloadHandler struct {
	repo *repositories.DownloadRepository
}

func NewDownloadHandler(repo *repositories.DownloadRepository) *DownloadHandler {
	return &DownloadHandler{repo: repo}
}

func (h *DownloadHandler) GetDownloads(c *gin.Context) {
	userID := getUserID(c)
	limit, offset := parsePagination(c, 50, 100)
	list, err := h.repo.GetForUser(userID, limit, offset)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to fetch downloads"})
		return
	}
	if list == nil {
		list = []repositories.Download{}
	}
	c.JSON(http.StatusOK, gin.H{"downloads": list})
}

type downloadRequest struct {
	ItemType string `json:"item_type" binding:"required"`
	ItemID   int    `json:"item_id"   binding:"required"`
}

func (h *DownloadHandler) AddDownload(c *gin.Context) {
	userID := getUserID(c)
	var req downloadRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "item_type و item_id مطلوبان"})
		return
	}
	affected, err := h.repo.Add(userID, req.ItemType, req.ItemID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to save download"})
		return
	}
	if affected == 0 {
		c.JSON(http.StatusOK, gin.H{"message": "العنصر محفوظ بالفعل", "already_exists": true})
		return
	}
	c.JSON(http.StatusCreated, gin.H{"message": "تم الحفظ بنجاح"})
}

func (h *DownloadHandler) DeleteDownload(c *gin.Context) {
	userID := getUserID(c)
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid id"})
		return
	}
	if err := h.repo.Delete(id, userID); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to delete"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "تم الحذف"})
}
