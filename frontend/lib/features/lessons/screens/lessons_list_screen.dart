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
  final VoidCallback onTap;

  const _LessonCard({required this.lesson, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasCover = lesson.coverImageUrl.isNotEmpty;
    final coverUrl = hasCover ? buildFileUrl(lesson.coverImageUrl) : '';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Row(
          children: [
            // ── Thumbnail ──
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              child: SizedBox(
                width: 110,
                height: 86,
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
                    // overlay خفيف + أيقونة
                    Container(
                      color: Colors.black.withValues(alpha: 0.25),
                      child: Center(
                        child: Icon(
                          lesson.isFree ? Icons.play_circle_filled : Icons.lock_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            // ── Info ──
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson.title,
                      style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 13, color: AppColors.textLight),
                        const SizedBox(width: 4),
                        Text(lesson.durationLabel, style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.textLight)),
                        const SizedBox(width: 8),
                        if (lesson.isFree)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text('مجاني', style: TextStyle(fontFamily: 'Cairo', fontSize: 10, color: AppColors.success, fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 10),
              child: Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textLight),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderBox() => Container(
        color: AppColors.primaryDark,
        child: const Center(child: Icon(Icons.menu_book_outlined, color: Colors.white54, size: 30)),
      );
}
