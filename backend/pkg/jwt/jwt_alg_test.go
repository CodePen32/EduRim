package jwt

import (
	"testing"
	"time"

	"github.com/golang-jwt/jwt/v5"
)

func TestVerify_RejectsNoneAlg(t *testing.T) {
	tok := jwt.NewWithClaims(jwt.SigningMethodNone, jwt.MapClaims{
		"user_id": 1,
		"exp":     time.Now().Add(time.Hour).Unix(),
	})
	s, err := tok.SignedString(jwt.UnsafeAllowNoneSignatureType)
	if err != nil {
		t.Fatal(err)
	}
	if _, err := Verify(s, "secret"); err == nil {
		t.Error("Verify accepted alg=none token")
	}
	if _, err := VerifyMapClaims(s, "secret"); err == nil {
		t.Error("VerifyMapClaims accepted alg=none token")
	}
}

func TestVerify_RejectsExpired(t *testing.T) {
	claims := Claims{
		UserID: 1,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(time.Now().Add(-time.Hour)),
		},
	}
	tok := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	s, err := tok.SignedString([]byte("secret"))
	if err != nil {
		t.Fatal(err)
	}
	if _, err := Verify(s, "secret"); err == nil {
		t.Error("Verify accepted expired token")
	}
}

func TestVerifyMapClaims_AcceptsValidAdminToken(t *testing.T) {
	tok := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"user_id": 1,
		"type":    "admin",
		"role":    "superadmin",
		"exp":     time.Now().Add(time.Hour).Unix(),
	})
	s, err := tok.SignedString([]byte("secret"))
	if err != nil {
		t.Fatal(err)
	}
	claims, err := VerifyMapClaims(s, "secret")
	if err != nil {
		t.Fatalf("expected valid token to verify, got %v", err)
	}
	if claims["type"] != "admin" {
		t.Error("expected type=admin claim")
	}
}
