# Cloudflare Pages — EduRim Deployment Guide

## 1. Student App (Flutter Web)

### Local Production Build

```bash
cd frontend

flutter build web --release \
  --dart-define=API_BASE_URL=https://api.edurim.com/api \
  --dart-define=FILES_BASE_URL=https://files.edurim.com
```

Output directory: `frontend/build/web`

### Cloudflare Pages — Direct Upload

1. Go to Cloudflare Dashboard → Pages → Create project → Direct Upload
2. Project name: `edurim-student`
3. Upload the folder: `frontend/build/web`
4. After deploy, add custom domain: `student.edurim.com`

> **Note:** Flutter Web does not have a standard CI build on Cloudflare Pages
> (no Flutter SDK available). Use Direct Upload after building locally.

### SPA Routing

File `frontend/web/_redirects` is copied automatically to `build/web/_redirects` during build:

```
/* /index.html 200
```

---

## 2. Admin Dashboard (React + Vite)

### Cloudflare Pages — Git Integration

| Setting | Value |
|---|---|
| Framework preset | Vite |
| Root directory | `admin` |
| Build command | `npm install && npm run build` |
| Build output directory | `dist` |

### Environment Variables (set in Cloudflare Pages Dashboard)

```
VITE_API_URL   = https://api.edurim.com/api
VITE_FILES_URL = https://files.edurim.com
```

> These override `admin/.env.production` values set at build time.

### Custom Domain

Add `admin.edurim.com` in Cloudflare Pages → Custom domains.

### SPA Routing

File `admin/public/_redirects` is copied automatically to `dist/_redirects` during build:

```
/* /index.html 200
```

---

## 3. Temporary URLs (initial deployment)

Before custom domains are configured, Cloudflare Pages assigns:

- Student: `https://edurim-student.pages.dev`
- Admin:   `https://edurim-admin.pages.dev`

Add both to `CORS_ALLOWED_ORIGINS` on Render:

```
CORS_ALLOWED_ORIGINS=https://student.edurim.com,https://admin.edurim.com,https://edurim-student.pages.dev,https://edurim-admin.pages.dev
```

---

## 4. Full Deployment Checklist

- [ ] Railway MySQL: import `edurim_backup_for_railway.sql`
- [ ] Cloudflare R2: create bucket `edurim-uploads`, enable public access
- [ ] Render: deploy backend, set all env vars from `.env.production.example`
- [ ] Cloudflare Pages: deploy admin via Git integration
- [ ] Cloudflare Pages: deploy student via Direct Upload
- [ ] DNS: point `api.edurim.com` → Render URL
- [ ] DNS: point `student.edurim.com` → Cloudflare Pages
- [ ] DNS: point `admin.edurim.com` → Cloudflare Pages
- [ ] DNS: point `files.edurim.com` → R2 bucket custom domain
- [ ] Test: `GET https://api.edurim.com/api/health`
- [ ] Test: login on student app
- [ ] Test: login on admin dashboard
- [ ] Test: file upload
