import { useEffect, useState } from 'react'
import { Plus, Pencil, Trash2, Megaphone, ToggleLeft, ToggleRight } from 'lucide-react'
import { useAdminScope } from '../context/AdminScopeContext'
import { announcementsService } from '../services/announcementsService'
import type { Announcement, AnnouncementForm } from '../services/announcementsService'
import { buildFileUrl } from '../lib/fileUrl'
import { Button } from '../components/ui/Button'
import { Input } from '../components/ui/Input'
import { Modal } from '../components/ui/Modal'
import { ConfirmDialog } from '../components/ui/ConfirmDialog'
import { Loading } from '../components/ui/Loading'
import { ErrorState } from '../components/ui/ErrorState'
import { EmptyState } from '../components/ui/EmptyState'
import { PageHeader } from '../components/ui/PageHeader'
import { FileUploadField } from '../components/FileUploadField'
import type { CSSProperties } from 'react'

const EMPTY: AnnouncementForm = {
  title: '', message: '', image_url: '', link_url: '',
  is_active: true, starts_at: '', ends_at: '',
  learning_path_id: null, bac_branch_id: null,
}

const cardStyle: CSSProperties = { background: '#fff', borderRadius: 14, padding: '14px 18px', display: 'flex', alignItems: 'flex-start', gap: 14, border: '1px solid #E2E8F0', boxShadow: '0 1px 4px rgba(0,0,0,0.04)' }
const iBtnStyle: CSSProperties = { width: 34, height: 34, borderRadius: 8, border: 'none', background: 'transparent', cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }

