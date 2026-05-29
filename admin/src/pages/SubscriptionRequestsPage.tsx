import { useEffect, useState } from 'react'
import { CheckCircle, XCircle, FileImage, ClipboardList, AlertCircle } from 'lucide-react'
import { useAdminScope } from '../context/AdminScopeContext'
import { subscriptionService } from '../services/subscriptionService'
import type { SubscriptionRequest } from '../types'
import { Button } from '../components/ui/Button'
import { Modal } from '../components/ui/Modal'
import { Loading } from '../components/ui/Loading'
import { ErrorState } from '../components/ui/ErrorState'
import { EmptyState } from '../components/ui/EmptyState'
import { PageHeader } from '../components/ui/PageHeader'
import { buildFileUrl } from '../lib/fileUrl'
import type { CSSProperties } from 'react'

const FILTERS = [
  { value: '', label: 'الكل' },
  { value: 'pending', label: 'قيد المراجعة' },
  { value: 'approved', label: 'مقبول' },
  { value: 'rejected', label: 'مرفوض' },
]

const STATUS_CONFIG = {
  pending:  { label: 'قيد المراجعة', bg: '#FFFBEB', color: '#D97706', border: '#FDE68A' },
  approved: { label: 'مقبول',        bg: '#F0FDF4', color: '#16A34A', border: '#BBF7D0' },
  rejected: { label: 'مرفوض',        bg: '#FEF2F2', color: '#DC2626', border: '#FECACA' },
}

const cardStyle: CSSProperties = {
  background: '#fff', borderRadius: 14, padding: '14px 16px',
  border: '1px solid #E2E8F0', boxShadow: '0 1px 4px rgba(0,0,0,0.04)',
  display: 'flex', alignItems: 'center', gap: 12, flexWrap: 'wrap',
}
const iBtnStyle: CSSProperties = {
  width: 34, height: 34, borderRadius: 8, border: 'none', background: 'transparent',
  cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center',
  transition: 'background 0.15s', flexShrink: 0,
}

type Toast = { id: number; msg: string; type: 'success' | 'error' }

