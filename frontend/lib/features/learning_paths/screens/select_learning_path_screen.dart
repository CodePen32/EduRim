import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/learning_path.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/learning_path_service.dart';
import '../../../shared/widgets/api_state_widget.dart';

class SelectLearningPathScreen extends StatefulWidget {
  const SelectLearningPathScreen({super.key});

  @override
  State<SelectLearningPathScreen> createState() => _SelectLearningPathScreenState();
}

class _SelectLearningPathScreenState extends State<SelectLearningPathScreen> {
  LearningPath? _selected;
  bool _saving = false;
  late Future<List<LearningPath>> _future;

  static const _pathIcons = {
    'CONCOURS': Icons.emoji_events_outlined,
    'BEPC': Icons.school_outlined,
    'BAC': Icons.workspace_premium_outlined,
  };
  static const _colors = {
    'CONCOURS': AppColors.primary,
    'BEPC': Color(0xFF7C3AED),
    'BAC': Color(0xFF059669),
  };

  @override
  void initState() {
    super.initState();
    _future = learningPathService.getLearningPaths();
  }

  void _reload() => setState(() {
    _future = learningPathService.getLearningPaths();
  });

  Future<void> _proceed() async {
    if (_selected == null) return;
    setState(() => _saving = true);
    try {
      await authService.updateProfile(learningPathId: _selected!.id);
    } catch (_) {
      // proceed even if save fails — user can update later
    }
    if (!mounted) return;
    setState(() => _saving = false);
    if (_selected!.code == 'BAC') {
      Navigator.pushNamed(context, AppRoutes.selectBacBranch);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Text('اختر مسارك الدراسي', style: TextStyle(fontFamily: 'Cairo', fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.white)),
                const SizedBox(height: 8),
                const Text('سيتم تخصيص المحتوى حسب اختيارك', style: TextStyle(fontFamily: 'Cairo', fontSize: 14, color: Colors.white70)),
                const SizedBox(height: 40),
                Expanded(
                  child: ApiBuilder<List<LearningPath>>(
                    future: _future,
                    onRetry: _reload,
                    builder: (paths) => ListView.separated(
                      itemCount: paths.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 16),
                      itemBuilder: (_, i) {
                        final path = paths[i];
                        final isSelected = _selected?.id == path.id;
                        final color = _colors[path.code] ?? AppColors.primary;
                        return GestureDetector(
                          onTap: () => setState(() => _selected = path),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.white : AppColors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: isSelected ? AppColors.white : Colors.transparent, width: 2),
                            ),
                            child: Row(
                              children: [
                                Icon(_pathIcons[path.code] ?? Icons.school_outlined, size: 36, color: isSelected ? color : AppColors.white),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(path.nameAr, style: TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.bold, color: isSelected ? color : AppColors.white)),
                                      Text(path.nameFr, style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: isSelected ? AppColors.textSecondary : Colors.white70)),
                                      if (path.description.isNotEmpty)
                                        Text(path.description, style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: isSelected ? AppColors.textLight : Colors.white60)),
                                    ],
                                  ),
                                ),
                                if (isSelected) Icon(Icons.check_circle, color: color, size: 28),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: (_selected != null && !_saving) ? _proceed : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.white,
                    foregroundColor: AppColors.primary,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _saving
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('متابعة', style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
