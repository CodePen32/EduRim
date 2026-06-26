package handlers

import (
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"
)

func newTestContext(rawQuery string) *gin.Context {
	gin.SetMode(gin.TestMode)
	c, _ := gin.CreateTestContext(httptest.NewRecorder())
	c.Request = httptest.NewRequest("GET", "/x?"+rawQuery, nil)
	return c
}

func TestParsePagination_Defaults(t *testing.T) {
	c := newTestContext("")
	limit, offset := parsePagination(c, 50, 100)
	if limit != 50 || offset != 0 {
		t.Errorf("got limit=%d offset=%d, want 50,0", limit, offset)
	}
}

func TestParsePagination_CustomWithinCap(t *testing.T) {
	c := newTestContext("limit=30&offset=10")
	limit, offset := parsePagination(c, 50, 100)
	if limit != 30 || offset != 10 {
		t.Errorf("got limit=%d offset=%d, want 30,10", limit, offset)
	}
}

func TestParsePagination_CappedAtMax(t *testing.T) {
	c := newTestContext("limit=99999")
	limit, _ := parsePagination(c, 50, 100)
	if limit != 100 {
		t.Errorf("got limit=%d, want capped at 100", limit)
	}
}

func TestParsePagination_InvalidFallsBackToDefault(t *testing.T) {
	c := newTestContext("limit=abc&offset=-5")
	limit, offset := parsePagination(c, 50, 100)
	if limit != 50 || offset != 0 {
		t.Errorf("got limit=%d offset=%d, want defaults 50,0", limit, offset)
	}
}
