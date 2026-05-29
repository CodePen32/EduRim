import { useEffect, useState } from 'react'
import { Plus, Pencil, Trash2, CreditCard } from 'lucide-react'
import { subscriptionService } from '../services/subscriptionService'
import type { SubscriptionPlan } from '../types'
import { Button } from '../components/ui/Button'
import { Input } from '../components/ui/Input'
import { Select } from '../components/ui/Select'
import { Modal } from '../components/ui/Modal'
import { ConfirmDialog } from '../components/ui/ConfirmDialog'
import { Loading } from '../components/ui/Loading'
import { ErrorState } from '../components/ui/ErrorState'
import { EmptyState } from '../components/ui/EmptyState'
import { PageHeader } from '../components/ui/PageHeader'
import type { CSSProperties } from 'react'

const LP_OPTIONS = [
  { value: 1, label: 'Concours' },
  { value: 2, label: 'BEPC' },
  { value: 3, label: 'Bac' },
]
const BAC_OPTIONS = [
  { value: 1, label: 'Bac C' },
  { value: 2, label: 'Bac D' },
]

interface FormState {
  name: string
  description: string
  duration_days: number
  price: number
  learning_path_id: number | ''
  bac_branch_id: number | ''
  is_active: boolean
}

const EMPTY: FormState = {
  name: '', description: '', duration_days: 30, price: 0,
  learning_path_id: '', bac_branch_id: '', is_active: true,
}

const cardStyle: CSSProperties = {
  background: '#fff', borderRadius: 14, padding: '12px 16px',
  display: 'flex', alignItems: 'center', gap: 14,
  border: '1px solid #E2E8F0', boxShadow: '0 1px 4px rgba(0,0,0,0.04)',
}
const iBtnStyle: CSSProperties = {
  width: 34, height: 34, borderRadius: 8, border: 'none', background: 'transparent',
  cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center',
  transition: 'background 0.15s', flexShrink: 0,
}

