import { useEffect, useState } from 'react'
import { Plus, Pencil, Trash2, BookMarked, Video, FileText } from 'lucide-react'
import { useAdminScope } from '../context/AdminScopeContext'
import { lessonsService } from '../services/lessonsService'
import { subjectsService } from '../services/subjectsService'
import { teachersService } from '../services/teachersService'
import type { Lesson, Subject, Teacher } from '../types'
import { buildFileUrl } from '../lib/fileUrl'
import { Button } from '../components/ui/Button'
import { Input } from '../components/ui/Input'
import { Select } from '../components/ui/Select'
import { Modal } from '../components/ui/Modal'
import { ConfirmDialog } from '../components/ui/ConfirmDialog'
import { Loading } from '../components/ui/Loading'
import { ErrorState } from '../components/ui/ErrorState'
import { EmptyState } from '../components/ui/EmptyState'
import { PageHeader } from '../components/ui/PageHeader'
import { FileUploadField } from '../components/FileUploadField'
import type { CSSProperties } from 'react'

interface FormState {
  title: string; description: string; subject_id: number | ''; teacher_id: number | ''
  video_url: string; summary_url: string; cover_image_url: string
  duration_minutes: number; is_free: boolean
}
const EMPTY: FormState = { title: '', description: '', subject_id: '', teacher_id: '', video_url: '', summary_url: '', cover_image_url: '', duration_minutes: 0, is_free: true }

