import { useEffect, useState } from 'react'
import type { FormEvent } from 'react'
import { Bell, Plus } from 'lucide-react'
import { useAdminScope } from '../context/AdminScopeContext'
import { notificationsService } from '../services/notificationsService'
import type { Notification } from '../types'
import { Button } from '../components/ui/Button'
import { Input } from '../components/ui/Input'
import { Select } from '../components/ui/Select'
import { Modal } from '../components/ui/Modal'
import { Loading } from '../components/ui/Loading'
import { ErrorState } from '../components/ui/ErrorState'
import { EmptyState } from '../components/ui/EmptyState'

export function NotificationsPage() {
  const { scope, queryParams } = useAdminScope()
  const [items, setItems] = useState<Notification[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')
  const [modal, setModal] = useState(false)
  const [title, setTitle] = useState('')
  const [body, setBody] = useState('')
  const [type, setType] = useState('info')
  const [saving, setSaving] = useState(false)

  async function load() {
    setLoading(true); setError('')
    try { setItems(await notificationsService.getAll(queryParams)) }
    catch (e) { setError((e as Error).message) }
    finally { setLoading(false) }
  }
  useEffect(() => { load() }, [queryParams])

  async function send(e: FormEvent) {
    e.preventDefault()
    if (!title.trim() || !body.trim()) return
    setSaving(true)
    try {
      await notificationsService.create({ title, body, type, learning_path_id: scope!.learningPathId, bac_branch_id: scope!.bacBranchId })
      setModal(false); setTitle(''); setBody(''); load()
    } catch (e) { alert((e as Error).message) } finally { setSaving(false) }
  }

  function formatDate(s: string) {
    try { return new Date(s).toLocaleDateString('ar', { year:'numeric', month:'short', day:'numeric' }) }
    catch { return s }
  }

  return (
    <div>
      <div className="flex items-center justify-between mb-6">
        <div><h1 className="text-2xl font-bold">الإشعارات</h1><p className="text-gray-500 text-sm">{scope?.label}</p></div>
        <Button onClick={() => setModal(true)}><Plus size={16} />إرسال إشعار</Button>
      </div>
      {loading ? <Loading /> : error ? <ErrorState message={error} onRetry={load} /> : items.length === 0 ? (
        <EmptyState icon={Bell} title="لا توجد إشعارات لهذا القسم" action={<Button onClick={() => setModal(true)}><Plus size={16} />إرسال إشعار</Button>} />
      ) : (
        <div className="flex flex-col gap-3">
          {items.map((n) => (
            <div key={n.id} className="bg-white rounded-xl p-4 shadow-sm border border-gray-100">
              <div className="flex items-start justify-between gap-2">
                <div>
                  <p className="font-semibold text-gray-900">{n.title}</p>
                  <p className="text-sm text-gray-500 mt-1">{n.body}</p>
                </div>
                <span className="text-xs text-gray-400 flex-shrink-0 mt-1">{formatDate(n.created_at)}</span>
              </div>
              <div className="mt-2">
                <span className="text-xs bg-blue-100 text-blue-700 px-2 py-0.5 rounded-full">{n.type}</span>
              </div>
            </div>
          ))}
        </div>
      )}
      <Modal open={modal} onClose={() => setModal(false)} title="إرسال إشعار جديد"
        footer={<><Button variant="secondary" onClick={() => setModal(false)}>إلغاء</Button><Button onClick={send as unknown as () => void} loading={saving}>إرسال</Button></>}>
        <form onSubmit={send} className="flex flex-col gap-4">
          <Input label="العنوان *" value={title} onChange={(e) => setTitle(e.target.value)} required />
          <div>
            <label className="text-sm font-medium text-gray-700 block mb-1">الرسالة *</label>
            <textarea required className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500" rows={4} value={body} onChange={(e) => setBody(e.target.value)} />
          </div>
          <Select label="النوع" value={type} options={[{value:'info',label:'معلومة'},{value:'warning',label:'تحذير'},{value:'success',label:'نجاح'},{value:'announcement',label:'إعلان'}]} onChange={(e) => setType(e.target.value)} />
          <div className="bg-blue-50 border border-blue-200 rounded-lg p-3 text-sm text-blue-700">
            سيُرسل هذا الإشعار لطلاب <strong>{scope?.label}</strong> فقط.
          </div>
        </form>
      </Modal>
    </div>
  )
}




