import { api } from '../lib/api'
import type { User } from '../types'

export const usersService = {
  async getAll(queryParams: string): Promise<User[]> {
    const res = await api.get(`/admin/users?${queryParams}`)
    return (res.data?.users ?? res.data?.data ?? []) as User[]
  },
  async update(id: number, data: Partial<User> & { learning_path_id?: number | null; bac_branch_id?: number | null }): Promise<void> {
    await api.put(`/admin/users/${id}`, data)
  },
  async toggleActive(id: number): Promise<void> {
    await api.patch(`/admin/users/${id}/toggle-active`, {})
  },
}
