package handlers

import (
	"net/http"
	"strconv"

	"edurim/backend/internal/models"
	"edurim/backend/internal/repositories"

	"github.com/gin-gonic/gin"
)

type SubscriptionHandler struct {
	repo *repositories.SubscriptionRepository
}

func NewSubscriptionHandler(repo *repositories.SubscriptionRepository) *SubscriptionHandler {
	return &SubscriptionHandler{repo: repo}
}

// GET /api/me/subscription
func (h *SubscriptionHandler) GetMySubscription(c *gin.Context) {
	userIDVal, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"message": "غير مصرح"})
		return
	}
	userID := userIDVal.(uint)

	resp, err := h.repo.GetUserSubscription(userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "خطأ في جلب بيانات الاشتراك", "error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"data": resp})
}

// GET /api/admin/subscription-plans
func (h *SubscriptionHandler) GetAdminPlans(c *gin.Context) {
	plans, err := h.repo.GetAllPlans()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "خطأ في جلب الخطط", "error": err.Error()})
		return
	}
	if plans == nil {
		plans = []models.SubscriptionPlan{}
	}
	c.JSON(http.StatusOK, gin.H{"data": plans})
}

// POST /api/admin/subscription-plans
func (h *SubscriptionHandler) CreatePlan(c *gin.Context) {
	var plan models.SubscriptionPlan
	if err := c.ShouldBindJSON(&plan); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "بيانات غير صالحة"})
		return
	}
	if err := h.repo.CreatePlan(plan); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "تعذر إنشاء الخطة", "error": err.Error()})
		return
	}
	c.JSON(http.StatusCreated, gin.H{"message": "تم إنشاء الخطة بنجاح"})
}

// PUT /api/admin/subscription-plans/:id
func (h *SubscriptionHandler) UpdatePlan(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "معرف غير صالح"})
		return
	}
	var plan models.SubscriptionPlan
	if err := c.ShouldBindJSON(&plan); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "بيانات غير صالحة"})
		return
	}
	if err := h.repo.UpdatePlan(id, plan); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "تعذر تعديل الخطة", "error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "تم تعديل الخطة بنجاح"})
}

// DELETE /api/admin/subscription-plans/:id
func (h *SubscriptionHandler) DeletePlan(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "معرف غير صالح"})
		return
	}
	if err := h.repo.DeletePlan(id); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "تعذر حذف الخطة", "error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "تم حذف الخطة بنجاح"})
}

// GET /api/admin/user-subscriptions
func (h *SubscriptionHandler) GetAdminUserSubscriptions(c *gin.Context) {
	lpID, _ := strconv.Atoi(c.DefaultQuery("learning_path_id", "0"))
	var bacBranchID *int
	if bacStr := c.Query("bac_branch_id"); bacStr != "" {
		v, err := strconv.Atoi(bacStr)
		if err == nil {
			bacBranchID = &v
		}
	}
	subs, err := h.repo.GetAllUserSubscriptions(lpID, bacBranchID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "خطأ في جلب الاشتراكات", "error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"data": subs})
}

// POST /api/admin/user-subscriptions
func (h *SubscriptionHandler) CreateUserSubscription(c *gin.Context) {
	var sub models.UserSubscription
	if err := c.ShouldBindJSON(&sub); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "بيانات غير صالحة"})
		return
	}
	if sub.UserID == 0 || sub.PlanID == 0 || sub.StartDate == "" || sub.EndDate == "" {
		c.JSON(http.StatusBadRequest, gin.H{"message": "حقول مطلوبة: user_id, plan_id, start_date, end_date"})
		return
	}
	sub.IsActive = true
	if err := h.repo.CreateUserSubscription(sub); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "تعذر إنشاء الاشتراك", "error": err.Error()})
		return
	}
	c.JSON(http.StatusCreated, gin.H{"message": "تم إنشاء الاشتراك بنجاح"})
}

// PUT /api/admin/user-subscriptions/:id
func (h *SubscriptionHandler) UpdateUserSubscription(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "معرف غير صالح"})
		return
	}
	var sub models.UserSubscription
	if err := c.ShouldBindJSON(&sub); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "بيانات غير صالحة"})
		return
	}
	if err := h.repo.UpdateUserSubscription(id, sub); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "تعذر تعديل الاشتراك", "error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "تم تعديل الاشتراك بنجاح"})
}

