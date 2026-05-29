// Dev:  uses VITE_FILES_URL from .env (defaults to localhost)
// Prod: set VITE_FILES_URL=https://files.edurim.com in .env.production
const FILES_URL = import.meta.env.VITE_FILES_URL || 'http://localhost:8081'

export function buildFileUrl(path?: string | null): string {
  if (!path) return ''
  if (path.startsWith('http://') || path.startsWith('https://')) return path
  if (path.startsWith('/')) return `${FILES_URL}${path}`
  return `${FILES_URL}/${path}`
}
