import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Default (fallback) visuals for subjects that have no admin-uploaded cover.
///
/// Priority elsewhere stays: if a subject has `coverImageUrl`, that image is
/// shown; only when it is empty do we fall back to [subjectIcon] /
/// [DefaultSubjectCover] here. Icons are built-in Material glyphs (no extra
/// package, no asset bloat) rendered white on the app's blue gradient, to
/// match the unified Concouri subject-icon style.
IconData subjectIcon(String nameAr, String nameFr) {
  // Lowercase both so Latin keywords match even when stored in the Arabic
  // field (e.g. some subjects are named "Français"/"mathématiques" there).
  // Arabic letters are unaffected by toLowerCase.
  final ar = nameAr.trim().toLowerCase();
  final fr = nameFr.trim().toLowerCase();
  bool has(List<String> keys) =>
      keys.any((k) => ar.contains(k) || fr.contains(k));

  // Order matters: more specific subjects before broader ones.
  if (has(['رياض', 'math'])) return Icons.calculate_rounded;
  if (has(['فيزياء', 'physi'])) return Icons.science_rounded;
  if (has(['كيمياء', 'chimi', 'chemi'])) return Icons.science_outlined;
  if (has(['أحياء', 'احياء', 'biolog'])) return Icons.spa_rounded;
  // علوم الطبيعة / SVT / sciences — microscope
  if (has(['علوم', 'sciences', 'svt', 'naturel'])) return Icons.biotech_rounded;
  if (has(['عرب', 'arab'])) return Icons.menu_book_rounded;
  if (has(['فرنس', 'français', 'francais', 'french'])) {
    return Icons.translate_rounded;
  }
  if (has(['إنجليز', 'انجليز', 'anglais', 'english'])) {
    return Icons.language_rounded;
  }
  if (has(['إسلام', 'اسلام', 'islam', 'دين', 'شرع'])) {
    return Icons.mosque_rounded;
  }
  if (has(['تاريخ', 'جغراف', 'histoire', 'géo', 'geo'])) {
    return Icons.public_rounded;
  }
  if (has(['فلسف', 'philo'])) return Icons.psychology_rounded;
  if (has(['إعلام', 'اعلام', 'معلومات', 'حاسوب', 'informat', 'comput'])) {
    return Icons.computer_rounded;
  }
  if (has(['محاسب', 'comptab', 'account'])) {
    return Icons.account_balance_wallet_rounded;
  }
  if (has(['اقتصاد', 'écono', 'econo', 'gestion'])) {
    return Icons.bar_chart_rounded;
  }
  if (has(['مدني', 'مواطن', 'civi'])) return Icons.balance_rounded;
  if (has(['بدني', 'رياضة البدن', 'sport', 'eps', 'physique et sport'])) {
    return Icons.directions_run_rounded;
  }
  // Generic fallback for any unknown subject.
  return Icons.auto_stories_rounded;
}

/// Reusable default subject cover: white [subjectIcon] centered on the app's
/// blue gradient, with the subject name below — matching the unified
/// Concouri style. Used wherever a subject has no uploaded cover.
class DefaultSubjectCover extends StatelessWidget {
  final String nameAr;
  final String nameFr;
  final bool showLabel;

  const DefaultSubjectCover({
    super.key,
    required this.nameAr,
    this.nameFr = '',
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final icon = subjectIcon(nameAr, nameFr);
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 44),
            if (showLabel && nameAr.isNotEmpty) ...[
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  nameAr,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
