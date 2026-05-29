import { api } from '../lib/api'
import type { SubscriptionPlan, UserSubscription, SubscriptionRequest } from '../types'

export const subscriptionService = {
  async getPlans(): Promise<SubscriptionPlan[]> {
    const res = await api.get('/admin/subscription-plans')
    return (res.data?.data ?? []) as SubscriptionPlan[]
  },
  async createPlan(data: Partial<SubscriptionPlan>): Promise<void> {
    await api.post('/admin/subscription-plans', data)
  },
  async updatePlan(id: number, data: Partial<SubscriptionPlan>): Promise<void> {
    await api.put(`/admin/subscription-plans/${id}`, data)
  },
  async deletePlan(id: number): Promise<void> {
    await api.delete(`/admin/subscription-plans/${id}`)
  },

  async getUserSubscriptions(queryParams: string): Promise<UserSubscription[]> {
    const res = await api.get(`/admin/user-subscriptions?${queryParams}`)
    return (res.data?.data ?? []) as UserSubscription[]
  },
  async createUserSubscription(data: Partial<UserSubscription>): Promise<void> {
    await api.post('/admin/user-subscriptions', data)
  },
  async updateUserSubscription(id: number, data: Partial<UserSubscription>): Promise<void> {
    await api.put(`/admin/user-subscriptions/${id}`, data)
  },
  async deleteUserSubscription(id: number): Promise<void> {
    await api.delete(`/admin/user-subscriptions/${id}`)
  },

  async getRequests(queryParams: string, status?: string): Promise<SubscriptionRequest[]> {
    let q = queryParams ? `?${queryParams}` : '?'
    if (status) q += `&status=${status}`
    const res = await api.get(`/admin/subscription-requests${q}`)
    return (res.data?.data ?? []) as SubscriptionRequest[]
  },
  async approveRequest(id: number, adminNote: string): Promise<void> {
    await api.patch(`/admin/subscription-requests/${id}/approve`, { admin_note: adminNote })
  },
  async rejectRequest(id: number, adminNote: string): Promise<void> {
    await api.patch(`/admin/subscription-requests/${id}/reject`, { admin_note: adminNote })
  },
}
