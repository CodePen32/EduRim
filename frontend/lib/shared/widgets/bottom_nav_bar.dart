import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

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
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'الرئيسية'),
        BottomNavigationBarItem(icon: Icon(Icons.favorite_rounded), label: 'المفضلة'),
        BottomNavigationBarItem(icon: Icon(Icons.download_rounded), label: 'التنزيلات'),
        BottomNavigationBarItem(icon: Icon(Icons.calculate_rounded), label: 'الحاسبة'),
        BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'حسابي'),
      ],
    );
  }
}
