export interface Subject {
  id: number
  learning_path_id: number
  bac_branch_id: number | null
  name_ar: string
  name_fr: string
  icon: string
  color: string
  sort_order: number
  cover_image_url: string
  lessons_count?: number
}

export interface Lesson {
  id: number
  unit_id: number
  subject_id: number
  teacher_id: number
  title: string
  description: string
  video_url: string
  summary_url: string
  cover_image_url: string
  duration_minutes: number
  is_free: boolean
  sort_order: number
  created_at: string
  subject_name?: string
  teacher_name?: string
}

export interface Exercise {
  id: number
  subject_id: number
  title: string
  year: number
  difficulty: string
  exercise_file_url: string
  solution_file_url: string
  video_solution_url: string
  cover_image_url: string
  created_at: string
  subject_name?: string
}

export interface PastExam {
  id: number
  subject_id: number
  learning_path_id: number
  bac_branch_id: number | null
  title: string
  year: number
  exam_file_url: string
  solution_file_url: string
  cover_image_url: string
  created_at: string
  subject_name?: string
}

export interface Teacher {
  id: number
  subject_id: number
  learning_path_id: number
  bac_branch_id: number | null
  full_name: string
  bio: string
  avatar_url: string
  subject_name?: string
  // aliases للتوافق مع كود قديم
  name?: string
  photo_url?: string
}

export interface User {
  id: number
  full_name: string
  email: string
  phone: string
  gender: string
  city: string
  learning_path_id: number | null
  bac_branch_id: number | null
  is_active: boolean
  created_at: string
}

export interface Notification {
  id: number
  title: string
  body: string      // mapped from backend "message" field
  message?: string  // backend raw field
  type: string
  learning_path_id: number | null
  bac_branch_id: number | null
  created_at: string
  is_read?: boolean
}

export interface AdminScope {
  learningPathId: number
  bacBranchId: number | null
  label: string
}

export interface ApiResponse<T> {
  data?: T
  message?: string
  error?: string
}

export interface SubscriptionPlan {
  id: number
  name: string
  description: string
  duration_days: number
  price: number
  learning_path_id: number | null
  bac_branch_id: number | null
  is_active: boolean
  created_at: string
}

export interface UserSubscription {
  id: number
  user_id: number
  plan_id: number
  start_date: string
  end_date: string
  is_active: boolean
  notes: string
  plan_name?: string
  user_full_name?: string
}

export interface SubscriptionRequest {
  id: number
  user_id: number
  plan_id: number
  phone: string
  payment_method: string
  receipt_image_url: string
  note: string
  status: 'pending' | 'approved' | 'rejected'
  admin_note: string
  reviewed_at: string | null
  created_at: string
  user_full_name?: string
  plan_name?: string
  duration_days?: number
}

export interface DashboardStats {
  total_users: number
  total_subjects: number
  total_lessons: number
  total_exercises: number
  total_past_exams: number
  // total_teachers not returned by backend — optional
  total_teachers?: number
}

export interface Suggestion {
  id: number
  user_id: number
  title: string
  description: string
  status: 'new' | 'reviewing' | 'done' | 'rejected'
  created_at: string
  user_full_name: string
  user_phone: string
  user_email: string
  learning_path_id: number | null
  bac_branch_id: number | null
}
