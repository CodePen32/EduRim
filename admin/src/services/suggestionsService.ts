import { api } from '../lib/api'
import type { Suggestion } from '../types'

export const suggestionsService = {
  async getAll(): Promise<Suggestion[]> {
    const res = await api.get('/admin/suggestions')
    return (res.data?.data ?? []) as Suggestion[]
  },
  async updateStatus(id: number, status: Suggestion['status']): Promise<void> {
    await api.patch(`/admin/suggestions/${id}/status`, { status })
  },
}
