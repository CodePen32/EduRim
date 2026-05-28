import { useEffect, useState } from 'react'
import { Plus, Pencil, Trash2, FileText } from 'lucide-react'
import { useAdminScope } from '../context/AdminScopeContext'
import { pastExamsService } from '../services/pastExamsService'
import { subjectsService } from '../services/subjectsService'
import type { PastExam, Subject } from '../types'
import { buildFileUrl } from '../lib/fileUrl'
import { Button } from '../components/ui/Button'
import { Input } from '../components/ui/Input'
import { Select } from '../components/ui/Select'
import { Modal } from '../components/ui/Modal'
import { ConfirmDialog } from '../components/ui/ConfirmDialog'
import { Loading } from '../components/ui/Loading'
import { ErrorState } from '../components/ui/ErrorState'
import { EmptyState } from '../components/ui/EmptyState'
import { FileUploadField } from '../components/FileUploadField'

interface F { title:string; subject_id:number|''; year:number; exam_file_url:string; solution_file_url:string; cover_image_url:string }
const EMPTY: F = { title:'', subject_id:'', year:new Date().getFullYear(), exam_file_url:'', solution_file_url:'', cover_image_url:'' }

export function PastExamsPage() {
  const { scope, queryParams } = useAdminScope()
  const [items, setItems] = useState<PastExam[]>([])
  const [subjects, setSubjects] = useState<Subject[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')
  const [modal, setModal] = useState(false)
  const [editing, setEditing] = useState<PastExam|null>(null)
  const [form, setForm] = useState<F>(EMPTY)
  const [saving, setSaving] = useState(false)
  const [deleteId, setDeleteId] = useState<number|null>(null)
  const [deleting, setDeleting] = useState(false)

  async function load() {
    setLoading(true); setError('')
    try { const [p, ss] = await Promise.all([pastExamsService.getAll(queryParams), subjectsService.getAll(queryParams)]); setItems(p); setSubjects(ss) }
    catch (e) { setError((e as Error).message) }
    finally { setLoading(false) }
  }
  useEffect(() => { load() }, [queryParams])

  function openCreate() { setEditing(null); setForm(EMPTY); setModal(true) }
  function openEdit(p: PastExam) { setEditing(p); setForm({ title:p.title, subject_id:p.subject_id, year:p.year, exam_file_url:p.exam_file_url, solution_file_url:p.solution_file_url, cover_image_url:p.cover_image_url }); setModal(true) }

  async function save() {
    if (!form.title.trim() || !form.subject_id) return
    setSaving(true)
    try {
      const payload = { ...form, subject_id: Number(form.subject_id), learning_path_id: scope!.learningPathId, bac_branch_id: scope!.bacBranchId }
      if (editing) await pastExamsService.update(editing.id, payload); else await pastExamsService.create(payload)
      setModal(false); load()
    } catch (e) { alert((e as Error).message) } finally { setSaving(false) }
  }

  async function confirmDelete() {
    if (!deleteId) return; setDeleting(true)
    try { await pastExamsService.delete(deleteId); setDeleteId(null); load() }
    catch (e) { alert((e as Error).message) } finally { setDeleting(false) }
  }

  const f = <K extends keyof F>(k: K, v: F[K]) => setForm(p => ({ ...p, [k]: v }))

  return (
    <div>
      <div className="flex items-center justify-between mb-6">
        <div><h1 className="text-2xl font-bold">مواضيع الامتحانات</h1><p className="text-gray-500 text-sm">{scope?.label}</p></div>
        <Button onClick={openCreate}><Plus size={16} />إضافة</Button>
      </div>
      {loading ? <Loading /> : error ? <ErrorState message={error} onRetry={load} /> : items.length === 0 ? (
        <EmptyState icon={FileText} title="لا توجد مواضيع" action={<Button onClick={openCreate}><Plus size={16} />إضافة موضوع</Button>} />
      ) : (
        <div className="flex flex-col gap-3">
          {items.map((p) => (
            <div key={p.id} className="bg-white rounded-xl p-4 flex items-center gap-4 shadow-sm border border-gray-100">
              <div className="w-12 h-12 rounded-lg bg-red-50 flex-shrink-0 overflow-hidden">
                {p.cover_image_url ? <img src={buildFileUrl(p.cover_image_url)} alt="" className="w-full h-full object-cover" onError={(e)=>{(e.target as HTMLImageElement).style.display='none'}} /> : <FileText size={20} className="m-auto mt-3 text-red-400" />}
              </div>
              <div className="flex-1 min-w-0">
                <p className="font-semibold truncate">{p.title}</p>
                <p className="text-xs text-gray-400">{p.subject_name ?? `#${p.subject_id}`} {p.year > 0 ? `— ${p.year}` : ''}</p>
              </div>
              <button onClick={() => openEdit(p)} className="text-blue-500 hover:text-blue-700 p-1"><Pencil size={16} /></button>
              <button onClick={() => setDeleteId(p.id)} className="text-red-400 hover:text-red-600 p-1"><Trash2 size={16} /></button>
            </div>
          ))}
        </div>
      )}
      <Modal open={modal} onClose={() => setModal(false)} title={editing ? 'تعديل موضوع' : 'إضافة موضوع'}
        footer={<><Button variant="secondary" onClick={() => setModal(false)}>إلغاء</Button><Button onClick={save} loading={saving}>حفظ</Button></>}>
        <div className="flex flex-col gap-4">
          <Input label="العنوان *" value={form.title} onChange={(e) => f('title', e.target.value)} />
          <Select label="المادة *" value={form.subject_id} options={subjects.map(s=>({value:s.id,label:s.name_ar}))} placeholder="اختر المادة" onChange={(e) => f('subject_id', e.target.value ? Number(e.target.value) : '')} />
          <Input label="السنة" type="number" value={form.year} onChange={(e) => f('year', Number(e.target.value))} />
          <FileUploadField label="ملف الموضوع PDF" type="pdf" value={form.exam_file_url} onChange={(url) => f('exam_file_url', url)} />
          <FileUploadField label="ملف الحل PDF" type="pdf" value={form.solution_file_url} onChange={(url) => f('solution_file_url', url)} />
          <FileUploadField label="صورة الغلاف" type="image" value={form.cover_image_url} onChange={(url) => f('cover_image_url', url)} />
        </div>
      </Modal>
      <ConfirmDialog open={!!deleteId} onClose={() => setDeleteId(null)} onConfirm={confirmDelete} loading={deleting} />
    </div>
  )
}



