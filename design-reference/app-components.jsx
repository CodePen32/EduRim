/* eslint-disable */
// ─────────────────────────────────────────────────────────────
// مدرستي — EduBac Mauritania
// Shared design tokens & components (original brand)
// ─────────────────────────────────────────────────────────────

const EB = {
  primary: '#0F5FA8',
  primaryDark: '#0A4581',
  primaryLight: '#2E7EC9',
  primarySoft: '#E6EEF8',
  accent: '#F2A11A',      // warm gold (Mauritanian inspiration, distinct hue)
  accentSoft: '#FFF3DC',
  bg: '#F7F7FB',
  card: '#FFFFFF',
  ink: '#16213A',
  ink2: '#3D4860',
  muted: '#7A8499',
  line: '#E4E7EE',
  success: '#1E9E6A',
  danger: '#D7424B',
};

const ebGradient = `linear-gradient(160deg, ${EB.primaryLight} 0%, ${EB.primary} 55%, ${EB.primaryDark} 100%)`;

// ─── Original Logo ────────────────────────────────────────────
// A rounded-square badge with a custom geometric "م" / open-book
// glyph and a small gold star. Intentionally distinct from any
// existing brand.
function EBLogo({ size = 64, withWordmark = false }) {
  const r = size * 0.28;
  return (
    <div style={{ display: 'inline-flex', alignItems: 'center', gap: size * 0.18 }}>
      <div style={{
        width: size, height: size, borderRadius: r,
        background: ebGradient,
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        boxShadow: `0 ${size*0.12}px ${size*0.3}px -${size*0.1}px rgba(15,95,168,0.45)`,
        position: 'relative',
      }}>
        <svg width={size*0.62} height={size*0.62} viewBox="0 0 64 64" fill="none">
          {/* open book / pages */}
          <path d="M10 18 L32 14 L32 54 L10 50 Z" fill="#fff" opacity="0.95"/>
          <path d="M54 18 L32 14 L32 54 L54 50 Z" fill="#fff" opacity="0.78"/>
          <path d="M32 14 L32 54" stroke={EB.primary} strokeWidth="1.6"/>
          {/* spine accent */}
          <rect x="30" y="14" width="4" height="40" rx="1" fill={EB.accent}/>
        </svg>
        {/* star */}
        <div style={{
          position: 'absolute', top: -size*0.08, insetInlineEnd: -size*0.08,
          width: size*0.32, height: size*0.32, borderRadius: '50%',
          background: EB.accent,
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          boxShadow: '0 4px 10px rgba(242,161,26,0.45)',
        }}>
          <svg width={size*0.18} height={size*0.18} viewBox="0 0 24 24" fill="#fff">
            <path d="M12 2 L14.5 9 L22 9.3 L16 14 L18 21.5 L12 17 L6 21.5 L8 14 L2 9.3 L9.5 9 Z"/>
          </svg>
        </div>
      </div>
      {withWordmark && (
        <div style={{ display: 'flex', flexDirection: 'column', lineHeight: 1.1 }}>
          <span style={{ fontFamily: 'Tajawal, sans-serif', fontWeight: 800, fontSize: size*0.42, color: EB.ink }}>مدرستي</span>
          <span style={{ fontFamily: 'Inter, sans-serif', fontWeight: 600, fontSize: size*0.18, color: EB.muted, letterSpacing: 0.4 }}>EDUBAC · MAURITANIA</span>
        </div>
      )}
    </div>
  );
}

