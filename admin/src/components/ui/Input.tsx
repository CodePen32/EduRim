import type { InputHTMLAttributes } from 'react'

interface InputProps extends InputHTMLAttributes<HTMLInputElement> {
  label?: string
  error?: string
}

export function Input({ label, error, style, ...props }: InputProps) {
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
      {label && (
        <label style={{ fontSize: 13, fontWeight: 600, color: '#374151', fontFamily: 'Cairo' }}>
          {label}
        </label>
      )}
      <input
        style={{
          padding: '9px 12px',
          border: `1.5px solid ${error ? '#DC2626' : '#E2E8F0'}`,
          borderRadius: 10,
          fontSize: 13,
          fontFamily: 'Cairo',
          background: '#FAFAFA',
          color: '#1E293B',
          outline: 'none',
          transition: 'border-color 0.15s, background 0.15s',
          ...style,
        }}
        onFocus={(e) => { e.target.style.borderColor = '#2563EB'; e.target.style.background = '#fff' }}
        onBlur={(e) => { e.target.style.borderColor = error ? '#DC2626' : '#E2E8F0'; e.target.style.background = '#FAFAFA' }}
        {...props}
      />
      {error && <span style={{ fontSize: 12, color: '#DC2626', fontFamily: 'Cairo' }}>{error}</span>}
    </div>
  )
}
