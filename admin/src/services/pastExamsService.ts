import { api } from '../lib/api'
import type { PastExam } from '../types'

export const pastExamsService = {
  async getAll(queryParams: string): Promise<PastExam[]> {
    const res = await api.get(`/admin/past-exams?${queryParams}`)
    return (res.data?.past_exams ?? res.data?.data ?? []) as PastExam[]
  },
  async create(data: Partial<PastExam>): Promise<void> {
    await api.post('/admin/past-exams', data)
  },
  async update(id: number, data: Partial<PastExam>): Promise<void> {
    await api.put(`/admin/past-exams/${id}`, data)
  },
  async delete(id: number): Promise<void> {
    await api.delete(`/admin/past-exams/${id}`)
  },
}
