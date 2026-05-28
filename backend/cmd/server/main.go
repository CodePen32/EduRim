package main

import (
	"log"
	"os"

	"edurim/backend/internal/config"
	"edurim/backend/internal/database"
	"edurim/backend/internal/middleware"
	"edurim/backend/internal/routes"

	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
)

func main() {
	if err := godotenv.Load(); err != nil {
		log.Println("no .env file found, using environment variables")
	}

	cfg := config.Load()

	database.Connect(cfg.DSN())

	if os.Getenv("GIN_MODE") == "release" {
		gin.SetMode(gin.ReleaseMode)
	}

	r := gin.Default()
	r.Use(middleware.CORS())
	r.Static("/uploads", "./uploads")
	routes.Setup(r, cfg.JWTSecret, database.DB)

	addr := ":" + cfg.ServerPort
	log.Printf("🚀 Edurim API running on http://localhost%s", addr)
	if err := r.Run(addr); err != nil {
		log.Fatalf("failed to start server: %v", err)
	}
}
