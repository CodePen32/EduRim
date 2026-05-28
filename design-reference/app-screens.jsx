/* eslint-disable */
// ─────────────────────────────────────────────────────────────
// مدرستي — Screen designs
// ─────────────────────────────────────────────────────────────

const ScreenShell = ({ children, header, nav, scroll = true, bg = EB.bg }) => (
  <div style={{
    width: '100%', height: '100%', display: 'flex', flexDirection: 'column',
    background: bg, direction: 'rtl',
    fontFamily: 'Tajawal, sans-serif',
  }}>
    {header}
    <div style={{ flex: 1, overflow: scroll ? 'auto' : 'hidden', position: 'relative' }}>
      {children}
    </div>
    {nav}
  </div>
);

// ─── 1. Login ─────────────────────────────────────────────────
function LoginScreen() {
  return (
    <ScreenShell bg="#fff">
      <div style={{
        position: 'absolute', inset: 0, pointerEvents: 'none',
        background: `radial-gradient(ellipse at 50% -10%, ${EB.primarySoft}, transparent 55%)`,
      }}/>
      <div style={{ padding: 24, paddingTop: 56, display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 24, position: 'relative' }}>
        <EBLogo size={86} />
        <div style={{ textAlign: 'center' }}>
          <div style={{ fontWeight: 800, fontSize: 24, color: EB.ink, marginBottom: 4 }}>مرحبا بعودتك</div>
          <div style={{ fontSize: 14, color: EB.muted }}>سجل الدخول لمتابعة دروسك</div>
        </div>

        <div style={{ width: '100%', display: 'flex', flexDirection: 'column', gap: 14, marginTop: 4 }}>
          <PhoneInput value="32 81 67 79" />
          <FormInput
            value="••••••••"
            placeholder="كلمة المرور"
            icon={null}
            leading={<div style={{ color: EB.muted }}><EyeIcon /></div>}
          />

          <PrimaryButton>تسجيل الدخول</PrimaryButton>
          <PrimaryButton variant="outline">إنشاء حساب</PrimaryButton>

          <div style={{ display: 'flex', justifyContent: 'space-between', marginTop: 4, paddingInline: 6 }}>
            <a style={{ color: EB.primary, fontSize: 13, fontWeight: 600 }}>نسيت كلمة المرور؟</a>
            <a style={{ color: EB.muted, fontSize: 13, fontWeight: 600 }}>الدخول كزائر</a>
          </div>

          <div style={{
            marginTop: 18,
            background: EB.primarySoft, color: EB.primary,
            paddingBlock: 12, paddingInline: 14, borderRadius: 14,
            display: 'flex', alignItems: 'center', justifyContent: 'space-between',
          }}>
            <ChevRtl color={EB.primary} />
            <span style={{ fontSize: 13, fontWeight: 700 }}>طريقة استخدام التطبيق</span>
          </div>
        </div>
      </div>
    </ScreenShell>
  );
}

// ─── 2. Sign up ───────────────────────────────────────────────
function SignupScreen() {
  return (
    <ScreenShell>
      <AppHeader title="إنشاء حساب" />
      <div style={{ padding: 18, paddingBottom: 28, display: 'flex', flexDirection: 'column', gap: 12 }}>
        <div style={{ display: 'flex', justifyContent: 'center', marginBlock: 4 }}>
          <EBLogo size={64} />
        </div>
        <div style={{ textAlign: 'center', fontSize: 13, color: EB.muted, marginBottom: 4 }}>
          ١ من ٢ — معلوماتك الأساسية
        </div>

        <FormInput label="الاسم الكامل" value="سعد ميلود" />
        <FormInput label="البريد الإلكتروني" value="saad.meiloud@example.com" />
        <div>
          <label style={{ fontSize: 13, color: EB.ink2, fontWeight: 600, paddingInlineStart: 4, display: 'block', marginBottom: 6 }}>رقم الهاتف</label>
          <PhoneInput value="32 81 67 79" />
        </div>
        <SelectInput label="السنة الدراسية" value="ختم الدروس الإعدادية (BEPC)" />
        <div>
          <label style={{ fontSize: 13, color: EB.ink2, fontWeight: 600, paddingInlineStart: 4, display: 'block', marginBottom: 6 }}>المسار الدراسي</label>
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: 8 }}>
            {[
              { id: 'concours', label: 'Concours', sub: 'الابتدائية' },
              { id: 'bepc',     label: 'BEPC',     sub: 'الإعدادية', active: true },
              { id: 'bac',      label: 'BAC',      sub: 'الباكالوريا' },
            ].map(t => (
              <div key={t.id} style={{
                background: t.active ? EB.primary : '#fff',
                color: t.active ? '#fff' : EB.ink,
                border: t.active ? 'none' : `1.5px solid ${EB.line}`,
                borderRadius: 12, padding: 10,
                display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 2,
                boxShadow: t.active ? '0 8px 18px -10px rgba(15,95,168,0.55)' : 'none',
              }}>
                <span style={{ fontFamily: 'Inter', fontWeight: 800, fontSize: 13 }}>{t.label}</span>
                <span style={{ fontSize: 10.5, opacity: t.active ? 0.85 : 0.6 }}>{t.sub}</span>
              </div>
            ))}
          </div>
        </div>
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
          <SelectInput label="الفرع / الشعبة" value="5D — علوم" />
          <SelectInput label="المدينة" value="نواكشوط" />
        </div>

        <div>
          <label style={{ fontSize: 13, color: EB.ink2, fontWeight: 600, paddingInlineStart: 4, display: 'block', marginBottom: 6 }}>الجنس</label>
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
            <div style={{
              background: EB.primary, color: '#fff',
              minHeight: 48, borderRadius: 14,
              display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8,
              fontWeight: 700,
            }}><CheckIcon size={16}/> ذكر</div>
            <div style={{
              background: '#fff', color: EB.ink2,
              border: `1.5px solid ${EB.line}`,
              minHeight: 48, borderRadius: 14,
              display: 'flex', alignItems: 'center', justifyContent: 'center',
              fontWeight: 600,
            }}>أنثى</div>
          </div>
        </div>

        <FormInput label="كلمة المرور" value="••••••••" leading={<div style={{ color: EB.muted }}><EyeOff /></div>} />
        <FormInput label="تأكيد كلمة المرور" value="••••••••" focused leading={<div style={{ color: EB.primary }}><EyeIcon /></div>} />

        <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginTop: 6 }}>
          <div style={{
            width: 22, height: 22, borderRadius: 6,
            background: EB.primary, display: 'flex', alignItems: 'center', justifyContent: 'center',
          }}><CheckIcon size={14}/></div>
          <div style={{ fontSize: 12, color: EB.ink2, lineHeight: 1.5 }}>
            أوافق على <span style={{ color: EB.primary, fontWeight: 700 }}>شروط الاستخدام</span> و <span style={{ color: EB.primary, fontWeight: 700 }}>سياسة الخصوصية</span>
          </div>
        </div>

        <PrimaryButton style={{ marginTop: 8 }}>إنشاء حساب</PrimaryButton>

        <div style={{ textAlign: 'center', fontSize: 13, color: EB.muted, marginTop: 4 }}>
          لديك حساب؟ <span style={{ color: EB.primary, fontWeight: 700 }}>سجل دخولك</span>
        </div>
      </div>
    </ScreenShell>
  );
}

