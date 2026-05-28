/* eslint-disable */
// ─────────────────────────────────────────────────────────────
// مدرستي — Additional screens (v2)
// Track selection, lesson details, video player, exercise,
// notifications, search, favorites, packages
// ─────────────────────────────────────────────────────────────

// ─── 12. Track Selection (onboarding) ─────────────────────────
function TrackSelectionScreen() {
  const tracks = [
    {
      id: 'concours',
      en: 'Concours',
      ar: 'شهادة ختم الدروس الابتدائية',
      desc: 'للتلاميذ في السنة السادسة من التعليم الأساسي',
      grade: 'الابتدائية',
      color: '#1E9E6A',
      icon: (
        <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="#fff" strokeWidth="2"><path d="M3 6l9-3 9 3-9 3z"/><path d="M3 6v8M21 6v8M6 8v6c2 1.5 4 2 6 2s4-.5 6-2V8"/></svg>
      ),
    },
    {
      id: 'bepc',
      en: 'BEPC',
      ar: 'شهادة ختم الدروس الإعدادية',
      desc: 'للتلاميذ في الصف السابع والثامن والتاسع',
      grade: 'الإعدادية',
      color: '#0F5FA8',
      active: true,
      icon: (
        <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="#fff" strokeWidth="2"><path d="M4 4h16v16H4z" strokeLinejoin="round"/><path d="M8 8h8M8 12h8M8 16h5"/></svg>
      ),
    },
    {
      id: 'bac',
      en: 'BAC',
      ar: 'الباكالوريا',
      desc: '٤ شعب: الرياضيات، العلوم، الآداب العصرية والأصلية',
      grade: 'الثانوية',
      color: '#F2A11A',
      icon: (
        <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="#fff" strokeWidth="2"><path d="M22 9L12 4 2 9l10 5 10-5z"/><path d="M6 11v5l6 3 6-3v-5"/></svg>
      ),
    },
  ];
  return (
    <ScreenShell bg="#fff">
      <div style={{
        position: 'absolute', insetInlineStart: 0, insetInlineEnd: 0, top: 0,
        height: 240, background: `radial-gradient(ellipse at 50% 0%, ${EB.primarySoft}, transparent 70%)`,
        pointerEvents: 'none',
      }}/>
      <div style={{ padding: 22, paddingTop: 56, position: 'relative' }}>
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 28 }}>
          <EBLogo size={48} />
          <span style={{ fontSize: 12, color: EB.muted, fontFamily: 'Inter', fontWeight: 600 }}>الخطوة 1 / 3</span>
        </div>
        <div style={{ marginBottom: 22 }}>
          <div style={{ fontSize: 11, color: EB.primary, fontWeight: 700, letterSpacing: 1, marginBottom: 6, fontFamily: 'Inter' }}>WELCOME · مرحبا</div>
          <div style={{ fontSize: 26, fontWeight: 900, color: EB.ink, lineHeight: 1.2, marginBottom: 8 }}>اختر مسارك الدراسي</div>
          <div style={{ fontSize: 13.5, color: EB.muted, lineHeight: 1.6 }}>
            سنخصص لك المواد والدروس والتمارين المناسبة لمستواك الدراسي.
          </div>
        </div>

        <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
          {tracks.map(t => (
            <div key={t.id} style={{
              background: t.active ? '#fff' : '#fff',
              border: t.active ? `2px solid ${EB.primary}` : `1.5px solid ${EB.line}`,
              borderRadius: 20, padding: 16,
              display: 'flex', alignItems: 'center', gap: 14,
              boxShadow: t.active ? '0 16px 32px -18px rgba(15,95,168,0.55)' : '0 6px 14px -12px rgba(20,30,60,0.2)',
              position: 'relative', overflow: 'hidden',
            }}>
              {t.active && (
                <div style={{
                  position: 'absolute', top: 10, insetInlineStart: 10,
                  background: EB.primary, color: '#fff',
                  paddingInline: 8, paddingBlock: 3, borderRadius: 6,
                  fontSize: 10, fontWeight: 700, fontFamily: 'Inter',
                }}>محدد</div>
              )}
              <div style={{
                width: 60, height: 60, borderRadius: 16,
                background: `linear-gradient(135deg, ${t.color}, ${t.color}CC)`,
                display: 'flex', alignItems: 'center', justifyContent: 'center',
                boxShadow: `0 8px 16px -8px ${t.color}88`,
                flexShrink: 0,
              }}>{t.icon}</div>
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{ display: 'flex', alignItems: 'baseline', gap: 8, marginBottom: 3 }}>
                  <span style={{ fontFamily: 'Inter', fontWeight: 800, fontSize: 18, color: EB.ink }}>{t.en}</span>
                  <span style={{ fontSize: 10.5, color: EB.muted, fontWeight: 600 }}>{t.grade}</span>
                </div>
                <div style={{ fontSize: 13.5, fontWeight: 700, color: EB.ink, marginBottom: 4 }}>{t.ar}</div>
                <div style={{ fontSize: 11.5, color: EB.muted, lineHeight: 1.5 }}>{t.desc}</div>
              </div>
              <div style={{
                width: 24, height: 24, borderRadius: '50%',
                border: `2px solid ${t.active ? EB.primary : EB.line}`,
                background: t.active ? EB.primary : 'transparent',
                display: 'flex', alignItems: 'center', justifyContent: 'center',
                flexShrink: 0,
              }}>
                {t.active && <div style={{ width: 10, height: 10, borderRadius: '50%', background: '#fff' }}/>}
              </div>
            </div>
          ))}
        </div>

        <div style={{ marginTop: 24 }}>
          <PrimaryButton icon={<ChevRtl color="#fff" size={18} />}>متابعة</PrimaryButton>
        </div>
      </div>
    </ScreenShell>
  );
}

