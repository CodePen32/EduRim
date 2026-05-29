import { NavLink, Outlet, useNavigate } from 'react-router-dom'
import { useAdminScope } from '../context/AdminScopeContext'
import { adminLogout } from '../auth/useAdminAuth'

const SCOPE_COLOR: Record<string, string> = {
  'Concours': '#2563EB',
  'BEPC':     '#16A34A',
  'Bac C':    '#7C3AED',
  'Bac D':    '#D97706',
}

const NAV = [
  { to: '/dashboard',     label: 'لوحة القسم',          icon: DashIcon },
  { to: '/subjects',      label: 'المواد',               icon: BookIcon },
  { to: '/lessons',       label: 'الدروس',               icon: PlayIcon },
  { to: '/exercises',     label: 'التمارين',             icon: QuizIcon },
  { to: '/past-exams',    label: 'مواضيع الامتحانات',    icon: HistoryIcon },
  { to: '/teachers',      label: 'الأساتذة',             icon: PersonIcon },
  { to: '/users',         label: 'الطلاب',               icon: PeopleIcon },
  { to: '/notifications',  label: 'الإشعارات',            icon: BellIcon },
  { to: '/announcements', label: 'الإعلانات',            icon: MegaphoneIcon },
  { to: '/subscription-plans',   label: 'خطط الاشتراك',        icon: CreditCardIcon },
  { to: '/user-subscriptions',   label: 'اشتراكات الطلاب',     icon: CardCheckIcon },
  { to: '/subscription-requests', label: 'طلبات الاشتراك',      icon: RequestIcon },
]

export function AdminLayout() {
  const { scope, clearScope } = useAdminScope()
  const navigate = useNavigate()
  const scopeColor = scope ? (SCOPE_COLOR[scope.label] ?? '#2563EB') : '#2563EB'

  function handleChangeScope() {
    clearScope()
    navigate('/select-scope')
  }

  return (
    <div className="flex h-screen overflow-hidden" style={{ background: '#F1F5F9' }} dir="rtl">

      {/* ── Sidebar ── */}
      <aside
        className="flex flex-col flex-shrink-0 overflow-y-auto"
        style={{ width: 230, background: '#1E293B' }}
      >
        {/* Logo */}
        <div
          className="flex items-center gap-3 px-5 py-5"
          style={{ borderBottom: '1px solid rgba(255,255,255,0.08)' }}
        >
          <div
            className="flex items-center justify-center rounded-xl flex-shrink-0"
            style={{ width: 38, height: 38, background: '#2563EB' }}
          >
            <svg width="20" height="20" viewBox="0 0 24 24" fill="white">
              <path d="M12 3L1 9l11 6 9-4.91V17h2V9L12 3z"/>
              <path d="M5 13.18v4L12 21l7-3.82v-4L12 17l-7-3.82z" opacity="0.8"/>
            </svg>
          </div>
          <div>
            <p style={{ fontSize: 18, fontWeight: 700, color: '#fff', fontFamily: 'Cairo', lineHeight: 1.2 }}>Edurim</p>
            <p style={{ fontSize: 11, color: '#94A3B8', fontFamily: 'Cairo' }}>لوحة التحكم</p>
          </div>
        </div>

        {/* Current scope */}
        {scope && (
          <div className="px-4 py-4" style={{ borderBottom: '1px solid rgba(255,255,255,0.08)' }}>
            <p style={{ fontSize: 11, color: '#94A3B8', fontFamily: 'Cairo', marginBottom: 8 }}>القسم الحالي</p>
            <div
              className="rounded-xl px-3 py-2.5"
              style={{
                background: scopeColor + '20',
                border: `1px solid ${scopeColor}40`,
              }}
            >
              <p style={{ fontSize: 16, fontWeight: 700, color: scopeColor, fontFamily: 'Cairo', textAlign: 'center' }}>
                {scope.label}
              </p>
            </div>
          </div>
        )}

        {/* Navigation */}
        <nav className="flex-1 px-3 py-3">
          {NAV.map(({ to, label, icon: Icon }) => (
            <NavLink
              key={to}
              to={to}
              style={({ isActive }) => ({
                display: 'flex',
                alignItems: 'center',
                gap: 10,
                padding: '10px 12px',
                borderRadius: 8,
                marginBottom: 2,
                fontSize: 13,
                fontFamily: 'Cairo',
                fontWeight: 500,
                textDecoration: 'none',
                transition: 'all 0.15s',
                background: isActive ? '#2563EB' : 'transparent',
                color: isActive ? '#fff' : '#CBD5E1',
              })}
              className={({ isActive }) => isActive ? '' : 'hover-nav-item'}
            >
              {({ isActive }) => (
                <>
                  <Icon size={18} color={isActive ? '#fff' : '#94A3B8'} />
                  {label}
                </>
              )}
            </NavLink>
          ))}
        </nav>

        {/* Bottom: change scope + logout */}
        <div className="px-3 pb-4 pt-2" style={{ borderTop: '1px solid rgba(255,255,255,0.08)' }}>
          <button
            onClick={handleChangeScope}
            className="w-full flex items-center gap-2.5 px-3 py-2.5 rounded-lg transition-all"
            style={{ fontSize: 13, color: '#94A3B8', fontFamily: 'Cairo', background: 'rgba(255,255,255,0.07)', marginBottom: 4, cursor: 'pointer', border: 'none' }}
          >
            <RefreshIcon size={16} color="#94A3B8" />
            تغيير القسم
          </button>
          <button
            onClick={() => adminLogout()}
            className="w-full flex items-center gap-2.5 px-3 py-2.5 rounded-lg transition-all"
            style={{ fontSize: 13, color: '#94A3B8', fontFamily: 'Cairo', background: 'transparent', cursor: 'pointer', border: 'none' }}
            onMouseEnter={(e) => { (e.currentTarget as HTMLButtonElement).style.color = '#F87171'; (e.currentTarget as HTMLButtonElement).style.background = 'rgba(239,68,68,0.08)' }}
            onMouseLeave={(e) => { (e.currentTarget as HTMLButtonElement).style.color = '#94A3B8'; (e.currentTarget as HTMLButtonElement).style.background = 'transparent' }}
          >
            <LogoutIcon size={16} color="currentColor" />
            تسجيل الخروج
          </button>
        </div>
      </aside>

      {/* ── Main content ── */}
      <main className="flex-1 overflow-y-auto" style={{ background: '#F1F5F9' }}>
        <style>{`
          .hover-nav-item:hover {
            background: rgba(255,255,255,0.07) !important;
            color: #fff !important;
          }
        `}</style>
        <Outlet />
      </main>
    </div>
  )
}