// ─── 3. Home ──────────────────────────────────────────────────
function HomeScreen() {
  return (
    <ScreenShell nav={<BottomNav active="home" />}>
      <AppHeader title="مدرستي" showBell showMenu variant="home" />
      <div style={{ padding: 16, paddingBottom: 24 }}>
        {/* greeting */}
        <div style={{
          background: '#fff', borderRadius: 18,
          padding: 14, display: 'flex', alignItems: 'center', gap: 12,
          marginTop: -8, marginBottom: 12,
          boxShadow: '0 10px 24px -16px rgba(20,30,60,0.2)',
          border: `1px solid ${EB.line}`,
        }}>
          <div style={{
            width: 44, height: 44, borderRadius: 14,
            background: EB.primarySoft, color: EB.primary,
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            fontFamily: 'Tajawal', fontWeight: 800, fontSize: 18,
          }}>س</div>
          <div style={{ flex: 1 }}>
            <div style={{ fontSize: 12, color: EB.muted }}>السلام عليكم 👋</div>
            <div style={{ fontSize: 15, fontWeight: 800, color: EB.ink }}>سعد ميلود</div>
          </div>
          <div style={{
            background: EB.accentSoft, color: '#B47711',
            paddingInline: 10, paddingBlock: 6, borderRadius: 999,
            fontSize: 11, fontWeight: 700,
          }}>BEPC · 5D</div>
        </div>

        {/* current track strip */}
        <div style={{
          background: `linear-gradient(95deg, ${EB.primarySoft}, #EAF1FA)`,
          borderRadius: 14, padding: 12, paddingInline: 14,
          display: 'flex', alignItems: 'center', gap: 10,
          marginBottom: 14, border: `1px solid #DCE7F4`,
        }}>
          <div style={{
            width: 36, height: 36, borderRadius: 10,
            background: '#fff', color: EB.primary,
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            border: `1.5px solid ${EB.primary}30`,
          }}>
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M3 9l9-6 9 6v11a1 1 0 0 1-1 1h-4v-7H8v7H4a1 1 0 0 1-1-1z"/></svg>
          </div>
          <div style={{ flex: 1 }}>
            <div style={{ fontSize: 10.5, color: EB.muted, fontWeight: 600 }}>المسار الحالي</div>
            <div style={{ fontSize: 13.5, fontWeight: 800, color: EB.ink }}>BEPC · ختم الدروس الإعدادية</div>
          </div>
          <div style={{
            background: '#fff', color: EB.primary,
            paddingInline: 12, paddingBlock: 7, borderRadius: 10,
            fontSize: 11.5, fontWeight: 700,
            border: `1.5px solid ${EB.primary}`,
          }}>تغيير المسار</div>
        </div>

        {/* hero banner */}
        <div style={{
          borderRadius: 22, overflow: 'hidden',
          background: ebGradient,
          padding: 18, paddingInlineStart: 100, color: '#fff',
          position: 'relative', minHeight: 142,
        }}>
          {/* deco stripes */}
          <svg viewBox="0 0 200 200" style={{ position: 'absolute', insetInlineStart: -20, top: -20, width: 180, height: 180, opacity: 0.18 }}>
            <g stroke="#fff" fill="none" strokeWidth="1.5">
              <circle cx="60" cy="60" r="30"/>
              <circle cx="60" cy="60" r="50"/>
              <circle cx="60" cy="60" r="70"/>
            </g>
          </svg>
          {/* graduate illustration placeholder */}
          <div style={{
            position: 'absolute', insetInlineStart: 14, bottom: 12,
            width: 78, height: 100, borderRadius: 12,
            background: 'rgba(255,255,255,0.16)',
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            border: '1.5px dashed rgba(255,255,255,0.45)',
          }}>
            <svg width="44" height="44" viewBox="0 0 24 24" fill="#fff">
              <path d="M22 9L12 4 2 9l10 5 10-5zM6 11.4v4.6l6 3 6-3v-4.6"/>
              <circle cx="20" cy="13" r="0.8"/>
            </svg>
          </div>
          <div style={{ textAlign: 'right' }}>
            <div style={{ fontSize: 12, opacity: 0.85, marginBottom: 4 }}>تحضير</div>
            <div style={{ fontSize: 22, fontWeight: 800, lineHeight: 1.15 }}>ختم الدروس<br/>الإعدادية</div>
            <div style={{
              display: 'inline-flex', alignItems: 'center', gap: 6, marginTop: 10,
              background: 'rgba(255,255,255,0.18)',
              paddingInline: 12, paddingBlock: 6, borderRadius: 999,
              fontFamily: 'Inter, sans-serif', fontSize: 11, fontWeight: 700, letterSpacing: 1,
            }}>BREVET · 2026</div>
          </div>
        </div>

        {/* quick stats */}
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: 8, marginTop: 14 }}>
          {[
            { l: 'الدروس', v: '128', i: <TrophyIcon size={16}/> },
            { l: 'الفيديوهات', v: '64', i: <PlayIcon size={16}/> },
            { l: 'هذا الأسبوع', v: '4س 12د', i: <ClockIcon size={16}/> },
          ].map((s,i) => (
            <div key={i} style={{
              background: '#fff', borderRadius: 14, padding: 12,
              border: `1px solid ${EB.line}`,
              display: 'flex', flexDirection: 'column', gap: 4,
            }}>
              <div style={{ color: EB.primary }}>{s.i}</div>
              <div style={{ fontSize: 16, fontWeight: 800, color: EB.ink, fontFamily: 'Tajawal' }}>{s.v}</div>
              <div style={{ fontSize: 11, color: EB.muted }}>{s.l}</div>
            </div>
          ))}
        </div>

        <SectionTitle action="عرض الكل">واصل التعلم</SectionTitle>
        <div style={{
          background: '#fff', borderRadius: 18,
          border: `1px solid ${EB.line}`,
          padding: 12, display: 'flex', alignItems: 'center', gap: 12,
          boxShadow: '0 10px 24px -18px rgba(20,30,60,0.2)',
        }}>
          <div style={{
            width: 72, height: 72, borderRadius: 14,
            background: `linear-gradient(135deg, #B8C6D8, #6E8AA8)`,
            position: 'relative', overflow: 'hidden', flexShrink: 0,
          }}>
            <div style={{
              position: 'absolute', inset: 0,
              display: 'flex', alignItems: 'center', justifyContent: 'center',
            }}>
              <div style={{
                width: 32, height: 32, borderRadius: '50%',
                background: 'rgba(15,95,168,0.95)', border: '2px solid #fff',
                display: 'flex', alignItems: 'center', justifyContent: 'center',
              }}>
                <svg width="12" height="12" viewBox="0 0 24 24" fill="#fff"><path d="M8 5 L20 12 L8 19 Z"/></svg>
              </div>
            </div>
          </div>
          <div style={{ flex: 1, minWidth: 0 }}>
            <div style={{ fontSize: 11, color: EB.primary, fontWeight: 700, marginBottom: 2 }}>الرياضيات · أ. سيد المختار</div>
            <div style={{ fontSize: 14, fontWeight: 800, color: EB.ink, marginBottom: 6, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>Fonctions affines — Partie 2</div>
            <ProgressBar value={64} height={5} />
            <div style={{ display: 'flex', justifyContent: 'space-between', marginTop: 4 }}>
              <span style={{ fontSize: 10.5, color: EB.muted }}>تبقى ٤د ٣٢ث</span>
              <span style={{ fontSize: 10.5, color: EB.primary, fontWeight: 700 }}>٦٤٪</span>
            </div>
          </div>
        </div>

        <SectionTitle action="عرض الكل">المواد</SectionTitle>
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12 }}>
          <SubjectCard name="الرياضيات" icon={SubjectIcons.math} progress={42} />
          <SubjectCard name="العلوم الطبيعية" icon={SubjectIcons.science} progress={28} />
          <SubjectCard name="الفيزياء والكيمياء" icon={SubjectIcons.physics} progress={15} />
          <SubjectCard name="اللغة العربية" icon={SubjectIcons.arabic} progress={60} accent />
          <SubjectCard name="التربية الإسلامية" icon={SubjectIcons.islamic} progress={8} />
          <div style={{
            aspectRatio: '1 / 1.08', borderRadius: 22,
            border: `1.5px dashed ${EB.line}`, background: '#fff',
            display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', gap: 8,
            color: EB.muted,
          }}>
            <div style={{ width: 44, height: 44, borderRadius: 14, background: EB.primarySoft, color: EB.primary, display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 24, fontWeight: 700 }}>+</div>
            <div style={{ fontSize: 13, fontWeight: 600 }}>أضف مادة</div>
          </div>
        </div>
      </div>
    </ScreenShell>
  );
}

