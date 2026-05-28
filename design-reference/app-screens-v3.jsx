/* eslint-disable */
// ─────────────────────────────────────────────────────────────
// مدرستي — v3: missing screens + design system + states
// ─────────────────────────────────────────────────────────────

// ─── 21. Subjects List (dedicated) ────────────────────────────
function SubjectsListScreen() {
  const subjects = [
    { name: 'الرياضيات', icon: SubjectIcons.math,    progress: 42, lessons: 24, ex: 32, color: '#0F5FA8' },
    { name: 'العلوم الطبيعية', icon: SubjectIcons.science, progress: 28, lessons: 18, ex: 21, color: '#1E9E6A' },
    { name: 'الفيزياء والكيمياء', icon: SubjectIcons.physics, progress: 15, lessons: 16, ex: 18, color: '#2E7EC9' },
    { name: 'اللغة العربية', icon: SubjectIcons.arabic, progress: 60, lessons: 22, ex: 14, color: '#F2A11A' },
    { name: 'التربية الإسلامية', icon: SubjectIcons.islamic, progress: 8,  lessons: 12, ex: 8,  color: '#7C4DDD' },
    { name: 'اللغة الفرنسية', icon: (
      <svg width="28" height="28" viewBox="0 0 32 32"><text x="16" y="22" textAnchor="middle" fontFamily="Inter" fontWeight="900" fontSize="20" fill="#fff">Fr</text></svg>
    ), progress: 35, lessons: 19, ex: 12, color: '#D7424B' },
    { name: 'التاريخ والجغرافيا', icon: (
      <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="#fff" strokeWidth="2"><circle cx="12" cy="12" r="9"/><path d="M3 12h18M12 3a14 14 0 0 1 0 18M12 3a14 14 0 0 0 0 18"/></svg>
    ), progress: 20, lessons: 15, ex: 10, color: '#0A4581' },
  ];
  return (
    <ScreenShell nav={<BottomNav active="home" />}>
      <AppHeader title="كل المواد" />
      <div style={{ padding: 16 }}>
        {/* track indicator */}
        <div style={{
          background: `linear-gradient(95deg, ${EB.primarySoft}, #EAF1FA)`,
          borderRadius: 14, padding: 10, paddingInline: 14,
          display: 'flex', alignItems: 'center', gap: 10, marginBottom: 14,
          border: `1px solid #DCE7F4`,
        }}>
          <div style={{ flex: 1 }}>
            <div style={{ fontSize: 10.5, color: EB.muted, fontWeight: 600 }}>المسار الحالي</div>
            <div style={{ fontSize: 13, fontWeight: 800, color: EB.ink }}>BEPC · ختم الدروس الإعدادية</div>
          </div>
          <div style={{ fontSize: 11, color: EB.primary, fontWeight: 700 }}>تغيير</div>
        </div>

        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline', marginBottom: 10 }}>
          <span style={{ fontSize: 14, fontWeight: 800, color: EB.ink }}>{subjects.length} مادة</span>
          <span style={{ fontSize: 12, color: EB.muted }}>ترتيب: حسب التقدم</span>
        </div>

        <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
          {subjects.map((s, i) => (
            <div key={i} style={{
              background: '#fff', border: `1px solid ${EB.line}`,
              borderRadius: 16, padding: 12,
              display: 'flex', alignItems: 'center', gap: 12,
              boxShadow: '0 6px 14px -12px rgba(20,30,60,0.2)',
            }}>
              <div style={{
                width: 56, height: 56, borderRadius: 14,
                background: `linear-gradient(135deg, ${s.color}, ${s.color}CC)`,
                display: 'flex', alignItems: 'center', justifyContent: 'center',
                boxShadow: `0 6px 14px -8px ${s.color}88`, flexShrink: 0,
              }}>{s.icon}</div>
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{ fontSize: 14.5, fontWeight: 800, color: EB.ink, marginBottom: 4 }}>{s.name}</div>
                <div style={{ display: 'flex', gap: 10, fontSize: 11, color: EB.muted, marginBottom: 6 }}>
                  <span><span style={{ fontFamily: 'Inter', fontWeight: 700, color: EB.ink2 }}>{s.lessons}</span> درس</span>
                  <span>·</span>
                  <span><span style={{ fontFamily: 'Inter', fontWeight: 700, color: EB.ink2 }}>{s.ex}</span> تمرين</span>
                </div>
                <ProgressBar value={s.progress} height={5}/>
              </div>
              <div style={{
                fontFamily: 'Inter', fontWeight: 800, fontSize: 14,
                color: s.color, minWidth: 36, textAlign: 'center',
              }}>{s.progress}%</div>
            </div>
          ))}
        </div>
      </div>
    </ScreenShell>
  );
}

