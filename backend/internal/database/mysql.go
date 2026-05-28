package database

import (
	"database/sql"
	"log"

	_ "github.com/go-sql-driver/mysql"
)

var DB *sql.DB

func Connect(dsn string) {
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

	DB.SetMaxOpenConns(25)
	DB.SetMaxIdleConns(10)
	log.Println("✅ تم الاتصال بقاعدة البيانات MySQL بنجاح")
}

// IsConnected تحقق من وجود اتصال نشط
func IsConnected() bool {
	return DB != nil
}
