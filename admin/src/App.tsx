import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom'
import { AdminScopeProvider } from './context/AdminScopeContext'
import { ProtectedRoute, ScopedRoute } from './auth/ProtectedRoute'
import { AdminLayout } from './layout/AdminLayout'
import { LoginPage } from './pages/LoginPage'
import { ScopeSelectPage } from './pages/ScopeSelectPage'
import { DashboardPage } from './pages/DashboardPage'
import { SubjectsPage } from './pages/SubjectsPage'
import { LessonsPage } from './pages/LessonsPage'
import { ExercisesPage } from './pages/ExercisesPage'
import { PastExamsPage } from './pages/PastExamsPage'
import { TeachersPage } from './pages/TeachersPage'
import { UsersPage } from './pages/UsersPage'
import { NotificationsPage } from './pages/NotificationsPage'
import { AnnouncementsPage } from './pages/AnnouncementsPage'

export default function App() {
  return (
    <AdminScopeProvider>
      <BrowserRouter>
        <Routes>
          <Route path="/login" element={<LoginPage />} />
          <Route path="/select-scope" element={<ProtectedRoute><ScopeSelectPage /></ProtectedRoute>} />

          <Route element={<ScopedRoute><AdminLayout /></ScopedRoute>}>
            <Route path="/dashboard" element={<DashboardPage />} />
            <Route path="/subjects" element={<SubjectsPage />} />
            <Route path="/lessons" element={<LessonsPage />} />
            <Route path="/exercises" element={<ExercisesPage />} />
            <Route path="/past-exams" element={<PastExamsPage />} />
            <Route path="/teachers" element={<TeachersPage />} />
            <Route path="/users" element={<UsersPage />} />
            <Route path="/notifications" element={<NotificationsPage />} />
            <Route path="/announcements" element={<AnnouncementsPage />} />
          </Route>

          <Route path="/" element={<Navigate to="/dashboard" replace />} />
          <Route path="*" element={<Navigate to="/dashboard" replace />} />
        </Routes>
      </BrowserRouter>
    </AdminScopeProvider>
  )
}
