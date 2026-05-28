import type { ReactNode } from 'react'

interface PageHeaderProps { title: string; subtitle?: string; action?: ReactNode }

export function PageHeader({ title, subtitle, action }: PageHeaderProps) {
  return (
    <div
      style={{
        background: '#fff',
        borderBottom: '1px solid #E2E8F0',
        padding: '14px 24px',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'space-between',
        marginBottom: 24,
      }}
    >
      <div>
        <p style={{ fontSize: 17, fontWeight: 700, color: '#1E293B', fontFamily: 'Cairo' }}>{title}</p>
        {subtitle && <p style={{ fontSize: 12, color: '#64748B', fontFamily: 'Cairo', marginTop: 2 }}>{subtitle}</p>}
      </div>
      {action && <div>{action}</div>}
    </div>
  )
}
