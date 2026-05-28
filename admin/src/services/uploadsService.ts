import { api } from '../lib/api'

export type UploadCategory = 'covers' | 'files' | 'videos'

export async function uploadFile(file: File, category: UploadCategory, onProgress?: (pct: number) => void): Promise<string> {
  const form = new FormData()
  form.append('file', file)
  form.append('category', category)

  const res = await api.post('/admin/uploads', form, {
    headers: { 'Content-Type': 'multipart/form-data' },
    onUploadProgress: (e) => {
      if (e.total && onProgress) onProgress(Math.round((e.loaded / e.total) * 100))
    },
  })
  const url = res.data?.url ?? res.data?.path ?? ''
  if (!url) throw new Error('لم يُرجع الخادم رابط الملف')
  return url as string
}
