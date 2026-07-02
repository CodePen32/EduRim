import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// يدير لغة التطبيق (ar / fr) ويحفظها محلياً في shared_preferences.
/// - ar → RTL
/// - fr → LTR
/// يُستخدم كـ ValueNotifier حتى يعيد MaterialApp البناء عند التغيير.
class LocaleController {
  LocaleController._();
  static final LocaleController instance = LocaleController._();

  static const _prefsKey = 'app_locale_code';
  static const _supported = ['ar', 'fr'];

  /// الافتراضي: العربية (سلوك التطبيق الحالي بلا تغيير).
  final ValueNotifier<Locale> locale = ValueNotifier<Locale>(const Locale('ar'));

  bool get isArabic => locale.value.languageCode == 'ar';

  TextDirection get direction =>
      isArabic ? TextDirection.rtl : TextDirection.ltr;

  /// يُستدعى مرة عند الإقلاع لاستعادة اللغة المحفوظة.
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(_prefsKey);
      if (code != null && _supported.contains(code)) {
        locale.value = Locale(code);
      }
    } catch (_) {
      // عند أي فشل نبقى على العربية — لا يكسر الإقلاع.
    }
  }

  Future<void> setLocale(String code) async {
    if (!_supported.contains(code)) return;
    if (locale.value.languageCode == code) return;
    locale.value = Locale(code);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, code);
    } catch (_) {
      // الحفظ best-effort؛ التغيير الحيّ يعمل على أي حال.
    }
  }
}

final localeController = LocaleController.instance;
