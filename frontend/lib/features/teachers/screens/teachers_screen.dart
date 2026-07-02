import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/i18n/app_strings.dart';
import '../../../core/models/teacher.dart';
import '../../../core/services/teacher_service.dart';
import '../../../core/utils/url_helper.dart';
import '../../../shared/widgets/api_state_widget.dart';
import '../../../shared/widgets/app_header.dart';

class TeachersScreen extends StatefulWidget {
  const TeachersScreen({super.key});

  @override
  State<TeachersScreen> createState() => _TeachersScreenState();
}

class _TeachersScreenState extends State<TeachersScreen> {
  late Future<List<Teacher>> _future;
  int? _subjectId;


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_subjectId == null) {
      _subjectId = ModalRoute.of(context)?.settings.arguments as int?;
      _future = teacherService.getTeachers(subjectId: _subjectId);
    }
  }

  void _reload() => setState(() {
    _future = teacherService.getTeachers(subjectId: _subjectId);
  });

  Widget _avatarPlaceholder() => Container(
        color: AppColors.accentLight,
        child: const Center(child: Icon(Icons.person_rounded, size: 30, color: AppColors.primary)),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(title: tr('teachers.title')),
      body: ApiBuilder<List<Teacher>>(
        future: _future,
        onRetry: _reload,
        builder: (teachers) => teachers.isEmpty
            ? Center(child: Text(tr('teachers.none'), style: const TextStyle(fontFamily: 'Cairo', color: AppColors.textSecondary)))
            : ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: teachers.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final t = teachers[i];
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: SizedBox(
                            width: 58,
                            height: 58,
                            child: t.avatarUrl.isNotEmpty
                                ? Image.network(
                                    buildFileUrl(t.avatarUrl),
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => _avatarPlaceholder(),
                                  )
                                : _avatarPlaceholder(),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(t.fullName, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 15)),
                              if (t.bio.isNotEmpty)
                                Text(t.bio, style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
