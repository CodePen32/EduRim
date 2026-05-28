import { api } from '../lib/api'

export interface Announcement {
  id: number
  title: string
  message: string
  image_url: string
  link_url: string
  learning_path_id: number | null
  bac_branch_id: number | null
  is_active: boolean
  starts_at: string | null
  ends_at: string | null
  created_at: string
}

export interface AnnouncementForm {
  title: string
  message: string
  image_url: string
  link_url: string
  is_active: boolean
  starts_at: string
  ends_at: string
  learning_path_id: number | null
  bac_branch_id: number | null
}

export const announcementsService = {
  async getAll(queryParams: string): Promise<Announcement[]> {
    const res = await api.get(`/admin/announcements?${queryParams}`)
    return (res.data?.announcements ?? []) as Announcement[]
  },
  async create(data: AnnouncementForm): Promise<void> {
    await api.post('/admin/announcements', data)
  },
  async update(id: number, data: AnnouncementForm): Promise<void> {
    await api.put(`/admin/announcements/${id}`, data)
  },
  async toggleActive(id: number): Promise<void> {
    await api.patch(`/admin/announcements/${id}/toggle-active`, {})
  },
  async delete(id: number): Promise<void> {
    await api.delete(`/admin/announcements/${id}`)
  },
}
