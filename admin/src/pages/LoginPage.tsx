import { useState } from 'react'
import type { FormEvent } from 'react'
import { useNavigate } from 'react-router-dom'
import { adminLogin } from '../auth/useAdminAuth'

export function LoginPage() {
  const navigate = useNavigate()
  const [email, setEmail] = useState('admin@edurim.local')
  const [password, setPassword] = useState('')
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')

  async function handleSubmit(e: FormEvent) {
    e.preventDefault()
    setLoading(true)
    setError('')
    try {
      await adminLogin(email, password)
      navigate('/select-scope', { replace: true })
    } catch (err) {
      setError((err as Error).message)
    } finally {
      setLoading(false)
    }
  }

  return (
    <div
      className="min-h-screen flex items-center justify-center p-4"
      style={{ background: '#F1F5F9' }}
      dir="rtl"
    >
      <div
        className="w-full"
        style={{ maxWidth: 400 }}
      >
        {/* Card */}
        <div
          className="bg-white rounded-2xl p-10"
          style={{ boxShadow: '0 4px 24px rgba(0,0,0,0.08)' }}
        >
          {/* Header */}
          <div className="flex flex-col items-center mb-8">
            <div
              className="flex items-center justify-center rounded-2xl mb-4"
              style={{ width: 64, height: 64, background: '#EFF6FF' }}
            >
              <svg width="32" height="32" viewBox="0 0 24 24" fill="none">
                <path d="M12 3L1 9l11 6 9-4.91V17h2V9L12 3z" fill="#2563EB"/>
                <path d="M5 13.18v4L12 21l7-3.82v-4L12 17l-7-3.82z" fill="#2563EB" opacity="0.7"/>
              </svg>
            </div>
            <h1
              className="font-bold text-center"
              style={{ fontSize: 24, color: '#1E293B', fontFamily: 'Cairo' }}
            >
              Edurim Admin
            </h1>
            <p
              className="mt-1 text-center"
              style={{ fontSize: 14, color: '#64748B', fontFamily: 'Cairo' }}
            >
              لوحة التحكم
            </p>
          </div>

          {/* Error */}
          {error && (
            <div
              className="rounded-xl px-4 py-3 mb-5 text-sm text-center"
              style={{ background: '#FEF2F2', color: '#DC2626', border: '1px solid #FECACA', fontFamily: 'Cairo' }}
            >
              {error}
            </div>
          )}

          {/* Form */}
          <form onSubmit={handleSubmit} className="flex flex-col gap-4">
            <div className="flex flex-col gap-1.5">
              <label
                style={{ fontSize: 13, fontWeight: 600, color: '#374151', fontFamily: 'Cairo' }}
              >
                البريد الإلكتروني
              </label>
              <input
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
                dir="ltr"
                className="outline-none transition-all"
                style={{
                  padding: '10px 14px',
                  border: '1.5px solid #E2E8F0',
                  borderRadius: 10,
                  fontSize: 14,
                  background: '#FAFAFA',
                  color: '#1E293B',
                  fontFamily: 'Cairo',
                }}
                onFocus={(e) => { e.target.style.borderColor = '#2563EB'; e.target.style.background = '#fff' }}
                onBlur={(e) => { e.target.style.borderColor = '#E2E8F0'; e.target.style.background = '#FAFAFA' }}
              />
            </div>

            <div className="flex flex-col gap-1.5">
              <label
                style={{ fontSize: 13, fontWeight: 600, color: '#374151', fontFamily: 'Cairo' }}
              >
                كلمة المرور
              </label>
              <input
                type="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder="••••••••"
                required
                dir="ltr"
                className="outline-none transition-all"
                style={{
                  padding: '10px 14px',
                  border: '1.5px solid #E2E8F0',
                  borderRadius: 10,
                  fontSize: 14,
                  background: '#FAFAFA',
                  color: '#1E293B',
                  fontFamily: 'Cairo',
                }}
                onFocus={(e) => { e.target.style.borderColor = '#2563EB'; e.target.style.background = '#fff' }}
                onBlur={(e) => { e.target.style.borderColor = '#E2E8F0'; e.target.style.background = '#FAFAFA' }}
              />
            </div>

            <button
              type="submit"
              disabled={loading}
              className="flex items-center justify-center gap-2 font-bold transition-all mt-2"
              style={{
                padding: '12px',
                background: loading ? '#93C5FD' : '#2563EB',
                color: '#fff',
                borderRadius: 12,
                fontSize: 15,
                fontFamily: 'Cairo',
                cursor: loading ? 'not-allowed' : 'pointer',
                border: 'none',
                letterSpacing: 0.3,
              }}
              onMouseEnter={(e) => { if (!loading) (e.target as HTMLButtonElement).style.background = '#1D4ED8' }}
              onMouseLeave={(e) => { if (!loading) (e.target as HTMLButtonElement).style.background = '#2563EB' }}
            >
              {loading && (
                <span
                  className="border-2 border-white border-t-transparent rounded-full animate-spin"
                  style={{ width: 16, height: 16, display: 'inline-block' }}
                />
              )}
              {loading ? 'جاري الدخول...' : 'دخول'}
            </button>
          </form>
        </div>
      </div>
    </div>
  )
}
