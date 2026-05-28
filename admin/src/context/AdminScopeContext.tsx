import { createContext, useContext, useState } from 'react'
import type { ReactNode } from 'react'
import type { AdminScope } from '../types'

interface AdminScopeContextType {
  scope: AdminScope | null
  setScope: (s: AdminScope) => void
  clearScope: () => void
  queryParams: string
}

const AdminScopeContext = createContext<AdminScopeContextType | null>(null)

const SCOPE_KEY = 'admin_scope'

function loadStoredScope(): AdminScope | null {
  try {
    const raw = localStorage.getItem(SCOPE_KEY)
    return raw ? (JSON.parse(raw) as AdminScope) : null
  } catch {
    return null
  }
}

export function AdminScopeProvider({ children }: { children: ReactNode }) {
  const [scope, setScopeState] = useState<AdminScope | null>(loadStoredScope)

  function setScope(s: AdminScope) {
    setScopeState(s)
    localStorage.setItem(SCOPE_KEY, JSON.stringify(s))
  }

  function clearScope() {
    setScopeState(null)
    localStorage.removeItem(SCOPE_KEY)
  }

  const queryParams = scope
    ? `learning_path_id=${scope.learningPathId}${scope.bacBranchId ? `&bac_branch_id=${scope.bacBranchId}` : ''}`
    : ''

  return (
    <AdminScopeContext.Provider value={{ scope, setScope, clearScope, queryParams }}>
      {children}
    </AdminScopeContext.Provider>
  )
}

export function useAdminScope() {
  const ctx = useContext(AdminScopeContext)
  if (!ctx) throw new Error('useAdminScope must be used inside AdminScopeProvider')
  return ctx
}

