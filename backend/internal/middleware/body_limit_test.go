package middleware

import (
	"bytes"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"
)

func TestMaxBodyBytes_AllowsUnderLimit(t *testing.T) {
	gin.SetMode(gin.TestMode)
	r := gin.New()
	r.Use(MaxBodyBytes(100))
	r.POST("/x", func(c *gin.Context) {
		buf := make([]byte, 50)
		c.Request.Body.Read(buf)
		c.JSON(200, gin.H{"ok": true})
	})

	req := httptest.NewRequest("POST", "/x", bytes.NewReader(make([]byte, 50)))
	req.ContentLength = 50
	rec := httptest.NewRecorder()
	r.ServeHTTP(rec, req)

	if rec.Code != 200 {
		t.Fatalf("expected 200, got %d body=%s", rec.Code, rec.Body.String())
	}
}

func TestMaxBodyBytes_RejectsOverLimitByContentLength(t *testing.T) {
	gin.SetMode(gin.TestMode)
	r := gin.New()
	r.Use(MaxBodyBytes(100))
	r.POST("/x", func(c *gin.Context) {
		c.JSON(200, gin.H{"ok": true})
	})

	req := httptest.NewRequest("POST", "/x", bytes.NewReader(make([]byte, 1000)))
	req.ContentLength = 1000
	rec := httptest.NewRecorder()
	r.ServeHTTP(rec, req)

	if rec.Code != 413 {
		t.Fatalf("expected 413, got %d body=%s", rec.Code, rec.Body.String())
	}
	if !bytes.Contains(rec.Body.Bytes(), []byte("حجم الطلب كبير جداً")) {
		t.Fatalf("expected Arabic error message, got %s", rec.Body.String())
	}
}

func TestMaxBodyBytes_RejectsOverLimitWhenHandlerReadsPastLimit(t *testing.T) {
	gin.SetMode(gin.TestMode)
	r := gin.New()
	r.Use(MaxBodyBytes(100))
	r.POST("/x", func(c *gin.Context) {
		buf := make([]byte, 1000)
		_, err := c.Request.Body.Read(buf)
		if err != nil {
			c.Error(err)
			return
		}
		c.JSON(200, gin.H{"ok": true})
	})

	req := httptest.NewRequest("POST", "/x", bytes.NewReader(make([]byte, 1000)))
	req.ContentLength = -1 // force the body to be read instead of pre-checked
	rec := httptest.NewRecorder()
	r.ServeHTTP(rec, req)

	if rec.Code != 413 {
		t.Fatalf("expected 413, got %d body=%s", rec.Code, rec.Body.String())
	}
}
