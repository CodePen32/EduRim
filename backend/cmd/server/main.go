package main

import (
	"log"
	"os"
	"strings"

	"edurim/backend/internal/config"
	"edurim/backend/internal/database"
	"edurim/backend/internal/handlers"
	"edurim/backend/internal/middleware"
	"edurim/backend/internal/routes"
	"edurim/backend/internal/services"

	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
)

func main() {
	if err := godotenv.Load(); err != nil {
		log.Println("no .env file found, using environment variables")
	}

	cfg := config.Load()

	database.Connect(cfg.DSN())

	// Set release mode when APP_ENV=production or GIN_MODE=release
	if os.Getenv("APP_ENV") == "production" || os.Getenv("GIN_MODE") == "release" {
		gin.SetMode(gin.ReleaseMode)
	}

	// Initialize storage service (local or R2)
	storageSvc := services.NewStorageService(cfg)
	handlers.SetStorageService(storageSvc)
	log.Printf("Storage driver: %s", strings.ToUpper(cfg.StorageDriver))

	r := gin.Default()
	r.Use(middleware.CORS())
	// Local uploads served from disk (no-op in production when using R2)
	r.Static("/uploads", "./uploads")
	routes.Setup(r, cfg.JWTSecret, database.DB)

	addr := ":" + cfg.ServerPort
	log.Printf("Edurim API running on http://localhost%s", addr)
	if err := r.Run(addr); err != nil {
		log.Fatalf("failed to start server: %v", err)
	}
}
