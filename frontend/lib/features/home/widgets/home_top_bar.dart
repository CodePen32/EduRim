import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/notification_service.dart';

class HomeTopBar extends StatefulWidget implements PreferredSizeWidget {
  const HomeTopBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  State<HomeTopBar> createState() => _HomeTopBarState();
}

class _HomeTopBarState extends State<HomeTopBar> {
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    notificationService.getUnreadCount().then((c) {
      if (mounted) setState(() => _unreadCount = c);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      leading: Builder(
        builder: (ctx) => IconButton(
          icon: const Icon(Icons.menu, color: AppColors.white, size: 26),
          onPressed: () => Scaffold.of(ctx).openEndDrawer(),
          tooltip: 'القائمة',
        ),
      ),
      title: const Text(
        'Concouri',
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.white,
          letterSpacing: 0.5,
        ),
        textAlign: TextAlign.center,
      ),
      centerTitle: true,
      actions: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined, color: AppColors.white, size: 26),
              onPressed: () async {
                await Navigator.pushNamed(context, AppRoutes.notifications);
                notificationService.getUnreadCount().then((c) {
                  if (mounted) setState(() => _unreadCount = c);
                });
              },
              tooltip: 'الإشعارات',
            ),
            if (_unreadCount > 0)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                  child: Text(
                    _unreadCount > 99 ? '99+' : '$_unreadCount',
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}
