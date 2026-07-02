import { api } from '../lib/api'

export interface LearningPath {
  id: number
  code: string
  name_ar: string
  name_fr: string
  description: string
  enabled: boolean
  created_at: string
}

export const learningPathsService = {
  async getAll(): Promise<LearningPath[]> {
    const res = await api.get('/admin/learning-paths')
    return (res.data?.data ?? []) as LearningPath[]
  },
  async setEnabled(id: number, enabled: boolean): Promise<void> {
    await api.patch(`/admin/learning-paths/${id}/enabled`, { enabled })
  },
}
