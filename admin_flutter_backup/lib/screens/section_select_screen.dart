import 'package:flutter/material.dart';
import '../core/admin_scope.dart';
import '../core/app_colors.dart';

class SectionSelectScreen extends StatelessWidget {
  const SectionSelectScreen({super.key});

  static const _sections = [
    {'lpId': 1, 'bacId': 0, 'label': 'Concours', 'sub': 'مسار التحضير للمسابقات', 'icon': Icons.emoji_events_outlined},
    {'lpId': 2, 'bacId': 0, 'label': 'BEPC', 'sub': 'شهادة التعليم الأساسي', 'icon': Icons.school_outlined},
    {'lpId': 3, 'bacId': 1, 'label': 'Bac C', 'sub': 'باكالوريا — شعبة C', 'icon': Icons.functions_outlined},
    {'lpId': 3, 'bacId': 2, 'label': 'Bac D', 'sub': 'باكالوريا — شعبة D', 'icon': Icons.biotech_outlined},
  ];

  static const _colors = [
    AdminColors.primary,
    AdminColors.success,
    Color(0xFF7C3AED),
    AdminColors.warning,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.school_rounded, color: AdminColors.primary, size: 32),
                SizedBox(width: 12),
                Text('Edurim', style: TextStyle(fontFamily: 'Cairo', fontSize: 28, fontWeight: FontWeight.bold, color: AdminColors.textPrimary)),
              ]),
              const SizedBox(height: 8),
              const Text('لوحة التحكم', style: TextStyle(fontFamily: 'Cairo', fontSize: 14, color: AdminColors.textSecondary)),
              const SizedBox(height: 48),
              const Text('اختر القسم الدراسي', style: TextStyle(fontFamily: 'Cairo', fontSize: 22, fontWeight: FontWeight.bold, color: AdminColors.textPrimary)),
              const SizedBox(height: 8),
              const Text('كل بيانات لوحة التحكم ستكون خاصة بالقسم المختار', style: TextStyle(fontFamily: 'Cairo', fontSize: 14, color: AdminColors.textSecondary)),
              const SizedBox(height: 40),
              Wrap(
                spacing: 24,
                runSpacing: 24,
                alignment: WrapAlignment.center,
                children: List.generate(_sections.length, (i) {
                  final s = _sections[i];
                  final color = _colors[i];
                  return _SectionCard(
                    label: s['label'] as String,
                    sub: s['sub'] as String,
                    icon: s['icon'] as IconData,
                    color: color,
                    onTap: () async {
                      await adminScope.select(s['lpId'] as int, s['bacId'] as int);
                      if (context.mounted) {
                        Navigator.pushReplacementNamed(context, '/dashboard');
                      }
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String label;
  final String sub;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _SectionCard({required this.label, required this.sub, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AdminColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AdminColors.border),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 20),
            Text(label, style: TextStyle(fontFamily: 'Cairo', fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 6),
            Text(sub, style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AdminColors.textSecondary), textAlign: TextAlign.center),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
              child: const Text('دخول', style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