// ─── Top App Header ───────────────────────────────────────────
function AppHeader({ title, onBack, showBell = true, showMenu = false, variant = 'default' }) {
  const isHome = variant === 'home';
  return (
    <div style={{
      background: ebGradient,
      paddingInline: 18, paddingBlock: 14, paddingBottom: 18,
      borderBottomLeftRadius: isHome ? 26 : 0,
      borderBottomRightRadius: isHome ? 26 : 0,
      color: '#fff',
      display: 'flex', alignItems: 'center', justifyContent: 'space-between',
      minHeight: 56,
    }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
        {showBell && <IconBtn><BellIcon /></IconBtn>}
      </div>
      <div style={{ fontFamily: 'Tajawal, sans-serif', fontWeight: 700, fontSize: 19 }}>{title}</div>
      <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
        {showMenu ? <IconBtn><MenuIcon /></IconBtn> : (onBack !== false && <IconBtn><BackArrow /></IconBtn>)}
      </div>
    </div>
  );
}

function IconBtn({ children, onClick, light = false }) {
  return (
    <button onClick={onClick} style={{
      width: 36, height: 36, borderRadius: 12,
      background: light ? 'rgba(255,255,255,0.12)' : 'rgba(255,255,255,0.14)',
      border: 'none', display: 'flex', alignItems: 'center', justifyContent: 'center',
      color: '#fff', cursor: 'pointer', padding: 0,
    }}>{children}</button>
  );
}

// ─── Bottom Navigation ────────────────────────────────────────
function BottomNav({ active = 'home' }) {
  const items = [
    { id: 'home',   label: 'الرئيسية',     icon: <HomeIcon /> },
    { id: 'down',   label: 'المحملة',      icon: <DownloadIcon /> },
    { id: 'calc',   label: 'الحاسبة',      icon: <CalcIcon /> },
    { id: 'me',     label: 'حسابي',        icon: <UserIcon /> },
  ];
  return (
    <div style={{
      background: '#fff',
      borderTop: `1px solid ${EB.line}`,
      paddingInline: 8, paddingTop: 8, paddingBottom: 10,
      display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: 4,
    }}>
      {items.map(it => {
        const on = it.id === active;
        return (
          <div key={it.id} style={{
            display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 4,
            paddingBlock: 6, borderRadius: 12,
            color: on ? EB.primary : EB.muted,
            background: on ? EB.primarySoft : 'transparent',
          }}>
            <div style={{ width: 22, height: 22 }}>{it.icon}</div>
            <span style={{ fontFamily: 'Tajawal, sans-serif', fontSize: 11, fontWeight: on ? 700 : 500 }}>{it.label}</span>
          </div>
        );
      })}
    </div>
  );
}

// ─── Primary Button ───────────────────────────────────────────
function PrimaryButton({ children, variant = 'primary', icon, style = {}, block = true }) {
  const styles = {
    primary: { background: ebGradient, color: '#fff', shadow: '0 10px 24px -10px rgba(15,95,168,0.55)' },
    outline: { background: '#fff', color: EB.primary, shadow: 'none', border: `1.5px solid ${EB.primary}` },
    ghost:   { background: EB.primarySoft, color: EB.primary, shadow: 'none' },
    accent:  { background: EB.accent, color: '#fff', shadow: '0 10px 24px -10px rgba(242,161,26,0.55)' },
  }[variant];
  return (
    <button style={{
      width: block ? '100%' : 'auto',
      minHeight: 52, borderRadius: 16,
      background: styles.background, color: styles.color,
      border: styles.border || 'none',
      boxShadow: styles.shadow,
      fontFamily: 'Tajawal, sans-serif', fontWeight: 700, fontSize: 17,
      display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8,
      paddingInline: 18, cursor: 'pointer',
      ...style,
    }}>
      {icon}
      <span>{children}</span>
    </button>
  );
}

// ─── Form Input ───────────────────────────────────────────────
function FormInput({ label, value = '', placeholder, type = 'text', icon, suffix, leading, focused = false, error }) {
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
      {label && <label style={{
        fontFamily: 'Tajawal, sans-serif', fontSize: 13, color: EB.ink2, fontWeight: 600, paddingInlineStart: 4,
      }}>{label}</label>}
      <div style={{
        display: 'flex', alignItems: 'center', gap: 10,
        background: '#fff',
        border: `1.5px solid ${error ? EB.danger : focused ? EB.primary : EB.line}`,
        borderRadius: 14, paddingInline: 14, minHeight: 52,
      }}>
        {leading}
        {icon && <div style={{ color: EB.muted }}>{icon}</div>}
        <div style={{
          flex: 1, fontFamily: 'Tajawal, sans-serif', fontSize: 15,
          color: value ? EB.ink : EB.muted,
        }}>{value || placeholder}</div>
        {suffix}
      </div>
      {error && <span style={{ fontFamily: 'Tajawal, sans-serif', fontSize: 12, color: EB.danger, paddingInlineStart: 4 }}>{error}</span>}
    </div>
  );
}

function SelectInput({ label, value, placeholder }) {
  return (
    <FormInput
      label={label}
      value={value}
      placeholder={placeholder}
      suffix={<ChevDown />}
    />
  );
}