// ─── 4. Subject (lesson sections) ─────────────────────────────
function SubjectScreen() {
  const sections = [
    { name: 'الدروس المرئية', icon: <PlayIcon size={28}/>, progress: 35, count: '12 فيديو' },
    { name: 'الدروس المختصرة', icon: <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="#fff" strokeWidth="1.8" strokeLinecap="round"><path d="M4 4h16v16H4z"/><path d="M7 8h10M7 12h10M7 16h6"/></svg>, progress: 62, count: '8 ملخصات' },
    { name: 'تمارين محلولة', icon: <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="#fff" strokeWidth="1.8" strokeLinecap="round"><path d="M9 11l2 2 4-4"/><path d="M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0z"/></svg>, progress: 15, count: '24 تمرين' },
  ];
  return (
    <ScreenShell>
      <AppHeader title="الرياضيات" />
      <div style={{ padding: 16, display: 'flex', flexDirection: 'column', gap: 14 }}>
        {/* subject hero strip */}
        <div style={{
          background: '#fff', borderRadius: 18, padding: 14,
          display: 'flex', alignItems: 'center', gap: 12,
          border: `1px solid ${EB.line}`,
          boxShadow: '0 6px 18px -14px rgba(20,30,60,0.2)',
        }}>
          <div style={{
            width: 56, height: 56, borderRadius: 16,
            background: ebGradient, color: '#fff',
            display: 'flex', alignItems: 'center', justifyContent: 'center',
          }}>{SubjectIcons.math}</div>
          <div style={{ flex: 1 }}>
            <div style={{ fontWeight: 800, color: EB.ink, fontSize: 16 }}>الرياضيات</div>
            <div style={{ fontSize: 12, color: EB.muted, marginBottom: 6 }}>ختم الدروس الإعدادية · 5D</div>
            <ProgressBar value={42} />
            <div style={{ fontSize: 11, color: EB.muted, marginTop: 4 }}>التقدم العام ٤٢٪</div>
          </div>
        </div>

        {sections.map((s, i) => (
          <div key={i} style={{
            background: ebGradient,
            borderRadius: 20, padding: 16, color: '#fff',
            display: 'flex', flexDirection: 'column', gap: 12,
            boxShadow: '0 14px 28px -18px rgba(15,95,168,0.55)',
            position: 'relative', overflow: 'hidden',
          }}>
            <div style={{
              position: 'absolute', insetInlineStart: -20, bottom: -30,
              width: 120, height: 120, borderRadius: '50%',
              background: 'rgba(255,255,255,0.08)',
            }}/>
            <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
              <div style={{
                width: 54, height: 54, borderRadius: 14,
                background: 'rgba(255,255,255,0.18)',
                display: 'flex', alignItems: 'center', justifyContent: 'center',
              }}>{s.icon}</div>
              <div style={{ flex: 1 }}>
                <div style={{ fontWeight: 800, fontSize: 17 }}>{s.name}</div>
                <div style={{ fontSize: 12, opacity: 0.85, marginTop: 2 }}>{s.count}</div>
              </div>
              <ChevRtl color="#fff" />
            </div>
            <div>
              <ProgressBar value={s.progress} light />
              <div style={{ fontSize: 11, opacity: 0.9, marginTop: 6, fontFamily: 'Tajawal' }}>{s.progress}٪ المشاهدات</div>
            </div>
          </div>
        ))}
      </div>
    </ScreenShell>
  );
}

