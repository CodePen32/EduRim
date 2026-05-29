package config

import (
	"log"
	"os"
)

var insecureDefaults = []string{"change_me_later", "secret", "password", "12345", ""}

func isInsecureSecret(s string) bool {
	for _, bad := range insecureDefaults {
		if s == bad {
			return true
		}
	}
	return len(s) < 32
}

type Config struct {
	DBHost     string
	DBPort     string
	DBUser     string
	DBPassword string
	DBName     string
	JWTSecret  string
	ServerPort string

	// Storage
	StorageDriver   string // "local" or "r2"
	LocalUploadsDir string
	LocalPublicURL  string

	// Cloudflare R2 (S3-compatible)
	R2AccountID       string
	R2AccessKeyID     string
	R2SecretAccessKey string
	R2Bucket          string
	R2PublicURL       string
}

func Load() *Config {
	jwtSecret := getEnv("JWT_SECRET", "change_me_later")
	if os.Getenv("APP_ENV") == "production" || os.Getenv("GIN_MODE") == "release" {
		if isInsecureSecret(jwtSecret) {
			log.Fatal("FATAL: JWT_SECRET is insecure or missing. Set a strong random secret (min 32 chars) before running in production.")
		}
	}
	return &Config{
		DBHost:     getEnv("DB_HOST", "localhost"),
		DBPort:     getEnv("DB_PORT", "3306"),
		DBUser:     getEnv("DB_USER", "root"),
		DBPassword: getEnv("DB_PASSWORD", ""),
		DBName:     getEnv("DB_NAME", "edurim_db"),
		JWTSecret:  jwtSecret,
		// Render sets PORT; fall back to SERVER_PORT, then 8081
		ServerPort: getEnv("PORT", getEnv("SERVER_PORT", "8081")),

		StorageDriver:   getEnv("STORAGE_DRIVER", "local"),
		LocalUploadsDir: getEnv("LOCAL_UPLOADS_DIR", "uploads"),
		LocalPublicURL:  getEnv("LOCAL_PUBLIC_URL", "http://localhost:8081/uploads"),

		R2AccountID:       getEnv("R2_ACCOUNT_ID", ""),
		R2AccessKeyID:     getEnv("R2_ACCESS_KEY_ID", ""),
		R2SecretAccessKey: getEnv("R2_SECRET_ACCESS_KEY", ""),
		R2Bucket:          getEnv("R2_BUCKET", ""),
		R2PublicURL:       getEnv("R2_PUBLIC_URL", ""),
	}
}

// DSN يبني رابط الاتصال بـ MySQL
func (c *Config) DSN() string {
	auth := c.DBUser
	if c.DBPassword != "" {
		auth += ":" + c.DBPassword
	}
	return auth + "@tcp(" + c.DBHost + ":" + c.DBPort + ")/" + c.DBName +
		"?charset=utf8mb4&collation=utf8mb4_unicode_ci&parseTime=True&loc=Local"
}

func getEnv(key, defaultVal string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return defaultVal
}
