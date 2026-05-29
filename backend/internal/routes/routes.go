package routes

import (
	"database/sql"
	"net/http"

	"edurim/backend/internal/handlers"
	"edurim/backend/internal/middleware"
	"edurim/backend/internal/repositories"

	"github.com/gin-gonic/gin"
)

func Setup(r *gin.Engine, jwtSecret string, db *sql.DB) {
	r.Use(middleware.CORS())

	api := r.Group("/api")

	api.GET("/health", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{"status": "ok", "service": "edurim-api"})
	})

	// Auth
	auth := api.Group("/auth")
	authHandler := handlers.NewAuthHandler(jwtSecret)
	auth.POST("/register", authHandler.Register)
	auth.POST("/login", authHandler.Login)
	auth.GET("/me", middleware.Auth(jwtSecret), authHandler.Me)
	auth.PUT("/profile", middleware.Auth(jwtSecret), authHandler.UpdateProfile)

	// Repositories
	lpRepo := repositories.NewLearningPathRepository(db)
	bacRepo := repositories.NewBacBranchRepository(db)
	subjectRepo := repositories.NewSubjectRepository(db)
	teacherRepo := repositories.NewTeacherRepository(db)
	lessonRepo := repositories.NewLessonRepository(db)
	exerciseRepo := repositories.NewExerciseRepository(db)

	// Handlers
	lpHandler := handlers.NewLearningPathHandler(lpRepo, bacRepo)
	subjectHandler := handlers.NewSubjectHandler(subjectRepo)
	teacherHandler := handlers.NewTeacherHandler(teacherRepo)
	lessonHandler := handlers.NewLessonHandler(lessonRepo)
	exerciseHandler := handlers.NewExerciseHandler(exerciseRepo)
	meHandler := handlers.NewMeHandler(subjectRepo)

	// Learning paths
	api.GET("/learning-paths", lpHandler.GetLearningPaths)
	api.GET("/bac-branches", lpHandler.GetBacBranches)

	// Subjects (مع دعم ?learning_path_id و ?bac_branch_id)
	api.GET("/subjects", subjectHandler.GetSubjects)
	api.GET("/subjects/:id", subjectHandler.GetSubjectByID)

	// Me — مواد المستخدم حسب مساره (محمي بـ JWT)
	api.GET("/me/subjects", middleware.Auth(jwtSecret), meHandler.GetMySubjects)

	// Me — دروس/تمارين/أساتذة المستخدم حسب مساره (محمي بـ JWT)
	api.GET("/me/lessons", middleware.Auth(jwtSecret), lessonHandler.GetMyLessons)
	api.GET("/me/lessons/:id", middleware.Auth(jwtSecret), lessonHandler.GetMyLessonByID)
	api.GET("/me/exercises", middleware.Auth(jwtSecret), exerciseHandler.GetMyExercises)
	api.GET("/me/exercises/:id", middleware.Auth(jwtSecret), exerciseHandler.GetMyExerciseByID)
	api.GET("/me/teachers", middleware.Auth(jwtSecret), teacherHandler.GetMyTeachers)

	// Teachers (مع دعم ?subject_id)
	api.GET("/teachers", teacherHandler.GetTeachers)
	api.GET("/teachers/:id", teacherHandler.GetTeacherByID)

	// Lessons (مع دعم ?subject_id و ?teacher_id و ?unit_id)
	api.GET("/lessons", lessonHandler.GetLessons)
	api.GET("/lessons/:id", lessonHandler.GetLessonByID)

	// Exercises (مع دعم ?subject_id و ?lesson_id و ?year و ?difficulty)
	api.GET("/exercises", exerciseHandler.GetExercises)
	api.GET("/exercises/:id", exerciseHandler.GetExerciseByID)

	// Search
	searchRepo := repositories.NewSearchRepository(db)
	searchHandler := handlers.NewSearchHandler(searchRepo)
	api.GET("/search", searchHandler.Search)

	// Progress (محمي بـ JWT)
	progressRepo := repositories.NewProgressRepository(db)
	progressHandler := handlers.NewProgressHandler(progressRepo)
	progress := api.Group("/progress", middleware.Auth(jwtSecret))
	progress.GET("", progressHandler.GetProgress)
	progress.GET("/last", progressHandler.GetLastProgress)
	progress.GET("/stats", progressHandler.GetStats)
	progress.GET("/by-subject", progressHandler.GetBySubject)
	progress.POST("", progressHandler.SaveProgress)

	// Notifications (محمي بـ JWT)
	notifRepo := repositories.NewNotificationRepository(db)
	notifHandler := handlers.NewNotificationHandler(notifRepo)
	notifs := api.Group("/notifications", middleware.Auth(jwtSecret))
	notifs.GET("", notifHandler.GetNotifications)
	notifs.GET("/unread-count", notifHandler.UnreadCount)
	notifs.PATCH("/:id/read", notifHandler.MarkRead)

	// Favorites (محمي بـ JWT)
	favRepo := repositories.NewFavoriteRepository(db)
	favHandler := handlers.NewFavoriteHandler(favRepo)
	favs := api.Group("/favorites", middleware.Auth(jwtSecret))
	favs.GET("", favHandler.GetFavorites)
	favs.POST("", favHandler.AddFavorite)
	favs.DELETE("/:id", favHandler.DeleteFavorite)

	// Downloads (محمي بـ JWT)
	dlRepo := repositories.NewDownloadRepository(db)
	dlHandler := handlers.NewDownloadHandler(dlRepo)
	dls := api.Group("/downloads", middleware.Auth(jwtSecret))
	dls.GET("", dlHandler.GetDownloads)
	dls.POST("", dlHandler.AddDownload)
	dls.DELETE("/:id", dlHandler.DeleteDownload)

	// Calculator (محمي بـ JWT)
	calcRepo := repositories.NewCalculatorRepository(db)
	calcHandler := handlers.NewCalculatorHandler(calcRepo)
	calc := api.Group("/calculator", middleware.Auth(jwtSecret))
	calc.GET("/subjects", calcHandler.GetSubjects)
	calc.POST("/calculate", calcHandler.Calculate)

	// Past Exams (public)
	peRepo := repositories.NewPastExamRepository(db)
	peHandler := handlers.NewPastExamHandler(peRepo)
	api.GET("/past-exams", peHandler.GetPastExams)
	api.GET("/subjects/:id/past-exams", peHandler.GetBySubject)

	// File uploads (admin only)
	api.POST("/admin/uploads", middleware.AdminAuth(jwtSecret), handlers.UploadHandler)

	// Admin Auth
	adminRepo := repositories.NewAdminRepository(db)
	adminAuthHandler := handlers.NewAdminAuthHandler(adminRepo, jwtSecret)
	adminAuth := api.Group("/admin/auth")
	adminAuth.POST("/login", adminAuthHandler.Login)
	adminAuth.GET("/me", middleware.AdminAuth(jwtSecret), adminAuthHandler.Me)

	// Admin Content
	adminContentRepo := repositories.NewAdminContentRepository(db)
	adminContentHandler := handlers.NewAdminContentHandler(adminContentRepo, peRepo)
	admin := api.Group("/admin", middleware.AdminAuth(jwtSecret))
	admin.GET("/dashboard/stats", adminContentHandler.GetStats)
	admin.GET("/subjects", adminContentHandler.GetSubjects)
	admin.POST("/subjects", adminContentHandler.CreateSubject)
	admin.PUT("/subjects/:id", adminContentHandler.UpdateSubject)
	admin.DELETE("/subjects/:id", adminContentHandler.DeleteSubject)
	admin.GET("/lessons", adminContentHandler.GetLessons)
	admin.POST("/lessons", adminContentHandler.CreateLesson)
	admin.PUT("/lessons/:id", adminContentHandler.UpdateLesson)
	admin.DELETE("/lessons/:id", adminContentHandler.DeleteLesson)
	admin.GET("/exercises", adminContentHandler.GetExercises)
	admin.POST("/exercises", adminContentHandler.CreateExercise)
	admin.PUT("/exercises/:id", adminContentHandler.UpdateExercise)
	admin.DELETE("/exercises/:id", adminContentHandler.DeleteExercise)
	admin.GET("/past-exams", adminContentHandler.GetPastExams)
	admin.POST("/past-exams", adminContentHandler.CreatePastExam)
	admin.PUT("/past-exams/:id", adminContentHandler.UpdatePastExam)
	admin.DELETE("/past-exams/:id", adminContentHandler.DeletePastExam)
	// Admin Teachers
	admin.GET("/teachers", adminContentHandler.GetTeachers)
	admin.POST("/teachers", adminContentHandler.CreateTeacher)
	admin.PUT("/teachers/:id", adminContentHandler.UpdateTeacher)
	admin.DELETE("/teachers/:id", adminContentHandler.DeleteTeacher)
	// Admin Notifications
	notifHandler2 := handlers.NewNotificationHandler(notifRepo)
	admin.GET("/notifications", notifHandler2.GetAdminNotifications)
	admin.POST("/notifications", notifHandler2.CreateNotification)

	// Admin Announcements
	announcementRepo := repositories.NewAnnouncementRepository(db)
	announcementHandler := handlers.NewAnnouncementHandler(announcementRepo)
	admin.GET("/announcements", announcementHandler.GetAdminAnnouncements)
	admin.POST("/announcements", announcementHandler.CreateAnnouncement)
	admin.PUT("/announcements/:id", announcementHandler.UpdateAnnouncement)
	admin.DELETE("/announcements/:id", announcementHandler.DeleteAnnouncement)
	admin.PATCH("/announcements/:id/toggle-active", announcementHandler.ToggleActive)

	// Student Announcements (JWT protected)
	me := api.Group("/me", middleware.Auth(jwtSecret))
	me.GET("/announcements", announcementHandler.GetMyAnnouncements)

	// Subscriptions
	subRepo := repositories.NewSubscriptionRepository(db)
	subHandler := handlers.NewSubscriptionHandler(subRepo)
	me.GET("/subscription", subHandler.GetMySubscription)
	me.POST("/uploads", handlers.UploadHandler) // رفع إيصالات الاشتراك
	me.GET("/subscription-plans", subHandler.GetMyPlans)
	me.GET("/subscription-requests", subHandler.GetMyRequests)
	me.POST("/subscription-requests", subHandler.CreateRequest)
	admin.GET("/subscription-plans", subHandler.GetAdminPlans)
	admin.POST("/subscription-plans", subHandler.CreatePlan)
	admin.PUT("/subscription-plans/:id", subHandler.UpdatePlan)
	admin.DELETE("/subscription-plans/:id", subHandler.DeletePlan)
	admin.GET("/subscription-requests", subHandler.GetAdminRequests)
	admin.PATCH("/subscription-requests/:id/approve", subHandler.ApproveRequest)
	admin.PATCH("/subscription-requests/:id/reject", subHandler.RejectRequest)
	admin.GET("/user-subscriptions", subHandler.GetAdminUserSubscriptions)
	admin.POST("/user-subscriptions", subHandler.CreateUserSubscription)
	admin.PUT("/user-subscriptions/:id", subHandler.UpdateUserSubscription)
	admin.DELETE("/user-subscriptions/:id", subHandler.DeleteUserSubscription)

	// Admin Users
	adminUsersRepo := repositories.NewAdminUsersRepository(db)
	adminUsersHandler := handlers.NewAdminUsersHandler(adminUsersRepo)
	admin.GET("/users", adminUsersHandler.GetUsers)
	admin.GET("/users/:id", adminUsersHandler.GetUser)
	admin.PUT("/users/:id", adminUsersHandler.UpdateUser)
	admin.PATCH("/users/:id/toggle-active", adminUsersHandler.ToggleActive)
}