function PhoneInput({ value, placeholder = 'رقم الهاتف' }) {
  return (
    <div style={{ display: 'flex', gap: 8 }}>
      <div style={{
        display: 'flex', alignItems: 'center', gap: 8,
        background: '#fff', border: `1.5px solid ${EB.line}`,
        borderRadius: 14, paddingInline: 12, minHeight: 52, minWidth: 110,
      }}>
        <ChevDown />
        <span style={{ fontFamily: 'Inter, sans-serif', fontWeight: 600, color: EB.ink, fontSize: 15 }}>+222</span>
        <MRFlag />
      </div>
      <div style={{
        flex: 1, display: 'flex', alignItems: 'center', gap: 10,
        background: '#fff', border: `1.5px solid ${EB.line}`,
        borderRadius: 14, paddingInline: 14, minHeight: 52,
      }}>
        <PhoneIcon />
        <div style={{
          flex: 1, fontFamily: value ? 'Inter, sans-serif' : 'Tajawal, sans-serif',
          fontSize: 15, color: value ? EB.ink : EB.muted,
          direction: 'ltr', textAlign: 'right',
        }}>{value || placeholder}</div>
      </div>
    </div>
  );
}

// ─── Progress Bar ─────────────────────────────────────────────
function ProgressBar({ value = 0, height = 6, light = false }) {
  return (
    <div style={{
      width: '100%', height, borderRadius: 999,
      background: light ? 'rgba(255,255,255,0.25)' : EB.primarySoft,
      overflow: 'hidden',
    }}>
      <div style={{
        width: `${value}%`, height: '100%',
        background: light ? '#fff' : ebGradient,
        borderRadius: 999,
      }}/>
    </div>
  );
}

// ─── Subject Card (home grid) ─────────────────────────────────
function SubjectCard({ name, icon, progress = 0, accent = false }) {
  return (
    <div style={{
      aspectRatio: '1 / 1.08',
      borderRadius: 22,
      background: accent
        ? `linear-gradient(160deg, ${EB.accent} 0%, #E08F0F 100%)`
        : ebGradient,
      padding: 16,
      display: 'flex', flexDirection: 'column', justifyContent: 'space-between',
      color: '#fff', position: 'relative', overflow: 'hidden',
      boxShadow: '0 14px 28px -16px rgba(15,95,168,0.55)',
    }}>
      {/* decorative blob */}
      <div style={{
        position: 'absolute', insetInlineStart: -30, top: -30,
        width: 110, height: 110, borderRadius: '50%',
        background: 'rgba(255,255,255,0.08)',
      }}/>
      <div style={{
        position: 'absolute', insetInlineEnd: -20, bottom: -30,
        width: 90, height: 90, borderRadius: '50%',
        background: 'rgba(255,255,255,0.06)',
      }}/>
      <div style={{
        width: 52, height: 52, borderRadius: 14,
        background: 'rgba(255,255,255,0.18)',
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        backdropFilter: 'blur(6px)',
      }}>{icon}</div>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 8, position: 'relative' }}>
        <div style={{ fontFamily: 'Tajawal, sans-serif', fontWeight: 700, fontSize: 17 }}>{name}</div>
        <ProgressBar value={progress} light />
        <div style={{ fontFamily: 'Tajawal, sans-serif', fontSize: 11, opacity: 0.85 }}>{progress}٪ مكتمل</div>
      </div>
    </div>
  );
}

// ─── Lesson Button (big blue pill) ────────────────────────────
function LessonButton({ children, num }) {
  return (
    <div style={{
      borderRadius: 16,
      background: ebGradient,
      color: '#fff', minHeight: 60,
      display: 'flex', alignItems: 'center', gap: 12,
      paddingInline: 16,
      boxShadow: '0 10px 22px -14px rgba(15,95,168,0.55)',
    }}>
      {num !== undefined && (
        <div style={{
          width: 32, height: 32, borderRadius: 10,
          background: 'rgba(255,255,255,0.18)',
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          fontFamily: 'Inter, sans-serif', fontWeight: 700, fontSize: 13,
        }}>{num}</div>
      )}
      <div style={{ flex: 1, fontFamily: 'Tajawal, sans-serif', fontWeight: 600, fontSize: 15, lineHeight: 1.3 }}>{children}</div>
      <ChevRtl color="rgba(255,255,255,0.85)" />
    </div>
  );
}

