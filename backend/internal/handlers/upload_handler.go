package handlers

import (
	"fmt"
	"log"
	"net/http"
	"path/filepath"
	"strings"

	"edurim/backend/internal/services"

	"github.com/gin-gonic/gin"
)

var allowedExts = map[string]bool{
	".jpg": true, ".jpeg": true, ".png": true, ".webp": true,
	".pdf": true,
	".mp4": true, ".webm": true, ".mov": true,
}

// allowedContentTypes maps extensions to permitted MIME types.
var allowedContentTypes = map[string][]string{
	".jpg":  {"image/jpeg"},
	".jpeg": {"image/jpeg"},
	".png":  {"image/png"},
	".webp": {"image/webp"},
	".pdf":  {"application/pdf"},
	".mp4":  {"video/mp4"},
	".webm": {"video/webm"},
	".mov":  {"video/quicktime", "video/mp4"},
}

var maxSizes = map[string]int64{
	".mp4": 200 * 1024 * 1024, ".webm": 200 * 1024 * 1024, ".mov": 200 * 1024 * 1024,
}

// StorageSvc is set once at startup from main/routes via SetStorageService.
var StorageSvc services.StorageService

func SetStorageService(s services.StorageService) { StorageSvc = s }

func UploadHandler(c *gin.Context) {
	file, header, err := c.Request.FormFile("file")
	if err != nil {
		log.Printf("[upload] FormFile error: %v | Content-Type: %s", err, c.GetHeader("Content-Type"))
		c.JSON(http.StatusBadRequest, gin.H{"error": "لم يتم رفع أي ملف"})
		return
	}
	defer file.Close()

	ext := strings.ToLower(filepath.Ext(header.Filename))
	log.Printf("[upload] filename=%s ext=%s size=%d type-query=%s", header.Filename, ext, header.Size, c.Query("type"))

	if !allowedExts[ext] {
		log.Printf("[upload] rejected: extension %q not allowed", ext)
		c.JSON(http.StatusBadRequest, gin.H{"error": "نوع الملف غير مسموح. المسموح: jpg, png, pdf, mp4, webm, mov"})
		return
	}

	// Verify Content-Type header matches the declared extension
	ct := header.Header.Get("Content-Type")
	if ct != "" {
		// Strip params like "; boundary=..."
		if idx := strings.Index(ct, ";"); idx != -1 {
			ct = strings.TrimSpace(ct[:idx])
		}
		ct = strings.ToLower(ct)
		allowed := allowedContentTypes[ext]
		ok := false
		for _, a := range allowed {
			if ct == a {
				ok = true
				break
			}
		}
		if !ok {
			log.Printf("[upload] rejected: content-type %q does not match ext %q", ct, ext)
			c.JSON(http.StatusBadRequest, gin.H{"error": "نوع المحتوى لا يطابق امتداد الملف"})
			return
		}
	}

	maxSize := int64(20 * 1024 * 1024)
	if m, ok := maxSizes[ext]; ok {
		maxSize = m
	}
	if header.Size > maxSize {
		mb := maxSize / (1024 * 1024)
		c.JSON(http.StatusBadRequest, gin.H{"error": fmt.Sprintf("حجم الملف كبير جدًا (الحد الأقصى %dMB)", mb)})
		return
	}

	// Determine folder from ?type query param
	uploadType := c.DefaultQuery("type", "covers")
	isVideo := ext == ".mp4" || ext == ".webm" || ext == ".mov"
	var folder string
	if isVideo {
		folder = "videos"
	} else {
		switch uploadType {
		case "images":
			folder = "images"
		case "files":
			folder = "files"
		case "receipts":
			folder = "receipts"
		default:
			folder = "covers"
		}
	}

	if StorageSvc == nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "storage service not initialized"})
		return
	}

	url, err := StorageSvc.Upload(c.Request.Context(), folder, file, header)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "خطأ في رفع الملف"})
		return
	}

	// Response format unchanged: {"url": "..."}
	c.JSON(http.StatusOK, gin.H{"url": url})
}