// ─── 5. Teachers ──────────────────────────────────────────────
function TeachersScreen() {
  const teachers = [
    { name: 'أ. سيد المختار', subject: 'الرياضيات', initials: 'س', color: '#0F5FA8', lessons: 24, rating: 4.9 },
    { name: 'أ. محمد ولد أحمد', subject: 'الفيزياء والكيمياء', initials: 'م', color: '#2E7EC9', lessons: 18, rating: 4.8 },
    { name: 'أ. خديجة بنت سالم', subject: 'اللغة العربية', initials: 'خ', color: '#F2A11A', lessons: 32, rating: 4.9 },
    { name: 'أ. أحمدو ولد بابا', subject: 'العلوم الطبيعية', initials: 'أ', color: '#1E9E6A', lessons: 21, rating: 4.7 },
    { name: 'أ. فاطمة بنت يحيى', subject: 'التربية الإسلامية', initials: 'ف', color: '#7C4DDD', lessons: 14, rating: 5.0 },
  ];
  return (
    <ScreenShell>
      <AppHeader title="الأساتذة" />
      <div style={{ padding: 16 }}>
        {/* search */}
        <div style={{
          background: '#fff', border: `1.5px solid ${EB.line}`,
          borderRadius: 14, padding: '12px 14px',
          display: 'flex', alignItems: 'center', gap: 10, marginBottom: 14,
        }}>
          <div style={{ color: EB.muted }}><SearchIcon size={18}/></div>
          <span style={{ flex: 1, fontSize: 14, color: EB.muted }}>ابحث عن أستاذ...</span>
        </div>

        <div style={{ display: 'flex', gap: 8, overflow: 'hidden', marginBottom: 14 }}>
          {['الكل','الرياضيات','الفيزياء','العلوم','العربية'].map((c,i) => (
            <div key={i} style={{
              paddingInline: 14, paddingBlock: 8, borderRadius: 999,
              background: i === 0 ? EB.primary : '#fff',
              color: i === 0 ? '#fff' : EB.ink2,
              border: i === 0 ? 'none' : `1px solid ${EB.line}`,
              fontSize: 12, fontWeight: 600, whiteSpace: 'nowrap',
            }}>{c}</div>
          ))}
        </div>

        <div style={{ fontSize: 13, color: EB.muted, marginBottom: 10 }}>{teachers.length} أستاذ متاح</div>

        <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
          {teachers.map((t, i) => (
            <div key={i} style={{
              background: '#fff', border: `1px solid ${EB.line}`,
              borderRadius: 18, padding: 12,
              display: 'flex', alignItems: 'center', gap: 12,
              boxShadow: '0 6px 16px -14px rgba(20,30,60,0.2)',
            }}>
              <div style={{ position: 'relative' }}>
                <div style={{
                  width: 56, height: 56, borderRadius: '50%',
                  background: `linear-gradient(135deg, ${t.color}, ${EB.primaryDark})`,
                  color: '#fff', display: 'flex', alignItems: 'center', justifyContent: 'center',
                  fontFamily: 'Tajawal', fontWeight: 800, fontSize: 22,
                  border: '3px solid #fff',
                  boxShadow: `0 4px 10px -4px ${t.color}99`,
                }}>{t.initials}</div>
                <div style={{
                  position: 'absolute', bottom: 0, insetInlineEnd: -2,
                  width: 16, height: 16, borderRadius: '50%',
                  background: EB.success, border: '2px solid #fff',
                }}/>
              </div>
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: 6, marginBottom: 2 }}>
                  <span style={{ fontWeight: 800, color: EB.ink, fontSize: 14 }}>{t.name}</span>
                </div>
                <div style={{ fontSize: 12, color: EB.muted, marginBottom: 6 }}>{t.subject}</div>
                <div style={{ display: 'flex', gap: 10, fontSize: 11, color: EB.ink2 }}>
                  <span style={{ display: 'inline-flex', alignItems: 'center', gap: 4 }}>
                    <svg width="12" height="12" viewBox="0 0 24 24" fill="#F2A11A"><path d="M12 2 L14.5 9 L22 9.3 L16 14 L18 21.5 L12 17 L6 21.5 L8 14 L2 9.3 L9.5 9 Z"/></svg>
                    <span style={{ fontFamily: 'Inter', fontWeight: 700 }}>{t.rating}</span>
                  </span>
                  <span style={{ color: EB.muted }}>·</span>
                  <span style={{ fontWeight: 600 }}><span style={{ fontFamily: 'Inter' }}>{t.lessons}</span> درس</span>
                </div>
              </div>
              <div style={{
                background: ebGradient, color: '#fff',
                paddingInline: 14, paddingBlock: 8, borderRadius: 12,
                fontSize: 11.5, fontWeight: 700,
                boxShadow: '0 6px 14px -8px rgba(15,95,168,0.55)',
              }}>عرض الدروس</div>
            </div>
          ))}
        </div>
      </div>
    </ScreenShell>
  );
}

