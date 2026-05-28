package handlers

import (
	"net/http"
	"strconv"

	"edurim/backend/internal/repositories"

	"github.com/gin-gonic/gin"
)

type AdminContentHandler struct {
	repo   *repositories.AdminContentRepository
	peRepo *repositories.PastExamRepository
}

func NewAdminContentHandler(repo *repositories.AdminContentRepository, peRepo *repositories.PastExamRepository) *AdminContentHandler {
	return &AdminContentHandler{repo: repo, peRepo: peRepo}
}

func scopeFilters(c *gin.Context) (int, int) {
	lpID, _ := strconv.Atoi(c.Query("learning_path_id"))
	bacID, _ := strconv.Atoi(c.Query("bac_branch_id"))
	return lpID, bacID
}

// GET /api/admin/dashboard/stats
func (h *AdminContentHandler) GetStats(c *gin.Context) {
	lpID, bacID := scopeFilters(c)
	stats, err := h.repo.GetStats(lpID, bacID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "خطأ في الخادم"})
		return
	}
	c.JSON(http.StatusOK, stats)
}

// ---- SUBJECTS ----
func (h *AdminContentHandler) GetSubjects(c *gin.Context) {
	lpID, bacID := scopeFilters(c)
	data, err := h.repo.GetAllSubjects(lpID, bacID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "خطأ في الخادم"})
		return
	}
	if data == nil {
		data = []map[string]interface{}{}
	}
	c.JSON(http.StatusOK, gin.H{"subjects": data})
}

func (h *AdminContentHandler) CreateSubject(c *gin.Context) {
	var req struct {
		NameAr         string `json:"name_ar"`
		Icon           string `json:"icon"`
		Color          string `json:"color"`
		LearningPathID int    `json:"learning_path_id"`
		BacBranchID    *int   `json:"bac_branch_id"`
		CoverImageURL  string `json:"cover_image_url"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "بيانات غير صالحة"})
		return
	}
	if req.NameAr == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "اسم المادة مطلوب"})
		return
	}
	if req.LearningPathID <= 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "المسار الدراسي مطلوب"})
		return
	}
	// BAC يتطلب شعبة
	if req.LearningPathID == 3 && req.BacBranchID == nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "يجب تحديد الشعبة للباكالوريا"})
		return
	}
	if req.LearningPathID != 3 {
		req.BacBranchID = nil
	}
	id, err := h.repo.CreateSubject(req.NameAr, req.Icon, req.Color, req.LearningPathID, req.BacBranchID, req.CoverImageURL)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "تعذر إنشاء المادة"})
		return
	}
	c.JSON(http.StatusCreated, gin.H{"id": id, "message": "تم إنشاء المادة بنجاح"})
}

func (h *AdminContentHandler) UpdateSubject(c *gin.Context) {
	id, _ := strconv.Atoi(c.Param("id"))
	var req struct {
		NameAr         string `json:"name_ar"`
		Icon           string `json:"icon"`
		Color          string `json:"color"`
		LearningPathID int    `json:"learning_path_id"`
		BacBranchID    *int   `json:"bac_branch_id"`
		CoverImageURL  string `json:"cover_image_url"`
	}
	c.ShouldBindJSON(&req)
	if req.LearningPathID != 3 {
		req.BacBranchID = nil
	}
	if err := h.repo.UpdateSubject(id, req.NameAr, req.Icon, req.Color, req.LearningPathID, req.BacBranchID, req.CoverImageURL); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "تعذر التعديل"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "تم التعديل بنجاح"})
}

func (h *AdminContentHandler) DeleteSubject(c *gin.Context) {
	id, _ := strconv.Atoi(c.Param("id"))
	if err := h.repo.DeleteSubject(id); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "تعذر الحذف"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "تم الحذف"})
}

// ---- LESSONS ----
func (h *AdminContentHandler) GetLessons(c *gin.Context) {
	lpID, bacID := scopeFilters(c)
	data, err := h.repo.GetAllLessons(lpID, bacID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "خطأ في الخادم"})
		return
	}
	if data == nil {
		data = []map[string]interface{}{}
	}
	c.JSON(http.StatusOK, gin.H{"lessons": data})
}

func (h *AdminContentHandler) CreateLesson(c *gin.Context) {
	var req struct {
		Title         string `json:"title"`
		Description   string `json:"description"`
		VideoURL      string `json:"video_url"`
		SummaryURL    string `json:"summary_url"`
		Duration      int    `json:"duration_minutes"`
		IsFree        bool   `json:"is_free"`
		SubjectID     int    `json:"subject_id"`
		TeacherID     int    `json:"teacher_id"`
		CoverImageURL string `json:"cover_image_url"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "تنسيق البيانات غير صحيح: " + err.Error()})
		return
	}
	if req.Title == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "عنوان الدرس مطلوب"})
		return
	}
	if req.SubjectID <= 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "يرجى اختيار المادة"})
		return
	}
	id, err := h.repo.CreateLesson(req.Title, req.Description, req.VideoURL, req.SummaryURL, req.Duration, req.IsFree, req.SubjectID, req.TeacherID, req.CoverImageURL)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "تعذر إنشاء الدرس"})
		return
	}
	c.JSON(http.StatusCreated, gin.H{"id": id, "message": "تم إنشاء الدرس بنجاح"})
}

