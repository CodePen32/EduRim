import { api } from '../lib/api'
import type { Subject } from '../types'

export const subjectsService = {
  async getAll(queryParams: string): Promise<Subject[]> {
    const res = await api.get(`/admin/subjects?${queryParams}`)
    return (res.data?.subjects ?? res.data?.data ?? []) as Subject[]
  },
  async create(data: Partial<Subject>): Promise<void> {
    await api.post('/admin/subjects', data)
  },
  async update(id: number, data: Partial<Subject>): Promise<void> {
    await api.put(`/admin/subjects/${id}`, data)
  },
  async delete(id: number): Promise<void> {
    await api.delete(`/admin/subjects/${id}`)
  },
}
