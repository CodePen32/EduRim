package handlers

import (
	"log"
	"net/http"
	"path"
	"strings"

	"edurim/backend/internal/services"

	"github.com/gin-gonic/gin"
)

// FileProxySvc is the storage service used to fetch files.
// Set at startup alongside StorageSvc.
var FileProxySvc services.FileReader

func SetFileReader(f services.FileReader) { FileProxySvc = f }

// allowedFilePrefixes are the only top-level folders ServeFile may read from.
var allowedFilePrefixes = []string{"images/", "videos/", "pdfs/", "documents/", "uploads/"}

// sanitizeFileKey normalizes key and ensures it stays within an allowed
// prefix with no path traversal. Returns the cleaned key, or "" if invalid.
func sanitizeFileKey(key string) string {
	if strings.ContainsRune(key, 0) {
		return ""
	}
	// Reject raw traversal/backslash/double-slash markers before cleaning,
	// since path.Clean would otherwise silently resolve "..".
	if strings.Contains(key, "..") || strings.Contains(key, "\\") || strings.Contains(key, "//") {
		return ""
	}

	cleaned := path.Clean("/" + key)
	cleaned = strings.TrimPrefix(cleaned, "/")

	if cleaned == "" || cleaned == "." {
		return ""
	}

	for _, prefix := range allowedFilePrefixes {
		if strings.HasPrefix(cleaned, prefix) && len(cleaned) > len(prefix) {
			return cleaned
		}
	}
	return ""
}

// ServeFile proxies GET /api/files/*key from R2 (or local disk).
// The key is everything after /api/files/, e.g. "images/1234567890.jpg"
func ServeFile(c *gin.Context) {
	rawKey := c.Param("key")
	// Gin wildcard params include the leading slash
	rawKey = strings.TrimPrefix(rawKey, "/")
	if rawKey == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "مسار الملف مطلوب"})
		return
	}

	key := sanitizeFileKey(rawKey)
	if key == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "مسار الملف غير صالح"})
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