// ─── 22. Edit Profile ─────────────────────────────────────────
function EditProfileScreen() {
  return (
    <ScreenShell>
      <AppHeader title="تعديل الحساب" />
      <div style={{ padding: 18 }}>
        {/* avatar */}
        <div style={{ display: 'flex', justifyContent: 'center', marginBottom: 16 }}>
          <div style={{ position: 'relative' }}>
            <div style={{
              width: 100, height: 100, borderRadius: '50%',
              background: `linear-gradient(135deg, ${EB.primaryLight}, ${EB.primaryDark})`,
              color: '#fff', display: 'flex', alignItems: 'center', justifyContent: 'center',
              fontWeight: 800, fontSize: 38, border: '4px solid #fff',
              boxShadow: '0 12px 28px -12px rgba(15,95,168,0.5)',
            }}>س</div>
            <div style={{
              position: 'absolute', bottom: -2, insetInlineEnd: -2,
              width: 34, height: 34, borderRadius: '50%',
              background: EB.primary, color: '#fff',
              display: 'flex', alignItems: 'center', justifyContent: 'center',
              border: '3px solid #fff',
            }}>
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M23 19a2 2 0 0 1-2 2H3a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h4l2-3h6l2 3h4a2 2 0 0 1 2 2z"/><circle cx="12" cy="13" r="4"/></svg>
            </div>
          </div>
        </div>
        <div style={{ textAlign: 'center', fontSize: 12, color: EB.primary, fontWeight: 700, marginBottom: 18 }}>تغيير الصورة الشخصية</div>

        <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
          <FormInput label="الاسم الكامل" value="سعد ميلود" />
          <FormInput label="البريد الإلكتروني" value="saad.meiloud@example.com" />
          <div>
            <label style={{ fontSize: 13, color: EB.ink2, fontWeight: 600, paddingInlineStart: 4, display: 'block', marginBottom: 6 }}>رقم الهاتف</label>
            <PhoneInput value="32 81 67 79" />
          </div>
          <SelectInput label="المسار الدراسي" value="BEPC — ختم الدروس الإعدادية" />
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
            <SelectInput label="الفرع / الشعبة" value="5D — علوم" />
            <SelectInput label="المدينة" value="نواكشوط" />
          </div>

          {/* danger zone */}
          <div style={{
            marginTop: 10, padding: 14,
            background: '#FFF5F5', border: `1px solid #F3C4C7`,
            borderRadius: 14,
          }}>
            <div style={{ fontSize: 13, fontWeight: 800, color: EB.danger, marginBottom: 4 }}>منطقة حساسة</div>
            <div style={{ fontSize: 11.5, color: '#8C1F26', marginBottom: 10, lineHeight: 1.5 }}>تغيير كلمة المرور أو حذف الحساب — لا يمكن التراجع.</div>
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 8 }}>
              <div style={{ background: '#fff', border: `1.5px solid ${EB.danger}`, color: EB.danger, paddingBlock: 10, borderRadius: 12, textAlign: 'center', fontSize: 12, fontWeight: 700 }}>تغيير كلمة المرور</div>
              <div style={{ background: '#fff', border: `1.5px solid ${EB.danger}`, color: EB.danger, paddingBlock: 10, borderRadius: 12, textAlign: 'center', fontSize: 12, fontWeight: 700 }}>حذف الحساب</div>
            </div>
          </div>

          <div style={{ display: 'grid', gridTemplateColumns: '1fr 2fr', gap: 10, marginTop: 8 }}>
            <PrimaryButton variant="outline">إلغاء</PrimaryButton>
            <PrimaryButton icon={<CheckIcon size={16}/>}>حفظ التعديلات</PrimaryButton>
          </div>
        </div>
      </div>
    </ScreenShell>
  );
}

