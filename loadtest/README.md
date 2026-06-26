# EduRim — Phase 2B Load Testing

## 1. تجهيز حساب اختبار (test account)

لا تستخدم حساب طالب حقيقي. أنشئ حساباً مخصصاً للاختبار فقط:

```bash
curl -X POST https://edurim-api.onrender.com/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "full_name": "Load Test User",
    "email": "loadtest@example.com",
    "phone": "00000000",
    "password": "ChangeThisStrongPassword123",
    "gender": "ذكر",
    "city": "Test",
    "learning_path_id": 1
  }'
```

- استخدم بريداً ورقم هاتف لا يتعارضان مع مستخدمين حقيقيين (مثل `loadtest@example.com`).
- اختر `learning_path_id` موجوداً فعلياً (1 = Concours عادة، تحقق من `GET /api/learning-paths`) ليحصل الحساب على مواد/دروس حقيقية عند الاختبار.
- لا تشارك كلمة السر هذه في أي مكان عام؛ مرّرها فقط عبر `-e TEST_PASSWORD=...` وقت التشغيل.
- بعد انتهاء كل الاختبارات، يُفضّل تعطيل هذا الحساب من لوحة الأدمن (`PATCH /api/admin/users/:id/toggle-active`) بدل تركه نشطاً للأبد.

## 2. التشغيل

ثبّت k6 إن لم يكن مثبتاً: https://k6.io/docs/get-started/installation/

```bash
# المرحلة 1: 50 مستخدم
k6 run -e BASE_URL=https://edurim-api.onrender.com \
       -e TEST_EMAIL=loadtest@example.com \
       -e TEST_PASSWORD='ChangeThisStrongPassword123' \
       -e STAGE=50 \
       loadtest/k6-basic.js
```

بعد مراجعة النتائج (انظر التقرير الرئيسي لكيفية القراءة)، إن كانت سليمة:

```bash
# المرحلة 2: 100 مستخدم
k6 run -e BASE_URL=https://edurim-api.onrender.com \
       -e TEST_EMAIL=loadtest@example.com \
       -e TEST_PASSWORD='ChangeThisStrongPassword123' \
       -e STAGE=100 \
       loadtest/k6-basic.js
```

**لا تشغّل 300 أو 500 أو 1000 إلا بعد نجاح 50 و100 بوضوح وبموافقة صريحة.** السكربت الحالي يدعم فقط `STAGE=50` و`STAGE=100` عمداً.

### اختياري: اختبار تحميل ملف ثابت

إذا كان لديك مفتاح ملف حقيقي موجود على R2 (مثل `images/169...jpg`)، مرّره عبر:

```bash
-e SAMPLE_FILE_KEY="images/169xxxxxxxxxxxxx.jpg"
```

إن لم يُمرَّر، يتم تجاوز هذا الفحص تلقائياً بدل تخمين مسار قد يفشل بـ 404 ويُربك نسبة الفشل.
