import type { ReactNode } from 'react'
import type { LucideIcon } from 'lucide-react'

interface EmptyStateProps {
  icon?: LucideIcon
  title: string
  description?: string
  action?: ReactNode
}

export function EmptyState({ icon: Icon, title, description, action }: EmptyStateProps) {
  return (
    <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', padding: '64px 0', gap: 12, textAlign: 'center' }}>
      {Icon && <Icon size={52} color="#CBD5E1" />}
      <p style={{ fontSize: 15, fontWeight: 600, color: '#64748B', fontFamily: 'Cairo' }}>{title}</p>
      {description && <p style={{ fontSize: 13, color: '#94A3B8', fontFamily: 'Cairo' }}>{description}</p>}
      {action && <div style={{ marginTop: 8 }}>{action}</div>}
    </div>
  )
}