func (h *AdminContentHandler) UpdateLesson(c *gin.Context) {
	id, _ := strconv.Atoi(c.Param("id"))
	var req struct {
		Title         string `json:"title"`
		Description   string `json:"description"`
		VideoURL      string `json:"video_url"`
		SummaryURL    string `json:"summary_url"`
		Duration      int    `json:"duration_minutes"`
		IsFree        bool   `json:"is_free"`
		SubjectID     int    `json:"subject_id"`
		TeacherID     int    `json:"teacher_id"`
		CoverImageURL string `json:"cover_image_url"`
	}
	c.ShouldBindJSON(&req)
	if err := h.repo.UpdateLesson(id, req.Title, req.Description, req.VideoURL, req.SummaryURL, req.Duration, req.IsFree, req.SubjectID, req.TeacherID, req.CoverImageURL); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "تعذر التعديل"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "تم التعديل بنجاح"})
}

func (h *AdminContentHandler) DeleteLesson(c *gin.Context) {
	id, _ := strconv.Atoi(c.Param("id"))
	if err := h.repo.DeleteLesson(id); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "تعذر الحذف"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "تم الحذف"})
}

// ---- EXERCISES ----
func (h *AdminContentHandler) GetExercises(c *gin.Context) {
	lpID, bacID := scopeFilters(c)
	data, err := h.repo.GetAllExercises(lpID, bacID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "خطأ في الخادم"})
		return
	}
	if data == nil {
		data = []map[string]interface{}{}
	}
	c.JSON(http.StatusOK, gin.H{"exercises": data})
}

func (h *AdminContentHandler) CreateExercise(c *gin.Context) {
	var req struct {
		Title            string `json:"title"`
		SubjectID        int    `json:"subject_id"`
		Year             int    `json:"year"`
		Difficulty       string `json:"difficulty"`
		ExerciseFileURL  string `json:"exercise_file_url"`
		SolutionFileURL  string `json:"solution_file_url"`
		VideoSolutionURL string `json:"video_solution_url"`
		CoverImageURL    string `json:"cover_image_url"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "تنسيق البيانات غير صحيح: " + err.Error()})
		return
	}
	if req.Title == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "عنوان التمرين مطلوب"})
		return
	}
	if req.SubjectID <= 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "يرجى اختيار المادة"})
		return
	}
	if req.Difficulty == "" {
		req.Difficulty = "متوسط"
	}
	id, err := h.repo.CreateExercise(req.Title, req.SubjectID, req.Year, req.Difficulty, req.ExerciseFileURL, req.SolutionFileURL, req.VideoSolutionURL, req.CoverImageURL)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "تعذر إنشاء التمرين"})
		return
	}
	c.JSON(http.StatusCreated, gin.H{"id": id, "message": "تم إنشاء التمرين بنجاح"})
}

func (h *AdminContentHandler) UpdateExercise(c *gin.Context) {
	id, _ := strconv.Atoi(c.Param("id"))
	var req struct {
		Title            string `json:"title"`
		SubjectID        int    `json:"subject_id"`
		Year             int    `json:"year"`
		Difficulty       string `json:"difficulty"`
		ExerciseFileURL  string `json:"exercise_file_url"`
		SolutionFileURL  string `json:"solution_file_url"`
		VideoSolutionURL string `json:"video_solution_url"`
		CoverImageURL    string `json:"cover_image_url"`
	}
	c.ShouldBindJSON(&req)
	if err := h.repo.UpdateExercise(id, req.Title, req.SubjectID, req.Year, req.Difficulty, req.ExerciseFileURL, req.SolutionFileURL, req.VideoSolutionURL, req.CoverImageURL); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "تعذر التعديل"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "تم التعديل بنجاح"})
}

func (h *AdminContentHandler) DeleteExercise(c *gin.Context) {
	id, _ := strconv.Atoi(c.Param("id"))
	if err := h.repo.DeleteExercise(id); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "تعذر الحذف"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "تم الحذف"})
}

// ---- TEACHERS ----
func (h *AdminContentHandler) GetTeachers(c *gin.Context) {
	lpID, bacID := scopeFilters(c)
	subjectID, _ := strconv.Atoi(c.Query("subject_id"))
	data, err := h.repo.GetAllTeachers(lpID, bacID, subjectID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "خطأ في الخادم"})
		return
	}
	if data == nil {
		data = []map[string]interface{}{}
	}
	c.JSON(http.StatusOK, gin.H{"teachers": data})
}

func (h *AdminContentHandler) CreateTeacher(c *gin.Context) {
	var req struct {
		FullName  string `json:"full_name" binding:"required"`
		Bio       string `json:"bio"`
		SubjectID int    `json:"subject_id"`
		AvatarURL string `json:"avatar_url"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "بيانات غير صالحة"})
		return
	}
	id, err := h.repo.CreateTeacher(req.FullName, req.Bio, req.SubjectID, req.AvatarURL)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "تعذر الإنشاء"})
		return
	}
	c.JSON(http.StatusCreated, gin.H{"id": id, "message": "تم إنشاء الأستاذ بنجاح"})
}

