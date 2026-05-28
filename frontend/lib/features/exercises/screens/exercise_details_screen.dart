import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/exercise.dart';
import '../../../core/services/download_service.dart';
import '../../../core/services/favorite_service.dart';
import '../../../core/utils/url_helper.dart';
import '../../../shared/widgets/app_header.dart';
import '../../../shared/widgets/primary_button.dart';

class ExerciseDetailsScreen extends StatefulWidget {
  const ExerciseDetailsScreen({super.key});

  @override
  State<ExerciseDetailsScreen> createState() => _ExerciseDetailsScreenState();
}

class _ExerciseDetailsScreenState extends State<ExerciseDetailsScreen> {
  bool _favorited = false;
  bool _saved = false;

  Future<void> _toggleFavorite(int exerciseId) async {
    try {
      final added = await favoriteService.addFavorite(itemType: 'exercise', itemId: exerciseId);
      if (!mounted) return;
      if (added) {
        setState(() => _favorited = true);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تمت الإضافة إلى المفضلة ❤️', style: TextStyle(fontFamily: 'Cairo')), backgroundColor: AppColors.error, behavior: SnackBarBehavior.floating));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('التمرين موجود في المفضلة بالفعل', style: TextStyle(fontFamily: 'Cairo')), behavior: SnackBarBehavior.floating));
      }
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تعذر الإضافة', style: TextStyle(fontFamily: 'Cairo')), behavior: SnackBarBehavior.floating));
    }
  }

  Future<void> _saveExercise(int exerciseId) async {
    try {
      final saved = await downloadService.addDownload(itemType: 'exercise', itemId: exerciseId);
      if (!mounted) return;
      if (saved) {
        setState(() => _saved = true);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حفظ التمرين في قائمة التنزيلات', style: TextStyle(fontFamily: 'Cairo')), backgroundColor: AppColors.success, behavior: SnackBarBehavior.floating));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('التمرين محفوظ بالفعل', style: TextStyle(fontFamily: 'Cairo')), behavior: SnackBarBehavior.floating));
      }
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تعذر الحفظ', style: TextStyle(fontFamily: 'Cairo')), behavior: SnackBarBehavior.floating));
    }
  }

  Color _difficultyColor(String d) {
    switch (d) {
      case 'سهل':
        return AppColors.success;
      case 'متوسط':
        return AppColors.warning;
      default:
        return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final exercise = ModalRoute.of(context)?.settings.arguments as Exercise?;

    final title = exercise?.title ?? 'تفاصيل التمرين';
    final year = exercise?.year ?? 0;
    final difficulty = exercise?.difficulty ?? 'متوسط';
    final exerciseUrl = exercise?.exerciseFileUrl ?? '';
    final solutionUrl = exercise?.solutionFileUrl ?? '';
    final videoUrl = exercise?.videoSolutionUrl ?? '';
    final hasFile = exerciseUrl.isNotEmpty;
    final hasSolution = solutionUrl.isNotEmpty;
    final hasVideo = videoUrl.isNotEmpty;
    final diffColor = _difficultyColor(difficulty);
    final exerciseId = exercise?.id ?? 0;

    return Scaffold(
      appBar: const AppHeader(title: 'تفاصيل التمرين'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.quiz_rounded, size: 40, color: Colors.white),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.white),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            if (year > 0) ...[
                              const Icon(Icons.calendar_today, size: 13, color: Colors.white70),
                              const SizedBox(width: 4),
                              Text('سنة $year', style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.white70)),
                              const SizedBox(width: 12),
                            ],
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: diffColor.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                difficulty,
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 11,
                                  color: diffColor == AppColors.warning ? Colors.orange.shade200 : Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            const Text('موارد التمرين', style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 14),

            // ملف التمرين
            _ResourceCard(
              title: 'ملف التمرين',
              subtitle: hasFile ? 'اضغط لعرض التمرين' : 'ملف التمرين غير متاح حالياً',
              icon: Icons.picture_as_pdf_outlined,
              color: AppColors.error,
              enabled: hasFile,
              onTap: () => openExternalUrl(exerciseUrl, context: context),
            ),
            const SizedBox(height: 10),

            // الحل النموذجي
            _ResourceCard(
              title: 'الحل النموذجي',
              subtitle: hasSolution ? 'اضغط لعرض الحل' : 'الحل غير متاح حالياً',
              icon: Icons.check_circle_outline,
              color: AppColors.success,
              enabled: hasSolution,
              onTap: () => openExternalUrl(solutionUrl, context: context),
            ),
            const SizedBox(height: 10),

            // فيديو الحل
            _ResourceCard(
              title: 'فيديو الحل',
              subtitle: hasVideo ? 'شاهد شرح الحل بالفيديو' : 'شرح الفيديو غير متاح حالياً',
              icon: Icons.play_circle_outline,
              color: AppColors.primary,
              enabled: hasVideo,
              onTap: () => openExternalUrl(videoUrl, context: context),
            ),
            const SizedBox(height: 28),

            PrimaryButton(
              label: hasFile ? 'فتح ملف التمرين' : 'ملف التمرين غير متاح حالياً',
              icon: Icons.open_in_new_rounded,
              onPressed: hasFile
                  ? () => openExternalUrl(exerciseUrl, context: context)
                  : () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('ملف التمرين غير متاح حالياً', style: TextStyle(fontFamily: 'Cairo')),
                          behavior: SnackBarBehavior.floating,
                          duration: Duration(seconds: 2),
                        ),
                      ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: exerciseId > 0 ? () => _toggleFavorite(exerciseId) : null,
                    icon: Icon(_favorited ? Icons.favorite : Icons.favorite_border,
                        color: _favorited ? AppColors.error : AppColors.primary),
                    label: Text(_favorited ? 'في المفضلة' : 'إضافة للمفضلة',
                        style: const TextStyle(fontFamily: 'Cairo')),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _favorited ? AppColors.error : AppColors.primary,
                      side: BorderSide(color: _favorited ? AppColors.error : AppColors.primary),
                      minimumSize: const Size(0, 48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: exerciseId > 0 ? () => _saveExercise(exerciseId) : null,
                    icon: Icon(_saved ? Icons.bookmark : Icons.bookmark_border,
                        color: _saved ? AppColors.success : AppColors.primary),
                    label: Text(_saved ? 'محفوظ' : 'حفظ التمرين',
                        style: const TextStyle(fontFamily: 'Cairo')),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _saved ? AppColors.success : AppColors.primary,
                      side: BorderSide(color: _saved ? AppColors.success : AppColors.primary),
                      minimumSize: const Size(0, 48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ResourceCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool enabled;
  final VoidCallback onTap;

  const _ResourceCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = enabled ? color : AppColors.textLight;
    return GestureDetector(
      onTap: enabled
          ? onTap
          : () => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(subtitle, style: const TextStyle(fontFamily: 'Cairo')),
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 2),
                ),
              ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: enabled ? AppColors.cardBorder : AppColors.background),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: effectiveColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: effectiveColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 14, color: enabled ? AppColors.textPrimary : AppColors.textLight),
                  ),
                  Text(subtitle, style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
            Icon(enabled ? Icons.arrow_forward_ios : Icons.lock_outline, size: 14, color: AppColors.textLight),
          ],
        ),
      ),
    );
  }
}
