import 'package:flutter/material.dart';
import '../core/admin_api.dart';
import '../core/admin_scope.dart';
import '../core/app_colors.dart';

class AdminSidebar extends StatefulWidget {
  final String currentRoute;
  const AdminSidebar({super.key, required this.currentRoute});

  @override
  State<AdminSidebar> createState() => _AdminSidebarState();
}

class _AdminSidebarState extends State<AdminSidebar> {
  @override
  void initState() {
    super.initState();
    adminScope.addListener(_onScopeChange);
    adminScope.load();
  }

  @override
  void dispose() {
    adminScope.removeListener(_onScopeChange);
    super.dispose();
  }

  void _onScopeChange() {
    if (mounted) setState(() {});
  }

  Color get _sectionColor {
    final lp = adminScope.learningPathId;
    final bac = adminScope.bacBranchId;
    if (lp == 1) return AdminColors.primary;
    if (lp == 2) return AdminColors.success;
    if (lp == 3 && bac == 1) return const Color(0xFF7C3AED);
    if (lp == 3 && bac == 2) return AdminColors.warning;
    return AdminColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 230,
      color: AdminColors.sidebar,
      child: Column(
        children: [
          const SizedBox(height: 20),
          const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.school_rounded, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('Edurim', style: TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          ]),
          const SizedBox(height: 4),
          const Text('لوحة التحكم', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AdminColors.sidebarText)),
          const SizedBox(height: 16),
          // بطاقة القسم الحالي
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _sectionColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _sectionColor.withValues(alpha: 0.4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('القسم الحالي', style: TextStyle(fontFamily: 'Cairo', fontSize: 10, color: AdminColors.sidebarText)),
                const SizedBox(height: 4),
                Text(
                  adminScope.label.isNotEmpty ? adminScope.label : '—',
                  style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold, color: _sectionColor),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const _Divider(),
          const SizedBox(height: 8),
          _NavItem(icon: Icons.dashboard_outlined, label: 'لوحة القسم', route: '/dashboard', current: widget.currentRoute),
          _NavItem(icon: Icons.menu_book_outlined, label: 'المواد', route: '/subjects', current: widget.currentRoute),
          _NavItem(icon: Icons.play_lesson_outlined, label: 'الدروس', route: '/lessons', current: widget.currentRoute),
          _NavItem(icon: Icons.quiz_outlined, label: 'التمارين', route: '/exercises', current: widget.currentRoute),
          _NavItem(icon: Icons.history_edu_outlined, label: 'مواضيع الامتحانات', route: '/past-exams', current: widget.currentRoute),
          _NavItem(icon: Icons.person_outlined, label: 'الأساتذة', route: '/teachers', current: widget.currentRoute),
          _NavItem(icon: Icons.people_outlined, label: 'الطلاب', route: '/users', current: widget.currentRoute),
          _NavItem(icon: Icons.notifications_outlined, label: 'الإشعارات', route: '/notifications', current: widget.currentRoute),
          const SizedBox(height: 8),
          const _Divider(),
          const SizedBox(height: 8),
          // زر تغيير القسم
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListTile(
              leading: const Icon(Icons.swap_horiz_rounded, color: AdminColors.sidebarText, size: 20),
              title: const Text('تغيير القسم', style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AdminColors.sidebarText)),
              onTap: () async {
                await adminScope.clear();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, '/select-section');
                }
              },
              dense: true,
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextButton.icon(
              onPressed: () async {
                await adminApi.clearToken();
                await adminScope.clear();
                if (context.mounted) Navigator.pushReplacementNamed(context, '/');
              },
              icon: const Icon(Icons.logout, color: AdminColors.sidebarText, size: 18),
              label: const Text('تسجيل الخروج', style: TextStyle(fontFamily: 'Cairo', color: AdminColors.sidebarText)),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) => Container(
    height: 1,
    margin: const EdgeInsets.symmetric(horizontal: 16),
    color: Colors.white.withValues(alpha: 0.1),
  );
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  final String current;
  const _NavItem({required this.icon, required this.label, required this.route, required this.current});

  @override
  Widget build(BuildContext context) {
    final isActive = current == route;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: isActive ? AdminColors.sidebarActive : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(icon, color: isActive ? Colors.white : AdminColors.sidebarText, size: 20),
        title: Text(label, style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: isActive ? Colors.white : AdminColors.sidebarText)),
        onTap: () {
          if (!isActive) Navigator.pushReplacementNamed(context, route);
        },
        dense: true,
      ),
    );
  }
}
