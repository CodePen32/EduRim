import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/i18n/app_strings.dart';
import '../../../core/i18n/locale_controller.dart';
import '../../../shared/widgets/app_header.dart';

/// صفحة تغيير اللغة (العربية / الفرنسية).
/// الاختيار يُحفظ محلياً ويطبَّق فوراً على كامل التطبيق.
class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  Future<void> _select(String code) async {
    await localeController.setLocale(code);
    if (!mounted) return;
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(tr('lang.changed'),
          style: const TextStyle(fontFamily: 'Cairo')),
      backgroundColor: AppColors.success,
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final current = localeController.locale.value.languageCode;
    return Scaffold(
      appBar: AppHeader(title: tr('lang.title')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _LangTile(
            flag: '🇸🇦',
            label: tr('lang.arabic'),
            selected: current == 'ar',
            onTap: () => _select('ar'),
          ),
          const SizedBox(height: 12),
          _LangTile(
            flag: '🇫🇷',
            label: tr('lang.french'),
            selected: current == 'fr',
            onTap: () => _select('fr'),
          ),
        ],
      ),
    );
  }
}

class _LangTile extends StatelessWidget {
  final String flag;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LangTile({
    required this.flag,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.cardBorder,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Text(flag, style: const TextStyle(fontSize: 26)),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (selected)
                const Icon(Icons.check_circle_rounded,
                    color: AppColors.primary, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}
