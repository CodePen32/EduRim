import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/subject.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/subject_service.dart';
import '../../../core/utils/url_helper.dart';
import '../../../core/utils/subject_visuals.dart';

class SubjectsScreen extends StatefulWidget {
  const SubjectsScreen({super.key});

  @override
  State<SubjectsScreen> createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends State<SubjectsScreen> {
  late Future<List<Subject>> _future;

  @override
  void initState() {
    super.initState();
    _future = subjectService.getMySubjects();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        title: const Text('المواد', style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() => _future = subjectService.getMySubjects(forceRefresh: true));
          await _future;
        },
        child: FutureBuilder<List<Subject>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
              ],
            );
          }
          if (snapshot.hasError) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: 300,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, color: AppColors.error, size: 40),
                        const SizedBox(height: 12),
                        const Text('تعذر تحميل المواد', style: TextStyle(fontFamily: 'Cairo', color: AppColors.textSecondary)),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: () => setState(() => _future = subjectService.getMySubjects(forceRefresh: true)),
                          icon: const Icon(Icons.refresh),
                          label: const Text('إعادة المحاولة', style: TextStyle(fontFamily: 'Cairo')),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
          final subjects = snapshot.data ?? [];
          if (subjects.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(
                  height: 200,
                  child: Center(
                    child: Text('لا توجد مواد متاحة لهذا المستوى', style: TextStyle(fontFamily: 'Cairo', color: AppColors.textSecondary)),
                  ),
                ),
              ],
            );
          }
          return GridView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.0,
            ),
            itemCount: subjects.length,
            itemBuilder: (context, i) {
              final s = subjects[i];
              return GestureDetector(
                onTap: () => Navigator.pushNamed(context, AppRoutes.subjectDetails, arguments: s),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2))],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (s.coverImageUrl.isNotEmpty)
                          Image.network(
                            buildFileUrl(s.coverImageUrl),
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => DefaultSubjectCover(nameAr: s.nameAr, nameFr: s.nameFr, showLabel: false),
                          )
                        else
                          DefaultSubjectCover(nameAr: s.nameAr, nameFr: s.nameFr, showLabel: false),
                        // overlay أسفل
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.transparent, Colors.black.withValues(alpha: 0.6)],
                                stops: const [0.4, 1.0],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 10,
                          left: 10,
                          right: 10,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                s.nameAr,
                                style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (s.lessonsCount > 0)
                                Text(
                                  '${s.lessonsCount} درس',
                                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.white70),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
        ),
      ),
    );
  }
}
