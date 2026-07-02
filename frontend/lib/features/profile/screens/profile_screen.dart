import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/i18n/app_strings.dart';
import '../../../core/models/user.dart';
import '../../../core/models/progress_stats.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/network/api_client.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/progress_service.dart';
import '../../../core/services/subscription_service.dart';
import '../../../core/models/subscription.dart';
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
  MySubscription? _subscription;
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
      MySubscription? subscription;
      try { subscription = await subscriptionService.getMySubscription(); } catch (_) {}
      if (mounted) setState(() { _user = user; _stats = stats; _subscription = subscription; _loading = false; });
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
        _error = isConn ? tr('home.connError') : tr('profile.loadError');
        _loading = false;
      });
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(tr('drawer.logout'), style: const TextStyle(fontFamily: 'Cairo')),
        content: Text(tr('logout.confirm'), style: const TextStyle(fontFamily: 'Cairo')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(tr('common.cancel'), style: const TextStyle(fontFamily: 'Cairo'))),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(tr('profile.logoutShort'), style: const TextStyle(fontFamily: 'Cairo', color: AppColors.error)),
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
      appBar: widget.standalone ? AppHeader(title: tr('profile.title')) : null,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!, style: const TextStyle(fontFamily: 'Cairo', color: AppColors.textSecondary)),
                      const SizedBox(height: 12),
                      TextButton(onPressed: _loadUser, child: Text(tr('common.retry'), style: const TextStyle(fontFamily: 'Cairo', color: AppColors.primary))),
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
                                  label: tr('profile.completedLessons'),
                                  value: '${_stats!.completedLessons}',
                                  icon: Icons.check_circle_outline,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _StatsCard(
                                  label: tr('profile.avgProgress'),
                                  value: '${_stats!.averagePercentage.toStringAsFixed(0)}%',
                                  icon: Icons.trending_up,
                                ),
                              ),
                            ],
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                        child: _SubscriptionCard(
                          subscription: _subscription,
                          onTap: () async {
                            await Navigator.pushNamed(context, AppRoutes.mySubscription);
                            if (mounted) _loadUser();
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _ProfileTile(icon: Icons.bar_chart_outlined, label: tr('profile.viewProgress'), onTap: () => Navigator.pushNamed(context, AppRoutes.progress)),
                            _ProfileTile(icon: Icons.edit_outlined, label: tr('profile.edit'), onTap: () async {
                              final changed = await Navigator.pushNamed(context, AppRoutes.editProfile);
                              if (changed == true && mounted) {
                                _loadUser();
                                widget.onProfileUpdated?.call();
                              }
                            }),
                            _ProfileTile(icon: Icons.calculate_outlined, label: tr('profile.calculator'), onTap: () => Navigator.pushNamed(context, AppRoutes.averageCalculator)),
                            _ProfileTile(icon: Icons.notifications_outlined, label: tr('drawer.notifications'), onTap: () => Navigator.pushNamed(context, AppRoutes.notifications)),
                            _ProfileTile(icon: Icons.help_outline, label: tr('profile.help'), onTap: () {}),
                            const SizedBox(height: 8),
                            _ProfileTile(icon: Icons.logout, label: tr('drawer.logout'), color: AppColors.error, onTap: _logout),
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

/// Shows whether the student is a subscriber ("مشترك") or a free viewer
/// ("متفرّج / غير مشترك"). Uses only data from GET /me/subscription. When not
/// subscribed, tapping opens the subscription page.
class _SubscriptionCard extends StatelessWidget {
  final MySubscription? subscription;
  final VoidCallback onTap;

  const _SubscriptionCard({required this.subscription, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final sub = subscription;
    final isSubscribed = sub != null && sub.hasSubscription && sub.isActive;

    final Color bg = isSubscribed ? AppColors.success : AppColors.warning;
    final IconData icon = isSubscribed ? Icons.verified_rounded : Icons.lock_clock_outlined;
    final String title = isSubscribed ? tr('sub.subscribed') : tr('sub.notSubscribed');

    String subtitle;
    if (isSubscribed) {
      final parts = <String>[];
      if (sub.planName.isNotEmpty) parts.add(sub.planName);
      if (sub.daysRemaining > 0) {
        parts.add(AppStrings.withArg('sub.daysLeft', '${sub.daysRemaining}'));
      } else if (sub.endDate.isNotEmpty) {
        parts.add(AppStrings.withArg('sub.endsOn', sub.endDate));
      }
      subtitle = parts.isEmpty ? tr('sub.active') : parts.join(' · ');
    } else {
      subtitle = tr('sub.cta');
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: bg.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: bg.withValues(alpha: 0.35)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: bg.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: bg, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.bold, color: bg == AppColors.success ? AppColors.primaryDark : AppColors.textPrimary)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
            if (!isSubscribed)
              const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textLight),
          ],
        ),
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
