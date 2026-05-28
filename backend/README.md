# Edurim Backend — Go REST API

## التشغيل

```bash
cp .env.example .env
# عدّل .env

go mod tidy
go run cmd/server/main.go
```

السيرفر يعمل على `http://localhost:8080`

## ملاحظة

السيرفر يعمل حتى بدون قاعدة بيانات — يرجع بيانات mock.
