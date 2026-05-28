import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/user.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/utils/url_helper.dart';
import '../../../shared/screens/placeholder_screen.dart';

class HomeDrawer extends StatelessWidget {
  final UserModel? user;
  const HomeDrawer({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    final name = user?.fullName ?? '...';
    final email = user?.email ?? '';
    final phone = user?.phone ?? '';

    return Drawer(
      child: Column(
        children: [
          // ── Header ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 48, 20, 24),
            color: AppColors.primary,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.person, size: 36, color: AppColors.white),
                ),
                const SizedBox(height: 12),
                Text(
                  name,
                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.white),
                  textAlign: TextAlign.right,
                ),
                if (phone.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(phone, style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: Colors.white70)),
                      const SizedBox(width: 6),
                      const Icon(Icons.phone, size: 14, color: Colors.white70),
                    ],
                  ),
                ],
                if (email.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                        child: Text(email, style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.white70), overflow: TextOverflow.ellipsis),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.email_outlined, size: 14, color: Colors.white70),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // ── القائمة ──
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _DrawerItem(
                  icon: Icons.home_outlined,
                  label: 'الصفحة الرئيسية',
                  onTap: () => Navigator.pop(context),
                ),
                _DrawerItem(
                  icon: Icons.menu_book_outlined,
                  label: 'المواد',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRoutes.subjects);
                  },
                ),
                _DrawerItem(
                  icon: Icons.list_alt_outlined,
                  label: 'قائمة اشتراكاتي',
                  onTap: () => _openPlaceholder(context, 'قائمة اشتراكاتي'),
                ),
                _DrawerItem(
                  icon: Icons.phone_outlined,
                  label: 'تواصل معنا',
                  onTap: () => _openWhatsApp(context),
                ),
                _DrawerItem(
                  icon: Icons.contact_page_outlined,
                  label: 'سجل التواصل',
                  onTap: () => _openPlaceholder(context, 'سجل التواصل'),
                ),
                _DrawerItem(
                  icon: Icons.notifications_outlined,
                  label: 'الإشعارات',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRoutes.notifications);
                  },
                ),
                _DrawerItem(
                  icon: Icons.help_outline,
                  label: 'الأسئلة الشائعة',
                  onTap: () => _openPlaceholder(context, 'الأسئلة الشائعة'),
                ),
                _DrawerItem(
                  icon: Icons.lightbulb_outline,
                  label: 'اقترح تطوير',
                  onTap: () => _openPlaceholder(context, 'اقترح تطوير'),
                ),
                _DrawerItem(
                  icon: Icons.info_outline,
                  label: 'من نحن',
                  onTap: () => _openPlaceholder(context, 'من نحن'),
                ),
                _DrawerItem(
                  icon: Icons.description_outlined,
                  label: 'شروط الاستخدام',
                  onTap: () => _openPlaceholder(context, 'شروط الاستخدام'),
                ),
                const Divider(height: 1),
                _DrawerItem(
                  icon: Icons.logout,
                  label: 'تسجيل الخروج',
                  color: AppColors.error,
                  onTap: () async {
                    Navigator.pop(context);
                    await authService.clearToken();
                    if (context.mounted) {
                      Navigator.pushReplacementNamed(context, AppRoutes.login);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openPlaceholder(BuildContext context, String title) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PlaceholderScreen(title: title)),
    );
  }

  Future<void> _openWhatsApp(BuildContext context) async {
    Navigator.pop(context);
    await openExternalUrl('https://wa.me/22232816779', context: context);
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
    return ListTile(
      leading: Icon(icon, color: c, size: 22),
      title: Text(label, style: TextStyle(fontFamily: 'Cairo', fontSize: 14, color: c), textAlign: TextAlign.right),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
    );
  }
}
