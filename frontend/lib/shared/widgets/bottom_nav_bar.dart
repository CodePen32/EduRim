import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/i18n/app_strings.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavBar({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textLight,
      backgroundColor: AppColors.white,
      selectedLabelStyle: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600, fontSize: 11),
      unselectedLabelStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 11),
      items: [
        BottomNavigationBarItem(icon: const Icon(Icons.home_rounded), label: tr('nav.home')),
        BottomNavigationBarItem(icon: const Icon(Icons.favorite_rounded), label: tr('nav.favorites')),
        BottomNavigationBarItem(icon: const Icon(Icons.download_rounded), label: tr('nav.downloads')),
        BottomNavigationBarItem(icon: const Icon(Icons.calculate_rounded), label: tr('nav.calculator')),
        BottomNavigationBarItem(icon: const Icon(Icons.person_rounded), label: tr('nav.account')),
      ],
    );
  }
}