export function AnnouncementsPage() {
  const { scope, queryParams } = useAdminScope()
  const [items, setItems] = useState<Announcement[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')
  const [modal, setModal] = useState(false)
  const [editing, setEditing] = useState<Announcement | null>(null)
  const [form, setForm] = useState<AnnouncementForm>(EMPTY)
  const [saving, setSaving] = useState(false)
  const [deleteId, setDeleteId] = useState<number | null>(null)
  const [deleting, setDeleting] = useState(false)

  async function load() {
    setLoading(true); setError('')
    try { setItems(await announcementsService.getAll(queryParams)) }
    catch (e) { setError((e as Error).message) }
    finally { setLoading(false) }
  }
  useEffect(() => { load() }, [queryParams])

  function openCreate() {
    setEditing(null)
    setForm({ ...EMPTY, learning_path_id: scope!.learningPathId, bac_branch_id: scope!.bacBranchId })
    setModal(true)
  }

  function openEdit(a: Announcement) {
    setEditing(a)
    setForm({
      title: a.title, message: a.message, image_url: a.image_url, link_url: a.link_url,
      is_active: a.is_active,
      starts_at: a.starts_at ? a.starts_at.slice(0, 16) : '',
      ends_at: a.ends_at ? a.ends_at.slice(0, 16) : '',
      learning_path_id: a.learning_path_id,
      bac_branch_id: a.bac_branch_id,
    })
    setModal(true)
  }

  async function save() {
    if (!form.title.trim()) return
    setSaving(true)
    try {
      const payload = { ...form, learning_path_id: scope!.learningPathId, bac_branch_id: scope!.bacBranchId }
      if (editing) await announcementsService.update(editing.id, payload)
      else await announcementsService.create(payload)
      setModal(false); load()
    } catch (e) { alert((e as Error).message) }
    finally { setSaving(false) }
  }

  async function toggle(a: Announcement) {
    try { await announcementsService.toggleActive(a.id); load() }
    catch (e) { alert((e as Error).message) }
  }

  async function confirmDelete() {
    if (!deleteId) return; setDeleting(true)
    try { await announcementsService.delete(deleteId); setDeleteId(null); load() }
    catch (e) { alert((e as Error).message) }
    finally { setDeleting(false) }
  }

  const f = <K extends keyof AnnouncementForm>(k: K, v: AnnouncementForm[K]) => setForm(p => ({ ...p, [k]: v }))

  function formatDate(d: string | null) {
    if (!d) return ''
    try { return new Date(d).toLocaleDateString('ar', { year: 'numeric', month: 'short', day: 'numeric' }) }
    catch { return d }
  }

  return (
    <div>
      <PageHeader title="الإعلانات" subtitle={scope?.label} action={<Button onClick={openCreate}><Plus size={15} />إضافة</Button>} />
      <div style={{ padding: '0 24px 24px' }}>
        {loading ? <Loading /> : error ? <ErrorState message={error} onRetry={load} /> : items.length === 0 ? (
          <EmptyState icon={Megaphone} title="لا توجد إعلانات لهذا القسم" action={<Button onClick={openCreate}><Plus size={15} />إضافة إعلان</Button>} />
        ) : (
          <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
            {items.map((a) => (
              <div key={a.id} style={{ ...cardStyle, opacity: a.is_active ? 1 : 0.6 }}>
                {/* Thumb */}
                {a.image_url ? (
                  <img src={buildFileUrl(a.image_url)} alt="" style={{ width: 52, height: 52, borderRadius: 10, objectFit: 'cover', flexShrink: 0 }} onError={(e) => { (e.target as HTMLImageElement).style.display = 'none' }} />
                ) : (
                  <div style={{ width: 52, height: 52, borderRadius: 10, background: '#EFF6FF', display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
                    <Megaphone size={22} color="#2563EB" />
                  </div>
                )}
                {/* Info */}
                <div style={{ flex: 1, minWidth: 0 }}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: 8, flexWrap: 'wrap' }}>
                    <p style={{ fontSize: 14, fontWeight: 700, color: '#1E293B', fontFamily: 'Cairo' }}>{a.title}</p>
                    <span style={{ fontSize: 11, padding: '2px 8px', borderRadius: 20, background: a.is_active ? '#F0FDF4' : '#F1F5F9', color: a.is_active ? '#16A34A' : '#94A3B8', fontFamily: 'Cairo', fontWeight: 600 }}>
                      {a.is_active ? 'مفعل' : 'معطل'}
                    </span>
                  </div>
                  {a.message && <p style={{ fontSize: 12, color: '#64748B', fontFamily: 'Cairo', marginTop: 3, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{a.message}</p>}
                  <p style={{ fontSize: 11, color: '#CBD5E1', fontFamily: 'Cairo', marginTop: 4 }}>{formatDate(a.created_at)}{a.ends_at ? ` — ينتهي ${formatDate(a.ends_at)}` : ''}</p>
                </div>
                {/* Actions */}
                <div style={{ display: 'flex', gap: 2, flexShrink: 0 }}>
                  <button onClick={() => toggle(a)} style={iBtnStyle} title={a.is_active ? 'تعطيل' : 'تفعيل'}
                    onMouseEnter={(e) => { (e.currentTarget as HTMLButtonElement).style.background = '#F1F5F9' }}
                    onMouseLeave={(e) => { (e.currentTarget as HTMLButtonElement).style.background = 'transparent' }}>
                    {a.is_active ? <ToggleRight size={18} color="#16A34A" /> : <ToggleLeft size={18} color="#94A3B8" />}
                  </button>
                  <button onClick={() => openEdit(a)} style={iBtnStyle}
                    onMouseEnter={(e) => { (e.currentTarget as HTMLButtonElement).style.background = '#EFF6FF' }}
                    onMouseLeave={(e) => { (e.currentTarget as HTMLButtonElement).style.background = 'transparent' }}>
                    <Pencil size={15} color="#2563EB" />
                  </button>
                  <button onClick={() => setDeleteId(a.id)} style={iBtnStyle}
                    onMouseEnter={(e) => { (e.currentTarget as HTMLButtonElement).style.background = '#FEF2F2' }}
                    onMouseLeave={(e) => { (e.currentTarget as HTMLButtonElement).style.background = 'transparent' }}>
                    <Trash2 size={15} color="#DC2626" />
                  </button>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>

      <Modal open={modal} onClose={() => setModal(false)} title={editing ? 'تعديل إعلان' : 'إضافة إعلان'}
        footer={<><Button variant="secondary" onClick={() => setModal(false)}>إلغاء</Button><Button onClick={save} loading={saving}>حفظ</Button></>}>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 14 }}>
          <Input label="العنوان *" value={form.title} onChange={(e) => f('title', e.target.value)} />
          <div style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
            <label style={{ fontSize: 13, fontWeight: 600, color: '#374151', fontFamily: 'Cairo' }}>الرسالة (اختياري)</label>
            <textarea rows={3} value={form.message} onChange={(e) => f('message', e.target.value)} style={{ padding: '9px 12px', border: '1.5px solid #E2E8F0', borderRadius: 10, fontSize: 13, fontFamily: 'Cairo', background: '#FAFAFA', color: '#1E293B', outline: 'none', resize: 'vertical' }} />
          </div>
          <Input label="رابط (اختياري)" value={form.link_url} onChange={(e) => f('link_url', e.target.value)} dir="ltr" placeholder="https://..." />
          <FileUploadField label="صورة الإعلان (اختياري)" type="image" value={form.image_url} onChange={(url) => f('image_url', url)} />
          <Input label="تاريخ البداية (اختياري)" type="datetime-local" value={form.starts_at} onChange={(e) => f('starts_at', e.target.value)} dir="ltr" />
          <Input label="تاريخ الانتهاء (اختياري)" type="datetime-local" value={form.ends_at} onChange={(e) => f('ends_at', e.target.value)} dir="ltr" />
          <label style={{ display: 'flex', alignItems: 'center', gap: 8, cursor: 'pointer' }}>
            <input type="checkbox" checked={form.is_active} onChange={(e) => f('is_active', e.target.checked)} style={{ width: 16, height: 16, accentColor: '#2563EB' }} />
            <span style={{ fontSize: 13, fontWeight: 600, color: '#374151', fontFamily: 'Cairo' }}>مفعل</span>
          </label>
          <div style={{ background: '#EFF6FF', border: '1px solid #BFDBFE', borderRadius: 10, padding: '10px 14px' }}>
            <p style={{ fontSize: 12, color: '#1D4ED8', fontFamily: 'Cairo' }}>سيظهر هذا الإعلان لطلاب <strong>{scope?.label}</strong> فقط.</p>
          </div>
        </div>
      </Modal>

      <ConfirmDialog open={!!deleteId} onClose={() => setDeleteId(null)} onConfirm={confirmDelete} loading={deleting} message="هل أنت متأكد من حذف هذا الإعلان؟" />
    </div>
  )
}
