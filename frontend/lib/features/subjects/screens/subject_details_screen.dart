import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/lesson.dart';
import '../../../core/models/subject.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/lesson_service.dart';
import '../../../core/utils/url_helper.dart';
import '../../../shared/widgets/api_state_widget.dart';

class SubjectDetailsScreen extends StatefulWidget {
  const SubjectDetailsScreen({super.key});

  @override
  State<SubjectDetailsScreen> createState() => _SubjectDetailsScreenState();
}

class _SubjectDetailsScreenState extends State<SubjectDetailsScreen> {
  Subject? _subject;
  late Future<List<Lesson>> _lessonsFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_subject == null) {
      _subject = ModalRoute.of(context)?.settings.arguments as Subject?;
      _lessonsFuture = lessonService.getLessons(subjectId: _subject?.id);
    }
  }

  void _reload() => setState(() {
    _lessonsFuture = lessonService.getLessons(subjectId: _subject?.id);
  });

  Color _hexToColor(String hex) {
    try {
      final h = hex.replaceAll('#', '');
      return Color(int.parse('FF$h', radix: 16));
    } catch (_) {
      return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final subject = _subject;
    final subjectColor = subject != null ? _hexToColor(subject.color) : AppColors.primary;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: subjectColor,
            foregroundColor: AppColors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (subject != null && subject.coverImageUrl.isNotEmpty)
                    Image.network(
                      buildFileUrl(subject.coverImageUrl),
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(color: subjectColor),
                    )
                  else
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [subjectColor, subjectColor.withValues(alpha: 0.7)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                  Container(color: subjectColor.withValues(alpha: 0.55)),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      const Icon(Icons.menu_book_rounded, size: 56, color: Colors.white70),
                      const SizedBox(height: 12),
                      Text(
                        subject?.nameAr ?? 'المادة',
                        style: const TextStyle(fontFamily: 'Cairo', fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.white),
                      ),
                      Text(
                        subject?.nameFr ?? '',
                        style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: Colors.white70),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick nav buttons
                  Row(
                    children: [
                      _NavButton(
                        icon: Icons.people_outline,
                        label: 'الأساتذة',
                        color: const Color(0xFF059669),
                        onTap: () => Navigator.pushNamed(context, AppRoutes.teachers, arguments: subject?.id),
                      ),
                      const SizedBox(width: 10),
                      _NavButton(
                        icon: Icons.quiz_outlined,
                        label: 'التمارين',
                        color: const Color(0xFF7C3AED),
                        onTap: () => Navigator.pushNamed(context, AppRoutes.exercisesList, arguments: subject?.id),
                      ),
                      const SizedBox(width: 10),
                      _NavButton(
                        icon: Icons.menu_book_rounded,
                        label: 'كل الدروس',
                        color: AppColors.primary,
                        onTap: () => Navigator.pushNamed(context, AppRoutes.lessonsList, arguments: subject?.id),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _NavButton(
                        icon: Icons.history_edu_outlined,
                        label: 'الامتحانات السابقة',
                        color: const Color(0xFFDC2626),
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.pastExams,
                          arguments: {'subject_id': subject?.id, 'subject_name': subject?.nameAr ?? 'مواضيع الامتحانات'},
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  const Text('الدروس المتاحة', style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          // Lessons list
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            sliver: FutureBuilder<List<Lesson>>(
              future: _lessonsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverToBoxAdapter(child: SizedBox(height: 80, child: LoadingWidget()));
                }
                if (snapshot.hasError) {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: TextButton.icon(
                        onPressed: _reload,
                        icon: const Icon(Icons.refresh),
                        label: const Text('إعادة التحميل', style: TextStyle(fontFamily: 'Cairo')),
                      ),
                    ),
                  );
                }
                final lessons = snapshot.data ?? [];
                if (lessons.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text('لا توجد دروس لهذه المادة حالياً', style: TextStyle(fontFamily: 'Cairo', color: AppColors.textSecondary)),
                      ),
                    ),
                  );
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final l = lessons[i];
                      return _LessonTile(
                        lesson: l,
                        onTap: () => Navigator.pushNamed(context, AppRoutes.lessonDetails, arguments: l),
                      );
                    },
                    childCount: lessons.length,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _NavButton({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
          child: Column(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 4),
              Text(label, style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: color, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

class _LessonTile extends StatelessWidget {
  final Lesson lesson;
  final VoidCallback onTap;

  const _LessonTile({required this.lesson, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: lesson.isFree ? AppColors.success.withValues(alpha: 0.1) : AppColors.accentLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                lesson.isFree ? Icons.play_circle_outline : Icons.lock_outline,
                color: lesson.isFree ? AppColors.success : AppColors.textLight,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(lesson.title, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 12, color: AppColors.textLight),
                      const SizedBox(width: 3),
                      Text(lesson.durationLabel, style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.textLight)),
                      if (lesson.isFree) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                          child: const Text('مجاني', style: TextStyle(fontFamily: 'Cairo', fontSize: 10, color: AppColors.success, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textLight),
          ],
        ),
      ),
    );
  }
}
