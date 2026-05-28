import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/learning_path.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/learning_path_service.dart';
import '../../../shared/widgets/api_state_widget.dart';

class SelectBacBranchScreen extends StatefulWidget {
  const SelectBacBranchScreen({super.key});

  @override
  State<SelectBacBranchScreen> createState() => _SelectBacBranchScreenState();
}

class _SelectBacBranchScreenState extends State<SelectBacBranchScreen> {
  BacBranch? _selected;
  bool _saving = false;
  late Future<List<BacBranch>> _future;

  static const _branchIcons = {
    'C': Icons.calculate_outlined,
    'D': Icons.science_outlined,
    'A': Icons.chrome_reader_mode_outlined,
    'O': Icons.menu_book_outlined,
  };

  @override
  void initState() {
    super.initState();
    _future = learningPathService.getBacBranches();
  }

  void _reload() => setState(() {
    _future = learningPathService.getBacBranches();
  });

  Future<void> _proceed() async {
    if (_selected == null) return;
    setState(() => _saving = true);
    try {
      await authService.updateProfile(bacBranchId: _selected!.id);
    } catch (_) {
      // proceed even if save fails
    }
    if (!mounted) return;
    setState(() => _saving = false);
    Navigator.pushReplacementNamed(context, AppRoutes.home);
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
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: AppColors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(height: 10),
                const Text('اختر شعبة الباكالوريا', style: TextStyle(fontFamily: 'Cairo', fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.white)),
                const SizedBox(height: 8),
                const Text('سيتم عرض مواد شعبتك فقط', style: TextStyle(fontFamily: 'Cairo', fontSize: 14, color: Colors.white70)),
                const SizedBox(height: 32),
                Expanded(
                  child: ApiBuilder<List<BacBranch>>(
                    future: _future,
                    onRetry: _reload,
                    builder: (branches) => GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.1,
                      ),
                      itemCount: branches.length,
                      itemBuilder: (context, i) {
                        final b = branches[i];
                        final isSelected = _selected?.id == b.id;
                        return GestureDetector(
                          onTap: () => setState(() => _selected = b),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.white : AppColors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected ? AppColors.white : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(_branchIcons[b.code] ?? Icons.menu_book_outlined, size: 36, color: isSelected ? AppColors.primary : AppColors.white),
                                const SizedBox(height: 10),
                                Text(b.nameFr, style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 16, color: isSelected ? AppColors.primary : AppColors.white)),
                                const SizedBox(height: 4),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: Text(b.nameAr, style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: isSelected ? AppColors.textSecondary : Colors.white70), textAlign: TextAlign.center),
                                ),
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
                      : const Text('ابدأ التعلم', style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
