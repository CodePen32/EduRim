import { api } from '../lib/api'
import type { Teacher } from '../types'

export const teachersService = {
  async getAll(queryParams: string): Promise<Teacher[]> {
    const res = await api.get(`/admin/teachers?${queryParams}`)
    return (res.data?.teachers ?? res.data?.data ?? []) as Teacher[]
  },
  async getBySubject(subjectId: number): Promise<Teacher[]> {
    const res = await api.get(`/teachers?subject_id=${subjectId}`)
    return (res.data?.teachers ?? res.data?.data ?? []) as Teacher[]
  },
  async create(data: Partial<Teacher>): Promise<void> {
    await api.post('/admin/teachers', data)
  },
  async update(id: number, data: Partial<Teacher>): Promise<void> {
    await api.put(`/admin/teachers/${id}`, data)
  },
  async delete(id: number): Promise<void> {
    await api.delete(`/admin/teachers/${id}`)
  },
}
