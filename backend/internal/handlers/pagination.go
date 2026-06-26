package handlers

import (
	"strconv"

	"github.com/gin-gonic/gin"
)

// parsePagination reads optional ?limit=&offset= query params, falling back
// to defaultLimit when absent/invalid so existing clients (Flutter/Admin)
// that don't send these params still get a bounded result set instead of
// every row in the table. limit is capped at maxLimit to prevent abuse.
func parsePagination(c *gin.Context, defaultLimit, maxLimit int) (limit, offset int) {
	limit = defaultLimit
	if v := c.Query("limit"); v != "" {
		if n, err := strconv.Atoi(v); err == nil && n > 0 {
			limit = n
		}
	}
	if limit > maxLimit {
		limit = maxLimit
	}

	if v := c.Query("offset"); v != "" {
		if n, err := strconv.Atoi(v); err == nil && n >= 0 {
			offset = n
		}
	}
	return limit, offset
}
