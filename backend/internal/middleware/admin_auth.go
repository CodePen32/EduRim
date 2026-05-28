package middleware

import (
	"net/http"
	"strings"

	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v5"
)

func AdminAuth(jwtSecret string) gin.HandlerFunc {
	return func(c *gin.Context) {
		authHeader := c.GetHeader("Authorization")
		if !strings.HasPrefix(authHeader, "Bearer ") {
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "غير مصرح"})
			return
		}
		tokenStr := strings.TrimPrefix(authHeader, "Bearer ")
		token, err := jwt.Parse(tokenStr, func(t *jwt.Token) (interface{}, error) {
			return []byte(jwtSecret), nil
		})
		if err != nil || !token.Valid {
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "رمز غير صالح"})
			return
		}
		claims, ok := token.Claims.(jwt.MapClaims)
		if !ok || claims["type"] != "admin" {
			c.AbortWithStatusJSON(http.StatusForbidden, gin.H{"error": "غير مسموح"})
			return
		}
		c.Set("admin_id", claims["user_id"])
		c.Set("admin_role", claims["role"])
		c.Next()
	}
}