// ─── 6. Units ─────────────────────────────────────────────────
function UnitsScreen() {
  const units = [
    { name: 'ملخص أ. سيد المختار', sub: '٧ وحدات · ١٢ ساعة' },
    { name: 'ملخص أ. التام', sub: '٥ وحدات · ٨ ساعات' },
    { name: 'الوحدات المشتركة', sub: '٣ وحدات · مفتوحة للجميع' },
  ];
  return (
    <ScreenShell>
      <AppHeader title="الوحدات — الرياضيات" />
      <div style={{ padding: 16 }}>
        {/* teacher header */}
        <div style={{
          background: '#fff', borderRadius: 18, padding: 14,
          display: 'flex', alignItems: 'center', gap: 12,
          border: `1px solid ${EB.line}`,
          marginBottom: 16,
        }}>
          <div style={{
            width: 52, height: 52, borderRadius: '50%',
            background: `linear-gradient(135deg, ${EB.primaryLight}, ${EB.primaryDark})`,
            color: '#fff', display: 'flex', alignItems: 'center', justifyContent: 'center',
            fontWeight: 800, fontSize: 20,
          }}>س</div>
          <div style={{ flex: 1 }}>
            <div style={{ fontSize: 12, color: EB.muted }}>الأستاذ المسؤول</div>
            <div style={{ fontWeight: 800, color: EB.ink, fontSize: 15 }}>أ. سيد المختار</div>
          </div>
          <div style={{
            background: EB.primarySoft, color: EB.primary,
            paddingInline: 12, paddingBlock: 6, borderRadius: 999,
            fontSize: 11, fontWeight: 700,
          }}>أستاذ معتمد</div>
        </div>

        <SectionTitle>اختر مجموعة الملخصات</SectionTitle>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
          {units.map((u, i) => (
            <div key={i} style={{
              background: ebGradient, color: '#fff',
              borderRadius: 18, padding: 18,
              display: 'flex', alignItems: 'center', gap: 14,
              boxShadow: '0 12px 24px -16px rgba(15,95,168,0.55)',
            }}>
              <div style={{
                width: 48, height: 48, borderRadius: 14,
                background: 'rgba(255,255,255,0.18)',
                display: 'flex', alignItems: 'center', justifyContent: 'center',
                fontFamily: 'Inter, sans-serif', fontWeight: 800, fontSize: 18,
              }}>{String(i+1).padStart(2,'0')}</div>
              <div style={{ flex: 1 }}>
                <div style={{ fontWeight: 800, fontSize: 16 }}>{u.name}</div>
                <div style={{ fontSize: 12, opacity: 0.85, marginTop: 3 }}>{u.sub}</div>
              </div>
              <ChevRtl color="#fff" />
            </div>
          ))}
        </div>
      </div>
    </ScreenShell>
  );
}