export function SubscriptionRequestsPage() {
  const { queryParams } = useAdminScope()
  const [items, setItems] = useState<SubscriptionRequest[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')
  const [filter, setFilter] = useState('')

  // review modal
  const [reviewTarget, setReviewTarget] = useState<{ id: number; action: 'approve' | 'reject' } | null>(null)
  const [adminNote, setAdminNote] = useState('')
  const [submitting, setSubmitting] = useState(false)
  const [modalError, setModalError] = useState('')

  // image preview
  const [previewUrl, setPreviewUrl] = useState<string | null>(null)

  // toasts
  const [toasts, setToasts] = useState<Toast[]>([])
  let toastId = 0

  function showToast(msg: string, type: 'success' | 'error') {
    const id = ++toastId
    setToasts(prev => [...prev, { id, msg, type }])
    setTimeout(() => setToasts(prev => prev.filter(t => t.id !== id)), 4000)
  }

  async function load() {
    setLoading(true); setError('')
    try { setItems(await subscriptionService.getRequests(queryParams, filter || undefined)) }
    catch (e) { setError((e as Error).message) }
    finally { setLoading(false) }
  }

  useEffect(() => { load() }, [filter, queryParams]) // eslint-disable-line react-hooks/exhaustive-deps

  function openReview(id: number, action: 'approve' | 'reject') {
    setAdminNote(''); setModalError('')
    setReviewTarget({ id, action })
  }

  function closeReview() {
    if (submitting) return
    setReviewTarget(null); setModalError('')
  }

  async function submitReview() {
    if (!reviewTarget || submitting) return
    setSubmitting(true); setModalError('')
    try {
      if (reviewTarget.action === 'approve') {
        await subscriptionService.approveRequest(reviewTarget.id, adminNote)
        setReviewTarget(null)
        showToast('تم قبول الطلب وإنشاء الاشتراك بنجاح', 'success')
      } else {
        await subscriptionService.rejectRequest(reviewTarget.id, adminNote)
        setReviewTarget(null)
        showToast('تم رفض الطلب وإشعار الطالب', 'success')
      }
      // أعد تحميل القائمة — إذا فشل لا نُظهر خطأ القبول
      try { await load() } catch { /* تم القبول بنجاح، تجاهل خطأ التحديث */ }
    } catch (e) {
      // أظهر الخطأ داخل modal بدلاً من alert
      setModalError((e as Error).message)
    } finally {
      setSubmitting(false)
    }
  }

  const fmt = (s: string) => {
    try { return new Date(s).toLocaleDateString('ar-EG', { year: 'numeric', month: 'short', day: 'numeric' }) }
    catch { return s }
  }

  return (
    <div style={{ position: 'relative' }}>
      <PageHeader title="طلبات الاشتراك" />

      {/* Filter tabs */}
      <div style={{ padding: '0 24px 16px', display: 'flex', gap: 8, flexWrap: 'wrap' }}>
        {FILTERS.map(f => (
          <button key={f.value} onClick={() => setFilter(f.value)}
            style={{
              padding: '6px 16px', borderRadius: 20, fontSize: 13, fontFamily: 'Cairo', fontWeight: 600,
              border: '1.5px solid', cursor: 'pointer', transition: 'all 0.15s',
              background: filter === f.value ? '#2563EB' : '#fff',
              color: filter === f.value ? '#fff' : '#64748B',
              borderColor: filter === f.value ? '#2563EB' : '#E2E8F0',
            }}>
            {f.label}
          </button>
        ))}
      </div>

      <div style={{ padding: '0 24px 24px' }}>
        {loading ? <Loading /> : error ? <ErrorState message={error} onRetry={load} /> : items.length === 0 ? (
          <EmptyState icon={ClipboardList} title="لا توجد طلبات" />
        ) : (
          <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
            {items.map((req) => {
              const st = STATUS_CONFIG[req.status] ?? STATUS_CONFIG.pending
              return (
                <div key={req.id} style={cardStyle}>
                  {/* Icon */}
                  <div style={{ width: 44, height: 44, borderRadius: 12, flexShrink: 0, background: '#EFF6FF', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                    <ClipboardList size={20} color="#2563EB" />
                  </div>

                  {/* Info */}
                  <div style={{ flex: 1, minWidth: 160 }}>
                    <p style={{ fontSize: 14, fontWeight: 700, color: '#1E293B', fontFamily: 'Cairo', marginBottom: 2 }}>
                      {req.user_full_name || `مستخدم #${req.user_id}`}
                    </p>
                    <p style={{ fontSize: 12, color: '#64748B', fontFamily: 'Cairo' }}>
                      {req.plan_name || `خطة #${req.plan_id}`}
                      {req.phone ? ` · ${req.phone}` : ''}
                      {req.payment_method ? ` · ${req.payment_method}` : ''}
                    </p>
                    {req.note && (
                      <p style={{ fontSize: 11, color: '#94A3B8', fontFamily: 'Cairo', marginTop: 2 }}>
                        ملاحظة: {req.note}
                      </p>
                    )}
                    {req.admin_note && req.status !== 'pending' && (
                      <p style={{ fontSize: 11, color: '#7C3AED', fontFamily: 'Cairo', marginTop: 2 }}>
                        رد الإدارة: {req.admin_note}
                      </p>
                    )}
                  </div>

                  {/* Date */}
                  <p style={{ fontSize: 11, color: '#94A3B8', fontFamily: 'Cairo', flexShrink: 0 }}>
                    {fmt(req.created_at)}
                  </p>

                  {/* Receipt image */}
                  {req.receipt_image_url ? (
                    <button onClick={() => setPreviewUrl(buildFileUrl(req.receipt_image_url))}
                      style={{ ...iBtnStyle, background: '#F8FAFC', border: '1px solid #E2E8F0' }}
                      title="عرض الإيصال">
                      <FileImage size={16} color="#2563EB" />
                    </button>
                  ) : null}

                  {/* Status badge */}
                  <span style={{
                    fontSize: 11, padding: '3px 10px', borderRadius: 20, fontFamily: 'Cairo', fontWeight: 600,
                    background: st.bg, color: st.color, border: `1px solid ${st.border}`, flexShrink: 0,
                  }}>
                    {st.label}
                  </span>

                  {/* Actions (pending only) */}
                  {req.status === 'pending' && (
                    <>
                      <button onClick={() => openReview(req.id, 'approve')} style={iBtnStyle} title="قبول"
                        onMouseEnter={(e) => { (e.currentTarget as HTMLButtonElement).style.background = '#F0FDF4' }}
                        onMouseLeave={(e) => { (e.currentTarget as HTMLButtonElement).style.background = 'transparent' }}>
                        <CheckCircle size={18} color="#16A34A" />
                      </button>
                      <button onClick={() => openReview(req.id, 'reject')} style={iBtnStyle} title="رفض"
                        onMouseEnter={(e) => { (e.currentTarget as HTMLButtonElement).style.background = '#FEF2F2' }}
                        onMouseLeave={(e) => { (e.currentTarget as HTMLButtonElement).style.background = 'transparent' }}>
                        <XCircle size={18} color="#DC2626" />
                      </button>
                    </>
                  )}
                  {req.status !== 'pending' && (
                    <div style={{ width: 34, flexShrink: 0 }}>
                      {req.status === 'approved'
                        ? <CheckCircle size={18} color="#16A34A" />
                        : <XCircle size={18} color="#DC2626" />}
                    </div>
                  )}
                </div>
              )
            })}
          </div>
        )}
      </div>

      {/* Review Modal */}
      <Modal
        open={!!reviewTarget}
        onClose={closeReview}
        title={reviewTarget?.action === 'approve' ? 'قبول الطلب' : 'رفض الطلب'}
        footer={
          <>
            <Button variant="secondary" onClick={closeReview} disabled={submitting}>إلغاء</Button>
            <Button
              onClick={submitReview}
              loading={submitting}
              disabled={submitting}
              style={reviewTarget?.action === 'reject' ? { background: '#DC2626' } : undefined}
            >
              {reviewTarget?.action === 'approve' ? 'قبول وإنشاء الاشتراك' : 'رفض الطلب'}
            </Button>
          </>
        }
      >
        <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
          {/* info banner */}
          <div style={{
            padding: '12px 16px', borderRadius: 10, fontFamily: 'Cairo', fontSize: 13,
            background: reviewTarget?.action === 'approve' ? '#F0FDF4' : '#FEF2F2',
            color: reviewTarget?.action === 'approve' ? '#16A34A' : '#DC2626',
            display: 'flex', alignItems: 'center', gap: 8,
          }}>
            {reviewTarget?.action === 'approve'
              ? <><CheckCircle size={16} /> سيتم إنشاء الاشتراك تلقائياً عند القبول</>
              : <><XCircle size={16} /> سيتم رفض الطلب وإشعار الطالب</>}
          </div>

          {/* خطأ داخل modal */}
          {modalError && (
            <div style={{
              padding: '10px 14px', borderRadius: 10, fontFamily: 'Cairo', fontSize: 13,
              background: '#FEF2F2', color: '#DC2626', border: '1px solid #FECACA',
              display: 'flex', alignItems: 'center', gap: 8,
            }}>
              <AlertCircle size={16} />
              {modalError}
            </div>
          )}

          {/* ملاحظة */}
          <div style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
            <label style={{ fontSize: 13, fontWeight: 600, color: '#374151', fontFamily: 'Cairo' }}>
              ملاحظة للطالب (اختياري)
            </label>
            <textarea
              rows={3}
              value={adminNote}
              onChange={(e) => setAdminNote(e.target.value)}
              placeholder="أضف ملاحظة للطالب..."
              disabled={submitting}
              style={{
                padding: '9px 12px', border: '1.5px solid #E2E8F0', borderRadius: 10,
                fontSize: 13, fontFamily: 'Cairo', background: '#FAFAFA', color: '#1E293B',
                outline: 'none', resize: 'vertical',
              }}
            />
          </div>
        </div>
      </Modal>

      {/* Image Preview */}
      {previewUrl && (
        <div onClick={() => setPreviewUrl(null)} style={{
          position: 'fixed', inset: 0, background: 'rgba(0,0,0,0.7)', zIndex: 9999,
          display: 'flex', alignItems: 'center', justifyContent: 'center', cursor: 'zoom-out',
        }}>
          <img src={previewUrl} alt="إيصال الدفع"
            style={{ maxWidth: '90vw', maxHeight: '90vh', borderRadius: 12, boxShadow: '0 8px 32px rgba(0,0,0,0.4)' }}
            onClick={(e) => e.stopPropagation()} />
        </div>
      )}

      {/* Toasts */}
      <div style={{ position: 'fixed', bottom: 24, left: '50%', transform: 'translateX(-50%)', zIndex: 9998, display: 'flex', flexDirection: 'column', gap: 8, alignItems: 'center' }}>
        {toasts.map(t => (
          <div key={t.id} style={{
            padding: '12px 20px', borderRadius: 12, fontFamily: 'Cairo', fontSize: 14, fontWeight: 600,
            background: t.type === 'success' ? '#16A34A' : '#DC2626', color: '#fff',
            boxShadow: '0 4px 16px rgba(0,0,0,0.15)', display: 'flex', alignItems: 'center', gap: 8,
            animation: 'fadeIn 0.2s ease',
          }}>
            {t.type === 'success' ? <CheckCircle size={16} /> : <AlertCircle size={16} />}
            {t.msg}
          </div>
        ))}
      </div>
    </div>
  )
}
