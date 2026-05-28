# Edurim — منصة تعليمية موريتانية

منصة تعليمية للطلاب الموريتانيين تدعم مسارات Concours وBEPC والباكالوريا (Bac C / Bac D).

---

## هيكل المشروع

```
edurim/
├── backend/               API Server — Go + Gin + MySQL
├── frontend/              تطبيق الطالب — Flutter Web
├── admin/                 لوحة التحكم الرسمية — React + Vite + TypeScript
├── admin_flutter_backup/  نسخة احتياطية قديمة — Flutter Web (غير مستخدمة)
└── database/              SQL migrations
```

---

## تشغيل المشروع

### 1. Backend (يجب أن يعمل أولاً)

```bash
cd backend
go run cmd/server/main.go
```

يعمل على: `http://localhost:8081`

---

### 2. لوحة التحكم — Admin Dashboard

```bash
cd admin
npm install
npm run dev
```

يعمل على: **`http://localhost:5173`**

بيانات الدخول:
- البريد: `admin@edurim.local`
- كلمة المرور: `Admin@2024!`

---

### 3. تطبيق الطالب

```bash
cd frontend
flutter run -d chrome --web-port 3000
```

يعمل على: **`http://localhost:3000`**

---

## بناء للإنتاج

```bash
# Backend
cd backend && go build -o backend_server.exe ./cmd/server/

# Admin
cd admin && npm run build

# Student App
cd frontend && flutter build web --profile --no-wasm-dry-run
python -m http.server 3000 -d build/web
```

---

## ملاحظات

- `admin_flutter_backup/` نسخة قديمة من Flutter Admin — **لا تُستخدم في الإنتاج**.
- لوحة التحكم الرسمية هي `admin/` — React + Vite + TypeScript على port **5173**.
- Backend يجب أن يكون شغالاً قبل فتح أي من الواجهتين.