// ─── 7. Lessons list ──────────────────────────────────────────
function LessonsScreen() {
  const lessons = [
    'Nombres réels',
    'Angles inscrits et angles au centre',
    'Calcul littéral',
    'Système de deux équations à deux inconnues',
    'Géométrie analytique (Repère)',
    'Fonctions affines',
    'Théorème de Thalès',
    'Trigonométrie dans le triangle',
  ];
  return (
    <ScreenShell>
      <AppHeader title="الوحدات — الرياضيات" />
      <div style={{ padding: 16 }}>
        <div style={{
          background: '#fff', borderRadius: 16, padding: 12, paddingInline: 14,
          display: 'flex', alignItems: 'center', justifyContent: 'space-between',
          border: `1px solid ${EB.line}`, marginBottom: 14,
        }}>
          <div style={{
            background: EB.success + '22', color: EB.success,
            paddingInline: 10, paddingBlock: 4, borderRadius: 999,
            fontSize: 12, fontWeight: 700,
          }}>٣ / ٨ مكتمل</div>
          <div>
            <div style={{ fontWeight: 800, fontSize: 14, color: EB.ink }}>أ. سيد المختار</div>
            <div style={{ fontSize: 12, color: EB.muted }}>ملخص الرياضيات — BEPC</div>
          </div>
        </div>

        <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
          {lessons.map((l, i) => (
            <div key={i} style={{
              borderRadius: 16,
              background: i < 3 ? ebGradient : '#fff',
              color: i < 3 ? '#fff' : EB.ink,
              border: i < 3 ? 'none' : `1.5px solid ${EB.line}`,
              minHeight: 58, paddingInline: 14,
              display: 'flex', alignItems: 'center', gap: 12,
              boxShadow: i < 3 ? '0 10px 22px -16px rgba(15,95,168,0.55)' : 'none',
            }}>
              <div style={{
                width: 30, height: 30, borderRadius: 10,
                background: i < 3 ? 'rgba(255,255,255,0.18)' : EB.primarySoft,
                color: i < 3 ? '#fff' : EB.primary,
                display: 'flex', alignItems: 'center', justifyContent: 'center',
                fontFamily: 'Inter, sans-serif', fontSize: 12, fontWeight: 800,
              }}>{String(i+1).padStart(2,'0')}</div>
              <div style={{ flex: 1, fontWeight: 700, fontSize: 14, fontFamily: 'Inter, Tajawal, sans-serif', direction: 'ltr', textAlign: 'right' }}>{l}</div>
              {i < 3 ? <CheckIcon size={18}/> : <ChevRtl />}
            </div>
          ))}
        </div>
      </div>
    </ScreenShell>
  );
}

// ─── 8. Videos list ───────────────────────────────────────────
function VideosScreen() {
  const vids = [
    { title: 'BEPC 2017', subtitle: 'تمرين — التناسل عند الإنسان' },
    { title: 'BEPC 2018', subtitle: 'تمرين — الجهاز التناسلي' },
    { title: 'BEPC 2019', subtitle: 'تمرين — الإخصاب والتطور الجنيني' },
  ];
  return (
    <ScreenShell>
      <AppHeader title="قائمة التمارين" />
      <div style={{ padding: 16 }}>
        <div style={{
          background: '#fff', borderRadius: 16, padding: 14,
          border: `1px solid ${EB.line}`, marginBottom: 14,
          display: 'flex', alignItems: 'center', gap: 12,
        }}>
          <div style={{
            width: 44, height: 44, borderRadius: 12,
            background: ebGradient, color: '#fff',
            display: 'flex', alignItems: 'center', justifyContent: 'center',
          }}>{SubjectIcons.science}</div>
          <div style={{ flex: 1 }}>
            <div style={{ fontWeight: 800, color: EB.ink, fontSize: 15 }}>العلوم الطبيعية</div>
            <div style={{ fontSize: 12, color: EB.muted, marginTop: 2 }}>تمارين امتحانات BEPC</div>
          </div>
          <div style={{
            background: EB.success + '22', color: EB.success,
            paddingInline: 10, paddingBlock: 5, borderRadius: 999,
            fontSize: 11, fontWeight: 700,
          }}>٠ / ٧ المشاهدات</div>
        </div>

        <div style={{ marginBottom: 12 }}>
          <ProgressBar value={5} />
        </div>

        <div style={{
          background: '#fff', border: `1.5px solid ${EB.line}`,
          borderRadius: 14, padding: '12px 14px',
          display: 'flex', alignItems: 'center', gap: 10, marginBottom: 14,
        }}>
          <div style={{ color: EB.muted }}><SearchIcon size={18}/></div>
          <span style={{ flex: 1, fontSize: 14, color: EB.muted }}>ابحث في التمارين...</span>
        </div>

        <div style={{ display: 'flex', flexDirection: 'column', gap: 14 }}>
          {vids.map((v, i) => <VideoCard key={i} title={v.title} subtitle={v.subtitle} />)}
        </div>
      </div>
    </ScreenShell>
  );
}

