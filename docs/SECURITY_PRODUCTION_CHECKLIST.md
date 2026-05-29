# EduRim — Security Production Checklist

قائمة تحقق أمنية يجب إكمالها قبل رفع المشروع Live.

---

## 1. Secrets & Environment Variables

- [ ] `JWT_SECRET` مضبوط بقيمة عشوائية قوية (≥ 32 حرف) في Render
- [ ] `DB_PASSWORD` مضبوط في Railway ولا يُستخدم الافتراضي
- [ ] `R2_SECRET_ACCESS_KEY` مضبوط في Render ولا يُستخدم في الكود مباشرة
- [ ] ملفات `.env` و `admin/.env` **غير مرفوعة** في Git (تم إزالتها بـ `git rm --cached`)
- [ ] لا يوجد secret في `render.yaml` أو أي ملف مُتعقَّب بـ Git

---

## 2. Admin Account

- [ ] كلمة مرور Admin الافتراضية (`admin12345`) تم تغييرها قبل Live
- [ ] **طريقة تغيير كلمة المرور:**
  ```sql
  -- قم بتشغيل هذا في Railway MySQL console
  UPDATE admins SET password_hash = '<bcrypt_hash_of_new_password>' WHERE email = 'admin@edurim.com';
  ```
  استخدم أداة مثل https://bcrypt-generator.com أو Go script لتوليد الـ hash
- [ ] Admin الافتراضي للـ seed غير نشط أو محذوف إن لم يكن مطلوباً

---

## 3. CORS

- [ ] `CORS_ALLOWED_ORIGINS` مضبوط في Render يحتوي فقط:
  - `https://student.edurim.com`
  - `https://admin.edurim.com`
  - (روابط pages.dev المؤقتة إن لزم للاختبار)
- [ ] لا يوجد `*` wildcard في production

---

## 4. JWT

- [ ] `JWT_SECRET` ليس `change_me_later` — Backend سيفشل في التشغيل إن كان كذلك في production
- [ ] مدة Token معقولة (24h للمستخدم، 24h للـ admin)
- [ ] Token لا يُطبع في logs

---

## 5. File Uploads (R2)

- [ ] `STORAGE_DRIVER=r2` مضبوط في Render
- [ ] `R2_BUCKET`، `R2_PUBLIC_URL`، `R2_ACCOUNT_ID` مضبوطة
- [ ] الامتدادات المسموح بها فقط: jpg, jpeg, png, webp, pdf, mp4, webm, mov
- [ ] الامتدادات الخطيرة محظورة: php, js, html, exe, svg, sh, bat
- [ ] Content-Type verification مفعّل
- [ ] حجم الصور ≤ 20MB، الفيديو ≤ 200MB
- [ ] أسماء الملفات في R2 عشوائية (UUID) — لا تعتمد على اسم الملف الأصلي

---

## 6. Rate Limiting

- [ ] Login: 5 محاولات/دقيقة لكل IP
- [ ] Register: 5 محاولات/دقيقة لكل IP
- [ ] Admin Login: 5 محاولات/دقيقة لكل IP
- [ ] Uploads: 10 محاولات/دقيقة لكل IP
- [ ] Subscription requests: 5 محاولات/دقيقة لكل IP
- [ ] ملاحظة: Rate limiter حالي in-memory — يُعاد ضبطه عند restart. لـ production قوي استخدم Redis لاحقاً.

---

## 7. Paid Content Protection

- [ ] درس `is_free=false` لا يُرجع `video_url` أو `summary_url` إذا لم يكن للمستخدم اشتراك نشط
- [ ] Flutter لا يكفي وحده لإخفاء المحتوى — Backend يتحقق
- [ ] الاشتراك النشط يتحقق من `end_date >= NOW()`

---

## 8. Level Isolation

- [ ] طالب Bac D لا يستطيع رؤية محتوى Concours أو Bac C
- [ ] `/api/me/lessons`, `/api/me/exercises`, `/api/me/past-exams` كلها مفلترة حسب `learning_path_id` و `bac_branch_id`
- [ ] اختبر بـ token طالب من مسار ثم حاول طلب lesson_id من مسار آخر → يجب 404

---

## 9. SQL Injection

- [ ] جميع queries تستخدم placeholders (`?`) — لا string concatenation من user input
- [ ] تم مراجعة جميع repositories يدوياً

---

## 10. Error Messages

- [ ] رسائل الخطأ للمستخدم عامة ولا تكشف تفاصيل DB
- [ ] `err.Error()` لا يُرجع في أي API response للمستخدم
- [ ] Login يرجع `"بيانات الدخول غير صحيحة"` بغض النظر عن السبب

---

## 11. Security Headers

- [ ] `X-Content-Type-Options: nosniff` مضبوط
- [ ] `X-Frame-Options: DENY` مضبوط
- [ ] `Referrer-Policy: strict-origin-when-cross-origin` مضبوط
- [ ] `Permissions-Policy: camera=(), microphone=(), geolocation=()` مضبوط
- [ ] CSP يُضاف لاحقاً بعد اختبار Flutter Web (قد يكسر inline scripts)

---

## 12. Database

- [ ] DB backup مفعّل في Railway
- [ ] DB user في production لديه صلاحيات محدودة (SELECT/INSERT/UPDATE/DELETE فقط، لا DROP/ALTER)
- [ ] لا يوجد root user في production connection string

---

## 13. Cloudflare / Render

- [ ] HTTPS مفعّل على جميع الدومينات
- [ ] Cloudflare Bot Protection مفعّل
- [ ] files subdomain (`files.edurim.com`) منفصل عن student/admin domains لمنع Cookie theft
- [ ] Cloudflare Pages: `_headers` مضبوط للـ admin و student

---

## 14. Pre-Launch Tests

```bash
# 1. SQL Injection test
curl -X POST https://api.edurim.com/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"identifier":"'\'' OR '\''1'\''='\''1","password":"test"}'
# Expected: 401 بيانات الدخول غير صحيحة

# 2. IDOR test — token طالب Bac يحاول lesson من Concours
curl https://api.edurim.com/api/me/lessons/999 \
  -H "Authorization: Bearer <bac_user_token>"
# Expected: 404

# 3. Malicious upload
curl -X POST https://api.edurim.com/api/admin/uploads \
  -H "Authorization: Bearer <admin_token>" \
  -F "file=@test.php;type=application/x-php"
# Expected: 400 نوع الملف غير مسموح

# 4. User token على admin route
curl https://api.edurim.com/api/admin/users \
  -H "Authorization: Bearer <user_token>"
# Expected: 403

# 5. Rate limit
for i in {1..10}; do
  curl -X POST https://api.edurim.com/api/auth/login \
    -H "Content-Type: application/json" \
    -d '{"identifier":"test@test.com","password":"wrong"}'
done
# Expected: بعد 5 محاولات → 429

# 6. Paid content without subscription
curl https://api.edurim.com/api/me/lessons/<paid_lesson_id> \
  -H "Authorization: Bearer <user_token_no_sub>"
# Expected: data بدون video_url/summary_url + requires_subscription: true
```

---

## 15. Monitoring

- [ ] Render logs مراقبة لأي errors
- [ ] تفعيل alerts على 5xx errors في Render/Cloudflare
- [ ] مراجعة دورية لـ subscription requests غير المعالجة
