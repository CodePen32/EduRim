package handlers

import (
	"database/sql"
	"net/http"
	"strings"

	"edurim/backend/internal/database"
	"edurim/backend/internal/models"
	"edurim/backend/pkg/jwt"
	"edurim/backend/pkg/password"

	"github.com/gin-gonic/gin"
)

type AuthHandler struct {
	jwtSecret string
}

func NewAuthHandler(secret string) *AuthHandler {
	return &AuthHandler{jwtSecret: secret}
}

func (h *AuthHandler) Register(c *gin.Context) {
	var req models.RegisterRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "بيانات غير صحيحة: " + err.Error()})
		return
	}

	if database.DB == nil {
		c.JSON(http.StatusServiceUnavailable, gin.H{"message": "قاعدة البيانات غير متصلة"})
		return
	}

	// التحقق من عدم تكرار email أو phone
	var exists int
	err := database.DB.QueryRow(
		`SELECT COUNT(*) FROM users WHERE email = ? OR phone = ?`,
		req.Email, req.Phone,
	).Scan(&exists)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "خطأ في التحقق من البيانات"})
		return
	}
	if exists > 0 {
		// تحديد أيهما مكرر
		var emailCount int
		database.DB.QueryRow(`SELECT COUNT(*) FROM users WHERE email = ?`, req.Email).Scan(&emailCount)
		if emailCount > 0 {
			c.JSON(http.StatusConflict, gin.H{"message": "البريد الإلكتروني مستخدم بالفعل"})
		} else {
			c.JSON(http.StatusConflict, gin.H{"message": "رقم الهاتف مستخدم بالفعل"})
		}
		return
	}

	hash, err := password.Hash(req.Password)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "خطأ في معالجة كلمة المرور"})
		return
	}

	result, err := database.DB.Exec(
		`INSERT INTO users (full_name, email, phone, password_hash, learning_path_id, bac_branch_id, gender, city, created_at, updated_at)
		 VALUES (?, ?, ?, ?, ?, ?, ?, ?, NOW(), NOW())`,
		req.FullName, req.Email, req.Phone, hash,
		req.LearningPathID, req.BacBranchID,
		req.Gender, req.City,
	)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "فشل إنشاء الحساب"})
		return
	}

	id, _ := result.LastInsertId()
	token, err := jwt.Generate(uint(id), req.Email, h.jwtSecret)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "فشل إنشاء الجلسة"})
		return
	}

	user := models.User{
		ID:             uint(id),
		FullName:       req.FullName,
		Email:          req.Email,
		Phone:          req.Phone,
		Gender:         req.Gender,
		City:           req.City,
		LearningPathID: req.LearningPathID,
		BacBranchID:    req.BacBranchID,
	}

	c.JSON(http.StatusCreated, models.AuthResponse{Token: token, User: user})
}

func (h *AuthHandler) Login(c *gin.Context) {
	var req models.LoginRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "بيانات غير صحيحة"})
		return
	}

	if database.DB == nil {
		c.JSON(http.StatusServiceUnavailable, gin.H{"message": "قاعدة البيانات غير متصلة"})
		return
	}

	// تحديد المعرّف: identifier أو email أو phone
	identifier := strings.TrimSpace(req.Identifier)
	if identifier == "" {
		identifier = strings.TrimSpace(req.Email)
	}
	if identifier == "" {
		identifier = strings.TrimSpace(req.Phone)
	}
	if identifier == "" {
		c.JSON(http.StatusBadRequest, gin.H{"message": "أدخل البريد الإلكتروني أو رقم الهاتف"})
		return
	}

	var user models.User
	err := database.DB.QueryRow(
		`SELECT id, full_name, email, phone, password_hash,
		        COALESCE(learning_path_id, 0), COALESCE(bac_branch_id, 0),
		        COALESCE(city,''), COALESCE(gender,''), created_at, updated_at
		 FROM users WHERE email = ? OR phone = ?`,
		identifier, identifier,
	).Scan(
		&user.ID, &user.FullName, &user.Email, &user.Phone, &user.PasswordHash,
		new(uint), new(uint),
		&user.City, &user.Gender, &user.CreatedAt, &user.UpdatedAt,
	)

	if err == sql.ErrNoRows {
		c.JSON(http.StatusUnauthorized, gin.H{"message": "البريد الإلكتروني أو رقم الهاتف غير مسجل"})
		return
	}
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "خطأ في الخادم"})
		return
	}

	if !password.Check(req.Password, user.PasswordHash) {
		c.JSON(http.StatusUnauthorized, gin.H{"message": "كلمة المرور غير صحيحة"})
		return
	}

	// التحقق من أن الحساب نشط
	var isActive bool
	database.DB.QueryRow(`SELECT is_active FROM users WHERE id = ?`, user.ID).Scan(&isActive)
	if !isActive {
		c.JSON(http.StatusForbidden, gin.H{"message": "تم تعطيل هذا الحساب، يرجى التواصل مع الإدارة"})
		return
	}

	// جلب learning_path_id و bac_branch_id الحقيقيين (nullable)
	var lpID, bacID sql.NullInt64
	database.DB.QueryRow(
		`SELECT learning_path_id, bac_branch_id FROM users WHERE id = ?`, user.ID,
	).Scan(&lpID, &bacID)
	if lpID.Valid {
		v := uint(lpID.Int64)
		user.LearningPathID = &v
	}
	if bacID.Valid {
		v := uint(bacID.Int64)
		user.BacBranchID = &v
	}

	user.PasswordHash = ""
	token, err := jwt.Generate(user.ID, user.Email, h.jwtSecret)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "فشل إنشاء الجلسة"})
		return
	}

	c.JSON(http.StatusOK, models.AuthResponse{Token: token, User: user})
}

