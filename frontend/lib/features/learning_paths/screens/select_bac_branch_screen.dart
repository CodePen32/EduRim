import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
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
      setState(() => _future = learningPathService.getBacBranches());

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
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF2F6FF),
        body: FadeTransition(
          opacity: _fadeAnim,
          child: Column(
            children: [
              SelectionHeroHeader(
                icon: Icons.school_rounded,
                title: 'اختر شعبة الباكالوريا',
                subtitle: 'سيتم عرض المواد والمحتوى المناسب لشعبتك فقط',
                showBack: true,
              ),
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: ApiBuilder<List<BacBranch>>(
                    future: _future,
                    onRetry: _reload,
                    builder: (branches) => ListView.separated(
                      padding: const EdgeInsets.only(top: 16, bottom: 8),
                      itemCount: branches.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 14),
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
                label: 'ابدأ التعلم',
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
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEEF3FF) : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected ? AppColors.primary : const Color(0xFFDDE3F0),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, 7),
              )
            else
              const BoxShadow(
                color: Color(0x08000000),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
          ],
        ),
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
            const SizedBox(width: 16),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : const Color(0xFFF0F4FF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                size: 30,
                color: isSelected ? AppColors.primary : const Color(0xFF8A96B8),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    branch.nameAr,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    branch.nameFr,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.7)
                          : AppColors.textSecondary,
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
