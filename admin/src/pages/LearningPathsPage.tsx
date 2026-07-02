import { useEffect, useState } from 'react'
import { ToggleLeft, ToggleRight, Map, AlertTriangle, CheckCircle, AlertCircle } from 'lucide-react'
import { learningPathsService } from '../services/learningPathsService'
import type { LearningPath } from '../services/learningPathsService'
import { ConfirmDialog } from '../components/ui/ConfirmDialog'
import { Loading } from '../components/ui/Loading'
import { ErrorState } from '../components/ui/ErrorState'
import { PageHeader } from '../components/ui/PageHeader'
import type { CSSProperties } from 'react'

const cardStyle: CSSProperties = {
  background: '#fff', borderRadius: 14, padding: '14px 18px',
  display: 'flex', alignItems: 'center', gap: 14,
  border: '1px solid #E2E8F0', boxShadow: '0 1px 4px rgba(0,0,0,0.04)',
}

type Toast = { id: number; msg: string; type: 'success' | 'error' }

export function LearningPathsPage() {
  const [items, setItems] = useState<LearningPath[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')
  const [togglingId, setTogglingId] = useState<number | null>(null)
  const [confirmTarget, setConfirmTarget] = useState<LearningPath | null>(null)
  const [toasts, setToasts] = useState<Toast[]>([])
  let toastId = 0

  function showToast(msg: string, type: 'success' | 'error') {
    const id = ++toastId
    setToasts((prev) => [...prev, { id, msg, type }])
    setTimeout(() => setToasts((prev) => prev.filter((t) => t.id !== id)), 4000)
  }

  async function load() {
    setLoading(true); setError('')
    try { setItems(await learningPathsService.getAll()) }
    catch (e) { setError((e as Error).message) }
    finally { setLoading(false) }
  }
  useEffect(() => { load() }, [])

  const enabledCount = items.filter((p) => p.enabled).length

  function requestToggle(p: LearningPath) {
    // منع تعطيل آخر مسار مفعّل — يجب أن يبقى مسار واحد على الأقل ظاهراً للطلاب الجدد.
    if (p.enabled && enabledCount <= 1) {
      setConfirmTarget(p)
      return
    }
    doToggle(p)
  }

  async function doToggle(p: LearningPath) {
    setTogglingId(p.id)
    try {
      await learningPathsService.setEnabled(p.id, !p.enabled)
      setItems((prev) => prev.map((x) => (x.id === p.id ? { ...x, enabled: !x.enabled } : x)))
      showToast(!p.enabled ? `تم تفعيل ${p.name_ar}` : `تم تعطيل ${p.name_ar}`, 'success')
    } catch (e) {
      showToast((e as Error).message, 'error')
    } finally {
      setTogglingId(null)
    }
  }

  return (
    <div>
      <PageHeader title="المسارات الدراسية" subtitle="تفعيل أو تعطيل ظهور المسار لطلاب جدد" />
      <div style={{ padding: '0 24px 24px' }}>
        {/* تحذير ثابت أعلى الصفحة */}
        <div style={{
          background: '#FFFBEB', border: '1px solid #FDE68A', borderRadius: 10,
          padding: '10px 14px', marginBottom: 16, display: 'flex', alignItems: 'center', gap: 8,
        }}>
          <AlertTriangle size={16} color="#B45309" style={{ flexShrink: 0 }} />
          <p style={{ fontSize: 12.5, color: '#92400E', fontFamily: 'Cairo' }}>
            المسارات المعطلة لا تظهر للمستخدمين الجدد عند اختيار المسار.
          </p>
        </div>

        {loading ? <Loading /> : error ? <ErrorState message={error} onRetry={load} /> : (
          <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
            {items.map((p) => (
              <div key={p.id} style={{ ...cardStyle, opacity: p.enabled ? 1 : 0.65 }}>
                <div style={{
                  width: 44, height: 44, borderRadius: 10, background: '#EFF6FF',
                  display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0,
                }}>
                  <Map size={20} color="#2563EB" />
                </div>
                <div style={{ flex: 1, minWidth: 0 }}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: 8, flexWrap: 'wrap' }}>
                    <p style={{ fontSize: 14, fontWeight: 700, color: '#1E293B', fontFamily: 'Cairo' }}>{p.name_ar}</p>
                    <span style={{
                      fontSize: 11, padding: '2px 8px', borderRadius: 20, fontFamily: 'Cairo', fontWeight: 600,
                      background: p.enabled ? '#F0FDF4' : '#F1F5F9', color: p.enabled ? '#16A34A' : '#94A3B8',
                    }}>
                      {p.enabled ? 'مفعّل' : 'معطّل'}
                    </span>
                  </div>
                  <p style={{ fontSize: 12, color: '#64748B', fontFamily: 'Cairo', marginTop: 3 }}>
                    {p.name_fr} · <span dir="ltr" style={{ fontFamily: 'monospace' }}>{p.code}</span>
                  </p>
                </div>
                <button
                  onClick={() => requestToggle(p)}
                  disabled={togglingId === p.id}
                  title={p.enabled ? 'تعطيل' : 'تفعيل'}
                  style={{
                    width: 34, height: 34, borderRadius: 8, border: 'none', background: 'transparent',
                    cursor: togglingId === p.id ? 'wait' : 'pointer', display: 'flex', alignItems: 'center',
                    justifyContent: 'center', flexShrink: 0, opacity: togglingId === p.id ? 0.5 : 1,
                  }}
                  onMouseEnter={(e) => { (e.currentTarget as HTMLButtonElement).style.background = '#F1F5F9' }}
                  onMouseLeave={(e) => { (e.currentTarget as HTMLButtonElement).style.background = 'transparent' }}
                >
                  {p.enabled ? <ToggleRight size={22} color="#16A34A" /> : <ToggleLeft size={22} color="#94A3B8" />}
                </button>
              </div>
            ))}
          </div>
        )}
      </div>

      <ConfirmDialog
        open={!!confirmTarget}
        onClose={() => setConfirmTarget(null)}
        onConfirm={() => { const p = confirmTarget!; setConfirmTarget(null); doToggle(p) }}
        title="تحذير: آخر مسار مفعّل"
        message={`"${confirmTarget?.name_ar ?? ''}" هو المسار الوحيد المفعّل حالياً. تعطيله سيخفي كل المسارات عن المستخدمين الجدد عند اختيار المسار. هل تريد المتابعة؟`}
      />

      {/* Toasts */}
      <div style={{ position: 'fixed', bottom: 24, left: '50%', transform: 'translateX(-50%)', zIndex: 9998, display: 'flex', flexDirection: 'column', gap: 8, alignItems: 'center' }}>
        {toasts.map((t) => (
          <div key={t.id} style={{
            padding: '12px 20px', borderRadius: 12, fontFamily: 'Cairo', fontSize: 14, fontWeight: 600,
            background: t.type === 'success' ? '#16A34A' : '#DC2626', color: '#fff',
            boxShadow: '0 4px 16px rgba(0,0,0,0.15)', display: 'flex', alignItems: 'center', gap: 8,
          }}>
            {t.type === 'success' ? <CheckCircle size={16} /> : <AlertCircle size={16} />}
            {t.msg}
          </div>
        ))}
      </div>
    </div>
  )
}
