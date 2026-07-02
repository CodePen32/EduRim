import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/i18n/app_strings.dart';
import '../../../core/i18n/locale_controller.dart';
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
  bool _checking = true; // guard: verifying the user may still pick a path
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
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
    _guard();
  }

  /// Security/UX guard: the path may be chosen only during onboarding (when the
  /// user has none yet). If a path is already set, this screen must not let it
  /// be changed — redirect away. The backend also enforces immutability, so
  /// this is defense-in-depth; on a network error we let onboarding proceed
  /// (the backend remains the hard gate).
  Future<void> _guard() async {
    try {
      final user = await authService.me();
      if (!mounted) return;
      final lp = user.learningPathId;
      if (lp != null) {
        // Already has a path → not a fresh onboarding.
        if (lp == 3 && user.bacBranchId == null) {
          Navigator.pushReplacementNamed(context, AppRoutes.selectBacBranch);
        } else {
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        }
        return;
      }
    } catch (_) {
      // Network/error — fall through and allow onboarding (backend enforces).
    }
    if (mounted) setState(() => _checking = false);
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _reload() => setState(() => _future = learningPathService.getLearningPaths());

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
      textDirection: localeController.direction,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: SelectionAppBar(title: tr('path.title')),
        body: _checking
            ? const Center(child: CircularProgressIndicator())
            : FadeTransition(
          opacity: _fadeAnim,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SelectionSectionHeader(
                title: tr('path.title'),
                subtitle: tr('path.subtitle'),
              ),
              const SizedBox(height: 12),
              const SelectionStepIndicator(step: 1, total: 2),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ApiBuilder<List<LearningPath>>(
                    future: _future,
                    onRetry: _reload,
                    builder: (paths) => ListView.separated(
                      padding: const EdgeInsets.only(top: 8, bottom: 8),
                      itemCount: paths.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
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
                label: tr('common.continue'),
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
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEAF2FF) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
            width: isSelected ? 1.8 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(color: AppColors.primary.withValues(alpha: 0.12), blurRadius: 16, offset: const Offset(0, 4))
            else
              const BoxShadow(color: Color(0x06000000), blurRadius: 4, offset: Offset(0, 2)),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // Check circle
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : const Color(0xFFECF0FB),
                  shape: BoxShape.circle,
                ),
                child: isSelected ? const Icon(Icons.check_rounded, color: Colors.white, size: 14) : null,
              ),
              const SizedBox(width: 12),
              // Icon box
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : const Color(0xFFF0F4FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, size: 28, color: isSelected ? AppColors.primary : const Color(0xFF8A96B8)),
              ),
              const SizedBox(width: 12),
              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      path.nameAr,
                      style: TextStyle(
                        fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold,
                        color: isSelected ? AppColors.primary : const Color(0xFF1E293B),
                      ),
                      textAlign: TextAlign.right,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      path.nameFr,
                      style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Color(0xFF94A3B8)),
                      textAlign: TextAlign.right,
                    ),
                    if (path.description.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        path.description,
                        style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Color(0xFFB0BAD0)),
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
