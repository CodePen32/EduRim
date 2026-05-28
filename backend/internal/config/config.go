package config

import (
	"os"
)

type Config struct {
	DBHost     string
	DBPort     string
	DBUser     string
	DBPassword string
	DBName     string
	JWTSecret  string
	ServerPort string
}

func Load() *Config {
	return &Config{
		DBHost:     getEnv("DB_HOST", "localhost"),
		DBPort:     getEnv("DB_PORT", "3306"),
		DBUser:     getEnv("DB_USER", "root"),
		DBPassword: getEnv("DB_PASSWORD", ""),
		DBName:     getEnv("DB_NAME", "edurim_db"),
		JWTSecret:  getEnv("JWT_SECRET", "change_me_later"),
		ServerPort: getEnv("SERVER_PORT", "8081"),
	}
}

// DSN يبني رابط الاتصال بـ MySQL
// إذا كانت كلمة المرور فارغة يحذفها من الرابط
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
