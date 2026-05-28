import { api } from '../lib/api'
import type { Notification } from '../types'

export const notificationsService = {
  async getAll(queryParams: string): Promise<Notification[]> {
    const res = await api.get(`/admin/notifications?${queryParams}`)
    const raw = (res.data?.notifications ?? res.data?.data ?? []) as (Notification & { message?: string })[]
    // Normalize: backend returns "message", UI uses "body"
    return raw.map(n => ({ ...n, body: n.body ?? n.message ?? '' }))
  },
  async create(data: { title: string; body: string; type: string; learning_path_id?: number | null; bac_branch_id?: number | null }): Promise<void> {
    await api.post('/admin/notifications', {
      title: data.title,
      message: data.body,
      type: data.type,
      learning_path_id: data.learning_path_id,
      bac_branch_id: data.bac_branch_id,
    })
  },
}
