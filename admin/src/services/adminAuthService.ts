import { api } from '../lib/api'

export const adminAuthService = {
  async login(email: string, password: string) {
    const res = await api.post('/admin/auth/login', { email, password })
    return res.data as { token: string; admin: unknown }
  },
  async me() {
    const res = await api.get('/admin/auth/me')
    return res.data
  },
}
