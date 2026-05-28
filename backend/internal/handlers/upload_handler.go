package handlers

import (
	"fmt"
	"io"
	"net/http"
	"os"
	"path/filepath"
	"strings"
	"time"

	"github.com/gin-gonic/gin"
)

var allowedExts = map[string]bool{
	".jpg": true, ".jpeg": true, ".png": true, ".webp": true,
	".pdf": true,
	".mp4": true, ".webm": true, ".mov": true,
}

var maxSizes = map[string]int64{
	".mp4": 200 * 1024 * 1024, ".webm": 200 * 1024 * 1024, ".mov": 200 * 1024 * 1024,
}

func UploadHandler(c *gin.Context) {
	file, header, err := c.Request.FormFile("file")
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "لم يتم رفع أي ملف"})
		return
	}
	defer file.Close()

	ext := strings.ToLower(filepath.Ext(header.Filename))
	if !allowedExts[ext] {
		c.JSON(http.StatusBadRequest, gin.H{"error": "نوع الملف غير مسموح. المسموح: jpg, png, pdf, mp4, webm, mov"})
		return
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

	uploadType := c.DefaultQuery("type", "covers")
	var dir string
	isVideo := ext == ".mp4" || ext == ".webm" || ext == ".mov"
	if isVideo {
		dir = "uploads/videos"
	} else {
		switch uploadType {
		case "images":
			dir = "uploads/images"
		case "files":
			dir = "uploads/files"
		default:
			dir = "uploads/covers"
		}
	}

	if err := os.MkdirAll(dir, 0755); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "خطأ في الخادم"})
		return
	}

	filename := fmt.Sprintf("%d%s", time.Now().UnixNano(), ext)
	destPath := filepath.Join(dir, filename)

	dest, err := os.Create(destPath)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "خطأ في حفظ الملف"})
		return
	}
	defer dest.Close()
	io.Copy(dest, file)

	url := "/" + strings.ReplaceAll(destPath, "\\", "/")
	c.JSON(http.StatusOK, gin.H{"url": url})
}
