package middleware

import (
	"net/http"
	"os"
	"strings"

	"edurim/backend/pkg/jwt"

	"github.com/gin-gonic/gin"
)

func Auth(jwtSecret string) gin.HandlerFunc {
	return func(c *gin.Context) {
		authHeader := c.GetHeader("Authorization")
		if authHeader == "" || !strings.HasPrefix(authHeader, "Bearer ") {
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"message": "مطلوب تسجيل الدخول"})
			return
		}

		tokenStr := strings.TrimPrefix(authHeader, "Bearer ")
		claims, err := jwt.Verify(tokenStr, jwtSecret)
		if err != nil {
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"message": "الجلسة منتهية، يرجى تسجيل الدخول مجدداً"})
			return
		}

		c.Set("user_id", claims.UserID)
		c.Set("email", claims.Email)
		c.Next()
	}
}

// CORS reads allowed origins from CORS_ALLOWED_ORIGINS env var (comma-separated).
// Dev fallback: if env is empty, allow all origins (*) to keep local dev working.
func CORS() gin.HandlerFunc {
	raw := os.Getenv("CORS_ALLOWED_ORIGINS")
	var allowed []string
	if raw != "" {
		for _, o := range strings.Split(raw, ",") {
			if t := strings.TrimSpace(o); t != "" {
				allowed = append(allowed, t)
			}
		}
	}

	return func(c *gin.Context) {
		origin := c.Request.Header.Get("Origin")
		if len(allowed) == 0 {
			// Dev mode — allow all
			c.Header("Access-Control-Allow-Origin", "*")
		} else {
			// Production — only allow listed origins
			for _, a := range allowed {
				if a == origin {
					c.Header("Access-Control-Allow-Origin", origin)
					c.Header("Vary", "Origin")
					break
				}
			}
		}
		c.Header("Access-Control-Allow-Methods", "GET, POST, PUT, PATCH, DELETE, OPTIONS")
		c.Header("Access-Control-Allow-Headers", "Content-Type, Authorization")
		if c.Request.Method == "OPTIONS" {
			c.AbortWithStatus(http.StatusNoContent)
			return
		}
		c.Next()
	}
}
