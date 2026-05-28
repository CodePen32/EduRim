import { useEffect, useState } from 'react'
import { Plus, Pencil, Trash2, GraduationCap } from 'lucide-react'
import { useAdminScope } from '../context/AdminScopeContext'
import { teachersService } from '../services/teachersService'
import { subjectsService } from '../services/subjectsService'
import type { Teacher, Subject } from '../types'
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

interface F { full_name: string; bio: string; subject_id: number | ''; avatar_url: string }
const EMPTY: F = { full_name: '', bio: '', subject_id: '', avatar_url: '' }

export function TeachersPage() {
  const { scope, queryParams } = useAdminScope()
  const [items, setItems] = useState<Teacher[]>([])
  const [subjects, setSubjects] = useState<Subject[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')
  const [modal, setModal] = useState(false)
  const [editing, setEditing] = useState<Teacher | null>(null)
  const [form, setForm] = useState<F>(EMPTY)
  const [saving, setSaving] = useState(false)
  const [deleteId, setDeleteId] = useState<number | null>(null)
  const [deleting, setDeleting] = useState(false)

  async function load() {
    setLoading(true); setError('')
    try {
      const [ts, ss] = await Promise.all([teachersService.getAll(queryParams), subjectsService.getAll(queryParams)])
      setItems(ts); setSubjects(ss)
    } catch (e) { setError((e as Error).message) }
    finally { setLoading(false) }
  }
  useEffect(() => { load() }, [queryParams])

  function openCreate() { setEditing(null); setForm(EMPTY); setModal(true) }
  function openEdit(t: Teacher) {
    setEditing(t)
    setForm({ full_name: t.full_name, bio: t.bio, subject_id: t.subject_id, avatar_url: t.avatar_url })
    setModal(true)
  }

  async function save() {
    if (!form.full_name.trim()) return
    setSaving(true)
    try {
      const payload = {
        full_name: form.full_name,
        bio: form.bio,
        avatar_url: form.avatar_url,
        subject_id: form.subject_id ? Number(form.subject_id) : 0,
        learning_path_id: scope!.learningPathId,
        bac_branch_id: scope!.bacBranchId,
      }
      if (editing) await teachersService.update(editing.id, payload)
      else await teachersService.create(payload)
      setModal(false); load()
    } catch (e) { alert((e as Error).message) }
    finally { setSaving(false) }
  }

  async function confirmDelete() {
    if (!deleteId) return; setDeleting(true)
    try { await teachersService.delete(deleteId); setDeleteId(null); load() }
    catch (e) { alert((e as Error).message) }
    finally { setDeleting(false) }
  }

  const f = <K extends keyof F>(k: K, v: F[K]) => setForm(p => ({ ...p, [k]: v }))

  return (
    <div>
      <div className="flex items-center justify-between mb-6">
        <div>
          <h1 className="text-2xl font-bold">الأساتذة</h1>
          <p className="text-gray-500 text-sm">{scope?.label}</p>
        </div>
        <Button onClick={openCreate}><Plus size={16} />إضافة</Button>
      </div>

      {loading ? <Loading /> : error ? <ErrorState message={error} onRetry={load} /> : items.length === 0 ? (
        <EmptyState icon={GraduationCap} title="لا يوجد أساتذة" action={<Button onClick={openCreate}><Plus size={16} />إضافة أستاذ</Button>} />
      ) : (
        <div className="grid grid-cols-1 gap-3">
          {items.map((t) => (
            <div key={t.id} className="bg-white rounded-xl p-4 flex items-center gap-4 shadow-sm border border-gray-100">
              <div className="w-12 h-12 rounded-full bg-teal-50 flex-shrink-0 overflow-hidden flex items-center justify-center">
                {t.avatar_url
                  ? <img src={buildFileUrl(t.avatar_url)} alt="" className="w-full h-full object-cover" onError={(e) => { (e.target as HTMLImageElement).style.display = 'none' }} />
                  : <GraduationCap size={22} className="text-teal-500" />
                }
              </div>
              <div className="flex-1 min-w-0">
                <p className="font-semibold truncate">{t.full_name}</p>
                {t.bio && <p className="text-xs text-gray-500 truncate">{t.bio}</p>}
                <p className="text-xs text-gray-400">{t.subject_name ?? (t.subject_id ? `مادة #${t.subject_id}` : '')}</p>
              </div>
              <button onClick={() => openEdit(t)} className="text-blue-500 hover:text-blue-700 p-1 flex-shrink-0"><Pencil size={16} /></button>
              <button onClick={() => setDeleteId(t.id)} className="text-red-400 hover:text-red-600 p-1 flex-shrink-0"><Trash2 size={16} /></button>
            </div>
          ))}
        </div>
      )}

      <Modal open={modal} onClose={() => setModal(false)} title={editing ? 'تعديل أستاذ' : 'إضافة أستاذ'}
        footer={<><Button variant="secondary" onClick={() => setModal(false)}>إلغاء</Button><Button onClick={save} loading={saving}>حفظ</Button></>}>
        <div className="flex flex-col gap-4">
          <Input label="الاسم الكامل *" value={form.full_name} onChange={(e) => f('full_name', e.target.value)} />
          <Select label="المادة" value={form.subject_id} options={subjects.map(s => ({ value: s.id, label: s.name_ar }))} placeholder="اختر المادة" onChange={(e) => f('subject_id', e.target.value ? Number(e.target.value) : '')} />
          <textarea className="px-3 py-2 border border-gray-300 rounded-lg text-sm" rows={2} placeholder="نبذة عن الأستاذ" value={form.bio} onChange={(e) => f('bio', e.target.value)} />
          <FileUploadField label="صورة الأستاذ" type="image" value={form.avatar_url} onChange={(url) => f('avatar_url', url)} />
        </div>
      </Modal>
      <ConfirmDialog open={!!deleteId} onClose={() => setDeleteId(null)} onConfirm={confirmDelete} loading={deleting} />
    </div>
  )
}
