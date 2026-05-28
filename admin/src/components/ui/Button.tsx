import type { ButtonHTMLAttributes } from 'react'

interface ButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: 'primary' | 'secondary' | 'danger' | 'ghost'
  size?: 'sm' | 'md' | 'lg'
  loading?: boolean
}

const STYLES = {
  primary:   { bg: '#2563EB', hover: '#1D4ED8', color: '#fff' },
  secondary: { bg: '#F1F5F9', hover: '#E2E8F0', color: '#475569' },
  danger:    { bg: '#DC2626', hover: '#B91C1C', color: '#fff' },
  ghost:     { bg: 'transparent', hover: '#F1F5F9', color: '#64748B' },
}
const SIZES = {
  sm: { padding: '6px 12px', fontSize: 12 },
  md: { padding: '8px 16px', fontSize: 13 },
  lg: { padding: '10px 20px', fontSize: 14 },
}

export function Button({ variant = 'primary', size = 'md', loading, children, disabled, style, ...props }: ButtonProps) {
  const s = STYLES[variant]
  const z = SIZES[size]
  return (
    <button
      disabled={disabled || loading}
      style={{
        display: 'inline-flex', alignItems: 'center', gap: 6,
        fontFamily: 'Cairo', fontWeight: 600, borderRadius: 10,
        cursor: disabled || loading ? 'not-allowed' : 'pointer',
        opacity: disabled || loading ? 0.6 : 1,
        transition: 'background 0.15s',
        background: s.bg, color: s.color,
        border: variant === 'secondary' ? '1.5px solid #E2E8F0' : 'none',
        ...z, ...style,
      }}
      onMouseEnter={(e) => { if (!disabled && !loading) (e.currentTarget as HTMLButtonElement).style.background = s.hover }}
      onMouseLeave={(e) => { if (!disabled && !loading) (e.currentTarget as HTMLButtonElement).style.background = s.bg }}
      {...props}
    >
      {loading && (
        <span style={{ width: 14, height: 14, borderRadius: '50%', border: '2px solid rgba(255,255,255,0.4)', borderTopColor: '#fff', display: 'inline-block', animation: 'spin 0.7s linear infinite' }} />
      )}
      {children}
    </button>
  )
}
