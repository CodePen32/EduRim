package handlers

import (
	"fmt"
	"io"
	"log"
	"net/http"
	"path/filepath"
	"strings"

	"edurim/backend/internal/services"

	"github.com/gin-gonic/gin"
)

// allowedMIMEs maps detected MIME → canonical extension.
// These are the only content types we accept.
var allowedMIMEs = map[string]string{
	"image/jpeg":      ".jpg",
	"image/png":       ".png",
	"image/webp":      ".webp",
	"application/pdf": ".pdf",
	"video/mp4":       ".mp4",
	"video/webm":      ".webm",
	"video/quicktime": ".mov",
}

var maxSizes = map[string]int64{
	".mp4":  200 * 1024 * 1024,
	".webm": 200 * 1024 * 1024,
	".mov":  200 * 1024 * 1024,
}

// StorageSvc is set once at startup via SetStorageService.
var StorageSvc services.StorageService

func SetStorageService(s services.StorageService) { StorageSvc = s }

func UploadHandler(c *gin.Context) {
	file, header, err := c.Request.FormFile("file")
	if err != nil {
		log.Printf("[upload] FormFile error: %v | request Content-Type: %s", err, c.GetHeader("Content-Type"))
		c.JSON(http.StatusBadRequest, gin.H{"error": "لم يتم رفع أي ملف"})
		return
	}
	defer file.Close()

	// ── 1. Read first 512 bytes for magic-byte MIME detection ─────────────
	sniff := make([]byte, 512)
	n, _ := file.Read(sniff)
	detectedMIME := strings.ToLower(http.DetectContentType(sniff[:n]))
	if idx := strings.Index(detectedMIME, ";"); idx != -1 {
		detectedMIME = strings.TrimSpace(detectedMIME[:idx])
	}
	// Seek back to start so storage receives the full file
	if _, err := file.Seek(0, io.SeekStart); err != nil {
		log.Printf("[upload] seek error: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "خطأ في معالجة الملف"})
		return
	}

	filenameExt := strings.ToLower(filepath.Ext(header.Filename))

	log.Printf("[upload] filename=%q filenameExt=%q detectedMIME=%q declaredCT=%q size=%d typeQuery=%q",
		header.Filename, filenameExt, detectedMIME,
		header.Header.Get("Content-Type"), header.Size, c.Query("type"))

	// ── 2. Validate by magic bytes (most trustworthy) ─────────────────────
	canonicalExt, mimeOK := allowedMIMEs[detectedMIME]
	if !mimeOK {
		log.Printf("[upload] rejected: detected MIME %q not in allow-list", detectedMIME)
		c.JSON(http.StatusBadRequest, gin.H{"error": "نوع الملف غير مسموح. المسموح: jpg, png, pdf, mp4, webm, mov"})
		return
	}

	// Fix filename extension if missing or mismatched
	if filenameExt == "" {
		header.Filename += canonicalExt
		log.Printf("[upload] assigned extension %q to filename", canonicalExt)
	}

	// ── 3. Size check ──────────────────────────────────────────────────────
	maxSize := int64(20 * 1024 * 1024)
	if m, ok := maxSizes[canonicalExt]; ok {
		maxSize = m
	}
	if header.Size > maxSize {
		mb := maxSize / (1024 * 1024)
		c.JSON(http.StatusBadRequest, gin.H{"error": fmt.Sprintf("حجم الملف كبير جدًا (الحد الأقصى %dMB)", mb)})
		return
	}

	// ── 4. Route to correct storage folder ────────────────────────────────
	uploadType := c.DefaultQuery("type", "covers")
	isVideo := canonicalExt == ".mp4" || canonicalExt == ".webm" || canonicalExt == ".mov"
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
		log.Printf("[upload] storage error: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "خطأ في رفع الملف"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"url": url})
}
