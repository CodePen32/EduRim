import { useEffect, useState } from 'react'
import { Plus, Pencil, Trash2, Users } from 'lucide-react'
import { subscriptionService } from '../services/subscriptionService'
import { usersService } from '../services/usersService'
import type { UserSubscription, SubscriptionPlan, User } from '../types'
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

interface FormState {
  user_id: number | ''
  plan_id: number | ''
  start_date: string
  end_date: string
  is_active: boolean
  notes: string
}

const EMPTY: FormState = {
  user_id: '', plan_id: '', start_date: '', end_date: '', is_active: true, notes: '',
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

function daysRemaining(endDate: string): number {
  const end = new Date(endDate)
  const now = new Date()
  const diff = Math.ceil((end.getTime() - now.getTime()) / (1000 * 60 * 60 * 24))
  return diff
}

export function UserSubscriptionsPage() {
  const [items, setItems] = useState<UserSubscription[]>([])
  const [plans, setPlans] = useState<SubscriptionPlan[]>([])
  const [users, setUsers] = useState<User[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')
  const [modal, setModal] = useState(false)
  const [editing, setEditing] = useState<UserSubscription | null>(null)
  const [form, setForm] = useState<FormState>(EMPTY)
  const [saving, setSaving] = useState(false)
  const [deleteId, setDeleteId] = useState<number | null>(null)
  const [deleting, setDeleting] = useState(false)
  const [search, setSearch] = useState('')

  async function load() {
    setLoading(true); setError('')
    try {
      const [subs, ps, us] = await Promise.all([
        subscriptionService.getUserSubscriptions(),
        subscriptionService.getPlans(),
        usersService.getAll(''),
      ])
      setItems(subs); setPlans(ps); setUsers(us)
    } catch (e) { setError((e as Error).message) }
    finally { setLoading(false) }
  }
  useEffect(() => { load() }, [])

  function openCreate() { setEditing(null); setForm(EMPTY); setModal(true) }
  function openEdit(s: UserSubscription) {
    setEditing(s)
    setForm({
      user_id: s.user_id, plan_id: s.plan_id,
      start_date: s.start_date, end_date: s.end_date,
      is_active: s.is_active, notes: s.notes ?? '',
    })
    setModal(true)
  }

  async function save() {
    if (!form.user_id || !form.plan_id || !form.start_date || !form.end_date) return
    setSaving(true)
    try {
      const payload = { ...form, user_id: Number(form.user_id), plan_id: Number(form.plan_id) }
      if (editing) await subscriptionService.updateUserSubscription(editing.id, payload)
      else await subscriptionService.createUserSubscription(payload)
      setModal(false); load()
    } catch (e) { alert((e as Error).message) }
    finally { setSaving(false) }
  }

  async function confirmDelete() {
    if (!deleteId) return; setDeleting(true)
    try { await subscriptionService.deleteUserSubscription(deleteId); setDeleteId(null); load() }
    catch (e) { alert((e as Error).message) }
    finally { setDeleting(false) }
  }

  function f<K extends keyof FormState>(key: K, val: FormState[K]) {
    setForm(p => ({ ...p, [key]: val }))
  }

  const filtered = items.filter(s =>
    !search ||
    (s.user_full_name ?? '').includes(search) ||
    (s.plan_name ?? '').includes(search)
  )

  return (
    <div>
      <PageHeader
        title="اشتراكات الطلاب"
        action={<Button onClick={openCreate}><Plus size={15} />إضافة اشتراك</Button>}
      />
      <div style={{ padding: '0 24px 24px' }}>
        <div style={{ marginBottom: 16 }}>
          <Input placeholder="بحث بالاسم أو الخطة..." value={search} onChange={(e) => setSearch(e.target.value)} />
        </div>
        {loading ? <Loading /> : error ? <ErrorState message={error} onRetry={load} /> : filtered.length === 0 ? (
          <EmptyState icon={Users} title="لا توجد اشتراكات" action={<Button onClick={openCreate}><Plus size={15} />إضافة اشتراك</Button>} />
        ) : (
          <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
            {filtered.map((s) => {
              const days = daysRemaining(s.end_date)
              const expired = days <= 0
              return (
                <div key={s.id} style={{ ...cardStyle, borderColor: expired ? '#FCA5A5' : '#E2E8F0', background: expired ? '#FFF8F8' : '#fff' }}>
                  <div style={{ width: 44, height: 44, borderRadius: 12, flexShrink: 0, background: '#EFF6FF', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                    <span style={{ fontSize: 16, fontWeight: 700, color: '#2563EB', fontFamily: 'Cairo' }}>
                      {(s.user_full_name ?? '؟').charAt(0)}
                    </span>
                  </div>
                  <div style={{ flex: 1, minWidth: 0 }}>
                    <p style={{ fontSize: 14, fontWeight: 700, color: '#1E293B', fontFamily: 'Cairo' }}>{s.user_full_name ?? `مستخدم #${s.user_id}`}</p>
                    <p style={{ fontSize: 12, color: '#94A3B8', fontFamily: 'Cairo' }}>
                      {s.plan_name ?? `خطة #${s.plan_id}`} · {s.start_date} ← {s.end_date}
                    </p>
                  </div>
                  <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 2 }}>
                    <span style={{ fontSize: 11, padding: '2px 8px', borderRadius: 20, background: expired ? '#FEF2F2' : s.is_active ? '#F0FDF4' : '#F1F5F9', color: expired ? '#DC2626' : s.is_active ? '#16A34A' : '#64748B', fontFamily: 'Cairo', fontWeight: 600 }}>
                      {expired ? 'منتهي' : s.is_active ? `${days} يوم` : 'معطّل'}
                    </span>
                  </div>
                  <button onClick={() => openEdit(s)} style={iBtnStyle}
                    onMouseEnter={(e) => { (e.currentTarget as HTMLButtonElement).style.background = '#EFF6FF' }}
                    onMouseLeave={(e) => { (e.currentTarget as HTMLButtonElement).style.background = 'transparent' }}>
                    <Pencil size={15} color="#2563EB" />
                  </button>
                  <button onClick={() => setDeleteId(s.id)} style={iBtnStyle}
                    onMouseEnter={(e) => { (e.currentTarget as HTMLButtonElement).style.background = '#FEF2F2' }}
                    onMouseLeave={(e) => { (e.currentTarget as HTMLButtonElement).style.background = 'transparent' }}>
                    <Trash2 size={15} color="#DC2626" />
                  </button>
                </div>
              )
            })}
          </div>
        )}
      </div>

      <Modal open={modal} onClose={() => setModal(false)} title={editing ? 'تعديل الاشتراك' : 'إضافة اشتراك'}
        footer={<><Button variant="secondary" onClick={() => setModal(false)}>إلغاء</Button><Button onClick={save} loading={saving}>حفظ</Button></>}>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 14 }}>
          <Select
            label="الطالب *"
            value={form.user_id}
            options={users.map(u => ({ value: u.id, label: u.full_name }))}
            placeholder="اختر الطالب"
            onChange={(e) => f('user_id', e.target.value ? Number(e.target.value) : '')}
          />
          <Select
            label="خطة الاشتراك *"
            value={form.plan_id}
            options={plans.map(p => ({ value: p.id, label: `${p.name} (${p.duration_days} يوم - ${p.price} MRU)` }))}
            placeholder="اختر الخطة"
            onChange={(e) => {
              const id = Number(e.target.value)
              f('plan_id', id || '')
              if (id) {
                const plan = plans.find(p => p.id === id)
                if (plan && !form.start_date) {
                  const today = new Date()
                  const end = new Date(today)
                  end.setDate(end.getDate() + plan.duration_days)
                  f('start_date', today.toISOString().slice(0, 10))
                  f('end_date', end.toISOString().slice(0, 10))
                }
              }
            }}
          />
          <Input label="تاريخ البداية *" type="date" value={form.start_date} onChange={(e) => f('start_date', e.target.value)} />
          <Input label="تاريخ النهاية *" type="date" value={form.end_date} onChange={(e) => f('end_date', e.target.value)} />
          <div style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
            <label style={{ fontSize: 13, fontWeight: 600, color: '#374151', fontFamily: 'Cairo' }}>ملاحظات</label>
            <textarea rows={2} value={form.notes} onChange={(e) => f('notes', e.target.value)}
              style={{ padding: '9px 12px', border: '1.5px solid #E2E8F0', borderRadius: 10, fontSize: 13, fontFamily: 'Cairo', background: '#FAFAFA', color: '#1E293B', outline: 'none', resize: 'vertical' }} />
          </div>
          <label style={{ display: 'flex', alignItems: 'center', gap: 8, cursor: 'pointer' }}>
            <input type="checkbox" checked={form.is_active} onChange={(e) => f('is_active', e.target.checked)} style={{ width: 16, height: 16, accentColor: '#2563EB' }} />
            <span style={{ fontSize: 13, fontWeight: 600, color: '#374151', fontFamily: 'Cairo' }}>اشتراك نشط</span>
          </label>
        </div>
      </Modal>
      <ConfirmDialog open={!!deleteId} onClose={() => setDeleteId(null)} onConfirm={confirmDelete} loading={deleting} />
    </div>
  )
}