export function SubscriptionPlansPage() {
  const [items, setItems] = useState<SubscriptionPlan[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')
  const [modal, setModal] = useState(false)
  const [editing, setEditing] = useState<SubscriptionPlan | null>(null)
  const [form, setForm] = useState<FormState>(EMPTY)
  const [saving, setSaving] = useState(false)
  const [deleteId, setDeleteId] = useState<number | null>(null)
  const [deleting, setDeleting] = useState(false)

  async function load() {
    setLoading(true); setError('')
    try { setItems(await subscriptionService.getPlans()) }
    catch (e) { setError((e as Error).message) }
    finally { setLoading(false) }
  }
  useEffect(() => { load() }, [])

  function openCreate() { setEditing(null); setForm(EMPTY); setModal(true) }
  function openEdit(p: SubscriptionPlan) {
    setEditing(p)
    setForm({
      name: p.name, description: p.description, duration_days: p.duration_days,
      price: p.price, learning_path_id: p.learning_path_id ?? '',
      bac_branch_id: p.bac_branch_id ?? '', is_active: p.is_active,
    })
    setModal(true)
  }

  async function save() {
    if (!form.name.trim()) return
    setSaving(true)
    try {
      const payload = {
        ...form,
        duration_days: Number(form.duration_days),
        price: Number(form.price),
        learning_path_id: form.learning_path_id ? Number(form.learning_path_id) : null,
        bac_branch_id: form.bac_branch_id ? Number(form.bac_branch_id) : null,
      }
      if (editing) await subscriptionService.updatePlan(editing.id, payload)
      else await subscriptionService.createPlan(payload)
      setModal(false); load()
    } catch (e) { alert((e as Error).message) }
    finally { setSaving(false) }
  }

  async function confirmDelete() {
    if (!deleteId) return; setDeleting(true)
    try { await subscriptionService.deletePlan(deleteId); setDeleteId(null); load() }
    catch (e) { alert((e as Error).message) }
    finally { setDeleting(false) }
  }

  function f<K extends keyof FormState>(key: K, val: FormState[K]) {
    setForm(p => ({ ...p, [key]: val }))
  }

  const lpLabel = (id: number | null) => LP_OPTIONS.find(o => o.value === id)?.label ?? 'عام'
  const bacLabel = (id: number | null) => BAC_OPTIONS.find(o => o.value === id)?.label ?? ''

  return (
    <div>
      <PageHeader
        title="خطط الاشتراك"
        action={<Button onClick={openCreate}><Plus size={15} />إضافة خطة</Button>}
      />
      <div style={{ padding: '0 24px 24px' }}>
        {loading ? <Loading /> : error ? <ErrorState message={error} onRetry={load} /> : items.length === 0 ? (
          <EmptyState icon={CreditCard} title="لا توجد خطط اشتراك" action={<Button onClick={openCreate}><Plus size={15} />إضافة خطة</Button>} />
        ) : (
          <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
            {items.map((p) => (
              <div key={p.id} style={cardStyle}>
                <div style={{ width: 44, height: 44, borderRadius: 12, flexShrink: 0, background: '#EFF6FF', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                  <CreditCard size={20} color="#2563EB" />
                </div>
                <div style={{ flex: 1, minWidth: 0 }}>
                  <p style={{ fontSize: 14, fontWeight: 700, color: '#1E293B', fontFamily: 'Cairo' }}>{p.name}</p>
                  <p style={{ fontSize: 12, color: '#94A3B8', fontFamily: 'Cairo' }}>
                    {p.duration_days} يوم · {p.price} MRU
                    {p.learning_path_id ? ` · ${lpLabel(p.learning_path_id)}` : ''}
                    {p.bac_branch_id ? ` · ${bacLabel(p.bac_branch_id)}` : ''}
                  </p>
                </div>
                <span style={{ fontSize: 11, padding: '2px 8px', borderRadius: 20, background: p.is_active ? '#F0FDF4' : '#FEF2F2', color: p.is_active ? '#16A34A' : '#DC2626', fontFamily: 'Cairo', fontWeight: 600 }}>
                  {p.is_active ? 'نشط' : 'معطّل'}
                </span>
                <button onClick={() => openEdit(p)} style={iBtnStyle}
                  onMouseEnter={(e) => { (e.currentTarget as HTMLButtonElement).style.background = '#EFF6FF' }}
                  onMouseLeave={(e) => { (e.currentTarget as HTMLButtonElement).style.background = 'transparent' }}>
                  <Pencil size={15} color="#2563EB" />
                </button>
                <button onClick={() => setDeleteId(p.id)} style={iBtnStyle}
                  onMouseEnter={(e) => { (e.currentTarget as HTMLButtonElement).style.background = '#FEF2F2' }}
                  onMouseLeave={(e) => { (e.currentTarget as HTMLButtonElement).style.background = 'transparent' }}>
                  <Trash2 size={15} color="#DC2626" />
                </button>
              </div>
            ))}
          </div>
        )}
      </div>

      <Modal open={modal} onClose={() => setModal(false)} title={editing ? 'تعديل خطة الاشتراك' : 'إضافة خطة اشتراك'}
        footer={<><Button variant="secondary" onClick={() => setModal(false)}>إلغاء</Button><Button onClick={save} loading={saving}>حفظ</Button></>}>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 14 }}>
          <Input label="اسم الخطة *" value={form.name} onChange={(e) => f('name', e.target.value)} />
          <div style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
            <label style={{ fontSize: 13, fontWeight: 600, color: '#374151', fontFamily: 'Cairo' }}>الوصف</label>
            <textarea rows={2} value={form.description} onChange={(e) => f('description', e.target.value)}
              style={{ padding: '9px 12px', border: '1.5px solid #E2E8F0', borderRadius: 10, fontSize: 13, fontFamily: 'Cairo', background: '#FAFAFA', color: '#1E293B', outline: 'none', resize: 'vertical' }} />
          </div>
          <Input label="مدة الاشتراك (أيام) *" type="number" value={form.duration_days} onChange={(e) => f('duration_days', Number(e.target.value))} />
          <Input label="السعر (MRU) *" type="number" value={form.price} onChange={(e) => f('price', Number(e.target.value))} />
          <Select label="المستوى الدراسي" value={form.learning_path_id} options={LP_OPTIONS} placeholder="عام (جميع المستويات)" onChange={(e) => { f('learning_path_id', e.target.value ? Number(e.target.value) : ''); f('bac_branch_id', '') }} />
          {form.learning_path_id === 3 && (
            <Select label="الشعبة" value={form.bac_branch_id} options={BAC_OPTIONS} placeholder="جميع الشعب" onChange={(e) => f('bac_branch_id', e.target.value ? Number(e.target.value) : '')} />
          )}
          <label style={{ display: 'flex', alignItems: 'center', gap: 8, cursor: 'pointer' }}>
            <input type="checkbox" checked={form.is_active} onChange={(e) => f('is_active', e.target.checked)} style={{ width: 16, height: 16, accentColor: '#2563EB' }} />
            <span style={{ fontSize: 13, fontWeight: 600, color: '#374151', fontFamily: 'Cairo' }}>خطة نشطة</span>
          </label>
        </div>
      </Modal>
      <ConfirmDialog open={!!deleteId} onClose={() => setDeleteId(null)} onConfirm={confirmDelete} loading={deleting} />
    </div>
  )
}
