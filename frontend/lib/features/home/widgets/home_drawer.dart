import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/user.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/utils/url_helper.dart';

class HomeDrawer extends StatelessWidget {
  final UserModel? user;
  const HomeDrawer({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    final name = user?.fullName ?? '...';
    final email = user?.email ?? '';
    final phone = user?.phone ?? '';

    return Drawer(
      backgroundColor: AppColors.white,
      child: Column(
        children: [
          // ── Header (gradient) ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 52, 20, 22),
            decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 2),
                  ),
                  child: const CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.person, size: 38, color: AppColors.white),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  name,
                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.white),
                  textAlign: TextAlign.right,
                ),
                if (phone.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  _HeaderLine(icon: Icons.phone, text: phone),
                ],
                if (email.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  _HeaderLine(icon: Icons.email_outlined, text: email),
                ],
              ],
            ),
          ),

          // ── List (sectioned) ──
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 10),
              children: [
                _DrawerItem(
                  icon: Icons.home_rounded,
                  label: 'الصفحة الرئيسية',
                  onTap: () => Navigator.pop(context),
                ),
                _DrawerItem(
                  icon: Icons.menu_book_rounded,
                  label: 'المواد',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRoutes.subjects);
                  },
                ),
                _DrawerItem(
                  icon: Icons.credit_card_rounded,
                  label: 'اشتراكي',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRoutes.mySubscription);
                  },
                ),
                _DrawerItem(
                  icon: Icons.notifications_rounded,
                  label: 'الإشعارات',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRoutes.notifications);
                  },
                ),

                const _SectionLabel('الدعم والمساعدة'),
                _DrawerItem(
                  icon: Icons.chat_rounded,
                  label: 'تواصل معنا',
                  onTap: () => _openWhatsApp(context),
                ),
                _DrawerItem(
                  icon: Icons.contact_page_rounded,
                  label: 'سجل التواصل',
                  onTap: () => _go(context, AppRoutes.contactHistory),
                ),
                _DrawerItem(
                  icon: Icons.help_rounded,
                  label: 'الأسئلة الشائعة',
                  onTap: () => _go(context, AppRoutes.faq),
                ),
                _DrawerItem(
                  icon: Icons.lightbulb_rounded,
                  label: 'اقترح تطوير',
                  onTap: () => _go(context, AppRoutes.suggestFeature),
                ),

                const _SectionLabel('معلومات قانونية'),
                _DrawerItem(
                  icon: Icons.info_rounded,
                  label: 'من نحن',
                  onTap: () => _go(context, AppRoutes.aboutUs),
                ),
                _DrawerItem(
                  icon: Icons.description_rounded,
                  label: 'شروط الاستخدام',
                  onTap: () => _go(context, AppRoutes.terms),
                ),

                const SizedBox(height: 6),
                const Divider(height: 1, indent: 16, endIndent: 16),
                const SizedBox(height: 6),
                _DrawerItem(
                  icon: Icons.logout_rounded,
                  label: 'تسجيل الخروج',
                  color: AppColors.error,
                  onTap: () => _confirmLogout(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _go(BuildContext context, String route) {
    Navigator.pop(context);
    Navigator.pushNamed(context, route);
  }

  Future<void> _openWhatsApp(BuildContext context) async {
    Navigator.pop(context);
    const msg = 'السلام عليكم، أريد التواصل مع دعم Concouri';
    final url = 'https://wa.me/22249886974?text=${Uri.encodeComponent(msg)}';
    await openExternalUrl(url, context: context);
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('تسجيل الخروج', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
          content: const Text('هل تريد تسجيل الخروج؟', style: TextStyle(fontFamily: 'Cairo')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo', color: AppColors.textSecondary)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('تسجيل الخروج', style: TextStyle(fontFamily: 'Cairo', color: AppColors.error, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
    if (confirmed != true) return;
    if (!context.mounted) return;
    // Same logout logic as before — unchanged.
    Navigator.pop(context); // close drawer
    await authService.clearToken();
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }
}

class _HeaderLine extends StatelessWidget {
  final IconData icon;
  final String text;
  const _HeaderLine({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Flexible(
          child: Text(
            text,
            style: const TextStyle(fontFamily: 'Cairo', fontSize: 12.5, color: Colors.white70),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
          ),
        ),
        const SizedBox(width: 6),
        Icon(icon, size: 14, color: Colors.white70),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(
          text,
          style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textLight, letterSpacing: 0.3),
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _DrawerItem({required this.icon, required this.label, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.textPrimary;
    final isDanger = color == AppColors.error;
    final tint = isDanger ? AppColors.error : AppColors.primary;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(fontFamily: 'Cairo', fontSize: 14.5, color: c, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.right,
                ),
              ),
              const SizedBox(width: 14),
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: tint.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, color: tint, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
