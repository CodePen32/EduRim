import { useRef, useState } from 'react'
import { FileText, Video, Image, X } from 'lucide-react'
import { uploadFile, type UploadCategory } from '../services/uploadsService'
import { buildFileUrl } from '../lib/fileUrl'

type UploadType = 'image' | 'pdf' | 'video'

interface Props {
  label: string
  type: UploadType
  value: string
  onChange: (url: string) => void
}

const ACCEPT: Record<UploadType, string> = {
  image: 'image/jpeg,image/png,image/webp',
  pdf: 'application/pdf',
  video: 'video/mp4,video/webm,video/quicktime',
}
const CATEGORY: Record<UploadType, UploadCategory> = {
  image: 'covers',
  pdf: 'files',
  video: 'videos',
}

export function FileUploadField({ label, type, value, onChange }: Props) {
  const ref = useRef<HTMLInputElement>(null)
  const [progress, setProgress] = useState(0)
  const [uploading, setUploading] = useState(false)
  const [error, setError] = useState('')

  async function handleFile(file: File) {
    setUploading(true)
    setError('')
    setProgress(0)
    try {
      const url = await uploadFile(file, CATEGORY[type], setProgress)
      onChange(url)
    } catch (e) {
      setError((e as Error).message)
    } finally {
      setUploading(false)
    }
  }

  const fullUrl = buildFileUrl(value)

  return (
    <div className="flex flex-col gap-2">
      <label className="text-sm font-medium text-gray-700">{label}</label>

      <div
        className="border-2 border-dashed border-gray-300 rounded-lg p-4 cursor-pointer hover:border-blue-400 transition-colors text-center"
        onClick={() => ref.current?.click()}
      >
        {type === 'image' ? <Image size={24} className="mx-auto text-gray-400 mb-1" /> :
         type === 'pdf' ? <FileText size={24} className="mx-auto text-gray-400 mb-1" /> :
         <Video size={24} className="mx-auto text-gray-400 mb-1" />}
        <p className="text-sm text-gray-500">اضغط لاختيار ملف</p>
        <input ref={ref} type="file" accept={ACCEPT[type]} className="hidden"
          onChange={(e) => { const f = e.target.files?.[0]; if (f) handleFile(f) }} />
      </div>

      {uploading && (
        <div className="flex items-center gap-2">
          <div className="flex-1 bg-gray-200 rounded-full h-2">
            <div className="bg-blue-600 h-2 rounded-full transition-all" style={{ width: `${progress}%` }} />
          </div>
          <span className="text-xs text-gray-500">{progress}%</span>
        </div>
      )}

      {error && <p className="text-xs text-red-500">{error}</p>}

      {value && !uploading && (
        <div className="flex items-center gap-2 p-2 bg-gray-50 rounded-lg">
          {type === 'image' && fullUrl ? (
            <img src={fullUrl} alt="" className="w-12 h-12 object-cover rounded" />
          ) : (
            <a href={fullUrl} target="_blank" rel="noreferrer" className="text-xs text-blue-600 hover:underline truncate flex-1">
              {type === 'video' ? 'فيديو محمّل' : 'PDF محمّل'}
            </a>
          )}
          <button type="button" onClick={() => onChange('')} className="text-gray-400 hover:text-red-500 transition-colors">
            <X size={16} />
          </button>
        </div>
      )}
    </div>
  )
}
