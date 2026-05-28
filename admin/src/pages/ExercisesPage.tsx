import { useEffect, useState } from 'react'
import { Plus, Pencil, Trash2, ClipboardList } from 'lucide-react'
import { useAdminScope } from '../context/AdminScopeContext'
import { exercisesService } from '../services/exercisesService'
import { subjectsService } from '../services/subjectsService'
import type { Exercise, Subject } from '../types'
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

interface F { title: string; subject_id: number | ''; year: number; difficulty: string; exercise_file_url: string; solution_file_url: string; video_solution_url: string; cover_image_url: string }
const EMPTY: F = { title: '', subject_id: '', year: new Date().getFullYear(), difficulty: 'متوسط', exercise_file_url: '', solution_file_url: '', video_solution_url: '', cover_image_url: '' }
const cardStyle: CSSProperties = { background: '#fff', borderRadius: 14, padding: '12px 16px', display: 'flex', alignItems: 'center', gap: 14, border: '1px solid #E2E8F0', boxShadow: '0 1px 4px rgba(0,0,0,0.04)' }
const iBtnStyle: CSSProperties = { width: 34, height: 34, borderRadius: 8, border: 'none', background: 'transparent', cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }

export function ExercisesPage() {
  const { scope, queryParams } = useAdminScope()
  const [items, setItems] = useState<Exercise[]>([])
  const [subjects, setSubjects] = useState<Subject[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')
  const [modal, setModal] = useState(false)
  const [editing, setEditing] = useState<Exercise | null>(null)
  const [form, setForm] = useState<F>(EMPTY)
  const [saving, setSaving] = useState(false)
  const [deleteId, setDeleteId] = useState<number | null>(null)
  const [deleting, setDeleting] = useState(false)

  async function load() {
    setLoading(true); setError('')
    try { const [ex, ss] = await Promise.all([exercisesService.getAll(queryParams), subjectsService.getAll(queryParams)]); setItems(ex); setSubjects(ss) }
    catch (e) { setError((e as Error).message) }
    finally { setLoading(false) }
  }
  useEffect(() => { load() }, [queryParams])

  function openCreate() { setEditing(null); setForm(EMPTY); setModal(true) }
  function openEdit(ex: Exercise) { setEditing(ex); setForm({ title: ex.title, subject_id: ex.subject_id, year: ex.year, difficulty: ex.difficulty, exercise_file_url: ex.exercise_file_url, solution_file_url: ex.solution_file_url, video_solution_url: ex.video_solution_url, cover_image_url: ex.cover_image_url }); setModal(true) }

  async function save() {
    if (!form.title.trim() || !form.subject_id) return
    setSaving(true)
    try {
      const p = { ...form, subject_id: Number(form.subject_id) }
      if (editing) await exercisesService.update(editing.id, p); else await exercisesService.create(p)
      setModal(false); load()
    } catch (e) { alert((e as Error).message) } finally { setSaving(false) }
  }

  async function confirmDelete() {
    if (!deleteId) return; setDeleting(true)
    try { await exercisesService.delete(deleteId); setDeleteId(null); load() }
    catch (e) { alert((e as Error).message) } finally { setDeleting(false) }
  }

  const f = <K extends keyof F>(k: K, v: F[K]) => setForm(p => ({ ...p, [k]: v }))

  return (
    <div>
      <PageHeader title="التمارين" subtitle={scope?.label} action={<Button onClick={openCreate}><Plus size={15} />إضافة</Button>} />
      <div style={{ padding: '0 24px 24px' }}>
        {loading ? <Loading /> : error ? <ErrorState message={error} onRetry={load} /> : items.length === 0 ? (
          <EmptyState icon={ClipboardList} title="لا توجد تمارين" action={<Button onClick={openCreate}><Plus size={15} />إضافة تمرين</Button>} />
        ) : (
          <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
            {items.map((ex) => (
              <div key={ex.id} style={cardStyle}>
                <div style={{ width: 44, height: 44, borderRadius: 12, overflow: 'hidden', flexShrink: 0, background: '#F5F3FF', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                  {ex.cover_image_url ? <img src={buildFileUrl(ex.cover_image_url)} alt="" style={{ width: '100%', height: '100%', objectFit: 'cover' }} onError={(e) => { (e.target as HTMLImageElement).style.display = 'none' }} /> : <ClipboardList size={18} color="#7C3AED" />}
                </div>
                <div style={{ flex: 1, minWidth: 0 }}>
                  <p style={{ fontSize: 14, fontWeight: 700, color: '#1E293B', fontFamily: 'Cairo', overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{ex.title}</p>
                  <p style={{ fontSize: 12, color: '#94A3B8', fontFamily: 'Cairo' }}>{ex.subject_name ?? `#${ex.subject_id}`} — {ex.difficulty}{ex.year > 0 ? ` — ${ex.year}` : ''}</p>
                </div>
                <button onClick={() => openEdit(ex)} style={iBtnStyle} onMouseEnter={(e) => { (e.currentTarget as HTMLButtonElement).style.background = '#EFF6FF' }} onMouseLeave={(e) => { (e.currentTarget as HTMLButtonElement).style.background = 'transparent' }}><Pencil size={15} color="#2563EB" /></button>
                <button onClick={() => setDeleteId(ex.id)} style={iBtnStyle} onMouseEnter={(e) => { (e.currentTarget as HTMLButtonElement).style.background = '#FEF2F2' }} onMouseLeave={(e) => { (e.currentTarget as HTMLButtonElement).style.background = 'transparent' }}><Trash2 size={15} color="#DC2626" /></button>
              </div>
            ))}
          </div>
        )}
      </div>

      <Modal open={modal} onClose={() => setModal(false)} title={editing ? 'تعديل تمرين' : 'إضافة تمرين'}
        footer={<><Button variant="secondary" onClick={() => setModal(false)}>إلغاء</Button><Button onClick={save} loading={saving}>حفظ</Button></>}>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 14 }}>
          <Input label="العنوان *" value={form.title} onChange={(e) => f('title', e.target.value)} />
          <Select label="المادة *" value={form.subject_id} options={subjects.map(s => ({ value: s.id, label: s.name_ar }))} placeholder="اختر المادة" onChange={(e) => f('subject_id', e.target.value ? Number(e.target.value) : '')} />
          <Input label="السنة" type="number" value={form.year} onChange={(e) => f('year', Number(e.target.value))} />
          <Select label="الصعوبة" value={form.difficulty} options={['سهل', 'متوسط', 'صعب'].map(d => ({ value: d, label: d }))} onChange={(e) => f('difficulty', e.target.value)} />
          <FileUploadField label="ملف التمرين PDF" type="pdf" value={form.exercise_file_url} onChange={(url) => f('exercise_file_url', url)} />
          <FileUploadField label="ملف الحل PDF" type="pdf" value={form.solution_file_url} onChange={(url) => f('solution_file_url', url)} />
          <FileUploadField label="فيديو الحل" type="video" value={form.video_solution_url} onChange={(url) => f('video_solution_url', url)} />
          <Input label="أو رابط فيديو خارجي" value={form.video_solution_url} onChange={(e) => f('video_solution_url', e.target.value)} dir="ltr" placeholder="https://..." />
          <FileUploadField label="صورة الغلاف" type="image" value={form.cover_image_url} onChange={(url) => f('cover_image_url', url)} />
        </div>
      </Modal>
      <ConfirmDialog open={!!deleteId} onClose={() => setDeleteId(null)} onConfirm={confirmDelete} loading={deleting} />
    </div>
  )
}