// ─── 12b. BAC Branch Selection ────────────────────────────────
function BacBranchScreen() {
  const branches = [
    { id: 'C', name: 'شعبة الرياضيات', en: 'BAC C', desc: 'رياضيات، فيزياء، علوم', subjects: 7, color: '#0F5FA8', active: true,
      icon: <svg width="26" height="26" viewBox="0 0 24 24" fill="none" stroke="#fff" strokeWidth="2"><circle cx="6" cy="6" r="3"/><path d="M14 4h6M17 1v6"/><path d="M3 17l6 6M9 17l-6 6"/><path d="M14 17h6M14 21h6"/></svg> },
    { id: 'D', name: 'شعبة العلوم الطبيعية', en: 'BAC D', desc: 'علوم، فيزياء، رياضيات', subjects: 7, color: '#1E9E6A',
      icon: <svg width="26" height="26" viewBox="0 0 24 24" fill="none" stroke="#fff" strokeWidth="2"><path d="M9 3h6M10 3v6l-5 10a3 3 0 0 0 2.7 4.3h8.6A3 3 0 0 0 19 19l-5-10V3"/></svg> },
    { id: 'A', name: 'شعبة الآداب العصرية', en: 'BAC A', desc: 'أدب، فلسفة، لغات', subjects: 6, color: '#F2A11A',
      icon: <svg width="26" height="26" viewBox="0 0 24 24" fill="none" stroke="#fff" strokeWidth="2"><path d="M4 4v16h16V4z"/><path d="M8 8h8M8 12h8M8 16h6"/></svg> },
    { id: 'O', name: 'شعبة الآداب الأصلية', en: 'BAC O', desc: 'دراسات إسلامية، عربية', subjects: 6, color: '#7C4DDD',
      icon: <svg width="26" height="26" viewBox="0 0 24 24" fill="none" stroke="#fff" strokeWidth="2"><path d="M19 6a9 9 0 1 0 3 13 7 7 0 1 1-3-13z"/></svg> },
  ];
  return (
    <ScreenShell>
      <AppHeader title="اختر شعبة الباكالوريا" />
      <div style={{ padding: 16 }}>
        <div style={{ marginBottom: 14 }}>
          <div style={{ fontSize: 11, color: EB.primary, fontWeight: 700, letterSpacing: 1, marginBottom: 4, fontFamily: 'Inter' }}>BAC · STREAM</div>
          <div style={{ fontSize: 18, fontWeight: 800, color: EB.ink, marginBottom: 4 }}>اختر الشعبة المناسبة لك</div>
          <div style={{ fontSize: 12.5, color: EB.muted, lineHeight: 1.5 }}>ستحدد المواد والدروس التي ستظهر لك في التطبيق.</div>
        </div>

        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12 }}>
          {branches.map(b => (
            <div key={b.id} style={{
              background: '#fff',
              border: b.active ? `2px solid ${EB.primary}` : `1.5px solid ${EB.line}`,
              borderRadius: 18, padding: 14,
              display: 'flex', flexDirection: 'column', gap: 10,
              position: 'relative', overflow: 'hidden',
              boxShadow: b.active ? '0 12px 24px -16px rgba(15,95,168,0.5)' : 'none',
            }}>
              <div style={{
                width: 48, height: 48, borderRadius: 14,
                background: `linear-gradient(135deg, ${b.color}, ${b.color}CC)`,
                display: 'flex', alignItems: 'center', justifyContent: 'center',
                boxShadow: `0 6px 14px -8px ${b.color}88`,
              }}>{b.icon}</div>
              <div>
                <div style={{ fontFamily: 'Inter', fontWeight: 800, fontSize: 14, color: EB.muted, marginBottom: 2 }}>{b.en}</div>
                <div style={{ fontSize: 14, fontWeight: 800, color: EB.ink, marginBottom: 3, lineHeight: 1.25 }}>{b.name}</div>
                <div style={{ fontSize: 11, color: EB.muted, lineHeight: 1.4 }}>{b.desc}</div>
              </div>
              <div style={{
                marginTop: 'auto', paddingTop: 8,
                borderTop: `1px solid ${EB.line}`,
                display: 'flex', justifyContent: 'space-between', alignItems: 'center',
              }}>
                <span style={{ fontSize: 11, color: EB.muted }}><span style={{ fontFamily: 'Inter', fontWeight: 700, color: EB.ink }}>{b.subjects}</span> مواد</span>
                <div style={{
                  width: 20, height: 20, borderRadius: '50%',
                  background: b.active ? EB.primary : 'transparent',
                  border: `2px solid ${b.active ? EB.primary : EB.line}`,
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                }}>
                  {b.active && <div style={{ width: 8, height: 8, borderRadius: '50%', background: '#fff' }}/>}
                </div>
              </div>
            </div>
          ))}
        </div>

        <div style={{ marginTop: 18 }}>
          <PrimaryButton>تأكيد الاختيار</PrimaryButton>
        </div>
      </div>
    </ScreenShell>
  );
}