// ─── DS BOARD 1: Type scale & spacing ─────────────────────────
function TypeScaleBoard() {
  const scale = [
    { label: 'Display', size: 32, weight: 900, sample: 'مدرستي' },
    { label: 'H1 / Hero', size: 24, weight: 800, sample: 'اختر مسارك' },
    { label: 'H2 / Section', size: 19, weight: 800, sample: 'الدروس المرئية' },
    { label: 'H3 / Card', size: 16, weight: 700, sample: 'الرياضيات' },
    { label: 'Body', size: 14, weight: 500, sample: 'هذا النص الأساسي للقراءة' },
    { label: 'Caption', size: 12, weight: 600, sample: 'تبقى 4د 32ث' },
    { label: 'Micro', size: 10, weight: 700, sample: 'BEPC · 5D' },
  ];
  return (
    <div style={{
      width: 600, height: PHONE_H + 16,
      background: '#fff', borderRadius: 36, padding: 28,
      direction: 'rtl', fontFamily: 'Tajawal',
      border: `1px solid ${EB.line}`,
      boxShadow: '0 20px 40px -30px rgba(20,30,60,0.3)',
      display: 'flex', flexDirection: 'column', gap: 16, overflow: 'hidden',
    }}>
      <div>
        <div style={{ fontSize: 11, color: EB.muted, letterSpacing: 2, fontFamily: 'Inter', marginBottom: 4 }}>TYPOGRAPHY</div>
        <div style={{ fontSize: 26, fontWeight: 800, color: EB.ink }}>الخطوط والأحجام</div>
        <div style={{ fontSize: 13, color: EB.muted, marginTop: 4 }}>Tajawal · العربية &nbsp;·&nbsp; Inter · أرقام و Latin</div>
      </div>

      <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
        {scale.map(s => (
          <div key={s.label} style={{
            display: 'flex', alignItems: 'baseline', gap: 14,
            paddingBlock: 10, borderBottom: `1px dashed ${EB.line}`,
          }}>
            <div style={{ minWidth: 110, fontSize: 11, color: EB.muted, fontWeight: 600 }}>
              <div>{s.label}</div>
              <div style={{ fontFamily: 'Inter', color: EB.ink2, marginTop: 2 }}>{s.size}px / {s.weight}</div>
            </div>
            <div style={{ flex: 1, fontSize: s.size, fontWeight: s.weight, color: EB.ink, lineHeight: 1.2 }}>{s.sample}</div>
          </div>
        ))}
      </div>

      <div>
        <div style={{ fontSize: 11, color: EB.muted, letterSpacing: 1.5, fontFamily: 'Inter', marginBottom: 8 }}>SPACING · 4PT GRID</div>
        <div style={{ display: 'flex', gap: 8, alignItems: 'flex-end' }}>
          {[4, 8, 12, 16, 20, 24, 32].map(n => (
            <div key={n} style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 4 }}>
              <div style={{ width: n, height: n, background: EB.primary, borderRadius: 4 }}/>
              <span style={{ fontFamily: 'Inter', fontSize: 10, color: EB.muted, fontWeight: 700 }}>{n}</span>
            </div>
          ))}
        </div>
      </div>

      <div>
        <div style={{ fontSize: 11, color: EB.muted, letterSpacing: 1.5, fontFamily: 'Inter', marginBottom: 8 }}>RADIUS</div>
        <div style={{ display: 'flex', gap: 10, alignItems: 'flex-end' }}>
          {[8, 12, 14, 16, 20, 999].map(n => (
            <div key={n} style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 4 }}>
              <div style={{
                width: 48, height: 48, background: EB.primarySoft,
                border: `2px solid ${EB.primary}`,
                borderRadius: n, color: EB.primary,
                display: 'flex', alignItems: 'center', justifyContent: 'center',
                fontFamily: 'Inter', fontSize: 11, fontWeight: 800,
              }}>{n}</div>
              <span style={{ fontFamily: 'Inter', fontSize: 10, color: EB.muted, fontWeight: 700 }}>{n === 999 ? 'pill' : n + 'px'}</span>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}