// getAdminID extracts admin_id (uint) from JWT context (set by AdminAuth middleware)
func getAdminID(c *gin.Context) uint {
	val, exists := c.Get("admin_id")
	if !exists {
		return 0
	}
	switch v := val.(type) {
	case uint:
		return v
	case float64:
		return uint(v)
	}
	return 0
}

// ── User endpoints ──

// POST /api/me/subscription-requests
func (h *SubscriptionHandler) CreateRequest(c *gin.Context) {
	userID := getUserID(c)
	if userID == 0 {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "غير مصرح"})
		return
	}

	var body struct {
		PlanID          uint   `json:"plan_id"`
		Phone           string `json:"phone"`
		PaymentMethod   string `json:"payment_method"`
		ReceiptImageURL string `json:"receipt_image_url"`
		Note            string `json:"note"`
	}
	if err := c.ShouldBindJSON(&body); err != nil || body.PlanID == 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "بيانات غير صالحة"})
		return
	}

	req := models.SubscriptionRequest{
		UserID: uint(userID), PlanID: body.PlanID,
		Phone: body.Phone, PaymentMethod: body.PaymentMethod,
		ReceiptImageURL: body.ReceiptImageURL, Note: body.Note,
	}
	if err := h.repo.CreateRequest(req); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "تعذر إرسال الطلب"})
		return
	}
	c.JSON(http.StatusCreated, gin.H{"message": "تم إرسال طلبك بنجاح"})
}

// GET /api/me/subscription-requests
func (h *SubscriptionHandler) GetMyRequests(c *gin.Context) {
	userID := getUserID(c)
	if userID == 0 {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "غير مصرح"})
		return
	}
	list, err := h.repo.GetMyRequests(uint(userID))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "تعذر تحميل الطلبات"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"data": list})
}

// GET /api/me/subscription-plans
func (h *SubscriptionHandler) GetMyPlans(c *gin.Context) {
	userID := getUserID(c)
	if userID == 0 {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "غير مصرح"})
		return
	}
	plans, err := h.repo.GetPlansByUser(uint(userID))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "تعذر تحميل الخطط"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"data": plans})
}

// ── Admin endpoints ──

// GET /api/admin/subscription-requests
func (h *SubscriptionHandler) GetAdminRequests(c *gin.Context) {
	status := c.Query("status")
	lpID, _ := strconv.Atoi(c.DefaultQuery("learning_path_id", "0"))
	var bacBranchID *int
	if bacStr := c.Query("bac_branch_id"); bacStr != "" {
		v, err := strconv.Atoi(bacStr)
		if err == nil {
			bacBranchID = &v
		}
	}
	list, err := h.repo.GetAllRequests(status, lpID, bacBranchID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "تعذر تحميل الطلبات"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"data": list})
}

// PATCH /api/admin/subscription-requests/:id/approve
func (h *SubscriptionHandler) ApproveRequest(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "معرّف غير صالح"})
		return
	}
	adminID := getAdminID(c)

	var body struct {
		AdminNote string `json:"admin_note"`
	}
	c.ShouldBindJSON(&body)

	if err := h.repo.ApproveRequest(uint(id), adminID, body.AdminNote); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "تم قبول الطلب وإنشاء الاشتراك"})
}

// PATCH /api/admin/subscription-requests/:id/reject
func (h *SubscriptionHandler) RejectRequest(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "معرّف غير صالح"})
		return
	}
	adminID := getAdminID(c)

	var body struct {
		AdminNote string `json:"admin_note"`
	}
	c.ShouldBindJSON(&body)

	if err := h.repo.RejectRequest(uint(id), adminID, body.AdminNote); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "تم رفض الطلب"})
}

// DELETE /api/admin/user-subscriptions/:id
func (h *SubscriptionHandler) DeleteUserSubscription(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "معرف غير صالح"})
		return
	}
	if err := h.repo.DeleteUserSubscription(id); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "تعذر حذف الاشتراك", "error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "تم حذف الاشتراك بنجاح"})
}
