import { api } from '../lib/api'
import type { Lesson } from '../types'

export const lessonsService = {
  async getAll(queryParams: string): Promise<Lesson[]> {
    const res = await api.get(`/admin/lessons?${queryParams}`)
    return (res.data?.lessons ?? res.data?.data ?? []) as Lesson[]
  },
  async create(data: Partial<Lesson>): Promise<void> {
    await api.post('/admin/lessons', data)
  },
  async update(id: number, data: Partial<Lesson>): Promise<void> {
    await api.put(`/admin/lessons/${id}`, data)
  },
  async delete(id: number): Promise<void> {
    await api.delete(`/admin/lessons/${id}`)
  },
}
