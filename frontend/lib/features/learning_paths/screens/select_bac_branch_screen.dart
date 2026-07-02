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

class SelectBacBranchScreen extends StatefulWidget {
  const SelectBacBranchScreen({super.key});

  @override
  State<SelectBacBranchScreen> createState() => _SelectBacBranchScreenState();
}

class _SelectBacBranchScreenState extends State<SelectBacBranchScreen>
    with SingleTickerProviderStateMixin {
  BacBranch? _selected;
  bool _saving = false;
  bool _checking = true; // guard: verifying the user may still pick a branch
  late Future<List<BacBranch>> _future;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  static const _branchIcons = {
    'C': Icons.calculate_rounded,
    'D': Icons.science_rounded,
    'A': Icons.chrome_reader_mode_rounded,
    'O': Icons.menu_book_rounded,
  };

  @override
  void initState() {
    super.initState();
    _future = learningPathService.getBacBranches();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
    _guard();
  }

  /// Guard: the bac branch may be chosen only during BAC onboarding — i.e. the
  /// user is on the BAC path (lp==3) and has no branch yet. Otherwise redirect
  /// home. Backend also enforces branch immutability once set (defense-in-depth);
  /// on a network error we proceed and let the backend remain the hard gate.
  Future<void> _guard() async {
    try {
      final user = await authService.me();
      if (!mounted) return;
      final lp = user.learningPathId;
      final bac = user.bacBranchId;
      final canPick = lp == 3 && bac == null;
      if (!canPick) {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
        return;
      }
    } catch (_) {
      // Network/error — allow; backend enforces immutability.
    }
    if (mounted) setState(() => _checking = false);
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _reload() => setState(() => _future = learningPathService.getBacBranches());

  Future<void> _proceed() async {
    if (_selected == null) return;
    setState(() => _saving = true);
    try {
      await authService.updateProfile(bacBranchId: _selected!.id);
    } catch (_) {}
    if (!mounted) return;
    setState(() => _saving = false);
    Navigator.pushReplacementNamed(context, AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: localeController.direction,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: SelectionAppBar(title: tr('branch.appbar'), showBack: true),
        body: _checking
            ? const Center(child: CircularProgressIndicator())
            : FadeTransition(
          opacity: _fadeAnim,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SelectionSectionHeader(
                title: tr('branch.title'),
                subtitle: tr('branch.subtitle'),
              ),
              const SizedBox(height: 12),
              const SelectionStepIndicator(step: 2, total: 2),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ApiBuilder<List<BacBranch>>(
                    future: _future,
                    onRetry: _reload,
                    builder: (branches) => ListView.separated(
                      padding: const EdgeInsets.only(top: 8, bottom: 8),
                      itemCount: branches.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (_, i) {
                        final b = branches[i];
                        final isSelected = _selected?.id == b.id;
                        return _BranchCard(
                          branch: b,
                          icon: _branchIcons[b.code] ?? Icons.menu_book_rounded,
                          isSelected: isSelected,
                          onTap: () => setState(() => _selected = b),
                        );
                      },
                    ),
                  ),
                ),
              ),
              SelectionBottomButton(
                label: tr('branch.start'),
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

class _BranchCard extends StatelessWidget {
  final BacBranch branch;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _BranchCard({
    required this.branch,
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
        padding: const EdgeInsets.all(18),
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
            const SizedBox(width: 14),
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
            const SizedBox(width: 14),
            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    branch.nameAr,
                    style: TextStyle(
                      fontFamily: 'Cairo', fontSize: 17, fontWeight: FontWeight.bold,
                      color: isSelected ? AppColors.primary : const Color(0xFF1E293B),
                    ),
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    branch.nameFr,
                    style: TextStyle(
                      fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w600,
                      color: isSelected ? AppColors.primary.withValues(alpha: 0.65) : const Color(0xFF94A3B8),
                    ),
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