func (h *AuthHandler) Me(c *gin.Context) {
	userIDVal, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"message": "غير مصرح"})
		return
	}
	userID := userIDVal.(uint)

	if database.DB == nil {
		c.JSON(http.StatusServiceUnavailable, gin.H{"message": "قاعدة البيانات غير متصلة"})
		return
	}

	var user models.User
	var lpID, bacID sql.NullInt64
	err := database.DB.QueryRow(
		`SELECT id, full_name, email, phone,
		        learning_path_id, bac_branch_id,
		        COALESCE(city,''), COALESCE(gender,''), created_at, updated_at
		 FROM users WHERE id = ?`, userID,
	).Scan(
		&user.ID, &user.FullName, &user.Email, &user.Phone,
		&lpID, &bacID,
		&user.City, &user.Gender, &user.CreatedAt, &user.UpdatedAt,
	)
	if err == sql.ErrNoRows {
		c.JSON(http.StatusNotFound, gin.H{"message": "المستخدم غير موجود"})
		return
	}
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "خطأ في الخادم"})
		return
	}
	if lpID.Valid {
		v := uint(lpID.Int64)
		user.LearningPathID = &v
	}
	if bacID.Valid {
		v := uint(bacID.Int64)
		user.BacBranchID = &v
	}

	c.JSON(http.StatusOK, gin.H{"data": user})
}

func (h *AuthHandler) UpdateProfile(c *gin.Context) {
	userIDVal, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"message": "غير مصرح"})
		return
	}
	userID := userIDVal.(uint)

	if database.DB == nil {
		c.JSON(http.StatusServiceUnavailable, gin.H{"message": "قاعدة البيانات غير متصلة"})
		return
	}

	var req struct {
		FullName string `json:"full_name"`
		Email    string `json:"email"`
		Phone    string `json:"phone"`
		City     string `json:"city"`
		Gender   string `json:"gender"`
		// LearningPathID and BacBranchID accepted only when user has no path yet
		LearningPathID *uint `json:"learning_path_id"`
		BacBranchID    *uint `json:"bac_branch_id"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "بيانات غير صحيحة"})
		return
	}

	// Check if user already has a learning path set
	var existingLP sql.NullInt64
	database.DB.QueryRow(`SELECT learning_path_id FROM users WHERE id = ?`, userID).Scan(&existingLP)

	var lpArg, bacArg interface{}
	if existingLP.Valid {
		// Path already set — ignore any incoming learning_path_id / bac_branch_id
		lpArg = nil
		bacArg = nil
	} else {
		// First time setting the path — allow it
		lpArg = req.LearningPathID
		if req.LearningPathID != nil && *req.LearningPathID == 3 {
			bacArg = req.BacBranchID
		} else {
			bacArg = nil
		}
	}

	_, err := database.DB.Exec(
		`UPDATE users SET
		   full_name         = COALESCE(NULLIF(?, ''), full_name),
		   email             = COALESCE(NULLIF(?, ''), email),
		   phone             = COALESCE(NULLIF(?, ''), phone),
		   city              = COALESCE(NULLIF(?, ''), city),
		   gender            = COALESCE(NULLIF(?, ''), gender),
		   learning_path_id  = COALESCE(?, learning_path_id),
		   bac_branch_id     = COALESCE(?, bac_branch_id),
		   updated_at        = NOW()
		 WHERE id = ?`,
		req.FullName, req.Email, req.Phone, req.City, req.Gender,
		lpArg, bacArg,
		userID,
	)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "فشل تحديث الملف الشخصي"})
		return
	}

	// إرجاع بيانات المستخدم المحدثة
	var user models.User
	var lpID, bacID sql.NullInt64
	database.DB.QueryRow(
		`SELECT id, full_name, email, phone, learning_path_id, bac_branch_id,
		        COALESCE(city,''), COALESCE(gender,''), created_at, updated_at
		 FROM users WHERE id = ?`, userID,
	).Scan(&user.ID, &user.FullName, &user.Email, &user.Phone,
		&lpID, &bacID, &user.City, &user.Gender, &user.CreatedAt, &user.UpdatedAt)
	if lpID.Valid { v := uint(lpID.Int64); user.LearningPathID = &v }
	if bacID.Valid { v := uint(bacID.Int64); user.BacBranchID = &v }

	c.JSON(http.StatusOK, gin.H{"message": "تم تحديث الملف الشخصي بنجاح", "user": user})
}
