import { useEffect, useState } from 'react'
import React from 'react'
import { useAdminScope } from '../context/AdminScopeContext'
import { api } from '../lib/api'
import type { DashboardStats } from '../types'
import { Loading } from '../components/ui/Loading'
import { ErrorState } from '../components/ui/ErrorState'

const CARDS: { key: keyof DashboardStats; label: string; iconColor: string; iconBg: string; icon: React.ReactNode }[] = [
  { key: 'total_users',      label: 'الطلاب',             iconColor: '#2563EB', iconBg: '#EFF6FF',  icon: <path d="M16 11c1.66 0 2.99-1.34 2.99-3S17.66 5 16 5c-1.66 0-3 1.34-3 3s1.34 3 3 3zm-8 0c1.66 0 2.99-1.34 2.99-3S9.66 5 8 5C6.34 5 5 6.34 5 8s1.34 3 3 3zm0 2c-2.33 0-7 1.17-7 3.5V19h14v-2.5c0-2.33-4.67-3.5-7-3.5zm8 0c-.29 0-.62.02-.97.05 1.16.84 1.97 1.97 1.97 3.45V19h6v-2.5c0-2.33-4.67-3.5-7-3.5z"/> },
  { key: 'total_subjects',   label: 'المواد',              iconColor: '#16A34A', iconBg: '#F0FDF4',  icon: <path d="M21 5c-1.11-.35-2.33-.5-3.5-.5-1.95 0-4.05.4-5.5 1.5-1.45-1.1-3.55-1.5-5.5-1.5S2.45 4.9 1 6v14.65c0 .25.25.5.5.5.1 0 .15-.05.25-.05C3.1 20.45 5.05 20 6.5 20c1.95 0 4.05.4 5.5 1.5 1.35-.85 3.8-1.5 5.5-1.5 1.65 0 3.35.3 4.75 1.05.1.05.15.05.25.05.25 0 .5-.25.5-.5V6c-.6-.45-1.25-.75-2-1zm0 13.5c-1.1-.35-2.3-.5-3.5-.5-1.7 0-4.15.65-5.5 1.5V8c1.35-.85 3.8-1.5 5.5-1.5 1.2 0 2.4.15 3.5.5v11.5z"/> },
  { key: 'total_lessons',    label: 'الدروس',              iconColor: '#D97706', iconBg: '#FFFBEB',  icon: <path d="M4 6H2v14c0 1.1.9 2 2 2h14v-2H4V6zm16-4H8c-1.1 0-2 .9-2 2v12c0 1.1.9 2 2 2h12c1.1 0 2-.9 2-2V4c0-1.1-.9-2-2-2zm-8 12.5v-9l6 4.5-6 4.5z"/> },
  { key: 'total_exercises',  label: 'التمارين',            iconColor: '#7C3AED', iconBg: '#F5F3FF',  icon: <path d="M4 6H2v14c0 1.1.9 2 2 2h14v-2H4V6zm16-4H8c-1.1 0-2 .9-2 2v12c0 1.1.9 2 2 2h12c1.1 0 2-.9 2-2V4c0-1.1-.9-2-2-2zm-2 10h-8v-2h8v2zm0-4h-8V6h8v2z"/> },
  { key: 'total_past_exams', label: 'مواضيع الامتحانات',   iconColor: '#DC2626', iconBg: '#FEF2F2',  icon: <path d="M13 3a9 9 0 00-9 9H1l3.89 3.89.07.14L9 12H6c0-3.87 3.13-7 7-7s7 3.13 7 7-3.13 7-7 7c-1.93 0-3.68-.79-4.94-2.06l-1.42 1.42A8.954 8.954 0 0013 21a9 9 0 000-18zm-1 5v5l4.28 2.54.72-1.21-3.5-2.08V8H12z"/> },
  { key: 'total_teachers',   label: 'الأساتذة',            iconColor: '#0284C7', iconBg: '#EFF8FF',  icon: <path d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z"/> },
]

export function DashboardPage() {
  const { scope, queryParams } = useAdminScope()
  const [stats, setStats] = useState<DashboardStats | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')

  async function load() {
    setLoading(true); setError('')
    try {
      const res = await api.get(`/admin/dashboard/stats?${queryParams}`)
      // Backend returns flat object: { total_users, total_subjects, ... }
      setStats(res.data as DashboardStats)
    } catch (e) { setError((e as Error).message) }
    finally { setLoading(false) }
  }

  useEffect(() => { load() }, [queryParams])

  return (
    <div>
      {/* Page header */}
      <div style={{ background: '#fff', borderBottom: '1px solid #E2E8F0', padding: '14px 24px', marginBottom: 24 }}>
        <p style={{ fontSize: 17, fontWeight: 700, color: '#1E293B', fontFamily: 'Cairo' }}>لوحة القسم</p>
        {scope && <p style={{ fontSize: 12, color: '#64748B', fontFamily: 'Cairo', marginTop: 2 }}>نظرة عامة — {scope.label}</p>}
      </div>

      {loading ? <Loading /> : error ? <ErrorState message={error} onRetry={load} /> : stats && (
        <div style={{ padding: '0 24px 24px', display: 'flex', flexWrap: 'wrap', gap: 16 }}>
          {CARDS.map(({ key, label, iconColor, iconBg, icon }) => {
            const value = stats[key] ?? 0
            return (
              <div
                key={key}
                style={{
                  background: '#fff',
                  borderRadius: 16,
                  padding: '20px 22px',
                  border: '1px solid #E2E8F0',
                  boxShadow: '0 1px 6px rgba(0,0,0,0.04)',
                  minWidth: 180,
                  flex: '1 1 180px',
                  maxWidth: 260,
                }}
              >
                <div style={{ width: 48, height: 48, borderRadius: 14, background: iconBg, display: 'flex', alignItems: 'center', justifyContent: 'center', marginBottom: 14 }}>
                  <svg width="24" height="24" viewBox="0 0 24 24" fill={iconColor}>{icon}</svg>
                </div>
                <p style={{ fontSize: 32, fontWeight: 700, color: '#1E293B', fontFamily: 'Cairo', lineHeight: 1 }}>
                  {value}
                </p>
                <p style={{ fontSize: 13, color: '#64748B', fontFamily: 'Cairo', marginTop: 6 }}>{label}</p>
              </div>
            )
          })}
        </div>
      )}
    </div>
  )
}
