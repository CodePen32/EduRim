import { useEffect, useState } from 'react'
import { Users, UserCheck, UserX, Pencil } from 'lucide-react'
import { useAdminScope } from '../context/AdminScopeContext'
import { usersService } from '../services/usersService'
import type { User } from '../types'
import { Button } from '../components/ui/Button'
import { Input } from '../components/ui/Input'
import { Select } from '../components/ui/Select'
import { Modal } from '../components/ui/Modal'
import { Loading } from '../components/ui/Loading'
import { ErrorState } from '../components/ui/ErrorState'
import { EmptyState } from '../components/ui/EmptyState'

const LP_OPTIONS = [
  { value: 1, label: 'Concours' },
  { value: 2, label: 'BEPC' },
  { value: 3, label: 'Bac' },
]
const BAC_OPTIONS = [
  { value: 1, label: 'Bac C' },
  { value: 2, label: 'Bac D' },
]

interface EditForm { full_name: string; email: string; phone: string; city: string; learning_path_id: number|''; bac_branch_id: number|'' }

export function UsersPage() {
  const { scope, queryParams } = useAdminScope()
  const [items, setItems] = useState<User[]>([])
  const [search, setSearch] = useState('')
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')
  const [modal, setModal] = useState(false)
  const [editing, setEditing] = useState<User|null>(null)
  const [form, setForm] = useState<EditForm>({ full_name:'', email:'', phone:'', city:'', learning_path_id:'', bac_branch_id:'' })
  const [saving, setSaving] = useState(false)

  async function load() {
    setLoading(true); setError('')
    try { setItems(await usersService.getAll(queryParams)) }
    catch (e) { setError((e as Error).message) }
    finally { setLoading(false) }
  }
  useEffect(() => { load() }, [queryParams])

  async function toggleActive(u: User) {
    try { await usersService.toggleActive(u.id); load() }
    catch (e) { alert((e as Error).message) }
  }

  function openEdit(u: User) {
    setEditing(u)
    setForm({ full_name:u.full_name, email:u.email, phone:u.phone, city:u.city, learning_path_id:u.learning_path_id??'', bac_branch_id:u.bac_branch_id??'' })
    setModal(true)
  }

  async function save() {
    if (!editing) return; setSaving(true)
    try {
      await usersService.update(editing.id, { ...form, learning_path_id: form.learning_path_id ? Number(form.learning_path_id) : null, bac_branch_id: form.bac_branch_id ? Number(form.bac_branch_id) : null })
      setModal(false); load()
    } catch (e) { alert((e as Error).message) } finally { setSaving(false) }
  }

  const filtered = items.filter(u => !search || u.full_name.includes(search) || u.email.includes(search) || u.phone.includes(search))
  const f = <K extends keyof EditForm>(k: K, v: EditForm[K]) => setForm(p => ({ ...p, [k]: v }))

  return (
    <div>
      <div className="flex items-center justify-between mb-6">
        <div><h1 className="text-2xl font-bold">الطلاب</h1><p className="text-gray-500 text-sm">{scope?.label}</p></div>
        <div className="w-64">
          <Input placeholder="بحث..." value={search} onChange={(e) => setSearch(e.target.value)} />
        </div>
      </div>
      {loading ? <Loading /> : error ? <ErrorState message={error} onRetry={load} /> : filtered.length === 0 ? (
        <EmptyState icon={Users} title="لا يوجد طلاب" />
      ) : (
        <div className="flex flex-col gap-2">
          {filtered.map((u) => (
            <div key={u.id} className={`bg-white rounded-xl p-4 flex items-center gap-4 shadow-sm border ${u.is_active ? 'border-gray-100' : 'border-red-100 bg-red-50/30'}`}>
              <div className="w-10 h-10 rounded-full bg-blue-50 flex items-center justify-center flex-shrink-0">
                <span className="text-blue-600 font-semibold text-sm">{u.full_name.charAt(0)}</span>
              </div>
              <div className="flex-1 min-w-0">
                <p className="font-semibold text-sm truncate">{u.full_name}</p>
                <p className="text-xs text-gray-400">{u.email} · {u.phone}</p>
              </div>
              {!u.is_active && <span className="text-xs bg-red-100 text-red-600 px-2 py-0.5 rounded-full">معطّل</span>}
              <button onClick={() => openEdit(u)} className="text-blue-500 hover:text-blue-700 p-1"><Pencil size={15} /></button>
              <button onClick={() => toggleActive(u)} className={`p-1 ${u.is_active ? 'text-red-400 hover:text-red-600' : 'text-green-500 hover:text-green-700'}`}>
                {u.is_active ? <UserX size={15} /> : <UserCheck size={15} />}
              </button>
            </div>
          ))}
        </div>
      )}
      <Modal open={modal} onClose={() => setModal(false)} title="تعديل بيانات الطالب"
        footer={<><Button variant="secondary" onClick={() => setModal(false)}>إلغاء</Button><Button onClick={save} loading={saving}>حفظ</Button></>}>
        <div className="flex flex-col gap-4">
          <Input label="الاسم الكامل" value={form.full_name} onChange={(e) => f('full_name', e.target.value)} />
          <Input label="البريد الإلكتروني" value={form.email} onChange={(e) => f('email', e.target.value)} dir="ltr" />
          <Input label="رقم الهاتف" value={form.phone} onChange={(e) => f('phone', e.target.value)} dir="ltr" />
          <Input label="المدينة" value={form.city} onChange={(e) => f('city', e.target.value)} />
          <Select label="المستوى الدراسي" value={form.learning_path_id} options={LP_OPTIONS} placeholder="اختر المستوى" onChange={(e) => f('learning_path_id', e.target.value ? Number(e.target.value) : '')} />
          {form.learning_path_id === 3 && <Select label="الشعبة" value={form.bac_branch_id} options={BAC_OPTIONS} placeholder="اختر الشعبة" onChange={(e) => f('bac_branch_id', e.target.value ? Number(e.target.value) : '')} />}
        </div>
      </Modal>
    </div>
  )
}



