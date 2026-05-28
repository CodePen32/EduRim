# Edurim Database

قاعدة البيانات MySQL لمنصة Edurim التعليمية.

## إعداد قاعدة البيانات

```bash
# 1. افتح MySQL
mysql -u root -p

# 2. أنشئ قاعدة البيانات
CREATE DATABASE edurim_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE edurim_db;

# 3. نفّذ الـ Schema
SOURCE database/schema.sql;

# 4. أضف البيانات التجريبية
SOURCE database/seed.sql;
```

## الجداول

| الجدول | الوصف |
|--------|-------|
| `learning_paths` | المسارات الدراسية (كونكور، بيبيسي، باك) |
| `bac_branches` | شعب الباكالوريا (C, D, A, O) |
| `users` | المستخدمون |
| `subjects` | المواد الدراسية |
| `teachers` | الأساتذة |
| `units` | الوحدات التعليمية |
| `lessons` | الدروس |
| `exercises` | التمارين والاختبارات |
| `favorites` | المفضلة |
| `downloads` | التنزيلات |
| `progress` | تقدم المستخدم |
| `notifications` | الإشعارات |
| `subscription_plans` | خطط الاشتراك |
| `user_subscriptions` | اشتراكات المستخدمين |