func (h *AdminContentHandler) UpdateTeacher(c *gin.Context) {
	id, _ := strconv.Atoi(c.Param("id"))
	var req struct {
		FullName  string `json:"full_name"`
		Bio       string `json:"bio"`
		SubjectID int    `json:"subject_id"`
		AvatarURL string `json:"avatar_url"`
	}
	c.ShouldBindJSON(&req)
	if err := h.repo.UpdateTeacher(id, req.FullName, req.Bio, req.SubjectID, req.AvatarURL); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "تعذر التعديل"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "تم التعديل بنجاح"})
}

func (h *AdminContentHandler) DeleteTeacher(c *gin.Context) {
	id, _ := strconv.Atoi(c.Param("id"))
	if err := h.repo.DeleteTeacher(id); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "تعذر الحذف"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "تم الحذف"})
}

// ---- PAST EXAMS ----
func (h *AdminContentHandler) GetPastExams(c *gin.Context) {
	data, err := h.peRepo.GetFiltered(repositories.PastExamFilter{})
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "خطأ في الخادم"})
		return
	}
	if data == nil {
		data = []repositories.PastExam{}
	}
	c.JSON(http.StatusOK, gin.H{"past_exams": data})
}

func (h *AdminContentHandler) CreatePastExam(c *gin.Context) {
	var req struct {
		LearningPathID  int    `json:"learning_path_id" binding:"required"`
		BacBranchID     *int   `json:"bac_branch_id"`
		SubjectID       int    `json:"subject_id" binding:"required"`
		Title           string `json:"title" binding:"required"`
		Year            int    `json:"year" binding:"required"`
		Description     string `json:"description"`
		ExamFileURL     string `json:"exam_file_url"`
		SolutionFileURL string `json:"solution_file_url"`
		CoverImageURL   string `json:"cover_image_url"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "بيانات غير صالحة"})
		return
	}
	pe := &repositories.PastExam{
		LearningPathID: req.LearningPathID, BacBranchID: req.BacBranchID,
		SubjectID: req.SubjectID, Title: req.Title, Year: req.Year,
		Description: req.Description, ExamFileURL: req.ExamFileURL,
		SolutionFileURL: req.SolutionFileURL, CoverImageURL: req.CoverImageURL,
	}
	id, err := h.peRepo.Create(pe)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "تعذر الإنشاء"})
		return
	}
	c.JSON(http.StatusCreated, gin.H{"id": id, "message": "تم إنشاء الموضوع بنجاح"})
}

func (h *AdminContentHandler) UpdatePastExam(c *gin.Context) {
	id, _ := strconv.Atoi(c.Param("id"))
	var req struct {
		LearningPathID  int    `json:"learning_path_id"`
		BacBranchID     *int   `json:"bac_branch_id"`
		SubjectID       int    `json:"subject_id"`
		Title           string `json:"title"`
		Year            int    `json:"year"`
		Description     string `json:"description"`
		ExamFileURL     string `json:"exam_file_url"`
		SolutionFileURL string `json:"solution_file_url"`
		CoverImageURL   string `json:"cover_image_url"`
		IsActive        bool   `json:"is_active"`
	}
	c.ShouldBindJSON(&req)
	pe := &repositories.PastExam{
		LearningPathID: req.LearningPathID, BacBranchID: req.BacBranchID,
		SubjectID: req.SubjectID, Title: req.Title, Year: req.Year,
		Description: req.Description, ExamFileURL: req.ExamFileURL,
		SolutionFileURL: req.SolutionFileURL, CoverImageURL: req.CoverImageURL, IsActive: req.IsActive,
	}
	if err := h.peRepo.Update(id, pe); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "تعذر التعديل"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "تم التعديل بنجاح"})
}

func (h *AdminContentHandler) DeletePastExam(c *gin.Context) {
	id, _ := strconv.Atoi(c.Param("id"))
	if err := h.peRepo.Delete(id); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "تعذر الحذف"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "تم الحذف"})
}