// ─── DS BOARD 2: Form elements & states ──────────────────────
function FormStatesBoard() {
  return (
    <div style={{
      width: 600, height: PHONE_H + 16,
      background: '#fff', borderRadius: 36, padding: 28,
      direction: 'rtl', fontFamily: 'Tajawal',
      border: `1px solid ${EB.line}`,
      boxShadow: '0 20px 40px -30px rgba(20,30,60,0.3)',
      display: 'flex', flexDirection: 'column', gap: 14, overflow: 'auto',
    }}>
      <div>
        <div style={{ fontSize: 11, color: EB.muted, letterSpacing: 2, fontFamily: 'Inter', marginBottom: 4 }}>FORMS & INPUTS</div>
        <div style={{ fontSize: 22, fontWeight: 800, color: EB.ink }}>حقول الإدخال وحالاتها</div>
      </div>

      <FormInput label="عادي (Default)" placeholder="أدخل النص..." />
      <FormInput label="ممتلئ (Filled)" value="سعد ميلود" />
      <FormInput label="نشط (Focused)" value="جاري الكتابة" focused />
      <FormInput label="خطأ (Error)" value="بريد غير صحيح" error="يجب أن يحتوي على @" />
      <PhoneInput value="32 81 67 79" />
      <SelectInput label="قائمة منسدلة" value="نواكشوط" />

      {/* checkbox / radio */}
      <div>
        <div style={{ fontSize: 13, color: EB.ink2, fontWeight: 600, marginBottom: 6 }}>اختيارات</div>
        <div style={{ display: 'flex', gap: 14 }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
            <div style={{ width: 22, height: 22, borderRadius: 6, background: EB.primary, display: 'flex', alignItems: 'center', justifyContent: 'center', color: '#fff' }}><CheckIcon size={14}/></div>
            <span style={{ fontSize: 13, color: EB.ink }}>مفعّل</span>
          </div>
          <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
            <div style={{ width: 22, height: 22, borderRadius: 6, background: '#fff', border: `1.5px solid ${EB.line}` }}/>
            <span style={{ fontSize: 13, color: EB.ink2 }}>غير مفعّل</span>
          </div>
          <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
            <div style={{ width: 22, height: 22, borderRadius: '50%', border: `2px solid ${EB.primary}`, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              <div style={{ width: 10, height: 10, borderRadius: '50%', background: EB.primary }}/>
            </div>
            <span style={{ fontSize: 13, color: EB.ink }}>راديو</span>
          </div>
          <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
            <div style={{ width: 38, height: 22, borderRadius: 999, background: EB.primary, position: 'relative' }}>
              <div style={{ position: 'absolute', insetInlineStart: 18, top: 2, width: 18, height: 18, borderRadius: '50%', background: '#fff' }}/>
            </div>
            <span style={{ fontSize: 13, color: EB.ink }}>تبديل</span>
          </div>
        </div>
      </div>

      {/* buttons row */}
      <div>
        <div style={{ fontSize: 13, color: EB.ink2, fontWeight: 600, marginBottom: 8 }}>الأزرار وحالاتها</div>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
          <PrimaryButton>زر رئيسي · ضغط</PrimaryButton>
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 8 }}>
            <PrimaryButton variant="outline">إطار</PrimaryButton>
            <PrimaryButton variant="ghost">خفيف</PrimaryButton>
          </div>
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 8 }}>
            <PrimaryButton variant="accent">تأكيد</PrimaryButton>
            <div style={{
              background: '#E5E7EB', color: '#9CA3AF',
              borderRadius: 16, minHeight: 52,
              display: 'flex', alignItems: 'center', justifyContent: 'center',
              fontFamily: 'Tajawal', fontWeight: 700, fontSize: 17,
            }}>معطّل</div>
          </div>
        </div>
      </div>

      {/* badges */}
      <div>
        <div style={{ fontSize: 13, color: EB.ink2, fontWeight: 600, marginBottom: 8 }}>الشارات</div>
        <div style={{ display: 'flex', gap: 6, flexWrap: 'wrap' }}>
          {[
            { l: 'جديد',    bg: EB.primarySoft, c: EB.primary },
            { l: 'مكتمل',   bg: '#D8F3E1', c: EB.success },
            { l: 'مهم',     bg: EB.accentSoft, c: '#B47711' },
            { l: 'متأخر',   bg: '#FEE2E2', c: EB.danger },
            { l: 'BEPC 2024', bg: '#F3F4F6', c: EB.ink2 },
          ].map(b => (
            <div key={b.l} style={{
              background: b.bg, color: b.c,
              paddingInline: 10, paddingBlock: 5, borderRadius: 999,
              fontSize: 11, fontWeight: 700,
            }}>{b.l}</div>
          ))}
        </div>
      </div>
    </div>
  );
}