// ─── 13. Lesson Details ───────────────────────────────────────
function LessonDetailsScreen() {
  const tabs = ['الفيديو', 'الملخص', 'التمارين', 'الأسئلة'];
  return (
    <ScreenShell>
      {/* hero (no app header — overlay buttons) */}
      <div style={{
        position: 'relative', aspectRatio: '16/10',
        background: `linear-gradient(135deg, #647F9D, #2B405C)`,
      }}>
        <svg viewBox="0 0 320 200" style={{ position: 'absolute', inset: 0, width: '100%', height: '100%', opacity: 0.4 }}>
          <g stroke="#fff" strokeWidth="1" fill="none">
            <path d="M20 40h60M20 60h120M20 80h80"/>
            <path d="M180 50 L200 30 L230 60 L260 25"/>
            <path d="M180 110 L200 100 L230 130 L260 95"/>
            <text x="40" y="160" fontFamily="Inter" fontSize="22" fill="#fff" opacity="0.8">f(x) = ax + b</text>
          </g>
        </svg>
        <div style={{
          position: 'absolute', top: 14, insetInlineStart: 14, insetInlineEnd: 14,
          display: 'flex', justifyContent: 'space-between',
        }}>
          <IconBtn light><BellIcon /></IconBtn>
          <IconBtn light><BackArrow /></IconBtn>
        </div>
        <div style={{
          position: 'absolute', inset: 0,
          display: 'flex', alignItems: 'center', justifyContent: 'center',
        }}>
          <div style={{
            width: 68, height: 68, borderRadius: '50%',
            background: 'rgba(255,255,255,0.95)',
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            boxShadow: '0 14px 28px rgba(0,0,0,0.3)',
          }}>
            <svg width="26" height="26" viewBox="0 0 24 24" fill={EB.primary}><path d="M8 5 L20 12 L8 19 Z"/></svg>
          </div>
        </div>
        <div style={{
          position: 'absolute', bottom: 12, insetInlineEnd: 12,
          background: 'rgba(0,0,0,0.6)', color: '#fff',
          paddingInline: 10, paddingBlock: 4, borderRadius: 8,
          fontFamily: 'Inter', fontSize: 12, fontWeight: 600,
        }}>14:32</div>
      </div>

      <div style={{ padding: 16, paddingTop: 14 }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 8 }}>
          <div style={{ background: EB.primarySoft, color: EB.primary, paddingInline: 10, paddingBlock: 4, borderRadius: 999, fontSize: 11, fontWeight: 700 }}>الرياضيات</div>
          <div style={{ background: EB.accentSoft, color: '#B47711', paddingInline: 10, paddingBlock: 4, borderRadius: 999, fontSize: 11, fontWeight: 700 }}>الوحدة ٤</div>
        </div>
        <div style={{ fontSize: 19, fontWeight: 800, color: EB.ink, lineHeight: 1.3, marginBottom: 8, fontFamily: 'Inter, Tajawal', direction: 'ltr', textAlign: 'right' }}>Fonctions affines — Partie 2</div>

        {/* teacher row */}
        <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginBottom: 14 }}>
          <div style={{
            width: 34, height: 34, borderRadius: '50%',
            background: `linear-gradient(135deg, ${EB.primaryLight}, ${EB.primaryDark})`,
            color: '#fff', display: 'flex', alignItems: 'center', justifyContent: 'center',
            fontWeight: 800, fontSize: 14,
          }}>س</div>
          <div style={{ flex: 1 }}>
            <div style={{ fontSize: 13, fontWeight: 700, color: EB.ink }}>أ. سيد المختار</div>
            <div style={{ fontSize: 11, color: EB.muted }}>أستاذ معتمد · ٢٤ درس</div>
          </div>
          <div style={{ fontSize: 11, color: EB.muted, display: 'inline-flex', alignItems: 'center', gap: 4 }}>
            <ClockIcon size={14}/> ١٤د ٣٢ث
          </div>
        </div>

        {/* watch progress */}
        <div style={{
          background: '#fff', border: `1px solid ${EB.line}`,
          borderRadius: 14, padding: 12, marginBottom: 14,
        }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 6 }}>
            <span style={{ fontSize: 12, color: EB.muted, fontWeight: 600 }}>نسبة المشاهدة</span>
            <span style={{ fontSize: 12, color: EB.primary, fontWeight: 800 }}>٦٤٪</span>
          </div>
          <ProgressBar value={64} height={6}/>
        </div>

        {/* action buttons */}
        <div style={{ display: 'grid', gridTemplateColumns: '2fr 1fr 1fr', gap: 8, marginBottom: 16 }}>
          <PrimaryButton icon={<PlayIcon size={16}/>}>مشاهدة الدرس</PrimaryButton>
          <div style={{
            background: EB.primarySoft, color: EB.primary,
            borderRadius: 16, minHeight: 52,
            display: 'flex', alignItems: 'center', justifyContent: 'center',
          }}><DownloadIcon size={20}/></div>
          <div style={{
            background: EB.accentSoft, color: '#B47711',
            borderRadius: 16, minHeight: 52,
            display: 'flex', alignItems: 'center', justifyContent: 'center',
          }}>
            <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor"><path d="M19 21l-7-4-7 4V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2z"/></svg>
          </div>
        </div>

        {/* tabs */}
        <div style={{ display: 'flex', gap: 4, borderBottom: `1px solid ${EB.line}`, marginBottom: 14 }}>
          {tabs.map((t, i) => (
            <div key={t} style={{
              flex: 1, paddingBlock: 10, textAlign: 'center',
              fontSize: 13, fontWeight: i === 1 ? 800 : 600,
              color: i === 1 ? EB.primary : EB.muted,
              borderBottom: i === 1 ? `2.5px solid ${EB.primary}` : '2.5px solid transparent',
              marginBottom: -1,
            }}>{t}</div>
          ))}
        </div>

        {/* summary content (active tab) */}
        <div>
          <div style={{ fontSize: 14, fontWeight: 800, color: EB.ink, marginBottom: 8 }}>ملخص الدرس</div>
          <div style={{ fontSize: 13, color: EB.ink2, lineHeight: 1.7 }}>
            في هذا الدرس نتعرف على الدالة التآلفية وخصائصها، طريقة تمثيلها بيانيا، وكيفية إيجاد المعادلة من معطيات هندسية. يشمل الدرس ٣ تمارين تطبيقية مع الحلول التفصيلية.
          </div>
          <div style={{ display: 'flex', gap: 8, marginTop: 12, flexWrap: 'wrap' }}>
            {['دالة تآلفية','معامل التوجيه','الترتيب الأصلي'].map(t => (
              <div key={t} style={{
                background: EB.primarySoft, color: EB.primary,
                paddingInline: 10, paddingBlock: 5, borderRadius: 8,
                fontSize: 11, fontWeight: 700,
              }}>#{t}</div>
            ))}
          </div>
        </div>
      </div>
    </ScreenShell>
  );
}

