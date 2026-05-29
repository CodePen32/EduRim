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

	// Determine calculation type and learning path from first subject
	calcType := "weighted_average"
	learningPathID := 0
	if len(subjects) > 0 {
		calcType = subjects[0].CalculationType
		learningPathID = subjects[0].LearningPathID
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

	// learningPathID=2 → BEPC rules, learningPathID=3 → BAC rules
	if learningPathID == 2 {
		// BEPC: <7 failed, 7–<8.5 promoted, >=8.5 passed
		if average >= 8.5 {
			status = "ناجح"
			message = "مبروك! لقد نجحت في شهادة التعليم الأساسي"
		} else if average >= 7 {
			status = "متجاوز"
			message = "أنت في منطقة الاستدراك — بلغت حد التجاوز"
		} else {
			status = "راسب"
			message = "لم تبلغ الحد الأدنى للنجاح — استمر في المجهود"
		}
	} else {
		// BAC (learningPathID=3): <8 failed, 8–<10 retake, >=10 passed
		if average >= 10 {
			status = "ناجح"
			message = "مبروك! لقد نجحت في الباكالوريا"
		} else if average >= 8 {
			status = "استدراك"
			message = "أنت في منطقة الاستدراك — يمكنك المحاولة في الدور الثاني"
		} else {
			status = "راسب"
			message = "لم تبلغ الحد الأدنى للاستدراك — استمر في المجهود"
		}
	}

	c.JSON(http.StatusOK, gin.H{
		"average":            average,
		"max_total":          20.0,
		"total_points":       weightedSum,
		"total_coefficients": totalCoef,
		"status":             status,
		"message":            message,
		"calculation_type":   "weighted_average",
		"learning_path_id":   learningPathID,
	})
}
