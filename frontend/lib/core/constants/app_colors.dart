import 'package:flutter/material.dart';
import '../theme/theme_controller.dart';

class AppColors {
  // ── ألوان الهوية (ثابتة في الوضعين) ──
  static const Color primary = Color(0xFF1565C0);
  static const Color primaryDark = Color(0xFF0D47A1);
  static const Color primaryLight = Color(0xFF1976D2);
  static const Color accent = Color(0xFF2196F3);
  static const Color accentLight = Color(0xFFBBDEFB);

  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);

  // النصوص الثابتة على الأسطح الملوّنة (تبقى بيضاء دائماً).
  static const Color white = Color(0xFFFFFFFF);

  static bool get _dark => themeController.isDark;

  // ── أسطح ديناميكية حسب الوضع (0 استخدام const، فالتحويل آمن) ──
  // كل الشاشات التي تستخدم AppColors.background/surface مباشرة تتبع الوضع تلقائياً.
  static Color get background => _dark ? const Color(0xFF0F1420) : const Color(0xFFF5F8FF);
  static Color get surface => _dark ? const Color(0xFF1A2232) : const Color(0xFFFFFFFF);

  // ── نصوص/حدود: ثابتة (لها استخدامات const كثيرة). الوضع الداكن
  // يعالج ألوان النص أساساً عبر darkTheme.textTheme و ColorScheme.onSurface. ──
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textLight = Color(0xFF9CA3AF);

  static const Color cardBorder = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFF3F4F6);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryDark, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
