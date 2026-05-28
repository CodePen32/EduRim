import { api } from '../lib/api'
import type { Exercise } from '../types'

export const exercisesService = {
  async getAll(queryParams: string): Promise<Exercise[]> {
    const res = await api.get(`/admin/exercises?${queryParams}`)
    return (res.data?.exercises ?? res.data?.data ?? []) as Exercise[]
  },
  async create(data: Partial<Exercise>): Promise<void> {
    await api.post('/admin/exercises', data)
  },
  async update(id: number, data: Partial<Exercise>): Promise<void> {
    await api.put(`/admin/exercises/${id}`, data)
  },
  async delete(id: number): Promise<void> {
    await api.delete(`/admin/exercises/${id}`)
  },
}
