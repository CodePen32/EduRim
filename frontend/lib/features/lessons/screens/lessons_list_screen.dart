import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/lesson.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/lesson_service.dart';
import '../../../core/utils/url_helper.dart';
import '../../../shared/widgets/api_state_widget.dart';
import '../../../shared/widgets/app_header.dart';

class LessonsListScreen extends StatefulWidget {
  const LessonsListScreen({super.key});

  @override
  State<LessonsListScreen> createState() => _LessonsListScreenState();
}

class _LessonsListScreenState extends State<LessonsListScreen> {
  late Future<List<Lesson>> _future;
  int? _subjectId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_subjectId == null) {
      _subjectId = ModalRoute.of(context)?.settings.arguments as int?;
      _future = lessonService.getLessons(subjectId: _subjectId);
    }
  }

  void _reload() => setState(() {
    _future = lessonService.getLessons(subjectId: _subjectId);
  });

  @override
  Widget build(BuildContext context) {
    final title = _subjectId != null ? 'دروس المادة' : 'جميع الدروس';
    return Scaffold(
      appBar: AppHeader(title: title),
      body: ApiBuilder<List<Lesson>>(
        future: _future,
        onRetry: _reload,
        builder: (lessons) => lessons.isEmpty
            ? const Center(child: Text('لا توجد دروس حالياً', style: TextStyle(fontFamily: 'Cairo', color: AppColors.textSecondary)))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: lessons.length,
                itemBuilder: (context, i) {
                  final l = lessons[i];
                  return _LessonCard(
                    lesson: l,
                    index: i + 1,
                    onTap: () => Navigator.pushNamed(context, AppRoutes.lessonDetails, arguments: l),
                  );
                },
              ),
      ),
    );
  }
}

class _LessonCard extends StatelessWidget {
  final Lesson lesson;
  final int index;
  final VoidCallback onTap;

  const _LessonCard({required this.lesson, required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasCover = lesson.coverImageUrl.isNotEmpty;
    final coverUrl = hasCover ? buildFileUrl(lesson.coverImageUrl) : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Cover كبير + Play وسط + Badge رقم ──
          GestureDetector(
            onTap: onTap,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (hasCover)
                      Image.network(
                        coverUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => _placeholderBox(),
                      )
                    else
                      _placeholderBox(),
                    // تعتيم خفيف لإبراز زر التشغيل
                    Container(color: Colors.black.withValues(alpha: 0.18)),
                    // زر Play دائري في الوسط
                    Center(
                      child: Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.92),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Icon(
                          lesson.isFree ? Icons.play_arrow_rounded : Icons.lock_rounded,
                          color: AppColors.primary,
                          size: 34,
                        ),
                      ),
                    ),
                    // Badge رقم الدرس في الزاوية
                    PositionedDirectional(
                      top: 10,
                      start: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '#$index',
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    // شارة "مجاني" أعلى الجهة المقابلة
                    if (lesson.isFree)
                      PositionedDirectional(
                        top: 10,
                        end: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'مجاني',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          // ── العنوان أسفل الصورة ──
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
            child: Text(
              lesson.title,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: AppColors.textPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (lesson.durationLabel.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 4, 14, 0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.access_time, size: 13, color: AppColors.textLight),
                  const SizedBox(width: 4),
                  Text(
                    lesson.durationLabel,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
          const Divider(height: 20, thickness: 1, color: AppColors.divider),
          // ── زر "شاهد" + زر التنزيل ──
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: onTap,
                    icon: const Icon(Icons.play_circle_outline, size: 20, color: AppColors.primary),
                    label: const Text(
                      'شاهد',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      alignment: AlignmentDirectional.centerStart,
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onTap,
                  tooltip: 'تنزيل',
                  icon: const Icon(Icons.download_rounded, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholderBox() => Container(
        color: AppColors.primaryDark,
        child: const Center(child: Icon(Icons.menu_book_outlined, color: Colors.white54, size: 40)),
      );
}