// ─── 9. Downloaded (empty) ────────────────────────────────────
function DownloadedScreen() {
  return (
    <ScreenShell nav={<BottomNav active="down" />}>
      <AppHeader title="الدروس المحملة" onBack={false} showMenu />
      <div style={{
        flex: 1, display: 'flex', flexDirection: 'column',
        alignItems: 'center', justifyContent: 'center',
        padding: 32, gap: 20, textAlign: 'center',
        height: '100%',
      }}>
        <div style={{
          width: 140, height: 140, borderRadius: '50%',
          background: EB.primarySoft,
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          position: 'relative',
        }}>
          <div style={{
            position: 'absolute', inset: 18, borderRadius: '50%',
            background: '#fff', display: 'flex', alignItems: 'center', justifyContent: 'center',
            color: EB.primary,
          }}>
            <DownloadIcon size={52} />
          </div>
          <div style={{
            position: 'absolute', top: 4, insetInlineEnd: 8,
            width: 32, height: 32, borderRadius: '50%',
            background: EB.accent,
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            color: '#fff', fontFamily: 'Inter', fontWeight: 800, fontSize: 16,
          }}>!</div>
        </div>
        <div>
          <div style={{ fontWeight: 800, fontSize: 19, color: EB.ink, marginBottom: 6 }}>لا توجد دروس محملة بعد</div>
          <div style={{ fontSize: 13.5, color: EB.muted, lineHeight: 1.6, maxWidth: 280 }}>
            حمّل دروسك المفضلة لمشاهدتها بدون إنترنت أينما كنت.
          </div>
        </div>
        <PrimaryButton block={false} icon={<HomeIcon size={18}/>} style={{ paddingInline: 28 }}>
          تصفح الدروس
        </PrimaryButton>

        {/* helpful tips */}
        <div style={{
          background: '#fff', border: `1px solid ${EB.line}`,
          borderRadius: 16, padding: 14,
          display: 'flex', alignItems: 'center', gap: 12,
          width: '100%', maxWidth: 320, marginTop: 8,
        }}>
          <div style={{
            width: 36, height: 36, borderRadius: 10,
            background: EB.accentSoft, color: '#B47711',
            display: 'flex', alignItems: 'center', justifyContent: 'center',
          }}>
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><circle cx="12" cy="12" r="9"/><path d="M12 8v4M12 16h.01"/></svg>
          </div>
          <div style={{ flex: 1, textAlign: 'right' }}>
            <div style={{ fontSize: 13, fontWeight: 700, color: EB.ink }}>نصيحة</div>
            <div style={{ fontSize: 12, color: EB.muted, marginTop: 2 }}>اضغط على أيقونة التحميل بجانب كل فيديو</div>
          </div>
        </div>
      </div>
    </ScreenShell>
  );
}

// ─── 10. Profile ──────────────────────────────────────────────
function ProfileScreen() {
  return (
    <ScreenShell nav={<BottomNav active="me" />}>
      <AppHeader title="حسابي" showMenu />
      <div style={{ padding: 16, paddingTop: 0 }}>
        <div style={{
          background: '#fff', borderRadius: 22, padding: 18,
          marginTop: -16,
          border: `1px solid ${EB.line}`,
          boxShadow: '0 14px 28px -20px rgba(20,30,60,0.25)',
          display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 8,
        }}>
          <div style={{ position: 'relative' }}>
            <div style={{
              width: 88, height: 88, borderRadius: '50%',
              background: `linear-gradient(135deg, ${EB.primaryLight}, ${EB.primaryDark})`,
              color: '#fff', display: 'flex', alignItems: 'center', justifyContent: 'center',
              fontWeight: 800, fontSize: 34, border: '4px solid #fff',
              boxShadow: '0 10px 24px -10px rgba(15,95,168,0.5)',
            }}>س</div>
            <div style={{
              position: 'absolute', bottom: 0, insetInlineEnd: 0,
              width: 28, height: 28, borderRadius: '50%',
              background: EB.accent, color: '#fff',
              display: 'flex', alignItems: 'center', justifyContent: 'center',
              border: '3px solid #fff',
            }}><EditIcon size={14}/></div>
          </div>
          <div style={{ textAlign: 'center' }}>
            <div style={{ fontWeight: 800, fontSize: 18, color: EB.ink }}>سعد ميلود</div>
            <div style={{ fontSize: 12, color: EB.muted, fontFamily: 'Inter' }}>+222 32 81 67 79</div>
          </div>
          <div style={{
            display: 'flex', gap: 8, marginTop: 4,
          }}>
            <div style={{ background: EB.primarySoft, color: EB.primary, paddingInline: 10, paddingBlock: 5, borderRadius: 999, fontSize: 11, fontWeight: 700 }}>BEPC · 5D</div>
            <div style={{ background: EB.accentSoft, color: '#B47711', paddingInline: 10, paddingBlock: 5, borderRadius: 999, fontSize: 11, fontWeight: 700 }}>نواكشوط</div>
          </div>

          <div style={{ width: '100%', marginTop: 14 }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 6 }}>
              <span style={{ fontSize: 12, color: EB.muted }}>نسبة التقدم العامة</span>
              <span style={{ fontSize: 12, color: EB.primary, fontWeight: 700 }}>٣٨٪</span>
            </div>
            <ProgressBar value={38} height={8} />
          </div>
        </div>

        {/* info rows */}
        <div style={{
          background: '#fff', borderRadius: 18, marginTop: 14,
          border: `1px solid ${EB.line}`, overflow: 'hidden',
        }}>
          {[
            { l: 'البريد الإلكتروني', v: 'saad.meiloud@example.com', ltr: true },
            { l: 'السنة الدراسية', v: 'ختم الدروس الإعدادية' },
            { l: 'الفرع', v: '5D — علوم' },
            { l: 'المدينة', v: 'نواكشوط' },
            { l: 'تاريخ الانضمام', v: 'سبتمبر 2025' },
          ].map((r, i, a) => (
            <div key={i} style={{
              padding: 14,
              borderBottom: i < a.length - 1 ? `1px solid ${EB.line}` : 'none',
              display: 'flex', justifyContent: 'space-between', alignItems: 'center',
            }}>
              <div style={{ fontSize: 13.5, color: EB.ink, fontWeight: 600, direction: r.ltr ? 'ltr' : 'rtl', fontFamily: r.ltr ? 'Inter' : 'Tajawal' }}>{r.v}</div>
              <div style={{ fontSize: 12, color: EB.muted }}>{r.l}</div>
            </div>
          ))}
        </div>

        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10, marginTop: 14 }}>
          <PrimaryButton icon={<EditIcon size={16}/>}>تعديل الحساب</PrimaryButton>
          <PrimaryButton variant="outline" icon={<LogoutIcon size={16}/>}>تسجيل الخروج</PrimaryButton>
        </div>
      </div>
    </ScreenShell>
  );
}

