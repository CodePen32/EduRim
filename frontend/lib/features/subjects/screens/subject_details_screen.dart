import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/i18n/app_strings.dart';
import '../../../core/i18n/locale_controller.dart';
import '../../../core/models/lesson.dart';
import '../../../core/models/subject.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/lesson_service.dart';
import '../../../shared/widgets/api_state_widget.dart';
import '../../../shared/widgets/app_header.dart';

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

  /// اسم المادة حسب لغة الواجهة (بيانات API — نختار الحقل المناسب فقط).
  String get _subjectName {
    final s = _subject;
    if (s == null) return tr('subject.fallback');
    if (localeController.isArabic) {
      return s.nameAr.isNotEmpty ? s.nameAr : s.nameFr;
    }
    return s.nameFr.isNotEmpty ? s.nameFr : s.nameAr;
  }

  @override
  Widget build(BuildContext context) {
    // العنوان: «الوحدات - {اسم المادة}» / «Unités - {matière}»
    final title = '${tr('subject.unitsPrefix')}$_subjectName';

    return Scaffold(
      appBar: AppHeader(title: title),
      body: ApiBuilder<List<Lesson>>(
        future: _lessonsFuture,
        onRetry: _reload,
        builder: (lessons) {
          if (lessons.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  tr('subject.noLessons'),
                  style: const TextStyle(fontFamily: 'Cairo', color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: lessons.length,
            separatorBuilder: (_, _) => const SizedBox(height: 14),
            itemBuilder: (context, i) {
              final l = lessons[i];
              return _UnitTile(
                title: l.title,
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.lessonDetails,
                  arguments: l,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// مستطيل وحدة/درس كبير — أزرق، نص أبيض في الوسط، حواف 22.
class _UnitTile extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _UnitTile({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          constraints: const BoxConstraints(minHeight: 100),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          alignment: Alignment.center,
          child: Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
        ),
      ),
    );
  }
}
