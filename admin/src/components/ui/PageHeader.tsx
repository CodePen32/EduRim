import type { ReactNode } from 'react'

interface PageHeaderProps { title: string; subtitle?: string; action?: ReactNode }

export function PageHeader({ title, subtitle, action }: PageHeaderProps) {
  return (
    <div
      style={{
        background: '#fff',
        borderBottom: '1px solid #E2E8F0',
        padding: '12px 16px',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'space-between',
        gap: 12,
        marginBottom: 20,
        flexWrap: 'wrap',
      }}
    >
      <div style={{ minWidth: 0 }}>
        <p style={{ fontSize: 16, fontWeight: 700, color: '#1E293B', fontFamily: 'Cairo', margin: 0 }}>{title}</p>
        {subtitle && <p style={{ fontSize: 12, color: '#64748B', fontFamily: 'Cairo', marginTop: 2, margin: 0 }}>{subtitle}</p>}
      </div>
      {action && <div style={{ flexShrink: 0 }}>{action}</div>}
    </div>
  )
}
