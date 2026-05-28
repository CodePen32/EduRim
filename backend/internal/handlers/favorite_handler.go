package handlers

import (
	"net/http"
	"strconv"

	"edurim/backend/internal/repositories"

	"github.com/gin-gonic/gin"
)

type FavoriteHandler struct {
	repo *repositories.FavoriteRepository
}

func NewFavoriteHandler(repo *repositories.FavoriteRepository) *FavoriteHandler {
	return &FavoriteHandler{repo: repo}
}

func (h *FavoriteHandler) GetFavorites(c *gin.Context) {
	userID := getUserID(c)
	list, err := h.repo.GetForUser(userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to fetch favorites"})
		return
	}
	if list == nil {
		list = []repositories.Favorite{}
	}
	c.JSON(http.StatusOK, gin.H{"favorites": list})
}

type favoriteRequest struct {
	ItemType string `json:"item_type" binding:"required"`
	ItemID   int    `json:"item_id"   binding:"required"`
}

func (h *FavoriteHandler) AddFavorite(c *gin.Context) {
	userID := getUserID(c)
	var req favoriteRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "item_type و item_id مطلوبان"})
		return
	}
	affected, err := h.repo.Add(userID, req.ItemType, req.ItemID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to add favorite"})
		return
	}
	if affected == 0 {
		c.JSON(http.StatusOK, gin.H{"message": "العنصر موجود في المفضلة بالفعل", "already_exists": true})
		return
	}
	c.JSON(http.StatusCreated, gin.H{"message": "تمت الإضافة إلى المفضلة"})
}

func (h *FavoriteHandler) DeleteFavorite(c *gin.Context) {
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
	c.JSON(http.StatusOK, gin.H{"message": "تم الحذف من المفضلة"})
}
