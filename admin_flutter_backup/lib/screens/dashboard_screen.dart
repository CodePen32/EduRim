import 'package:flutter/material.dart';
import '../core/admin_api.dart';
import '../core/admin_scope.dart';
import '../core/app_colors.dart';
import '../widgets/admin_sidebar.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});
  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  Map<String, dynamic>? _stats;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    adminScope.addListener(_onScopeChange);
    _load();
  }

  @override
  void dispose() {
    adminScope.removeListener(_onScopeChange);
    super.dispose();
  }

  void _onScopeChange() => _load();

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await adminApi.get('/dashboard/stats?${adminScope.queryParams}');
      if (mounted) setState(() { _stats = data; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminColors.background,
      body: Row(
        children: [
          const AdminSidebar(currentRoute: '/dashboard'),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _AppBar(title: 'لوحة التحكم'),
                Expanded(
                  child: _loading
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('نظرة عامة — ${adminScope.label}', style: const TextStyle(fontFamily: 'Cairo', fontSize: 20, fontWeight: FontWeight.bold, color: AdminColors.textPrimary)),
                              const SizedBox(height: 20),
                              Wrap(
                                spacing: 16,
                                runSpacing: 16,
                                children: [
                                  _StatCard(label: 'الطلاب', value: '${_stats?['total_users'] ?? 0}', icon: Icons.people_outline, color: AdminColors.primary),
                                  _StatCard(label: 'المواد', value: '${_stats?['total_subjects'] ?? 0}', icon: Icons.menu_book_outlined, color: AdminColors.success),
                                  _StatCard(label: 'الدروس', value: '${_stats?['total_lessons'] ?? 0}', icon: Icons.play_lesson_outlined, color: AdminColors.warning),
                                  _StatCard(label: 'التمارين', value: '${_stats?['total_exercises'] ?? 0}', icon: Icons.quiz_outlined, color: const Color(0xFF7C3AED)),
                                  _StatCard(label: 'مواضيع الامتحانات', value: '${_stats?['total_past_exams'] ?? 0}', icon: Icons.history_edu_outlined, color: AdminColors.error),
                                ],
                              ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AppBar extends StatelessWidget {
  final String title;
  const _AppBar({required this.title});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: AdminColors.white,
        border: Border(bottom: BorderSide(color: AdminColors.border)),
      ),
      alignment: Alignment.centerRight,
      child: Text(title, style: const TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.bold, color: AdminColors.textPrimary)),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AdminColors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AdminColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(value, style: TextStyle(fontFamily: 'Cairo', fontSize: 28, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AdminColors.textSecondary)),
        ],
      ),
    );
  }
}
