package handlers

import (
	"net/http"
	"strings"

	"github.com/gin-gonic/gin"
	"edurim/backend/internal/repositories"
)

type SearchHandler struct {
	repo *repositories.SearchRepository
}

func NewSearchHandler(repo *repositories.SearchRepository) *SearchHandler {
	return &SearchHandler{repo: repo}
}

func (h *SearchHandler) Search(c *gin.Context) {
	q := strings.TrimSpace(c.Query("q"))
	if q == "" {
		c.JSON(http.StatusOK, gin.H{"results": []interface{}{}})
		return
	}
	results, err := h.repo.Search(q)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "search failed"})
		return
	}
	if results == nil {
		results = []repositories.SearchResult{}
	}
	c.JSON(http.StatusOK, gin.H{"results": results})
}
