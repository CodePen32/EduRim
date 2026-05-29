import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/learning_path.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/learning_path_service.dart';
import '../../../shared/widgets/api_state_widget.dart';
import '../widgets/selection_widgets.dart';

class SelectLearningPathScreen extends StatefulWidget {
  const SelectLearningPathScreen({super.key});

  @override
  State<SelectLearningPathScreen> createState() =>
      _SelectLearningPathScreenState();
}

class _SelectLearningPathScreenState extends State<SelectLearningPathScreen>
    with SingleTickerProviderStateMixin {
  LearningPath? _selected;
  bool _saving = false;
  late Future<List<LearningPath>> _future;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  static const _pathIcons = {
    'CONCOURS': Icons.emoji_events_rounded,
    'BEPC': Icons.school_rounded,
    'BAC': Icons.workspace_premium_rounded,
  };

  @override
  void initState() {
    super.initState();
    _future = learningPathService.getLearningPaths();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _reload() =>
      setState(() => _future = learningPathService.getLearningPaths());

  Future<void> _proceed() async {
    if (_selected == null) return;
    setState(() => _saving = true);
    try {
      await authService.updateProfile(learningPathId: _selected!.id);
    } catch (_) {}
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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF2F6FF),
        body: FadeTransition(
          opacity: _fadeAnim,
          child: Column(
            children: [
              SelectionHeroHeader(
                icon: Icons.route_rounded,
                title: 'اختر مسارك الدراسي',
                subtitle: 'سيتم تخصيص المحتوى والمواد حسب اختيارك',
              ),
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: ApiBuilder<List<LearningPath>>(
                    future: _future,
                    onRetry: _reload,
                    builder: (paths) => ListView.separated(
                      padding: const EdgeInsets.only(top: 16, bottom: 8),
                      itemCount: paths.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (_, i) {
                        final path = paths[i];
                        final isSelected = _selected?.id == path.id;
                        return _PathCard(
                          path: path,
                          icon: _pathIcons[path.code] ?? Icons.school_rounded,
                          isSelected: isSelected,
                          onTap: () => setState(() => _selected = path),
                        );
                      },
                    ),
                  ),
                ),
              ),
              SelectionBottomButton(
                label: 'متابعة',
                saving: _saving,
                enabled: _selected != null,
                onPressed: _proceed,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PathCard extends StatelessWidget {
  final LearningPath path;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _PathCard({
    required this.path,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEEF3FF) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : const Color(0xFFDDE3F0),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.14),
                blurRadius: 18,
                offset: const Offset(0, 6),
              )
            else
              const BoxShadow(
                color: Color(0x08000000),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : const Color(0xFFECF0FB),
                  shape: BoxShape.circle,
                ),
                child: isSelected
                    ? const Icon(Icons.check_rounded,
                        color: Colors.white, size: 15)
                    : null,
              ),
              const SizedBox(width: 14),
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : const Color(0xFFF0F4FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  size: 26,
                  color: isSelected
                      ? AppColors.primary
                      : const Color(0xFF8A96B8),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      path.nameAr,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.right,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      path.nameFr,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.right,
                    ),
                    if (path.description.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        path.description,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 11,
                          color: AppColors.textLight,
                        ),
                        textAlign: TextAlign.right,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
