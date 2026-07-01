import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Gradient hero header used across the info screens.
class InfoHero extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const InfoHero({super.key, required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 26),
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(18)),
            child: Icon(icon, color: AppColors.white, size: 34),
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontFamily: 'Cairo', fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.white), textAlign: TextAlign.center),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 3),
            Text(subtitle, style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: Colors.white70), textAlign: TextAlign.center),
          ],
        ],
      ),
    );
  }
}

/// White rounded content card with soft shadow.
class InfoCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  const InfoCard({super.key, required this.child, this.padding = const EdgeInsets.all(16)});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: child,
    );
  }
}

/// RTL paragraph text.
class InfoPara extends StatelessWidget {
  final String text;
  const InfoPara(this.text, {super.key});
  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, height: 1.9, color: AppColors.textSecondary), textAlign: TextAlign.right);
  }
}

/// A titled section header inside a card (icon + title).
class InfoSectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  const InfoSectionTitle({super.key, required this.icon, required this.title});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title, style: const TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary), textAlign: TextAlign.right),
        ),
        const SizedBox(width: 10),
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: AppColors.primary, size: 19),
        ),
      ],
    );
  }
}

/// Standard scaffold wrapper for info screens (RTL + AppBar + list body).
class InfoScaffold extends StatelessWidget {
  final String appBarTitle;
  final List<Widget> children;
  const InfoScaffold({super.key, required this.appBarTitle, required this.children});
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          elevation: 0,
          title: Text(appBarTitle, style: const TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        body: ListView(padding: const EdgeInsets.all(20), children: children),
      ),
    );
  }
}
