import { Modal } from './Modal'
import { Button } from './Button'

interface Props { open: boolean; onClose: () => void; onConfirm: () => void; title?: string; message?: string; loading?: boolean }

export function ConfirmDialog({ open, onClose, onConfirm, title = 'تأكيد الحذف', message = 'هل أنت متأكد من الحذف؟ لا يمكن التراجع عن هذه العملية.', loading }: Props) {
  return (
    <Modal
      open={open}
      onClose={onClose}
      title={title}
      footer={
        <>
          <Button variant="secondary" onClick={onClose}>إلغاء</Button>
          <Button variant="danger" onClick={onConfirm} loading={loading}>حذف</Button>
        </>
      }
    >
      <p style={{ fontSize: 14, color: '#64748B', fontFamily: 'Cairo', lineHeight: 1.7 }}>{message}</p>
    </Modal>
  )
}