// ─── 14. Video Player ─────────────────────────────────────────
function VideoPlayerScreen() {
  return (
    <ScreenShell bg="#0B1322">
      {/* player */}
      <div style={{
        background: '#000', position: 'relative', aspectRatio: '16/10',
      }}>
        <div style={{
          position: 'absolute', inset: 0,
          background: `linear-gradient(135deg, #2B405C, #0B1322)`,
        }}>
          <svg viewBox="0 0 320 200" style={{ position: 'absolute', inset: 0, width: '100%', height: '100%', opacity: 0.5 }}>
            <g stroke="#fff" strokeWidth="1.2" fill="none">
              <path d="M30 160 L60 100 L100 130 L140 60 L180 90 L220 40 L260 70 L290 30"/>
              <path d="M30 170 L290 170" strokeOpacity="0.4"/>
              <text x="160" y="40" textAnchor="middle" fontFamily="Inter" fontSize="14" fill="#fff" opacity="0.7">y = ax + b</text>
            </g>
          </svg>
        </div>
        <div style={{
          position: 'absolute', top: 12, insetInlineStart: 12, insetInlineEnd: 12,
          display: 'flex', justifyContent: 'space-between',
        }}>
          <div style={{
            width: 32, height: 32, borderRadius: 10,
            background: 'rgba(0,0,0,0.4)', color: '#fff',
            display: 'flex', alignItems: 'center', justifyContent: 'center',
          }}>
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M3 7V5a2 2 0 0 1 2-2h2M17 3h2a2 2 0 0 1 2 2v2M21 17v2a2 2 0 0 1-2 2h-2M7 21H5a2 2 0 0 1-2-2v-2"/></svg>
          </div>
          <IconBtn light><BackArrow /></IconBtn>
        </div>
        <div style={{
          position: 'absolute', inset: 0,
          display: 'flex', alignItems: 'center', justifyContent: 'center',
        }}>
          <div style={{
            width: 60, height: 60, borderRadius: '50%',
            background: 'rgba(255,255,255,0.18)', backdropFilter: 'blur(8px)',
            border: '2px solid rgba(255,255,255,0.6)',
            display: 'flex', alignItems: 'center', justifyContent: 'center',
          }}>
            <svg width="22" height="22" viewBox="0 0 24 24" fill="#fff"><rect x="6" y="5" width="4" height="14" rx="1"/><rect x="14" y="5" width="4" height="14" rx="1"/></svg>
          </div>
        </div>
        {/* control bar */}
        <div style={{
          position: 'absolute', insetInlineStart: 12, insetInlineEnd: 12, bottom: 10,
          color: '#fff', fontFamily: 'Inter',
        }}>
          <div style={{ height: 4, background: 'rgba(255,255,255,0.25)', borderRadius: 2, marginBottom: 8, position: 'relative' }}>
            <div style={{ position: 'absolute', insetInlineEnd: 0, top: 0, height: 4, width: '36%', background: EB.accent, borderRadius: 2 }}/>
            <div style={{ position: 'absolute', insetInlineEnd: '36%', top: -4, width: 12, height: 12, borderRadius: '50%', background: EB.accent, transform: 'translateX(50%)' }}/>
          </div>
          <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: 11, fontWeight: 600 }}>
            <span>14:32</span>
            <span>9:14</span>
          </div>
        </div>
      </div>

      <div style={{ flex: 1, background: '#fff', borderTopLeftRadius: 24, borderTopRightRadius: 24, marginTop: -16, padding: 18, paddingTop: 20, overflow: 'auto' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 6 }}>
          <div style={{ background: EB.primarySoft, color: EB.primary, paddingInline: 10, paddingBlock: 4, borderRadius: 999, fontSize: 11, fontWeight: 700 }}>الرياضيات</div>
          <span style={{ fontSize: 11, color: EB.muted }}>الوحدة ٤ · الدرس ٧</span>
        </div>
        <div style={{ fontSize: 18, fontWeight: 800, color: EB.ink, marginBottom: 4, fontFamily: 'Inter, Tajawal', direction: 'ltr', textAlign: 'right' }}>Fonctions affines — Partie 2</div>
        <div style={{ fontSize: 12, color: EB.muted, marginBottom: 14 }}>أ. سيد المختار · ١٤ دقيقة</div>

        {/* action chips */}
        <div style={{ display: 'flex', gap: 8, marginBottom: 18 }}>
          {[
            { l: 'تحميل', i: <DownloadIcon size={16}/>, active: false },
            { l: 'حفظ', i: <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M19 21l-7-4-7 4V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2z"/></svg>, active: true },
            { l: 'تمت المشاهدة', i: <CheckIcon size={16}/>, active: false },
          ].map((b, i) => (
            <div key={i} style={{
              flex: 1, borderRadius: 12, paddingBlock: 10, paddingInline: 8,
              background: b.active ? EB.primarySoft : '#fff',
              border: `1.5px solid ${b.active ? EB.primary : EB.line}`,
              color: b.active ? EB.primary : EB.ink2,
              display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 6,
              fontSize: 11.5, fontWeight: 700,
            }}>{b.i}{b.l}</div>
          ))}
        </div>

        {/* my notes */}
        <div style={{
          background: EB.accentSoft, border: `1px solid #F3D58A`,
          borderRadius: 14, padding: 12, marginBottom: 18,
        }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 6 }}>
            <span style={{ fontSize: 13, fontWeight: 800, color: '#8C5A0E' }}>📝 ملاحظاتي</span>
            <span style={{ fontSize: 11, color: '#B47711', fontWeight: 700 }}>+ إضافة</span>
          </div>
          <div style={{ fontSize: 12, color: '#8C5A0E', lineHeight: 1.6 }}>
            معامل التوجيه a = (y₂ - y₁) / (x₂ - x₁) — مراجعة قبل الامتحان.
          </div>
        </div>

        <div style={{ fontSize: 14, fontWeight: 800, color: EB.ink, marginBottom: 10 }}>دروس مقترحة</div>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
          {[
            { t: 'Fonctions affines — Partie 1', d: '12:18' },
            { t: 'Théorème de Thalès', d: '18:42' },
            { t: 'Géométrie analytique', d: '21:10' },
          ].map((l, i) => (
            <div key={i} style={{
              display: 'flex', alignItems: 'center', gap: 10,
              padding: 8, paddingInline: 10, borderRadius: 12,
              background: '#fff', border: `1px solid ${EB.line}`,
            }}>
              <div style={{
                width: 52, height: 36, borderRadius: 8,
                background: `linear-gradient(135deg, #B8C6D8, #6E8AA8)`,
                position: 'relative', flexShrink: 0,
              }}>
                <div style={{
                  position: 'absolute', inset: 0,
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                }}>
                  <div style={{ width: 18, height: 18, borderRadius: '50%', background: 'rgba(255,255,255,0.9)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                    <svg width="8" height="8" viewBox="0 0 24 24" fill={EB.primary}><path d="M8 5 L20 12 L8 19 Z"/></svg>
                  </div>
                </div>
              </div>
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{ fontSize: 13, fontWeight: 700, color: EB.ink, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap', fontFamily: 'Inter, Tajawal', direction: 'ltr', textAlign: 'right' }}>{l.t}</div>
                <div style={{ fontSize: 11, color: EB.muted, marginTop: 2, fontFamily: 'Inter' }}>{l.d}</div>
              </div>
              <ChevRtl />
            </div>
          ))}
        </div>
      </div>
    </ScreenShell>
  );
}

// ─── 15. Exercise Details ─────────────────────────────────────
function ExerciseDetailsScreen() {
  return (
    <ScreenShell>
      <AppHeader title="تفاصيل التمرين" />
      <div style={{ padding: 16 }}>
        <div style={{ display: 'flex', gap: 8, marginBottom: 12 }}>
          <div style={{ background: EB.primary, color: '#fff', paddingInline: 12, paddingBlock: 5, borderRadius: 8, fontFamily: 'Inter', fontSize: 11, fontWeight: 800 }}>BEPC 2017</div>
          <div style={{ background: EB.accentSoft, color: '#B47711', paddingInline: 12, paddingBlock: 5, borderRadius: 8, fontSize: 11, fontWeight: 700 }}>العلوم الطبيعية</div>
          <div style={{ background: '#FFE5E0', color: EB.danger, paddingInline: 12, paddingBlock: 5, borderRadius: 8, fontSize: 11, fontWeight: 700, marginInlineStart: 'auto' }}>صعب</div>
        </div>
        <div style={{ fontSize: 18, fontWeight: 800, color: EB.ink, lineHeight: 1.35, marginBottom: 6 }}>تمرين التناسل عند الإنسان</div>
        <div style={{ fontSize: 12, color: EB.muted, marginBottom: 14 }}>الامتحان الرسمي لشهادة ختم الدروس الإعدادية</div>

        {/* PDF preview */}
        <div style={{
          background: '#fff', border: `1.5px solid ${EB.line}`,
          borderRadius: 16, padding: 14, marginBottom: 14,
          position: 'relative',
        }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginBottom: 10 }}>
            <div style={{
              width: 36, height: 44, borderRadius: 6,
              background: '#E63946', color: '#fff',
              display: 'flex', alignItems: 'center', justifyContent: 'center',
              fontFamily: 'Inter', fontWeight: 800, fontSize: 11,
            }}>PDF</div>
            <div style={{ flex: 1 }}>
              <div style={{ fontSize: 13, fontWeight: 800, color: EB.ink, fontFamily: 'Inter', direction: 'ltr', textAlign: 'right' }}>BEPC_2017_Sciences.pdf</div>
              <div style={{ fontSize: 11, color: EB.muted, marginTop: 2 }}>4 صفحات · 380 ك.ب</div>
            </div>
          </div>
          {/* text snippet */}
          <div style={{
            background: EB.bg, borderRadius: 10, padding: 12,
            fontSize: 12, color: EB.ink2, lineHeight: 1.7,
            border: `1px dashed ${EB.line}`,
          }}>
            <strong style={{ display: 'block', marginBottom: 6, color: EB.ink }}>التمرين ١ — على ٨ نقاط</strong>
            عند دراسة الجهاز التناسلي عند الذكر، أعطيت لك مجموعة من المعطيات...
            <div style={{ marginTop: 8 }}>
              ١. حدد المكونات الأساسية للحيوان المنوي.<br/>
              ٢. اشرح آلية الإخصاب الداخلي.<br/>
              ٣. أكمل الجدول التالي بالمعلومات المناسبة.
            </div>
          </div>
        </div>

        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10, marginBottom: 12 }}>
          <PrimaryButton icon={<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><circle cx="12" cy="12" r="3"/><path d="M2 12s4-7 10-7 10 7 10 7-4 7-10 7S2 12 2 12z"/></svg>}>عرض الحل</PrimaryButton>
          <PrimaryButton variant="outline" icon={<DownloadIcon size={16}/>}>تحميل الحل</PrimaryButton>
        </div>
        <PrimaryButton variant="ghost" icon={<PlayIcon size={16}/>}>مشاهدة الشرح بالفيديو</PrimaryButton>

        {/* difficulty + meta */}
        <div style={{
          background: '#fff', border: `1px solid ${EB.line}`,
          borderRadius: 14, padding: 14, marginTop: 14,
        }}>
          <div style={{ fontSize: 12, fontWeight: 700, color: EB.muted, marginBottom: 10 }}>تفاصيل التمرين</div>
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12 }}>
            {[
              { l: 'المدة', v: '٤٥ د' },
              { l: 'النقاط', v: '٢٠' },
              { l: 'الصعوبة', v: 'صعب', color: EB.danger },
              { l: 'محلول', v: 'نعم', color: EB.success },
            ].map((m, i) => (
              <div key={i}>
                <div style={{ fontSize: 11, color: EB.muted, marginBottom: 2 }}>{m.l}</div>
                <div style={{ fontSize: 14, fontWeight: 800, color: m.color || EB.ink, fontFamily: 'Tajawal' }}>{m.v}</div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </ScreenShell>
  );
}

// ─── 16. Notifications ────────────────────────────────────────
function NotificationsScreen() {
  const items = [
    { type: 'lesson',   title: 'درس جديد متاح', body: 'تم نشر درس "Géométrie analytique" بقسم الرياضيات.', t: 'قبل دقيقتين', unread: true, color: EB.primary, icon: <PlayIcon size={16}/> },
    { type: 'exercise', title: 'تمرين جديد محلول', body: 'تمرين BEPC 2024 — الفيزياء والكيمياء جاهز للمراجعة.', t: 'قبل ساعة', unread: true, color: '#1E9E6A', icon: <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M9 11l2 2 4-4"/><circle cx="12" cy="12" r="9"/></svg> },
    { type: 'reminder', title: 'تذكير بالمراجعة', body: 'لم تكمل درس "Fonctions affines" منذ أمس.', t: 'قبل 3 ساعات', color: '#F2A11A', icon: <ClockIcon size={16}/> },
    { type: 'admin',    title: 'إعلان من الإدارة', body: 'موعد امتحان BEPC الرسمي: 15 يونيو 2026.', t: 'البارحة', color: '#7C4DDD', icon: <BellIcon size={16}/> },
    { type: 'update',   title: 'تحديث التطبيق متاح', body: 'الإصدار 2.1 يضيف وضعا ليليا وتحسينات في الأداء.', t: 'قبل يومين', color: EB.muted, icon: <DownloadIcon size={16}/> },
  ];
  return (
    <ScreenShell>
      <AppHeader title="الإشعارات" />
      <div style={{ padding: 16 }}>
        <div style={{
          display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 14,
        }}>
          <div style={{ fontSize: 13, color: EB.muted }}>لديك <span style={{ color: EB.primary, fontWeight: 800 }}>٢</span> إشعارات جديدة</div>
          <div style={{ fontSize: 12, color: EB.primary, fontWeight: 700 }}>تحديد الكل كمقروء</div>
        </div>

        <div style={{ display: 'flex', gap: 8, marginBottom: 14 }}>
          {['الكل','جديدة','الدروس','الإدارة'].map((c,i) => (
            <div key={i} style={{
              paddingInline: 12, paddingBlock: 6, borderRadius: 999,
              background: i === 0 ? EB.primary : '#fff',
              color: i === 0 ? '#fff' : EB.ink2,
              border: i === 0 ? 'none' : `1px solid ${EB.line}`,
              fontSize: 12, fontWeight: 600, whiteSpace: 'nowrap',
            }}>{c}</div>
          ))}
        </div>

        <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
          {items.map((n, i) => (
            <div key={i} style={{
              background: n.unread ? '#EFF5FC' : '#fff',
              border: `1px solid ${n.unread ? '#D0E1F4' : EB.line}`,
              borderRadius: 16, padding: 12,
              display: 'flex', gap: 12, alignItems: 'flex-start',
              position: 'relative',
            }}>
              {n.unread && <div style={{
                position: 'absolute', top: 14, insetInlineEnd: 10,
                width: 8, height: 8, borderRadius: '50%', background: EB.primary,
              }}/>}
              <div style={{
                width: 38, height: 38, borderRadius: 12,
                background: n.color + '22', color: n.color,
                display: 'flex', alignItems: 'center', justifyContent: 'center',
                flexShrink: 0,
              }}>{n.icon}</div>
              <div style={{ flex: 1, paddingInlineEnd: n.unread ? 14 : 0 }}>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline', gap: 6, marginBottom: 3 }}>
                  <span style={{ fontSize: 13.5, fontWeight: 800, color: EB.ink }}>{n.title}</span>
                  <span style={{ fontSize: 10.5, color: EB.muted, whiteSpace: 'nowrap' }}>{n.t}</span>
                </div>
                <div style={{ fontSize: 12, color: EB.ink2, lineHeight: 1.55 }}>{n.body}</div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </ScreenShell>
  );
}

// ─── 17. Global Search ────────────────────────────────────────
function SearchScreen() {
  return (
    <ScreenShell>
      <div style={{
        background: ebGradient, padding: 16, paddingTop: 14,
        borderBottomLeftRadius: 22, borderBottomRightRadius: 22,
        color: '#fff',
      }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 12 }}>
          <IconBtn><BackArrow /></IconBtn>
          <div style={{ fontFamily: 'Tajawal', fontWeight: 700, fontSize: 17 }}>البحث</div>
          <div style={{ width: 36 }}/>
        </div>
        <div style={{
          background: '#fff', borderRadius: 14, padding: '12px 14px',
          display: 'flex', alignItems: 'center', gap: 10,
        }}>
          <div style={{ color: EB.muted }}><SearchIcon size={18}/></div>
          <div style={{ flex: 1, fontSize: 14, color: EB.ink, fontFamily: 'Tajawal' }}>fonctions affines</div>
          <div style={{ color: EB.muted, fontSize: 18 }}>×</div>
        </div>
      </div>

      <div style={{ padding: 16 }}>
        <div style={{ display: 'flex', gap: 8, overflow: 'hidden', marginBottom: 14 }}>
          {[
            { l: 'الكل', n: 24, active: true },
            { l: 'دروس', n: 12 },
            { l: 'تمارين', n: 8 },
            { l: 'أساتذة', n: 2 },
            { l: 'مواد', n: 2 },
          ].map((c,i) => (
            <div key={i} style={{
              paddingInline: 14, paddingBlock: 8, borderRadius: 999,
              background: c.active ? EB.primary : '#fff',
              color: c.active ? '#fff' : EB.ink2,
              border: c.active ? 'none' : `1px solid ${EB.line}`,
              fontSize: 12, fontWeight: 600, whiteSpace: 'nowrap',
              display: 'inline-flex', alignItems: 'center', gap: 6,
            }}>{c.l} <span style={{ background: c.active ? 'rgba(255,255,255,0.25)' : EB.primarySoft, color: c.active ? '#fff' : EB.primary, paddingInline: 6, borderRadius: 999, fontSize: 10, fontWeight: 800, fontFamily: 'Inter' }}>{c.n}</span></div>
          ))}
        </div>

        {/* filter pills */}
        <div style={{
          background: EB.bg, border: `1px solid ${EB.line}`,
          borderRadius: 14, padding: 10, marginBottom: 16,
          display: 'flex', flexWrap: 'wrap', gap: 6, alignItems: 'center',
        }}>
          <span style={{ fontSize: 11, color: EB.muted, fontWeight: 700, paddingInline: 4 }}>الفلاتر:</span>
          {['الرياضيات','BEPC','أ. سيد المختار','فيديو'].map(f => (
            <div key={f} style={{
              background: '#fff', border: `1px solid ${EB.line}`,
              paddingInline: 10, paddingBlock: 4, borderRadius: 999,
              fontSize: 11, fontWeight: 600, color: EB.ink2,
              display: 'inline-flex', alignItems: 'center', gap: 4,
            }}>{f} <span style={{ color: EB.muted }}>×</span></div>
          ))}
        </div>

        {/* results */}
        <div style={{ fontSize: 12, fontWeight: 700, color: EB.muted, marginBottom: 10 }}>أفضل نتيجة</div>
        <div style={{
          background: '#fff', borderRadius: 16, padding: 12,
          border: `2px solid ${EB.primary}`, marginBottom: 14,
          display: 'flex', gap: 12, alignItems: 'center',
        }}>
          <div style={{
            width: 56, height: 56, borderRadius: 14,
            background: ebGradient, color: '#fff',
            display: 'flex', alignItems: 'center', justifyContent: 'center',
          }}><PlayIcon size={22}/></div>
          <div style={{ flex: 1 }}>
            <div style={{ fontSize: 14, fontWeight: 800, color: EB.ink, fontFamily: 'Inter, Tajawal', direction: 'ltr', textAlign: 'right' }}>Fonctions affines — Partie 1</div>
            <div style={{ fontSize: 11, color: EB.muted, marginTop: 2 }}>الرياضيات · أ. سيد المختار · ١٢:١٨</div>
          </div>
          <div style={{
            background: EB.primarySoft, color: EB.primary,
            paddingInline: 10, paddingBlock: 4, borderRadius: 999,
            fontSize: 10, fontWeight: 800,
          }}>درس</div>
        </div>

        <div style={{ fontSize: 12, fontWeight: 700, color: EB.muted, marginBottom: 10 }}>نتائج أخرى</div>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
          {[
            { t: 'Fonctions affines — Partie 2', sub: 'درس · أ. سيد المختار', kind: 'فيديو' },
            { t: 'تمرين Fonctions BEPC 2019', sub: 'تمرين · العلوم', kind: 'تمرين' },
            { t: 'أ. سيد المختار', sub: 'أستاذ · الرياضيات', kind: 'أستاذ' },
          ].map((r, i) => (
            <div key={i} style={{
              background: '#fff', border: `1px solid ${EB.line}`,
              borderRadius: 14, padding: 12,
              display: 'flex', gap: 12, alignItems: 'center',
            }}>
              <div style={{
                width: 40, height: 40, borderRadius: 12,
                background: EB.primarySoft, color: EB.primary,
                display: 'flex', alignItems: 'center', justifyContent: 'center',
              }}>
                {r.kind === 'فيديو' ? <PlayIcon size={16}/> : r.kind === 'تمرين' ? <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><path d="M14 2v6h6"/></svg> : <UserIcon size={16}/>}
              </div>
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{ fontSize: 13, fontWeight: 700, color: EB.ink, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{r.t}</div>
                <div style={{ fontSize: 11, color: EB.muted, marginTop: 2 }}>{r.sub}</div>
              </div>
              <ChevRtl />
            </div>
          ))}
        </div>
      </div>
    </ScreenShell>
  );
}

// ─── 18. Favorites ────────────────────────────────────────────
function FavoritesScreen() {
  const tabs = [
    { l: 'الدروس', n: 8, active: true },
    { l: 'التمارين', n: 5 },
    { l: 'الأساتذة', n: 3 },
  ];
  const lessons = [
    { t: 'Fonctions affines — Partie 1', s: 'الرياضيات · أ. سيد المختار', d: '12:18' },
    { t: 'Théorème de Thalès', s: 'الرياضيات · أ. التام', d: '18:42' },
    { t: 'التناسل عند الإنسان', s: 'العلوم · أ. أحمدو', d: '21:30' },
    { t: 'Géométrie analytique', s: 'الرياضيات · أ. سيد المختار', d: '15:08' },
  ];
  return (
    <ScreenShell>
      <AppHeader title="المفضلة" />
      <div style={{ padding: 16 }}>
        {/* tabs */}
        <div style={{
          background: '#fff', borderRadius: 14, padding: 4,
          display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: 4,
          border: `1px solid ${EB.line}`, marginBottom: 14,
        }}>
          {tabs.map((t, i) => (
            <div key={i} style={{
              paddingBlock: 10, borderRadius: 10, textAlign: 'center',
              background: t.active ? ebGradient : 'transparent',
              color: t.active ? '#fff' : EB.ink2,
              fontSize: 13, fontWeight: 700,
              display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 6,
            }}>{t.l}<span style={{
              background: t.active ? 'rgba(255,255,255,0.25)' : EB.primarySoft,
              color: t.active ? '#fff' : EB.primary,
              paddingInline: 6, borderRadius: 999, fontSize: 10, fontWeight: 800, fontFamily: 'Inter',
            }}>{t.n}</span></div>
          ))}
        </div>

        <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 10 }}>
          <span style={{ fontSize: 12, color: EB.muted }}>٨ دروس محفوظة</span>
          <span style={{ fontSize: 12, color: EB.primary, fontWeight: 700 }}>ترتيب: الأحدث</span>
        </div>

        <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
          {lessons.map((l, i) => (
            <div key={i} style={{
              background: '#fff', border: `1px solid ${EB.line}`,
              borderRadius: 16, padding: 10,
              display: 'flex', gap: 12, alignItems: 'center',
              boxShadow: '0 6px 14px -12px rgba(20,30,60,0.2)',
            }}>
              <div style={{
                width: 76, height: 56, borderRadius: 12,
                background: `linear-gradient(135deg, #B8C6D8, #6E8AA8)`,
                position: 'relative', flexShrink: 0, overflow: 'hidden',
              }}>
                <div style={{
                  position: 'absolute', inset: 0,
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                }}>
                  <div style={{ width: 24, height: 24, borderRadius: '50%', background: 'rgba(255,255,255,0.95)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                    <svg width="10" height="10" viewBox="0 0 24 24" fill={EB.primary}><path d="M8 5 L20 12 L8 19 Z"/></svg>
                  </div>
                </div>
                <div style={{
                  position: 'absolute', bottom: 4, insetInlineEnd: 4,
                  background: 'rgba(0,0,0,0.6)', color: '#fff',
                  paddingInline: 5, paddingBlock: 1, borderRadius: 4,
                  fontFamily: 'Inter', fontSize: 9, fontWeight: 700,
                }}>{l.d}</div>
              </div>
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{ fontSize: 13, fontWeight: 800, color: EB.ink, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap', fontFamily: 'Inter, Tajawal', direction: 'ltr', textAlign: 'right' }}>{l.t}</div>
                <div style={{ fontSize: 11, color: EB.muted, marginTop: 3 }}>{l.s}</div>
              </div>
              <div style={{ color: EB.accent, padding: 6 }}>
                <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor"><path d="M19 21l-7-4-7 4V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2z"/></svg>
              </div>
            </div>
          ))}
        </div>
      </div>
    </ScreenShell>
  );
}

// ─── 19. Packages ─────────────────────────────────────────────
function PackagesScreen() {
  const plans = [
    {
      id: 'free', name: 'الباقة المجانية', price: '0', period: 'مدى الحياة',
      badge: 'دائمة', color: EB.muted,
      features: ['الوصول لـ٢٠٪ من الدروس', 'دروس مرئية محدودة', 'بدون تحميل غير متصل'],
    },
    {
      id: 'monthly', name: 'الباقة الشهرية', price: '1500', period: 'أوقية / شهر',
      badge: 'الأكثر مرونة', color: EB.primary,
      features: ['كل الدروس والتمارين', 'تحميل غير محدود', 'حاسبة المعدل', 'بدون إعلانات'],
    },
    {
      id: 'yearly', name: 'الباقة السنوية', price: '12000', period: 'أوقية / سنة',
      badge: 'وفر 33%', color: EB.accent, active: true,
      features: ['كل ميزات الباقة الشهرية', 'دعم أولوية من الأساتذة', 'دروس حصرية للامتحانات', 'حساب لأخ أو أخت مجانا'],
    },
  ];
  return (
    <ScreenShell>
      <AppHeader title="الاشتراك والباقات" />
      <div style={{ padding: 16 }}>
        <div style={{ marginBottom: 14, textAlign: 'center' }}>
          <div style={{ fontSize: 20, fontWeight: 900, color: EB.ink, marginBottom: 6 }}>اختر الباقة المناسبة لك</div>
          <div style={{ fontSize: 12.5, color: EB.muted, lineHeight: 1.6 }}>كل الباقات اختيارية — يمكنك متابعة استخدام التطبيق مجانا.</div>
        </div>

        <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
          {plans.map(p => (
            <div key={p.id} style={{
              background: p.active ? ebGradient : '#fff',
              color: p.active ? '#fff' : EB.ink,
              border: p.active ? 'none' : `1.5px solid ${EB.line}`,
              borderRadius: 20, padding: 16,
              position: 'relative', overflow: 'hidden',
              boxShadow: p.active ? '0 20px 36px -20px rgba(15,95,168,0.55)' : '0 6px 16px -14px rgba(20,30,60,0.2)',
            }}>
              {p.badge && (
                <div style={{
                  position: 'absolute', top: 14, insetInlineStart: 14,
                  background: p.active ? EB.accent : p.color + '22',
                  color: p.active ? '#fff' : p.color,
                  paddingInline: 10, paddingBlock: 4, borderRadius: 999,
                  fontSize: 10.5, fontWeight: 800,
                }}>{p.badge}</div>
              )}
              <div style={{ marginBottom: 10 }}>
                <div style={{ fontSize: 14, fontWeight: 700, opacity: p.active ? 0.9 : 0.7, marginBottom: 6 }}>{p.name}</div>
                <div style={{ display: 'flex', alignItems: 'baseline', gap: 6 }}>
                  <span style={{ fontFamily: 'Inter', fontWeight: 900, fontSize: 30, lineHeight: 1 }}>{p.price}</span>
                  <span style={{ fontSize: 12, opacity: p.active ? 0.85 : 0.65 }}>{p.period}</span>
                </div>
              </div>
              <div style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
                {p.features.map((f, i) => (
                  <div key={i} style={{ display: 'flex', alignItems: 'center', gap: 8, fontSize: 12.5 }}>
                    <div style={{
                      width: 18, height: 18, borderRadius: '50%',
                      background: p.active ? 'rgba(255,255,255,0.22)' : EB.primarySoft,
                      color: p.active ? '#fff' : EB.primary,
                      display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0,
                    }}><CheckIcon size={11}/></div>
                    <span style={{ opacity: p.active ? 0.95 : 1 }}>{f}</span>
                  </div>
                ))}
              </div>
              <div style={{
                marginTop: 14, paddingTop: 12,
                borderTop: `1px solid ${p.active ? 'rgba(255,255,255,0.2)' : EB.line}`,
                display: 'flex', justifyContent: 'space-between', alignItems: 'center',
              }}>
                <div style={{ fontSize: 12, opacity: p.active ? 0.85 : 0.7 }}>{p.active ? 'الباقة الحالية' : p.id === 'free' ? 'الباقة الافتراضية' : 'اختر هذه الباقة'}</div>
                <div style={{
                  background: p.active ? '#fff' : (p.id === 'free' ? EB.bg : EB.primary),
                  color: p.active ? EB.primary : (p.id === 'free' ? EB.muted : '#fff'),
                  paddingInline: 14, paddingBlock: 7, borderRadius: 10,
                  fontSize: 12, fontWeight: 800,
                }}>{p.active ? 'مفعلة' : p.id === 'free' ? 'مستخدمة' : 'اشترك'}</div>
              </div>
            </div>
          ))}
        </div>

        {/* payment methods */}
        <div style={{
          marginTop: 18, background: '#fff', borderRadius: 18,
          border: `1px solid ${EB.line}`, padding: 14,
        }}>
          <div style={{ fontSize: 13, fontWeight: 800, color: EB.ink, marginBottom: 4 }}>طرق الدفع المتاحة</div>
          <div style={{ fontSize: 11.5, color: EB.muted, marginBottom: 12, lineHeight: 1.5 }}>ادفع بسهولة عبر أحد المحافظ الموريتانية</div>
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: 8 }}>
            {[
              { n: 'Bankily', c: '#1B7E47' },
              { n: 'Masrvi',  c: '#D7424B' },
              { n: 'Sedad',   c: '#0F5FA8' },
            ].map(p => (
              <div key={p.n} style={{
                border: `1.5px solid ${EB.line}`, borderRadius: 12,
                padding: 12, textAlign: 'center',
                display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 6,
              }}>
                <div style={{
                  width: 38, height: 38, borderRadius: 10,
                  background: p.c, color: '#fff',
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                  fontFamily: 'Inter', fontWeight: 800, fontSize: 13,
                }}>{p.n[0]}</div>
                <span style={{ fontFamily: 'Inter', fontSize: 12, fontWeight: 700, color: EB.ink }}>{p.n}</span>
              </div>
            ))}
          </div>
          <div style={{
            marginTop: 12, padding: 10, borderRadius: 10,
            background: EB.bg, fontSize: 11, color: EB.muted, lineHeight: 1.5,
            display: 'flex', gap: 8, alignItems: 'center',
          }}>
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke={EB.muted} strokeWidth="2"><circle cx="12" cy="12" r="9"/><path d="M12 8v4M12 16h.01"/></svg>
            الدفع آمن — المعاملات معتمدة من البنك المركزي الموريتاني.
          </div>
        </div>
      </div>
    </ScreenShell>
  );
}

Object.assign(window, {
  TrackSelectionScreen, BacBranchScreen, LessonDetailsScreen,
  VideoPlayerScreen, ExerciseDetailsScreen, NotificationsScreen,
  SearchScreen, FavoritesScreen, PackagesScreen,
});
