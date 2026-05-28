import { Navigate } from 'react-router-dom'
import { isAuthenticated } from './useAdminAuth'
import { useAdminScope } from '../context/AdminScopeContext'
import type { ReactNode } from 'react'

export function ProtectedRoute({ children }: { children: ReactNode }) {
  if (!isAuthenticated()) return <Navigate to="/login" replace />
  return <>{children}</>
}

export function ScopedRoute({ children }: { children: ReactNode }) {
  if (!isAuthenticated()) return <Navigate to="/login" replace />
  const { scope } = useAdminScope()
  if (!scope) return <Navigate to="/select-scope" replace />
  return <>{children}</>
}