/* ── Inline SVG Icons (no dependency) ── */
function DashIcon({ size, color }: { size: number; color: string }) {
  return <svg width={size} height={size} viewBox="0 0 24 24" fill={color}><path d="M3 13h8V3H3v10zm0 8h8v-6H3v6zm10 0h8V11h-8v10zm0-18v6h8V3h-8z"/></svg>
}
function BookIcon({ size, color }: { size: number; color: string }) {
  return <svg width={size} height={size} viewBox="0 0 24 24" fill={color}><path d="M21 5c-1.11-.35-2.33-.5-3.5-.5-1.95 0-4.05.4-5.5 1.5-1.45-1.1-3.55-1.5-5.5-1.5S2.45 4.9 1 6v14.65c0 .25.25.5.5.5.1 0 .15-.05.25-.05C3.1 20.45 5.05 20 6.5 20c1.95 0 4.05.4 5.5 1.5 1.35-.85 3.8-1.5 5.5-1.5 1.65 0 3.35.3 4.75 1.05.1.05.15.05.25.05.25 0 .5-.25.5-.5V6c-.6-.45-1.25-.75-2-1zm0 13.5c-1.1-.35-2.3-.5-3.5-.5-1.7 0-4.15.65-5.5 1.5V8c1.35-.85 3.8-1.5 5.5-1.5 1.2 0 2.4.15 3.5.5v11.5z"/></svg>
}
function PlayIcon({ size, color }: { size: number; color: string }) {
  return <svg width={size} height={size} viewBox="0 0 24 24" fill={color}><path d="M4 6H2v14c0 1.1.9 2 2 2h14v-2H4V6zm16-4H8c-1.1 0-2 .9-2 2v12c0 1.1.9 2 2 2h12c1.1 0 2-.9 2-2V4c0-1.1-.9-2-2-2zm-8 12.5v-9l6 4.5-6 4.5z"/></svg>
}
function QuizIcon({ size, color }: { size: number; color: string }) {
  return <svg width={size} height={size} viewBox="0 0 24 24" fill={color}><path d="M4 6H2v14c0 1.1.9 2 2 2h14v-2H4V6zm16-4H8c-1.1 0-2 .9-2 2v12c0 1.1.9 2 2 2h12c1.1 0 2-.9 2-2V4c0-1.1-.9-2-2-2zm-2 10h-8v-2h8v2zm0-4h-8V6h8v2z"/></svg>
}
function HistoryIcon({ size, color }: { size: number; color: string }) {
  return <svg width={size} height={size} viewBox="0 0 24 24" fill={color}><path d="M13 3a9 9 0 00-9 9H1l3.89 3.89.07.14L9 12H6c0-3.87 3.13-7 7-7s7 3.13 7 7-3.13 7-7 7c-1.93 0-3.68-.79-4.94-2.06l-1.42 1.42A8.954 8.954 0 0013 21a9 9 0 000-18zm-1 5v5l4.28 2.54.72-1.21-3.5-2.08V8H12z"/></svg>
}
function PersonIcon({ size, color }: { size: number; color: string }) {
  return <svg width={size} height={size} viewBox="0 0 24 24" fill={color}><path d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z"/></svg>
}
function PeopleIcon({ size, color }: { size: number; color: string }) {
  return <svg width={size} height={size} viewBox="0 0 24 24" fill={color}><path d="M16 11c1.66 0 2.99-1.34 2.99-3S17.66 5 16 5c-1.66 0-3 1.34-3 3s1.34 3 3 3zm-8 0c1.66 0 2.99-1.34 2.99-3S9.66 5 8 5C6.34 5 5 6.34 5 8s1.34 3 3 3zm0 2c-2.33 0-7 1.17-7 3.5V19h14v-2.5c0-2.33-4.67-3.5-7-3.5zm8 0c-.29 0-.62.02-.97.05 1.16.84 1.97 1.97 1.97 3.45V19h6v-2.5c0-2.33-4.67-3.5-7-3.5z"/></svg>
}
function BellIcon({ size, color }: { size: number; color: string }) {
  return <svg width={size} height={size} viewBox="0 0 24 24" fill={color}><path d="M12 22c1.1 0 2-.9 2-2h-4c0 1.1.9 2 2 2zm6-6v-5c0-3.07-1.64-5.64-4.5-6.32V4c0-.83-.67-1.5-1.5-1.5s-1.5.67-1.5 1.5v.68C7.63 5.36 6 7.92 6 11v5l-2 2v1h16v-1l-2-2z"/></svg>
}
function RefreshIcon({ size, color }: { size: number; color: string }) {
  return <svg width={size} height={size} viewBox="0 0 24 24" fill={color}><path d="M17.65 6.35C16.2 4.9 14.21 4 12 4c-4.42 0-7.99 3.58-7.99 8s3.57 8 7.99 8c3.73 0 6.84-2.55 7.73-6h-2.08c-.82 2.33-3.04 4-5.65 4-3.31 0-6-2.69-6-6s2.69-6 6-6c1.66 0 3.14.69 4.22 1.78L13 11h7V4l-2.35 2.35z"/></svg>
}
function LogoutIcon({ size, color }: { size: number; color: string }) {
  return <svg width={size} height={size} viewBox="0 0 24 24" fill={color}><path d="M17 7l-1.41 1.41L18.17 11H8v2h10.17l-2.58 2.58L17 17l5-5zM4 5h8V3H4c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h8v-2H4V5z"/></svg>
}
function MegaphoneIcon({ size, color }: { size: number; color: string }) {
  return <svg width={size} height={size} viewBox="0 0 24 24" fill={color}><path d="M18 11v2h4v-2h-4zm-2 6.61c.96.71 2.21 1.65 3.2 2.39.4-.53.8-1.07 1.2-1.6-.99-.74-2.24-1.68-3.2-2.4-.4.54-.8 1.08-1.2 1.61zM20.4 5.6c-.4-.53-.8-1.07-1.2-1.6-.99.74-2.24 1.68-3.2 2.4.4.53.8 1.07 1.2 1.6.96-.72 2.21-1.65 3.2-2.4zM4 9c-1.1 0-2 .9-2 2v2c0 1.1.9 2 2 2h1v4h2v-4h1l5 3V6L8 9H4zm11.5 3c0-1.33-.58-2.53-1.5-3.35v6.69c.92-.81 1.5-2.01 1.5-3.34z"/></svg>
}
function CreditCardIcon({ size, color }: { size: number; color: string }) {
  return <svg width={size} height={size} viewBox="0 0 24 24" fill={color}><path d="M20 4H4c-1.11 0-2 .89-2 2v12c0 1.11.89 2 2 2h16c1.11 0 2-.89 2-2V6c0-1.11-.89-2-2-2zm0 14H4v-6h16v6zm0-10H4V6h16v2z"/></svg>
}
function RequestIcon({ size, color }: { size: number; color: string }) {
  return <svg width={size} height={size} viewBox="0 0 24 24" fill={color}><path d="M14 2H6c-1.1 0-2 .9-2 2v16c0 1.1.89 2 1.99 2H18c1.1 0 2-.9 2-2V8l-6-6zm2 16H8v-2h8v2zm0-4H8v-2h8v2zm-3-5V3.5L18.5 9H13z"/></svg>
}
function CardCheckIcon({ size, color }: { size: number; color: string }) {
  return <svg width={size} height={size} viewBox="0 0 24 24" fill={color}><path d="M17 12h-5v5h5v-5zM16 1v2H8V1H6v2H5c-1.11 0-1.99.9-1.99 2L3 19c0 1.1.89 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2h-1V1h-2zm3 18H5V8h14v11z"/></svg>
}
