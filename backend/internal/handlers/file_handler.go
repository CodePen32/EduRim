package handlers

import (
	"log"
	"net/http"
	"strings"

	"edurim/backend/internal/services"

	"github.com/gin-gonic/gin"
)

// FileProxySvc is the storage service used to fetch files.
// Set at startup alongside StorageSvc.
var FileProxySvc services.FileReader

func SetFileReader(f services.FileReader) { FileProxySvc = f }

// ServeFile proxies GET /api/files/*key from R2 (or local disk).
// The key is everything after /api/files/, e.g. "images/1234567890.jpg"
func ServeFile(c *gin.Context) {
	key := c.Param("key")
	// Gin wildcard params include the leading slash
	key = strings.TrimPrefix(key, "/")
	if key == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "مسار الملف مطلوب"})
		return
	}

	if FileProxySvc == nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "file service not initialized"})
		return
	}

	body, contentType, err := FileProxySvc.Get(c.Request.Context(), key)
	if err != nil {
		log.Printf("[files] GET %q failed: %v", key, err)
		c.JSON(http.StatusNotFound, gin.H{"error": "الملف غير موجود"})
		return
	}
	defer body.Close()

	if contentType == "" {
		contentType = "application/octet-stream"
	}

	c.Header("Cache-Control", "public, max-age=31536000, immutable")
	c.DataFromReader(http.StatusOK, -1, contentType, body, nil)
}
