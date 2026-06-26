package middleware

import (
	"errors"
	"net/http"

	"github.com/gin-gonic/gin"
)

// MaxBodyBytes rejects requests whose body exceeds limitBytes with a 413 and
// a JSON error, before the body is consumed by any handler/binder. It checks
// the declared Content-Length upfront (covers the common case where clients
// set it, e.g. multipart uploads) and also wraps the body in
// http.MaxBytesReader so chunked or misreported requests are caught the
// moment a handler tries to read past the limit, even if the handler's own
// error handling doesn't recognize *http.MaxBytesError specifically.
func MaxBodyBytes(limitBytes int64) gin.HandlerFunc {
	return func(c *gin.Context) {
		if c.Request.ContentLength > limitBytes {
			c.AbortWithStatusJSON(http.StatusRequestEntityTooLarge, gin.H{"error": "حجم الطلب كبير جداً"})
			return
		}

		c.Request.Body = http.MaxBytesReader(c.Writer, c.Request.Body, limitBytes)
		c.Next()

		if c.Writer.Written() {
			return
		}
		for _, ginErr := range c.Errors {
			var maxErr *http.MaxBytesError
			if errors.As(ginErr.Err, &maxErr) {
				c.AbortWithStatusJSON(http.StatusRequestEntityTooLarge, gin.H{"error": "حجم الطلب كبير جداً"})
				return
			}
		}
	}
}
