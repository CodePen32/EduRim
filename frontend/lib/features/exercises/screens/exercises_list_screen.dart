import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/exercise.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/exercise_service.dart';
import '../../../shared/widgets/api_state_widget.dart';
import '../../../shared/widgets/app_header.dart';

class ExercisesListScreen extends StatefulWidget {
  const ExercisesListScreen({super.key});

  @override
  State<ExercisesListScreen> createState() => _ExercisesListScreenState();
}

class _ExercisesListScreenState extends State<ExercisesListScreen> {
  late Future<List<Exercise>> _future;
  int? _subjectId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_subjectId == null) {
      _subjectId = ModalRoute.of(context)?.settings.arguments as int?;
      _future = exerciseService.getExercises(subjectId: _subjectId);
    }
  }

  void _reload() => setState(() {
    _future = exerciseService.getExercises(subjectId: _subjectId);
  });

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
    final title = _subjectId != null ? 'تمارين المادة' : 'التمارين والاختبارات';
    return Scaffold(
      appBar: AppHeader(title: title),
      body: ApiBuilder<List<Exercise>>(
        future: _future,
        onRetry: _reload,
        builder: (exercises) => exercises.isEmpty
            ? const Center(child: Text('لا توجد تمارين حالياً', style: TextStyle(fontFamily: 'Cairo', color: AppColors.textSecondary)))
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: exercises.length,
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final e = exercises[i];
                  final diffColor = _difficultyColor(e.difficulty);
                  return GestureDetector(
                    onTap: () => Navigator.pushNamed(context, AppRoutes.exerciseDetails, arguments: e),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6)],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(color: AppColors.accentLight, borderRadius: BorderRadius.circular(12)),
                            child: const Icon(Icons.quiz_outlined, color: AppColors.primary),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(e.title, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 14)),
                                const SizedBox(height: 4),
                                if (e.year > 0)
                                  Text('سنة ${e.year}', style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(color: diffColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                            child: Text(e.difficulty, style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: diffColor, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