// ─── EMPTY STATE Screen ───────────────────────────────────────
function EmptyStatesScreen() {
  const states = [
    {
      icon: <DownloadIcon size={32}/>,
      title: 'لا توجد دروس محملة',
      body: 'حمّل دروسك المفضلة لمشاهدتها بدون إنترنت.',
      cta: 'تصفح الدروس',
      color: EB.primary,
    },
    {
      icon: <svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M19 21l-7-4-7 4V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2z"/></svg>,
      title: 'لا توجد عناصر في المفضلة',
      body: 'اضغط ⭐ بجانب أي درس أو تمرين لإضافته.',
      cta: 'اكتشف الدروس',
      color: EB.accent,
    },
    {
      icon: <SearchIcon size={32}/>,
      title: 'لا نتائج مطابقة',
      body: 'جرّب كلمات مختلفة أو أزل بعض الفلاتر.',
      cta: 'مسح البحث',
      color: EB.muted,
    },
  ];
  return (
    <ScreenShell>
      <AppHeader title="الحالات الفارغة" />
      <div style={{ padding: 16, display: 'flex', flexDirection: 'column', gap: 14 }}>
        {states.map((s, i) => (
          <div key={i} style={{
            background: '#fff', border: `1px solid ${EB.line}`,
            borderRadius: 20, padding: 22,
            display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 10,
            textAlign: 'center',
          }}>
            <div style={{
              width: 80, height: 80, borderRadius: '50%',
              background: s.color + '15', color: s.color,
              display: 'flex', alignItems: 'center', justifyContent: 'center',
              position: 'relative',
            }}>
              {s.icon}
              <div style={{
                position: 'absolute', top: -4, insetInlineEnd: -4,
                width: 28, height: 28, borderRadius: '50%',
                background: EB.accent, color: '#fff',
                display: 'flex', alignItems: 'center', justifyContent: 'center',
                fontFamily: 'Inter', fontWeight: 800, fontSize: 14,
                border: '3px solid #fff',
              }}>0</div>
            </div>
            <div style={{ fontWeight: 800, fontSize: 15, color: EB.ink }}>{s.title}</div>
            <div style={{ fontSize: 12.5, color: EB.muted, lineHeight: 1.6, maxWidth: 260 }}>{s.body}</div>
            <div style={{
              marginTop: 4, background: s.color, color: '#fff',
              paddingInline: 18, paddingBlock: 9, borderRadius: 12,
              fontSize: 12.5, fontWeight: 700,
            }}>{s.cta}</div>
          </div>
        ))}
      </div>
    </ScreenShell>
  );
}

