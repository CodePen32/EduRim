import type { SelectHTMLAttributes } from 'react'

interface SelectProps extends SelectHTMLAttributes<HTMLSelectElement> {
  label?: string
  options: { value: string | number; label: string }[]
  placeholder?: string
}

export function Select({ label, options, placeholder, style, ...props }: SelectProps) {
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
      {label && (
        <label style={{ fontSize: 13, fontWeight: 600, color: '#374151', fontFamily: 'Cairo' }}>{label}</label>
      )}
      <select
        style={{
          padding: '9px 12px',
          border: '1.5px solid #E2E8F0',
          borderRadius: 10,
          fontSize: 13,
          fontFamily: 'Cairo',
          background: '#FAFAFA',
          color: '#1E293B',
          outline: 'none',
          cursor: 'pointer',
          ...style,
        }}
        onFocus={(e) => { e.target.style.borderColor = '#2563EB'; e.target.style.background = '#fff' }}
        onBlur={(e) => { e.target.style.borderColor = '#E2E8F0'; e.target.style.background = '#FAFAFA' }}
        {...props}
      >
        {placeholder && <option value="">{placeholder}</option>}
        {options.map((o) => (
          <option key={o.value} value={o.value}>{o.label}</option>
        ))}
      </select>
    </div>
  )
}
