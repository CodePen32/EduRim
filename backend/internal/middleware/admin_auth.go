package middleware

import (
	"net/http"
	"strings"

	"github.com/gin-gonic/gin"

	pkgjwt "edurim/backend/pkg/jwt"
)

func AdminAuth(jwtSecret string) gin.HandlerFunc {
	return func(c *gin.Context) {
		authHeader := c.GetHeader("Authorization")
		if !strings.HasPrefix(authHeader, "Bearer ") {
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "غير مصرح"})
			return
		}
		tokenStr := strings.TrimPrefix(authHeader, "Bearer ")
		claims, err := pkgjwt.VerifyMapClaims(tokenStr, jwtSecret)
		if err != nil {
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "رمز غير صالح"})
			return
		}
		if claims["type"] != "admin" {
			c.AbortWithStatusJSON(http.StatusForbidden, gin.H{"error": "غير مسموح"})
			return
		}
		c.Set("admin_id", claims["user_id"])
		c.Set("admin_role", claims["role"])
		c.Next()
	}
}