// ─── Video Card ───────────────────────────────────────────────
function VideoCard({ title, subtitle, thumb }) {
  return (
    <div style={{
      background: '#fff', borderRadius: 18, overflow: 'hidden',
      boxShadow: '0 6px 18px -10px rgba(20,30,60,0.18)',
      border: `1px solid ${EB.line}`,
    }}>
      <div style={{
        position: 'relative', aspectRatio: '16/9',
        background: thumb || `linear-gradient(135deg, #b8c6d8, #6e8aa8)`,
        backgroundSize: 'cover', backgroundPosition: 'center',
      }}>
        {/* whiteboard placeholder */}
        {!thumb && (
          <svg viewBox="0 0 320 180" style={{ position: 'absolute', inset: 0, width: '100%', height: '100%' }}>
            <rect width="320" height="180" fill="#E9EEF4"/>
            <g stroke="#6F7E94" strokeWidth="1.4" fill="none" opacity="0.55">
              <path d="M28 36 L60 36 M28 52 L96 52 M28 68 L72 68"/>
              <circle cx="200" cy="80" r="20"/>
              <path d="M200 80 L220 60 M200 80 L180 64"/>
              <path d="M40 130 Q 60 110 80 130 T 120 130"/>
            </g>
            <text x="160" y="170" textAnchor="middle" fontFamily="Inter, monospace" fontSize="9" fill="#7A8499">whiteboard footage</text>
          </svg>
        )}
        {/* play button */}
        <div style={{
          position: 'absolute', inset: 0,
          display: 'flex', alignItems: 'center', justifyContent: 'center',
        }}>
          <div style={{
            width: 52, height: 52, borderRadius: '50%',
            background: 'rgba(15,95,168,0.92)',
            border: '3px solid #fff',
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            boxShadow: '0 10px 24px rgba(0,0,0,0.25)',
          }}>
            <svg width="20" height="20" viewBox="0 0 24 24" fill="#fff">
              <path d="M8 5 L20 12 L8 19 Z"/>
            </svg>
          </div>
        </div>
        {/* duration */}
        <div style={{
          position: 'absolute', bottom: 8, insetInlineEnd: 8,
          background: 'rgba(0,0,0,0.65)', color: '#fff',
          fontFamily: 'Inter, sans-serif', fontSize: 11, fontWeight: 600,
          paddingInline: 8, paddingBlock: 3, borderRadius: 6,
        }}>12:48</div>
      </div>
      <div style={{
        padding: 12, paddingInline: 14,
        display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: 10,
      }}>
        <div style={{
          width: 36, height: 36, borderRadius: 10,
          background: EB.primarySoft, color: EB.primary,
          display: 'flex', alignItems: 'center', justifyContent: 'center',
        }}>
          <DownloadIcon size={18}/>
        </div>
        <div style={{ textAlign: 'right' }}>
          <div style={{ fontFamily: 'Tajawal, sans-serif', fontWeight: 700, fontSize: 15, color: EB.ink }}>{title}</div>
          {subtitle && <div style={{ fontFamily: 'Tajawal, sans-serif', fontSize: 12, color: EB.muted, marginTop: 2 }}>{subtitle}</div>}
        </div>
      </div>
    </div>
  );
}

// ─── Teacher Card ─────────────────────────────────────────────
function TeacherCard({ name, subject, color = EB.primary, initials }) {
  return (
    <div style={{
      background: '#fff',
      border: `1.5px solid ${EB.primarySoft}`,
      borderRadius: 20, padding: 16,
      display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 10,
      boxShadow: '0 6px 16px -12px rgba(20,30,60,0.2)',
    }}>
      <div style={{ position: 'relative' }}>
        <div style={{
          width: 76, height: 76, borderRadius: '50%',
          background: `linear-gradient(135deg, ${color}, ${EB.primaryDark})`,
          color: '#fff', display: 'flex', alignItems: 'center', justifyContent: 'center',
          fontFamily: 'Tajawal, sans-serif', fontWeight: 800, fontSize: 26,
          border: `3px solid #fff`,
          boxShadow: `0 6px 14px -6px ${color}99`,
        }}>{initials}</div>
        <div style={{
          position: 'absolute', bottom: 0, insetInlineEnd: 0,
          width: 22, height: 22, borderRadius: '50%',
          background: EB.success, border: '2.5px solid #fff',
        }}/>
      </div>
      <div style={{ textAlign: 'center' }}>
        <div style={{ fontFamily: 'Tajawal, sans-serif', fontWeight: 700, fontSize: 14, color: EB.ink }}>{name}</div>
        <div style={{ fontFamily: 'Tajawal, sans-serif', fontSize: 12, color: EB.muted, marginTop: 2 }}>{subject}</div>
      </div>
      <div style={{
        background: EB.primarySoft, color: EB.primary,
        fontFamily: 'Tajawal, sans-serif', fontWeight: 600, fontSize: 11,
        paddingInline: 10, paddingBlock: 4, borderRadius: 999,
      }}>عرض الوحدات</div>
    </div>
  );
}

