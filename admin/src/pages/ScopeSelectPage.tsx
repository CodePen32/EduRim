import { useNavigate } from 'react-router-dom'
import { useAdminScope } from '../context/AdminScopeContext'
import type { AdminScope } from '../types'

const SECTIONS: (AdminScope & { color: string; lightBg: string; description: string })[] = [
  { learningPathId: 1, bacBranchId: null, label: 'Concours', color: '#2563EB', lightBg: '#EFF6FF', description: 'اختبار Concours الوطني' },
  { learningPathId: 2, bacBranchId: null, label: 'BEPC',     color: '#16A34A', lightBg: '#F0FDF4', description: 'شهادة التعليم الأساسي' },
  { learningPathId: 3, bacBranchId: 1,    label: 'Bac C',    color: '#7C3AED', lightBg: '#F5F3FF', description: 'باكالوريا — شعبة العلوم' },
  { learningPathId: 3, bacBranchId: 2,    label: 'Bac D',    color: '#D97706', lightBg: '#FFFBEB', description: 'باكالوريا — شعبة الطبيعيات' },
]

export function ScopeSelectPage() {
  const { setScope } = useAdminScope()
  const navigate = useNavigate()

  function select(s: AdminScope) {
    setScope(s)
    navigate('/dashboard', { replace: true })
  }

  return (
    <div
      className="min-h-screen flex items-center justify-center"
      style={{ background: '#F1F5F9', padding: '24px 16px' }}
      dir="rtl"
    >
      <div style={{ width: '100%', maxWidth: 480 }}>

        {/* Header */}
        <div style={{ textAlign: 'center', marginBottom: 36 }}>
          <div
            className="flex items-center justify-center rounded-2xl mx-auto"
            style={{ width: 60, height: 60, background: '#EFF6FF', marginBottom: 16 }}
          >
            <svg width="30" height="30" viewBox="0 0 24 24" fill="#2563EB">
              <path d="M12 3L1 9l11 6 9-4.91V17h2V9L12 3z"/>
              <path d="M5 13.18v4L12 21l7-3.82v-4L12 17l-7-3.82z" opacity="0.7"/>
            </svg>
          </div>
          <h1 style={{ fontSize: 20, fontWeight: 700, color: '#1E293B', fontFamily: 'Cairo', margin: 0 }}>
            اختر القسم الدراسي
          </h1>
          <p style={{ fontSize: 13, color: '#64748B', fontFamily: 'Cairo', marginTop: 6 }}>
            ستُصفَّح جميع البيانات حسب القسم المختار
          </p>
        </div>

        {/* Section cards — responsive grid */}
        <div className="scope-cards-grid">
          {SECTIONS.map((s) => (
            <button
              key={s.label}
              onClick={() => select(s)}
              style={{
                background: s.color,
                border: 'none',
                borderRadius: 18,
                padding: '24px 16px',
                textAlign: 'center',
                cursor: 'pointer',
                boxShadow: `0 4px 20px ${s.color}40`,
                transform: 'translateY(0)',
                transition: 'transform 0.2s, box-shadow 0.2s',
                width: '100%',
              }}
              onMouseEnter={(e) => {
                (e.currentTarget as HTMLButtonElement).style.transform = 'translateY(-3px)'
                ;(e.currentTarget as HTMLButtonElement).style.boxShadow = `0 8px 28px ${s.color}55`
              }}
              onMouseLeave={(e) => {
                (e.currentTarget as HTMLButtonElement).style.transform = 'translateY(0)'
                ;(e.currentTarget as HTMLButtonElement).style.boxShadow = `0 4px 20px ${s.color}40`
              }}
            >
              <p style={{ fontSize: 20, fontWeight: 700, color: '#fff', fontFamily: 'Cairo', marginBottom: 6, margin: '0 0 6px' }}>{s.label}</p>
              <p style={{ fontSize: 12, color: 'rgba(255,255,255,0.82)', fontFamily: 'Cairo', margin: 0 }}>{s.description}</p>
            </button>
          ))}
        </div>
      </div>
    </div>
  )
}