// ─── 11. Calculator ───────────────────────────────────────────
function CalcScreen() {
  const subjects = [
    { name: 'الرياضيات', coef: 4, mark: 14.5 },
    { name: 'العلوم الطبيعية', coef: 3, mark: 12 },
    { name: 'الفيزياء والكيمياء', coef: 3, mark: 15 },
    { name: 'اللغة العربية', coef: 4, mark: 13 },
    { name: 'التربية الإسلامية', coef: 2, mark: 16 },
  ];
  return (
    <ScreenShell nav={<BottomNav active="calc" />}>
      <AppHeader title="حاسبة المعدل" showMenu />
      <div style={{ padding: 16 }}>
        {/* result preview */}
        <div style={{
          borderRadius: 22, padding: 18,
          background: ebGradient, color: '#fff',
          boxShadow: '0 16px 32px -18px rgba(15,95,168,0.55)',
          position: 'relative', overflow: 'hidden',
          marginBottom: 16,
        }}>
          <div style={{
            position: 'absolute', insetInlineStart: -30, top: -30,
            width: 130, height: 130, borderRadius: '50%',
            background: 'rgba(255,255,255,0.1)',
          }}/>
          <div style={{ fontSize: 12, opacity: 0.85, marginBottom: 4 }}>معدلك المتوقع</div>
          <div style={{ display: 'flex', alignItems: 'baseline', gap: 8 }}>
            <div style={{ fontFamily: 'Inter, sans-serif', fontWeight: 800, fontSize: 44, lineHeight: 1 }}>13.96</div>
            <div style={{ fontSize: 14, opacity: 0.8 }}>/ 20</div>
          </div>
          <div style={{
            display: 'inline-flex', alignItems: 'center', gap: 6, marginTop: 10,
            background: 'rgba(255,255,255,0.18)',
            paddingInline: 12, paddingBlock: 5, borderRadius: 999,
            fontSize: 12, fontWeight: 700,
          }}>
            <CheckIcon size={14}/> تقدير: جيد جدا
          </div>
        </div>

        <SectionTitle>أدخل علاماتك</SectionTitle>
        <div style={{
          background: '#fff', borderRadius: 18, padding: 6,
          border: `1px solid ${EB.line}`,
        }}>
          {subjects.map((s, i, a) => (
            <div key={i} style={{
              padding: 12,
              borderBottom: i < a.length - 1 ? `1px solid ${EB.line}` : 'none',
              display: 'flex', alignItems: 'center', gap: 12,
            }}>
              <div style={{
                width: 56, height: 44, borderRadius: 12,
                background: EB.bg, border: `1.5px solid ${EB.line}`,
                display: 'flex', alignItems: 'center', justifyContent: 'center',
                fontFamily: 'Inter, sans-serif', fontWeight: 800, fontSize: 18, color: EB.ink,
              }}>{s.mark}</div>
              <div style={{ flex: 1 }}>
                <div style={{ fontWeight: 700, color: EB.ink, fontSize: 14 }}>{s.name}</div>
                <div style={{ fontSize: 11, color: EB.muted, marginTop: 2 }}>المعامل {s.coef}</div>
              </div>
              <div style={{
                background: EB.primarySoft, color: EB.primary,
                paddingInline: 10, paddingBlock: 4, borderRadius: 999,
                fontFamily: 'Inter', fontSize: 11, fontWeight: 700,
              }}>×{s.coef}</div>
            </div>
          ))}
        </div>

        <div style={{ marginTop: 16 }}>
          <PrimaryButton icon={<CalcIcon size={18}/>}>احسب المعدل</PrimaryButton>
        </div>
      </div>
    </ScreenShell>
  );
}

Object.assign(window, {
  LoginScreen, SignupScreen, HomeScreen, SubjectScreen, TeachersScreen,
  UnitsScreen, LessonsScreen, VideosScreen, DownloadedScreen, ProfileScreen, CalcScreen,
});
