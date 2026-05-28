package handlers

import (
	"net/http"

	"edurim/backend/internal/repositories"

	"github.com/gin-gonic/gin"
)

type CalculatorHandler struct {
	repo *repositories.CalculatorRepository
}

func NewCalculatorHandler(repo *repositories.CalculatorRepository) *CalculatorHandler {
	return &CalculatorHandler{repo: repo}
}

// GET /api/calculator/subjects
func (h *CalculatorHandler) GetSubjects(c *gin.Context) {
	userID := getUserID(c)
	if userID == 0 {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "غير مصرح"})
		return
	}

	subjects, err := h.repo.GetSubjectsForUser(userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "تعذر تحميل المواد"})
		return
	}
	if subjects == nil {
		subjects = []repositories.CalculatorSubject{}
	}
	c.JSON(http.StatusOK, gin.H{"subjects": subjects})
}

type markInput struct {
	SubjectID int     `json:"subject_id"`
	Mark      float64 `json:"mark"`
}

type calculateRequest struct {
	Marks []markInput `json:"marks"`
}

// POST /api/calculator/calculate
func (h *CalculatorHandler) Calculate(c *gin.Context) {
	userID := getUserID(c)
	if userID == 0 {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "غير مصرح"})
		return
	}

	var req calculateRequest
	if err := c.ShouldBindJSON(&req); err != nil || len(req.Marks) == 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "بيانات غير صالحة"})
		return
	}

	subjects, err := h.repo.GetSubjectsForUser(userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "تعذر تحميل المواد"})
		return
	}

	// Build subject info map
	type subjectInfo struct {
		MaxMark         float64
		Coefficient     float64
		CalculationType string
	}
	infoMap := make(map[int]subjectInfo)
	for _, s := range subjects {
		infoMap[s.SubjectID] = subjectInfo{
			MaxMark:         s.MaxMark,
			Coefficient:     s.Coefficient,
			CalculationType: s.CalculationType,
		}
	}

	// Determine calculation type from first subject
	calcType := "weighted_average"
	if len(subjects) > 0 {
		calcType = subjects[0].CalculationType
	}

	// Validate marks against max_mark for each subject
	for _, m := range req.Marks {
		info, ok := infoMap[m.SubjectID]
		if !ok {
			continue
		}
		if m.Mark < 0 || m.Mark > info.MaxMark {
			c.JSON(http.StatusBadRequest, gin.H{"error": "نقطة خارج النطاق المسموح به"})
			return
		}
	}

	var status, message string
	var average, totalPoints, maxTotal float64

	if calcType == "points" {
		// Concours: sum raw marks, max = sum of max_marks
		for _, m := range req.Marks {
			info, ok := infoMap[m.SubjectID]
			if !ok {
				continue
			}
			totalPoints += m.Mark
			maxTotal += info.MaxMark
		}
		if maxTotal == 0 {
			c.JSON(http.StatusBadRequest, gin.H{"error": "لم يتم إدخال أي نقطة"})
			return
		}
		average = totalPoints
		if average >= 85 {
			status = "ناجح"
			message = "مبروك! لقد نجحت في الكونكور"
		} else {
			status = "غير ناجح"
			message = "لم تبلغ حد النجاح (85 نقطة). استمر في المجهود"
		}
		c.JSON(http.StatusOK, gin.H{
			"average":           average,
			"max_total":         maxTotal,
			"total_points":      totalPoints,
			"total_coefficients": maxTotal,
			"status":            status,
			"message":           message,
			"calculation_type":  "points",
		})
		return
	}

	// BEPC / BAC: weighted average /20
	var weightedSum, totalCoef float64
	for _, m := range req.Marks {
		info, ok := infoMap[m.SubjectID]
		if !ok {
			continue
		}
		weightedSum += m.Mark * info.Coefficient
		totalCoef += info.Coefficient
	}
	if totalCoef == 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "لم يتم إدخال أي نقطة"})
		return
	}
	average = weightedSum / totalCoef
	if average >= 10 {
		status = "ناجح"
		message = "مبروك! لقد نجحت في هذا الدور"
	} else if average >= 8 {
		status = "غير ناجح"
		message = "أنت قريب من النجاح، استمر في المجهود"
	} else {
		status = "غير ناجح"
		message = "تحتاج إلى مزيد من الجهد والمراجعة"
	}
	c.JSON(http.StatusOK, gin.H{
		"average":            average,
		"max_total":          20.0,
		"total_points":       weightedSum,
		"total_coefficients": totalCoef,
		"status":             status,
		"message":            message,
		"calculation_type":   "weighted_average",
	})
}
