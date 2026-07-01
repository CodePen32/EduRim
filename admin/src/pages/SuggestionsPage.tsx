import { useEffect, useState } from 'react'
import type { CSSProperties } from 'react'
import { Lightbulb, Phone, Mail } from 'lucide-react'
import { suggestionsService } from '../services/suggestionsService'
import type { Suggestion } from '../types'
import { Select } from '../components/ui/Select'
import { Loading } from '../components/ui/Loading'
import { ErrorState } from '../components/ui/ErrorState'
import { EmptyState } from '../components/ui/EmptyState'
import { PageHeader } from '../components/ui/PageHeader'

const STATUS_CONFIG: Record<Suggestion['status'], { label: string; bg: string; color: string; border: string }> = {
  new:       { label: 'جديد',        bg: '#EFF6FF', color: '#2563EB', border: '#BFDBFE' },
  reviewing: { label: 'قيد المراجعة', bg: '#FFFBEB', color: '#D97706', border: '#FDE68A' },
  done:      { label: 'تم التنفيذ',   bg: '#F0FDF4', color: '#16A34A', border: '#BBF7D0' },
  rejected:  { label: 'مرفوض',        bg: '#FEF2F2', color: '#DC2626', border: '#FECACA' },
}

const STATUS_OPTIONS = [
  { value: 'new', label: 'جديد' },
  { value: 'reviewing', label: 'قيد المراجعة' },
  { value: 'done', label: 'تم التنفيذ' },
  { value: 'rejected', label: 'مرفوض' },
]

const cardStyle: CSSProperties = {
  background: '#fff', borderRadius: 14, padding: '16px', border: '1px solid #E2E8F0',
  boxShadow: '0 1px 4px rgba(0,0,0,0.04)',
}

type Toast = { id: number; msg: string; type: 'success' | 'error' }

function fmtDate(s: string): string {
  try { return new Date(s).toLocaleDateString('ar', { year: 'numeric', month: 'short', day: 'numeric' }) }
  catch { return s }
}

export function SuggestionsPage() {
  const [items, setItems] = useState<Suggestion[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')
  const [savingId, setSavingId] = useState<number | null>(null)
  const [toasts, setToasts] = useState<Toast[]>([])

  function toast(msg: string, type: Toast['type']) {
    const id = Date.now()
    setToasts((t) => [...t, { id, msg, type }])
    setTimeout(() => setToasts((t) => t.filter((x) => x.id !== id)), 3000)
  }

  async function load() {
    setLoading(true); setError('')
    try { setItems(await suggestionsService.getAll()) }
    catch (e) { setError((e as Error).message) }
    finally { setLoading(false) }
  }

  useEffect(() => { load() }, [])

  async function changeStatus(s: Suggestion, status: Suggestion['status']) {
    if (status === s.status) return
    setSavingId(s.id)
    try {
      await suggestionsService.updateStatus(s.id, status)
      setItems((list) => list.map((x) => (x.id === s.id ? { ...x, status } : x)))
      toast('تم تحديث الحالة', 'success')
    } catch (e) {
      toast((e as Error).message || 'تعذر تحديث الحالة', 'error')
    } finally {
      setSavingId(null)
    }
  }

  return (
    <div>
      <PageHeader title="اقتراحات التطوير" subtitle="اقتراحات الطلاب لتحسين المنصة" />

      <div className="page-content">
        {loading ? <Loading /> : error ? <ErrorState message={error} onRetry={load} /> : items.length === 0 ? (
          <EmptyState icon={Lightbulb} title="لا توجد اقتراحات بعد" description="ستظهر اقتراحات الطلاب هنا فور إرسالها." />
        ) : (
          <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
            {items.map((s) => {
              const st = STATUS_CONFIG[s.status] ?? STATUS_CONFIG.new
              return (
                <div key={s.id} style={cardStyle}>
                  {/* Header: title + status badge */}
                  <div style={{ display: 'flex', alignItems: 'flex-start', justifyContent: 'space-between', gap: 10, flexWrap: 'wrap' }}>
                    <p style={{ fontSize: 15, fontWeight: 700, color: '#1E293B', fontFamily: 'Cairo', margin: 0 }}>{s.title}</p>
                    <span style={{ fontSize: 12, fontWeight: 600, background: st.bg, color: st.color, border: `1px solid ${st.border}`, borderRadius: 999, padding: '3px 10px', fontFamily: 'Cairo', flexShrink: 0 }}>
                      {st.label}
                    </span>
                  </div>

                  {/* Description */}
                  <p style={{ fontSize: 13, color: '#475569', fontFamily: 'Cairo', margin: '8px 0 0', lineHeight: 1.7 }}>{s.description}</p>

                  {/* Student info */}
                  <div style={{ display: 'flex', alignItems: 'center', gap: 14, flexWrap: 'wrap', marginTop: 12, paddingTop: 12, borderTop: '1px solid #F1F5F9' }}>
                    <span style={{ fontSize: 13, fontWeight: 600, color: '#1E293B', fontFamily: 'Cairo' }}>{s.user_full_name || `#${s.user_id}`}</span>
                    {s.user_phone && (
                      <span style={{ fontSize: 12, color: '#64748B', fontFamily: 'Cairo', display: 'inline-flex', alignItems: 'center', gap: 4, direction: 'ltr' }}>
                        <Phone size={12} /> {s.user_phone}
                      </span>
                    )}
                    {s.user_email && (
                      <span style={{ fontSize: 12, color: '#64748B', fontFamily: 'Cairo', display: 'inline-flex', alignItems: 'center', gap: 4, direction: 'ltr' }}>
                        <Mail size={12} /> {s.user_email}
                      </span>
                    )}
                    <span style={{ fontSize: 12, color: '#94A3B8', fontFamily: 'Cairo', marginInlineStart: 'auto' }}>{fmtDate(s.created_at)}</span>
                  </div>

                  {/* Status control */}
                  <div style={{ marginTop: 12, display: 'flex', alignItems: 'center', gap: 8 }}>
                    <span style={{ fontSize: 13, color: '#64748B', fontFamily: 'Cairo' }}>تغيير الحالة:</span>
                    <Select
                      options={STATUS_OPTIONS}
                      value={s.status}
                      disabled={savingId === s.id}
                      onChange={(e) => changeStatus(s, e.target.value as Suggestion['status'])}
                      style={{ minWidth: 160 }}
                    />
                  </div>
                </div>
              )
            })}
          </div>
        )}
      </div>

      {/* Toasts */}
      <div style={{ position: 'fixed', bottom: 20, insetInlineStart: 20, display: 'flex', flexDirection: 'column', gap: 8, zIndex: 100 }}>
        {toasts.map((t) => (
          <div key={t.id} style={{ background: t.type === 'success' ? '#16A34A' : '#DC2626', color: '#fff', padding: '10px 16px', borderRadius: 10, fontSize: 13, fontFamily: 'Cairo', boxShadow: '0 4px 12px rgba(0,0,0,0.15)' }}>
            {t.msg}
          </div>
        ))}
      </div>
    </div>
  )
}
