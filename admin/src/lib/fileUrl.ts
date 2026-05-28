const BASE = 'http://localhost:8081'

export function buildFileUrl(path?: string | null): string {
  if (!path) return ''
  if (path.startsWith('http://') || path.startsWith('https://')) return path
  if (path.startsWith('/')) return `${BASE}${path}`
  return `${BASE}/${path}`
}
