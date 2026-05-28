import axios from 'axios'

const BASE_URL = import.meta.env.VITE_API_URL ?? 'http://localhost:8081/api'

export const api = axios.create({ baseURL: BASE_URL })

api.interceptors.request.use((config) => {
  const token = localStorage.getItem('admin_token')
  if (token) config.headers.Authorization = `Bearer ${token}`
  return config
})

api.interceptors.response.use(
  (res) => res,
  (err) => {
    if (err.response?.status === 401) {
      localStorage.removeItem('admin_token')
      localStorage.removeItem('admin_scope')
      window.location.href = '/login'
    }
    const msg =
      err.response?.data?.message ??
      err.response?.data?.error ??
      (err.code === 'ERR_NETWORK' ? 'تعذر الاتصال بالخادم' : 'حدث خطأ غير متوقع')
    return Promise.reject(new Error(msg))
  }
)
