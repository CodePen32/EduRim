package config

import (
	"crypto/tls"
	"crypto/x509"
	"log"
	"os"
	"strconv"

	"github.com/go-sql-driver/mysql"
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

	// Database connection pool
	DBMaxOpenConns        int
	DBMaxIdleConns        int
	DBConnMaxLifetimeMins int

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

		// Defaults sized for a small launch (Phase 1: 500-1000 concurrent users).
		DBMaxOpenConns:        getEnvInt("DB_MAX_OPEN_CONNS", 25),
		DBMaxIdleConns:        getEnvInt("DB_MAX_IDLE_CONNS", 10),
		DBConnMaxLifetimeMins: getEnvInt("DB_CONN_MAX_LIFETIME_MINUTES", 5),

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

// RegisterTLS يسجّل TLS config لـ Aiven إذا كان DB_CA_CERT موجوداً.
// يجب استدعاؤه مرة واحدة قبل أي اتصال بقاعدة البيانات.
func RegisterTLS() {
	if os.Getenv("DB_TLS") != "true" {
		return
	}

	caCert := os.Getenv("DB_CA_CERT")
	if caCert == "" {
		// لا يوجد CA cert — نستخدم tls=true (يتحقق من CA النظام)
		// هذا يكفي إذا كان Aiven CA موثوقاً في النظام
		return
	}

	pool := x509.NewCertPool()
	if !pool.AppendCertsFromPEM([]byte(caCert)) {
		log.Fatal("FATAL: DB_CA_CERT غير صالح — تعذّر تحميل شهادة Aiven CA")
	}

	tlsCfg := &tls.Config{
		RootCAs:    pool,
		MinVersion: tls.VersionTLS12,
	}

	if err := mysql.RegisterTLSConfig("aiven", tlsCfg); err != nil {
		log.Fatalf("FATAL: تعذّر تسجيل TLS config لـ MySQL: %v", err)
	}

	log.Println("✅ Aiven TLS config registered with custom CA")
}

// DSN يبني رابط الاتصال بـ MySQL
func (c *Config) DSN() string {
	auth := c.DBUser
	if c.DBPassword != "" {
		auth += ":" + c.DBPassword
	}

	tlsParam := ""
	if os.Getenv("DB_TLS") == "true" {
		if os.Getenv("DB_CA_CERT") != "" {
			tlsParam = "&tls=aiven" // يستخدم CA المسجّل
		} else {
			tlsParam = "&tls=true" // يثق بـ CA النظام
		}
	}

	return auth + "@tcp(" + c.DBHost + ":" + c.DBPort + ")/" + c.DBName +
		"?charset=utf8mb4&collation=utf8mb4_unicode_ci&parseTime=True&loc=Local" + tlsParam
}

func getEnv(key, defaultVal string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return defaultVal
}

func getEnvInt(key string, defaultVal int) int {
	v := os.Getenv(key)
	if v == "" {
		return defaultVal
	}
	n, err := strconv.Atoi(v)
	if err != nil {
		return defaultVal
	}
	return n
}
