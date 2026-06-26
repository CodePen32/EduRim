package jwt

import (
	"errors"
	"time"

	"github.com/golang-jwt/jwt/v5"
)

type Claims struct {
	UserID uint   `json:"user_id"`
	Email  string `json:"email"`
	jwt.RegisteredClaims
}

func Generate(userID uint, email, secret string) (string, error) {
	claims := Claims{
		UserID: userID,
		Email:  email,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(time.Now().Add(24 * time.Hour)),
			IssuedAt:  jwt.NewNumericDate(time.Now()),
		},
	}
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString([]byte(secret))
}

// hmacKeyFunc returns a jwt.Keyfunc that only accepts HMAC-signed tokens
// (e.g. HS256), rejecting "none" and asymmetric algorithms such as RS256.
// This guards against algorithm-confusion attacks where a token's header
// claims a different alg than the server expects.
func hmacKeyFunc(secret string) jwt.Keyfunc {
	return func(t *jwt.Token) (interface{}, error) {
		if _, ok := t.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, errors.New("unexpected signing method")
		}
		return []byte(secret), nil
	}
}

// parserOpts restricts accepted algorithms to HS256 explicitly, in addition
// to the Keyfunc check, and is shared by every JWT verification path.
var parserOpts = []jwt.ParserOption{
	jwt.WithValidMethods([]string{jwt.SigningMethodHS256.Alg()}),
}

// Verify parses and validates a token into the strongly-typed Claims,
// enforcing HMAC/HS256 and expiration via the registered "exp" claim.
func Verify(tokenStr, secret string) (*Claims, error) {
	token, err := jwt.ParseWithClaims(tokenStr, &Claims{}, hmacKeyFunc(secret), parserOpts...)
	if err != nil {
		return nil, err
	}
	claims, ok := token.Claims.(*Claims)
	if !ok || !token.Valid {
		return nil, errors.New("invalid token")
	}
	return claims, nil
}

// VerifyMapClaims parses and validates a token into MapClaims, enforcing the
// same HMAC/HS256 + expiration checks as Verify. Used where claims are
// dynamic (e.g. admin tokens) rather than the fixed Claims struct.
func VerifyMapClaims(tokenStr, secret string) (jwt.MapClaims, error) {
	token, err := jwt.Parse(tokenStr, hmacKeyFunc(secret), parserOpts...)
	if err != nil {
		return nil, err
	}
	claims, ok := token.Claims.(jwt.MapClaims)
	if !ok || !token.Valid {
		return nil, errors.New("invalid token")
	}
	return claims, nil
}
