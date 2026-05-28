import { api } from '../lib/api'

export interface AdminInfo {
  id: number
  email: string
  name?: string
}

export async function adminLogin(email: string, password: string): Promise<string> {
  const res = await api.post('/admin/auth/login', { email, password })
  const token = res.data?.token as string
  if (!token) throw new Error('لم يُرجع الخادم token')
  localStorage.setItem('admin_token', token)
  return token
}

export function adminLogout() {
  localStorage.removeItem('admin_token')
  localStorage.removeItem('admin_scope')
  window.location.href = '/login'
}

export function isAuthenticated(): boolean {
  return !!localStorage.getItem('admin_token')
}
