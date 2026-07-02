import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// يدير وضع السمة (فاتح/داكن) ويحفظه محلياً في shared_preferences.
/// يُستخدم كـ ValueNotifier حتى يعيد MaterialApp البناء عند التبديل،
/// كما تقرأ منه AppColors ألوانها الديناميكية.
class ThemeController {
  ThemeController._();
  static final ThemeController instance = ThemeController._();

  static const _prefsKey = 'app_theme_mode';

  /// الافتراضي: فاتح (سلوك التطبيق الحالي بلا تغيير).
  final ValueNotifier<ThemeMode> mode = ValueNotifier<ThemeMode>(ThemeMode.light);

  bool get isDark => mode.value == ThemeMode.dark;

  /// يُستدعى مرة عند الإقلاع لاستعادة السمة المحفوظة.
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final v = prefs.getString(_prefsKey);
      if (v == 'dark') {
        mode.value = ThemeMode.dark;
      } else if (v == 'light') {
        mode.value = ThemeMode.light;
      }
    } catch (_) {
      // عند أي فشل نبقى على الفاتح — لا يكسر الإقلاع.
    }
  }

  Future<void> toggle() => setDark(!isDark);

  Future<void> setDark(bool dark) async {
    final next = dark ? ThemeMode.dark : ThemeMode.light;
    if (mode.value == next) return;
    mode.value = next;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, dark ? 'dark' : 'light');
    } catch (_) {
      // الحفظ best-effort؛ التبديل الحيّ يعمل على أي حال.
    }
  }
}

final themeController = ThemeController.instance;