// ─── Section title ────────────────────────────────────────────
function SectionTitle({ children, action }) {
  return (
    <div style={{
      display: 'flex', alignItems: 'center', justifyContent: 'space-between',
      marginBlock: 14,
    }}>
      <div style={{
        fontFamily: 'Tajawal, sans-serif', fontWeight: 800, fontSize: 17, color: EB.ink,
      }}>{children}</div>
      {action && (
        <div style={{ fontFamily: 'Tajawal, sans-serif', fontSize: 13, color: EB.primary, fontWeight: 600 }}>{action}</div>
      )}
    </div>
  );
}

// ─── Icons ────────────────────────────────────────────────────
function Icon({ children, size = 20, stroke = 'currentColor' }) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke={stroke} strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">
      {children}
    </svg>
  );
}

const BellIcon    = ({ size }) => <Icon size={size}><path d="M6 8a6 6 0 0 1 12 0c0 7 3 9 3 9H3s3-2 3-9"/><path d="M10 21a2 2 0 0 0 4 0"/></Icon>;
const MenuIcon    = ({ size }) => <Icon size={size}><path d="M4 6h16M4 12h16M4 18h16"/></Icon>;
const BackArrow   = ({ size }) => <Icon size={size}><path d="M5 12h14M12 5l7 7-7 7"/></Icon>; // RTL → "back" arrow points right
const HomeIcon    = ({ size }) => <Icon size={size}><path d="M3 11l9-8 9 8v10a1 1 0 0 1-1 1h-5v-7H9v7H4a1 1 0 0 1-1-1z"/></Icon>;
const UserIcon    = ({ size }) => <Icon size={size}><circle cx="12" cy="8" r="4"/><path d="M4 21c0-4.4 3.6-8 8-8s8 3.6 8 8"/></Icon>;
const CalcIcon    = ({ size }) => <Icon size={size}><rect x="4" y="3" width="16" height="18" rx="3"/><path d="M8 7h8M8 12h2M14 12h2M8 16h2M14 16h2"/></Icon>;
const DownloadIcon= ({ size }) => <Icon size={size}><path d="M12 3v12M7 10l5 5 5-5M4 21h16"/></Icon>;
const ChevDown    = ({ size = 16 }) => <Icon size={size}><path d="M6 9l6 6 6-6"/></Icon>;
const ChevRtl     = ({ color = EB.muted, size = 18 }) => <Icon size={size} stroke={color}><path d="M15 6l-6 6 6 6"/></Icon>;
const SearchIcon  = ({ size }) => <Icon size={size}><circle cx="11" cy="11" r="7"/><path d="M21 21l-5-5"/></Icon>;
const PlayIcon    = ({ size }) => <Icon size={size}><path d="M6 4l14 8-14 8z" fill="currentColor"/></Icon>;
const EyeIcon     = ({ size }) => <Icon size={size}><path d="M2 12s4-7 10-7 10 7 10 7-4 7-10 7S2 12 2 12z"/><circle cx="12" cy="12" r="3"/></Icon>;
const EyeOff      = ({ size }) => <Icon size={size}><path d="M3 3l18 18"/><path d="M10.6 6.1A10.9 10.9 0 0 1 12 6c6 0 10 6 10 6a17 17 0 0 1-3.2 3.9M6.6 6.6A17 17 0 0 0 2 12s4 6 10 6c1.5 0 2.8-.3 4-.8"/></Icon>;
const PhoneIcon   = ({ size }) => <Icon size={size}><path d="M22 16.9v3a2 2 0 0 1-2.2 2 19.8 19.8 0 0 1-8.6-3.1 19.5 19.5 0 0 1-6-6A19.8 19.8 0 0 1 2.1 4.2 2 2 0 0 1 4.1 2h3a2 2 0 0 1 2 1.7c.1.9.3 1.8.6 2.6a2 2 0 0 1-.5 2.1L7.9 9.7a16 16 0 0 0 6 6l1.3-1.3a2 2 0 0 1 2.1-.5c.8.3 1.7.5 2.6.6a2 2 0 0 1 1.7 2z"/></Icon>;
const CheckIcon   = ({ size }) => <Icon size={size}><path d="M20 6L9 17l-5-5"/></Icon>;
const EditIcon    = ({ size }) => <Icon size={size}><path d="M12 20h9"/><path d="M16.5 3.5a2.1 2.1 0 1 1 3 3L7 19l-4 1 1-4z"/></Icon>;
const LogoutIcon  = ({ size }) => <Icon size={size}><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/><path d="M16 17l5-5-5-5M21 12H9"/></Icon>;
const TrophyIcon  = ({ size }) => <Icon size={size}><path d="M8 21h8M12 17v4M7 4h10v5a5 5 0 0 1-10 0z"/><path d="M17 5h3v3a3 3 0 0 1-3 3M7 5H4v3a3 3 0 0 0 3 3"/></Icon>;
const ClockIcon   = ({ size }) => <Icon size={size}><circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 2"/></Icon>;

