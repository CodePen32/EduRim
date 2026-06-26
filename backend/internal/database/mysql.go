package database

import (
	"database/sql"
	"log"
	"time"

	_ "github.com/go-sql-driver/mysql"
)

var DB *sql.DB

// PoolConfig holds connection pool tuning values, sourced from env vars
// (DB_MAX_OPEN_CONNS, DB_MAX_IDLE_CONNS, DB_CONN_MAX_LIFETIME_MINUTES) via config.Config.
type PoolConfig struct {
	MaxOpenConns        int
	MaxIdleConns        int
	ConnMaxLifetimeMins int
}

func Connect(dsn string, pool PoolConfig) {
	var err error
	DB, err = sql.Open("mysql", dsn)
	if err != nil {
		log.Printf("❌ فشل فتح اتصال قاعدة البيانات: %v", err)
		DB = nil
		return
	}

	if err = DB.Ping(); err != nil {
		log.Printf("❌ فشل الاتصال بقاعدة البيانات: %v", err)
		log.Println("⚠️  السيرفر يعمل بدون قاعدة بيانات (mock data)")
		DB = nil
		return
	}

	DB.SetMaxOpenConns(pool.MaxOpenConns)
	DB.SetMaxIdleConns(pool.MaxIdleConns)
	DB.SetConnMaxLifetime(time.Duration(pool.ConnMaxLifetimeMins) * time.Minute)
	DB.SetConnMaxIdleTime(time.Duration(pool.ConnMaxLifetimeMins) * time.Minute)
	log.Printf("✅ تم الاتصال بقاعدة البيانات MySQL بنجاح (MaxOpenConns=%d MaxIdleConns=%d ConnMaxLifetime=%dm)",
		pool.MaxOpenConns, pool.MaxIdleConns, pool.ConnMaxLifetimeMins)
}

// IsConnected تحقق من وجود اتصال نشط
func IsConnected() bool {
	return DB != nil
}