// ─── LOADING STATE Screen ─────────────────────────────────────
function LoadingStatesScreen() {
  const skel = (w, h, r = 8) => (
    <div style={{
      width: w, height: h, borderRadius: r,
      background: 'linear-gradient(90deg, #ECEFF4 25%, #F5F7FA 50%, #ECEFF4 75%)',
    }}/>
  );
  return (
    <ScreenShell>
      <AppHeader title="حالات التحميل" />
      <div style={{ padding: 16, display: 'flex', flexDirection: 'column', gap: 16 }}>
        {/* spinner block */}
        <div style={{
          background: '#fff', border: `1px solid ${EB.line}`,
          borderRadius: 20, padding: 24,
          display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 12,
        }}>
          <div style={{ position: 'relative', width: 56, height: 56 }}>
            <div style={{
              position: 'absolute', inset: 0, borderRadius: '50%',
              border: `4px solid ${EB.primarySoft}`,
            }}/>
            <div style={{
              position: 'absolute', inset: 0, borderRadius: '50%',
              border: `4px solid ${EB.primary}`,
              borderTopColor: 'transparent', borderInlineEndColor: 'transparent',
              transform: 'rotate(45deg)',
            }}/>
          </div>
          <div style={{ fontSize: 13, fontWeight: 700, color: EB.ink }}>جاري تحميل الدروس...</div>
          <div style={{ fontSize: 11, color: EB.muted }}>قد يستغرق ذلك بضع ثوانٍ</div>
        </div>

        {/* skeleton lesson card */}
        <div>
          <div style={{ fontSize: 12, fontWeight: 700, color: EB.muted, marginBottom: 8 }}>Skeleton — بطاقة درس</div>
          <div style={{
            background: '#fff', border: `1px solid ${EB.line}`,
            borderRadius: 16, padding: 12,
            display: 'flex', gap: 12, alignItems: 'center',
          }}>
            {skel(76, 56, 12)}
            <div style={{ flex: 1, display: 'flex', flexDirection: 'column', gap: 6 }}>
              {skel('80%', 14)}
              {skel('50%', 12)}
              {skel('30%', 10)}
            </div>
          </div>
        </div>

        {/* skeleton subject grid */}
        <div>
          <div style={{ fontSize: 12, fontWeight: 700, color: EB.muted, marginBottom: 8 }}>Skeleton — شبكة المواد</div>
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
            {[0,1,2,3].map(i => (
              <div key={i} style={{
                aspectRatio: '1 / 1.08', borderRadius: 18,
                background: '#fff', border: `1px solid ${EB.line}`,
                padding: 12, display: 'flex', flexDirection: 'column', justifyContent: 'space-between',
              }}>
                {skel(40, 40, 10)}
                <div style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
                  {skel('60%', 12)}
                  {skel('100%', 5, 999)}
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* progress bar */}
        <div>
          <div style={{ fontSize: 12, fontWeight: 700, color: EB.muted, marginBottom: 8 }}>تحميل ملف</div>
          <div style={{
            background: '#fff', border: `1px solid ${EB.line}`,
            borderRadius: 14, padding: 14,
          }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 6 }}>
              <span style={{ fontSize: 13, fontWeight: 700, color: EB.ink, fontFamily: 'Inter, Tajawal' }}>BEPC_2017_Math.pdf</span>
              <span style={{ fontSize: 12, color: EB.primary, fontFamily: 'Inter', fontWeight: 700 }}>72%</span>
            </div>
            <ProgressBar value={72} height={6}/>
            <div style={{ fontSize: 11, color: EB.muted, marginTop: 6 }}>2.4 م.ب من 3.3 م.ب · 3 ثوان متبقية</div>
          </div>
        </div>
      </div>
    </ScreenShell>
  );
}

// ─── ERROR STATE Screen ──────────────────────────────────────
function ErrorStatesScreen() {
  return (
    <ScreenShell>
      <AppHeader title="حالات الخطأ" />
      <div style={{ padding: 16, display: 'flex', flexDirection: 'column', gap: 14 }}>
        {/* network error */}
        <div style={{
          background: '#fff', border: `1px solid ${EB.line}`,
          borderRadius: 20, padding: 22,
          display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 10,
          textAlign: 'center',
        }}>
          <div style={{
            width: 76, height: 76, borderRadius: '50%',
            background: '#FFE5E0', color: EB.danger,
            display: 'flex', alignItems: 'center', justifyContent: 'center',
          }}>
            <svg width="34" height="34" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M1 1l22 22"/><path d="M16.7 16.7A5 5 0 1 1 12 11"/><path d="M3 7s4-4 9-4M21 7a16 16 0 0 0-2.3-1.8"/></svg>
          </div>
          <div style={{ fontWeight: 800, fontSize: 16, color: EB.ink }}>لا يوجد اتصال بالإنترنت</div>
          <div style={{ fontSize: 12.5, color: EB.muted, lineHeight: 1.6, maxWidth: 260 }}>تأكد من اتصالك ثم حاول مرة أخرى. يمكنك تصفح الدروس المحملة دون اتصال.</div>
          <div style={{ display: 'flex', gap: 8, marginTop: 4 }}>
            <div style={{ background: EB.primary, color: '#fff', paddingInline: 18, paddingBlock: 9, borderRadius: 12, fontSize: 12.5, fontWeight: 700 }}>إعادة المحاولة</div>
            <div style={{ background: EB.primarySoft, color: EB.primary, paddingInline: 18, paddingBlock: 9, borderRadius: 12, fontSize: 12.5, fontWeight: 700 }}>الدروس المحملة</div>
          </div>
        </div>

        {/* inline form errors */}
        <div style={{
          background: '#FFF5F5', border: `1px solid #F3C4C7`,
          borderRadius: 14, padding: 14,
          display: 'flex', gap: 10, alignItems: 'flex-start',
        }}>
          <div style={{
            width: 28, height: 28, borderRadius: '50%',
            background: EB.danger, color: '#fff',
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            flexShrink: 0,
          }}>
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5"><path d="M12 8v4M12 16h.01"/></svg>
          </div>
          <div style={{ flex: 1 }}>
            <div style={{ fontSize: 13, fontWeight: 800, color: '#8C1F26', marginBottom: 2 }}>فشل إنشاء الحساب</div>
            <div style={{ fontSize: 12, color: '#8C1F26', lineHeight: 1.6 }}>رقم الهاتف مسجل مسبقا. حاول تسجيل الدخول بدلا من ذلك.</div>
          </div>
        </div>

        {/* validation example */}
        <div>
          <div style={{ fontSize: 12, fontWeight: 700, color: EB.muted, marginBottom: 8 }}>أخطاء التحقق في النموذج</div>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
            <FormInput label="البريد الإلكتروني" value="saad@" error="صيغة البريد غير صحيحة" />
            <FormInput label="كلمة المرور" value="123" error="يجب أن تكون 6 أحرف على الأقل" />
          </div>
        </div>

        {/* toast */}
        <div>
          <div style={{ fontSize: 12, fontWeight: 700, color: EB.muted, marginBottom: 8 }}>إشعار خاطف (Toast)</div>
          <div style={{
            background: EB.ink, color: '#fff',
            borderRadius: 14, padding: '14px 16px',
            display: 'flex', alignItems: 'center', gap: 12,
            boxShadow: '0 14px 28px -16px rgba(0,0,0,0.4)',
          }}>
            <div style={{ width: 30, height: 30, borderRadius: '50%', background: EB.success, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              <CheckIcon size={16}/>
            </div>
            <div style={{ flex: 1 }}>
              <div style={{ fontSize: 13, fontWeight: 700 }}>تم حفظ التعديلات</div>
              <div style={{ fontSize: 11, opacity: 0.7 }}>تم تحديث بياناتك الشخصية بنجاح</div>
            </div>
            <span style={{ fontSize: 18, opacity: 0.5 }}>×</span>
          </div>
        </div>

        {/* 404 illustration mini */}
        <div style={{
          background: ebGradient, color: '#fff',
          borderRadius: 20, padding: 20,
          display: 'flex', alignItems: 'center', gap: 14,
          boxShadow: '0 14px 28px -18px rgba(15,95,168,0.55)',
        }}>
          <div style={{ fontFamily: 'Inter', fontWeight: 900, fontSize: 44, lineHeight: 1 }}>404</div>
          <div style={{ flex: 1 }}>
            <div style={{ fontWeight: 800, fontSize: 15, marginBottom: 4 }}>الصفحة غير موجودة</div>
            <div style={{ fontSize: 12, opacity: 0.9 }}>الرابط الذي حاولت فتحه غير صالح أو تم حذفه.</div>
          </div>
        </div>
      </div>
    </ScreenShell>
  );
}

Object.assign(window, {
  SubjectsListScreen, EditProfileScreen,
  TypeScaleBoard, FormStatesBoard,
  EmptyStatesScreen, LoadingStatesScreen, ErrorStatesScreen,
});
