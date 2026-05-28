import { useEffect, useState } from 'react'
import { Plus, Pencil, Trash2, BookOpen } from 'lucide-react'
import { useAdminScope } from '../context/AdminScopeContext'
import { subjectsService } from '../services/subjectsService'
import type { Subject } from '../types'
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

const COLORS = ['#2563EB','#16A34A','#DC2626','#7C3AED','#0284C7','#D97706','#BE185D','#0F766E']

interface F { name_ar: string; name_fr: string; color: string; cover_image_url: string }
const EMPTY: F = { name_ar: '', name_fr: '', color: '#2563EB', cover_image_url: '' }

export function SubjectsPage() {
  const { scope, queryParams } = useAdminScope()
  const [items, setItems] = useState<Subject[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')
  const [modal, setModal] = useState(false)
  const [editing, setEditing] = useState<Subject | null>(null)
  const [form, setForm] = useState<F>(EMPTY)
  const [saving, setSaving] = useState(false)
  const [deleteId, setDeleteId] = useState<number | null>(null)
  const [deleting, setDeleting] = useState(false)

  async function load() {
    setLoading(true); setError('')
    try { setItems(await subjectsService.getAll(queryParams)) }
    catch (e) { setError((e as Error).message) }
    finally { setLoading(false) }
  }
  useEffect(() => { load() }, [queryParams])

  function openCreate() { setEditing(null); setForm(EMPTY); setModal(true) }
  function openEdit(s: Subject) {
    setEditing(s)
    setForm({ name_ar: s.name_ar, name_fr: s.name_fr, color: s.color || '#2563EB', cover_image_url: s.cover_image_url })
    setModal(true)
  }

  async function save() {
    if (!form.name_ar.trim()) return
    setSaving(true)
    try {
      const payload = { ...form, learning_path_id: scope!.learningPathId, bac_branch_id: scope!.bacBranchId }
      if (editing) await subjectsService.update(editing.id, payload)
      else await subjectsService.create(payload)
      setModal(false); load()
    } catch (e) { alert((e as Error).message) }
    finally { setSaving(false) }
  }

  async function confirmDelete() {
    if (!deleteId) return; setDeleting(true)
    try { await subjectsService.delete(deleteId); setDeleteId(null); load() }
    catch (e) { alert((e as Error).message) }
    finally { setDeleting(false) }
  }

  return (
    <div>
      <PageHeader title="المواد" subtitle={scope?.label} action={<Button onClick={openCreate}><Plus size={15} />إضافة</Button>} />

      <div style={{ padding: '0 24px 24px' }}>
        {loading ? <Loading /> : error ? <ErrorState message={error} onRetry={load} /> : items.length === 0 ? (
          <EmptyState icon={BookOpen} title={`لا توجد مواد في ${scope?.label}`} action={<Button onClick={openCreate}><Plus size={15} />إضافة مادة</Button>} />
        ) : (
          <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
            {items.map((s) => (
              <div key={s.id} style={{ background: '#fff', borderRadius: 14, padding: '12px 16px', display: 'flex', alignItems: 'center', gap: 14, border: '1px solid #E2E8F0', boxShadow: '0 1px 4px rgba(0,0,0,0.04)' }}>
                {/* Thumb */}
                <div style={{ width: 44, height: 44, borderRadius: 12, overflow: 'hidden', flexShrink: 0, background: (s.color || '#2563EB') + '18', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                  {s.cover_image_url
                    ? <img src={buildFileUrl(s.cover_image_url)} alt="" style={{ width: '100%', height: '100%', objectFit: 'cover' }} onError={(e) => { (e.target as HTMLImageElement).style.display = 'none' }} />
                    : <BookOpen size={18} color={s.color || '#2563EB'} />}
                </div>
                {/* Info */}
                <div style={{ flex: 1, minWidth: 0 }}>
                  <p style={{ fontSize: 14, fontWeight: 700, color: '#1E293B', fontFamily: 'Cairo' }}>{s.name_ar}</p>
                  <p style={{ fontSize: 12, color: '#94A3B8', fontFamily: 'Cairo' }}>{s.name_fr}</p>
                </div>
                {/* Color dot */}
                <div style={{ width: 14, height: 14, borderRadius: '50%', background: s.color || '#2563EB', flexShrink: 0, border: '2px solid #fff', boxShadow: '0 0 0 1px rgba(0,0,0,0.1)' }} />
                {/* Actions */}
                <button onClick={() => openEdit(s)} style={btnStyle('#2563EB')} onMouseEnter={(e) => { (e.currentTarget as HTMLButtonElement).style.background = '#EFF6FF' }} onMouseLeave={(e) => { (e.currentTarget as HTMLButtonElement).style.background = 'transparent' }}><Pencil size={15} color="#2563EB" /></button>
                <button onClick={() => setDeleteId(s.id)} style={btnStyle('#DC2626')} onMouseEnter={(e) => { (e.currentTarget as HTMLButtonElement).style.background = '#FEF2F2' }} onMouseLeave={(e) => { (e.currentTarget as HTMLButtonElement).style.background = 'transparent' }}><Trash2 size={15} color="#DC2626" /></button>
              </div>
            ))}
          </div>
        )}
      </div>

      <Modal open={modal} onClose={() => setModal(false)} title={editing ? 'تعديل مادة' : 'إضافة مادة'}
        footer={<><Button variant="secondary" onClick={() => setModal(false)}>إلغاء</Button><Button onClick={save} loading={saving}>حفظ</Button></>}>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 16 }}>
          <Input label="الاسم بالعربية *" value={form.name_ar} onChange={(e) => setForm(f => ({ ...f, name_ar: e.target.value }))} />
          <Input label="الاسم بالفرنسية" value={form.name_fr} onChange={(e) => setForm(f => ({ ...f, name_fr: e.target.value }))} />
          <div>
            <label style={{ fontSize: 13, fontWeight: 600, color: '#374151', fontFamily: 'Cairo', display: 'block', marginBottom: 8 }}>اللون</label>
            <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap' }}>
              {COLORS.map((c) => (
                <button key={c} type="button" onClick={() => setForm(f => ({ ...f, color: c }))} style={{ width: 30, height: 30, borderRadius: '50%', background: c, border: `3px solid ${form.color === c ? '#1E293B' : 'transparent'}`, cursor: 'pointer', transition: 'transform 0.1s' }} onMouseEnter={(e) => { (e.currentTarget as HTMLButtonElement).style.transform = 'scale(1.15)' }} onMouseLeave={(e) => { (e.currentTarget as HTMLButtonElement).style.transform = 'scale(1)' }} />
              ))}
            </div>
          </div>
          <FileUploadField label="صورة الغلاف" type="image" value={form.cover_image_url} onChange={(url) => setForm(f => ({ ...f, cover_image_url: url }))} />
        </div>
      </Modal>

      <ConfirmDialog open={!!deleteId} onClose={() => setDeleteId(null)} onConfirm={confirmDelete} loading={deleting} />
    </div>
  )
}

function btnStyle(_color: string) {
  return { width: 34, height: 34, borderRadius: 8, border: 'none', background: 'transparent', cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center', transition: 'background 0.15s', flexShrink: 0 }
}