// ─── Mauritania flag chip ─────────────────────────────────────
function MRFlag() {
  return (
    <svg width="22" height="16" viewBox="0 0 22 16" style={{ borderRadius: 3, overflow: 'hidden' }}>
      <rect width="22" height="2.4" fill="#D7424B"/>
      <rect y="2.4" width="22" height="11.2" fill="#0B7A3B"/>
      <rect y="13.6" width="22" height="2.4" fill="#D7424B"/>
      <path d="M11 5.5 a2.6 2.6 0 1 0 0 5.2 a2.2 2.2 0 1 1 0 -5.2" fill="#FFC107"/>
      <path d="M11 4.8 l0.4 1.1 l1.2 0 l-1 0.7 l0.4 1.1 l-1-0.7 l-1 0.7 l0.4 -1.1 l-1 -0.7 l1.2 0 z" fill="#FFC107"/>
    </svg>
  );
}

// ─── Subject Icons (custom) ───────────────────────────────────
const SubjectIcons = {
  math: (
    <svg width="28" height="28" viewBox="0 0 32 32" fill="none" stroke="#fff" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round">
      <circle cx="9" cy="9" r="3"/>
      <path d="M19 6h6M22 3v6"/>
      <path d="M6 19l6 6M12 19l-6 6"/>
      <path d="M19 22h6M19 25h6"/>
    </svg>
  ),
  science: (
    <svg width="28" height="28" viewBox="0 0 32 32" fill="none" stroke="#fff" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M12 3h8M13 3v8l-6 12a3 3 0 0 0 2.7 4.5h12.6A3 3 0 0 0 25 23L19 11V3"/>
      <circle cx="14" cy="20" r="1.3" fill="#fff"/>
      <circle cx="19" cy="23" r="1" fill="#fff"/>
    </svg>
  ),
  physics: (
    <svg width="28" height="28" viewBox="0 0 32 32" fill="none" stroke="#fff" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round">
      <ellipse cx="16" cy="16" rx="12" ry="5"/>
      <ellipse cx="16" cy="16" rx="12" ry="5" transform="rotate(60 16 16)"/>
      <ellipse cx="16" cy="16" rx="12" ry="5" transform="rotate(-60 16 16)"/>
      <circle cx="16" cy="16" r="1.8" fill="#fff"/>
    </svg>
  ),
  arabic: (
    <svg width="32" height="28" viewBox="0 0 36 28" fill="none">
      <text x="18" y="22" textAnchor="middle" fontFamily="Tajawal, serif" fontWeight="900" fontSize="26" fill="#fff">ع</text>
    </svg>
  ),
  islamic: (
    <svg width="28" height="28" viewBox="0 0 32 32" fill="none" stroke="#fff" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M22 6a10 10 0 1 0 4 14 8 8 0 1 1-4-14z"/>
      <path d="M9 11l1 2 2 .3-1.5 1.4.3 2L9 15.7 7.2 16.7l.3-2L6 13.3l2-.3z" fill="#fff"/>
    </svg>
  ),
};

// Expose to other Babel scripts
Object.assign(window, {
  EB, ebGradient,
  EBLogo, AppHeader, BottomNav, PrimaryButton, FormInput, SelectInput, PhoneInput,
  ProgressBar, SubjectCard, LessonButton, VideoCard, TeacherCard, SectionTitle,
  IconBtn,
  BellIcon, MenuIcon, BackArrow, HomeIcon, UserIcon, CalcIcon, DownloadIcon,
  ChevDown, ChevRtl, SearchIcon, PlayIcon, EyeIcon, EyeOff, PhoneIcon, CheckIcon,
  EditIcon, LogoutIcon, TrophyIcon, ClockIcon, MRFlag, SubjectIcons,
});