const cardStyle: CSSProperties = { background: '#fff', borderRadius: 14, padding: '12px 16px', display: 'flex', alignItems: 'center', gap: 14, border: '1px solid #E2E8F0', boxShadow: '0 1px 4px rgba(0,0,0,0.04)' }
const iBtnStyle: CSSProperties = { width: 34, height: 34, borderRadius: 8, border: 'none', background: 'transparent', cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center', transition: 'background 0.15s', flexShrink: 0 }

export function LessonsPage() {
  const { scope, queryParams } = useAdminScope()
  const [items, setItems] = useState<Lesson[]>([])
  const [subjects, setSubjects] = useState<Subject[]>([])
  const [teachers, setTeachers] = useState<Teacher[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')
  const [modal, setModal] = useState(false)
  const [editing, setEditing] = useState<Lesson | null>(null)
  const [form, setForm] = useState<FormState>(EMPTY)
  const [saving, setSaving] = useState(false)
  const [deleteId, setDeleteId] = useState<number | null>(null)
  const [deleting, setDeleting] = useState(false)
  const [loadingTeachers, setLoadingTeachers] = useState(false)

  async function load() {
    setLoading(true); setError('')
    try {
      const [ls, ss] = await Promise.all([lessonsService.getAll(queryParams), subjectsService.getAll(queryParams)])
      setItems(ls); setSubjects(ss)
    } catch (e) { setError((e as Error).message) }
    finally { setLoading(false) }
  }
  useEffect(() => { load() }, [queryParams])

  async function loadTeachers(subjectId: number) {
    setLoadingTeachers(true)
    try { setTeachers(await teachersService.getBySubject(subjectId)) }
    catch { setTeachers([]) }
    finally { setLoadingTeachers(false) }
  }

  function openCreate() { setEditing(null); setForm(EMPTY); setTeachers([]); setModal(true) }
  function openEdit(l: Lesson) {
    setEditing(l)
    setForm({ title: l.title, description: l.description, subject_id: l.subject_id, teacher_id: l.teacher_id, video_url: l.video_url, summary_url: l.summary_url, cover_image_url: l.cover_image_url, duration_minutes: l.duration_minutes, is_free: l.is_free })
    if (l.subject_id) loadTeachers(l.subject_id)
    setModal(true)
  }

  async function save() {
    if (!form.title.trim() || !form.subject_id) return
    setSaving(true)
    try {
      const payload = { ...form, subject_id: Number(form.subject_id), teacher_id: form.teacher_id ? Number(form.teacher_id) : 0 }
      if (editing) await lessonsService.update(editing.id, payload)
      else await lessonsService.create(payload)
      setModal(false); load()
    } catch (e) { alert((e as Error).message) }
    finally { setSaving(false) }
  }

  async function confirmDelete() {
    if (!deleteId) return; setDeleting(true)
    try { await lessonsService.delete(deleteId); setDeleteId(null); load() }
    catch (e) { alert((e as Error).message) }
    finally { setDeleting(false) }
  }

  function f<K extends keyof FormState>(key: K, val: FormState[K]) { setForm(p => ({ ...p, [key]: val })) }

  return (
    <div>
      <PageHeader title="الدروس" subtitle={scope?.label} action={<Button onClick={openCreate}><Plus size={15} />إضافة</Button>} />
      <div style={{ padding: '0 24px 24px' }}>
        {loading ? <Loading /> : error ? <ErrorState message={error} onRetry={load} /> : items.length === 0 ? (
          <EmptyState icon={BookMarked} title={`لا توجد دروس في ${scope?.label}`} action={<Button onClick={openCreate}><Plus size={15} />إضافة درس</Button>} />
        ) : (
          <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
            {items.map((l) => (
              <div key={l.id} style={cardStyle}>
                <div style={{ width: 44, height: 44, borderRadius: 12, overflow: 'hidden', flexShrink: 0, background: '#EFF6FF', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                  {l.cover_image_url ? <img src={buildFileUrl(l.cover_image_url)} alt="" style={{ width: '100%', height: '100%', objectFit: 'cover' }} onError={(e) => { (e.target as HTMLImageElement).style.display = 'none' }} /> : <BookMarked size={18} color="#2563EB" />}
                </div>
                <div style={{ flex: 1, minWidth: 0 }}>
                  <p style={{ fontSize: 14, fontWeight: 700, color: '#1E293B', fontFamily: 'Cairo', overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{l.title}</p>
                  <p style={{ fontSize: 12, color: '#94A3B8', fontFamily: 'Cairo' }}>{l.subject_name ?? `مادة #${l.subject_id}`}{l.teacher_name ? ` — ${l.teacher_name}` : ''}</p>
                </div>
                <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
                  {l.video_url && <Video size={14} color="#2563EB" />}
                  {l.summary_url && <FileText size={14} color="#DC2626" />}
                  <span style={{ fontSize: 11, padding: '2px 8px', borderRadius: 20, background: l.is_free ? '#F0FDF4' : '#F1F5F9', color: l.is_free ? '#16A34A' : '#64748B', fontFamily: 'Cairo', fontWeight: 600 }}>{l.is_free ? 'مجاني' : 'مدفوع'}</span>
                </div>
                <button onClick={() => openEdit(l)} style={iBtnStyle} onMouseEnter={(e) => { (e.currentTarget as HTMLButtonElement).style.background = '#EFF6FF' }} onMouseLeave={(e) => { (e.currentTarget as HTMLButtonElement).style.background = 'transparent' }}><Pencil size={15} color="#2563EB" /></button>
                <button onClick={() => setDeleteId(l.id)} style={iBtnStyle} onMouseEnter={(e) => { (e.currentTarget as HTMLButtonElement).style.background = '#FEF2F2' }} onMouseLeave={(e) => { (e.currentTarget as HTMLButtonElement).style.background = 'transparent' }}><Trash2 size={15} color="#DC2626" /></button>
              </div>
            ))}
          </div>
        )}
      </div>

      <Modal open={modal} onClose={() => setModal(false)} title={editing ? 'تعديل درس' : 'إضافة درس'}
        footer={<><Button variant="secondary" onClick={() => setModal(false)}>إلغاء</Button><Button onClick={save} loading={saving}>حفظ</Button></>}>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 14 }}>
          <Input label="العنوان *" value={form.title} onChange={(e) => f('title', e.target.value)} />
          <Select label="المادة *" value={form.subject_id} options={subjects.map(s => ({ value: s.id, label: s.name_ar }))} placeholder="اختر المادة" onChange={(e) => { const id = Number(e.target.value); f('subject_id', id); if (id) loadTeachers(id) }} />
          {loadingTeachers ? <p style={{ fontSize: 12, color: '#94A3B8', fontFamily: 'Cairo' }}>جاري تحميل الأساتذة...</p> : teachers.length > 0 && <Select label="الأستاذ" value={form.teacher_id} options={teachers.map(t => ({ value: t.id, label: t.full_name ?? '' }))} placeholder="اختر الأستاذ (اختياري)" onChange={(e) => f('teacher_id', e.target.value ? Number(e.target.value) : '')} />}
          <div style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
            <label style={{ fontSize: 13, fontWeight: 600, color: '#374151', fontFamily: 'Cairo' }}>الوصف</label>
            <textarea rows={3} value={form.description} onChange={(e) => f('description', e.target.value)} style={{ padding: '9px 12px', border: '1.5px solid #E2E8F0', borderRadius: 10, fontSize: 13, fontFamily: 'Cairo', background: '#FAFAFA', color: '#1E293B', outline: 'none', resize: 'vertical' }} />
          </div>
          <Input label="مدة الدرس (دقائق)" type="number" value={form.duration_minutes} onChange={(e) => f('duration_minutes', Number(e.target.value))} />
          <label style={{ display: 'flex', alignItems: 'center', gap: 8, cursor: 'pointer' }}>
            <input type="checkbox" checked={form.is_free} onChange={(e) => f('is_free', e.target.checked)} style={{ width: 16, height: 16, accentColor: '#2563EB' }} />
            <span style={{ fontSize: 13, fontWeight: 600, color: '#374151', fontFamily: 'Cairo' }}>درس مجاني</span>
          </label>
          <FileUploadField label="فيديو الدرس" type="video" value={form.video_url} onChange={(url) => f('video_url', url)} />
          <Input label="أو رابط فيديو خارجي" value={form.video_url} onChange={(e) => f('video_url', e.target.value)} dir="ltr" placeholder="https://..." />
          <FileUploadField label="ملخص PDF" type="pdf" value={form.summary_url} onChange={(url) => f('summary_url', url)} />
          <FileUploadField label="صورة الغلاف" type="image" value={form.cover_image_url} onChange={(url) => f('cover_image_url', url)} />
        </div>
      </Modal>
      <ConfirmDialog open={!!deleteId} onClose={() => setDeleteId(null)} onConfirm={confirmDelete} loading={deleting} />
    </div>
  )
}
