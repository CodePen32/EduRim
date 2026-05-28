import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/user.dart';
import '../../../core/models/progress_stats.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/network/api_client.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/progress_service.dart';
import '../../../shared/widgets/app_header.dart';

class ProfileScreen extends StatefulWidget {
  final bool standalone;
  final VoidCallback? onProfileUpdated;
  const ProfileScreen({super.key, this.standalone = true, this.onProfileUpdated});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? _user;
  ProgressStats? _stats;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    setState(() { _loading = true; _error = null; });
    try {
      final user = await authService.me();
      ProgressStats? stats;
      try { stats = await progressService.getStats(); } catch (_) {}
      if (mounted) setState(() { _user = user; _stats = stats; _loading = false; });
    } catch (e) {
      if (!mounted) return;
      final isAuth = e is ApiException && (e.statusCode == 401 || e.statusCode == 403);
      if (isAuth) {
        await authService.clearToken();
        if (mounted) Navigator.pushReplacementNamed(context, AppRoutes.login);
        return;
      }
      final isConn = e.toString().contains('SocketException') || e.toString().contains('Connection');
      setState(() {
        _error = isConn ? 'تعذر الاتصال بالخادم' : 'تعذر تحميل البيانات';
        _loading = false;
      });
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تسجيل الخروج', style: TextStyle(fontFamily: 'Cairo')),
        content: const Text('هل تريد تسجيل الخروج؟', style: TextStyle(fontFamily: 'Cairo')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo'))),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('خروج', style: TextStyle(fontFamily: 'Cairo', color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await authService.logout();
      if (mounted) Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.standalone ? const AppHeader(title: 'حسابي') : null,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!, style: const TextStyle(fontFamily: 'Cairo', color: AppColors.textSecondary)),
                      const SizedBox(height: 12),
                      TextButton(onPressed: _loadUser, child: const Text('إعادة المحاولة', style: TextStyle(fontFamily: 'Cairo', color: AppColors.primary))),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(20, 30, 20, 30),
                        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
                        child: Column(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: const BoxDecoration(color: AppColors.white, shape: BoxShape.circle),
                              child: const Center(child: Text('👤', style: TextStyle(fontSize: 36))),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _user?.fullName ?? '',
                              style: const TextStyle(fontFamily: 'Cairo', fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.white),
                            ),
                            if ((_user?.displayPath ?? '').isNotEmpty)
                              Text(
                                _user!.displayPath,
                                style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: Colors.white70),
                              ),
                            const SizedBox(height: 8),
                            Text(
                              _user?.phone ?? '',
                              style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.white60),
                            ),
                          ],
                        ),
                      ),
                      if (_stats != null)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                          child: Row(
                            children: [
                              Expanded(
                                child: _StatsCard(
                                  label: 'دروس مكتملة',
                                  value: '${_stats!.completedLessons}',
                                  icon: Icons.check_circle_outline,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _StatsCard(
                                  label: 'متوسط التقدم',
                                  value: '${_stats!.averagePercentage.toStringAsFixed(0)}%',
                                  icon: Icons.trending_up,
                                ),
                              ),
                            ],
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _ProfileTile(icon: Icons.bar_chart_outlined, label: 'عرض تقدمي', onTap: () => Navigator.pushNamed(context, AppRoutes.progress)),
                            _ProfileTile(icon: Icons.edit_outlined, label: 'تعديل الملف الشخصي', onTap: () async {
                              final changed = await Navigator.pushNamed(context, AppRoutes.editProfile);
                              if (changed == true && mounted) {
                                _loadUser();
                                widget.onProfileUpdated?.call();
                              }
                            }),
                            _ProfileTile(icon: Icons.school_outlined, label: 'المسار الدراسي', onTap: () => Navigator.pushNamed(context, AppRoutes.selectLearningPath)),
                            _ProfileTile(icon: Icons.calculate_outlined, label: 'حاسبة المعدل', onTap: () => Navigator.pushNamed(context, AppRoutes.averageCalculator)),
                            _ProfileTile(icon: Icons.notifications_outlined, label: 'الإشعارات', onTap: () => Navigator.pushNamed(context, AppRoutes.notifications)),
                            _ProfileTile(icon: Icons.help_outline, label: 'المساعدة', onTap: () {}),
                            const SizedBox(height: 8),
                            _ProfileTile(icon: Icons.logout, label: 'تسجيل الخروج', color: AppColors.error, onTap: _logout),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatsCard({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.accentLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
              Text(label, style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _ProfileTile({required this.icon, required this.label, required this.onTap, this.color = AppColors.textPrimary});

  @override
  Widget build(BuildContext context) {
    final isDestructive = color == AppColors.error;
    return ListTile(
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: isDestructive ? AppColors.error.withValues(alpha: 0.1) : AppColors.accentLight,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: isDestructive ? AppColors.error : AppColors.primary, size: 20),
      ),
      title: Text(label, style: TextStyle(fontFamily: 'Cairo', fontSize: 15, color: color)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textLight),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
