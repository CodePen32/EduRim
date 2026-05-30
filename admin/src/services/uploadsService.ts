import { api } from '../lib/api'

export type UploadCategory = 'covers' | 'files' | 'videos'

// Map category to the ?type query param backend expects
const categoryToType: Record<UploadCategory, string> = {
  covers: 'images',
  files:  'files',
  videos: 'videos',
}

export async function uploadFile(file: File, category: UploadCategory, onProgress?: (pct: number) => void): Promise<string> {
  const form = new FormData()
  // Backend reads FormFile("file") — only this field, no extra fields
  form.append('file', file)

  const type = categoryToType[category] ?? 'images'

  // Do NOT set Content-Type manually — let the browser set it with the correct boundary
  const res = await api.post(`/admin/uploads?type=${type}`, form, {
    onUploadProgress: (e) => {
      if (e.total && onProgress) onProgress(Math.round((e.loaded / e.total) * 100))
    },
  })
  const url = res.data?.url ?? res.data?.path ?? ''
  if (!url) throw new Error('لم يُرجع الخادم رابط الملف')
  return url as string
}
