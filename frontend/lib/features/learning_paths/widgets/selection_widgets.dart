import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

// ─────────────────────────────────────────────
// AppBar for selection screens
// ─────────────────────────────────────────────
class SelectionAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBack;

  const SelectionAppBar({
    super.key,
    required this.title,
    this.showBack = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false,
      leading: showBack
          ? IconButton(
              icon: const Icon(Icons.arrow_forward_ios_rounded, size: 20),
              onPressed: () => Navigator.pop(context),
            )
          : null,
      title: Text(
        title,
        style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 18),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Inline section header (title + subtitle)
// ─────────────────────────────────────────────
class SelectionSectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const SelectionSectionHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13,
              color: Color(0xFF64748B),
            ),
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Onboarding step indicator (e.g. "الخطوة 1 من 2")
// ─────────────────────────────────────────────
class SelectionStepIndicator extends StatelessWidget {
  final int step;
  final int total;

  const SelectionStepIndicator({super.key, required this.step, required this.total});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Progress dots/bars
          Row(
            children: List.generate(total, (i) {
              final active = i < step;
              return Container(
                margin: const EdgeInsetsDirectional.only(end: 6),
                width: active ? 22 : 10,
                height: 6,
                decoration: BoxDecoration(
                  color: active ? AppColors.primary : const Color(0xFFD7DEEC),
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
          Text(
            'الخطوة $step من $total',
            style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Bottom CTA button (gradient when enabled)
// ─────────────────────────────────────────────
class SelectionBottomButton extends StatelessWidget {
  final String label;
  final bool saving;
  final bool enabled;
  final VoidCallback onPressed;

  const SelectionBottomButton({
    super.key,
    required this.label,
    required this.saving,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: enabled
              ? const LinearGradient(colors: [Color(0xFF0D47A1), Color(0xFF1E88E5)])
              : null,
          color: enabled ? null : const Color(0xFFCFD8EC),
          boxShadow: enabled
              ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.28), blurRadius: 12, offset: const Offset(0, 4))]
              : [],
        ),
        child: ElevatedButton(
          onPressed: (enabled && !saving) ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.transparent,
            disabledForegroundColor: Colors.white54,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: saving
              ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
              : Text(label, style: const TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Kept for backward compat — redirects to new widget
// ─────────────────────────────────────────────
@Deprecated('Use SelectionAppBar + SelectionSectionHeader instead')
class SelectionHeroHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool showBack;

  const SelectionHeroHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.showBack = false,
  });

  @override
  Widget build(BuildContext context) {
    return SelectionSectionHeader(title: title, subtitle: subtitle);
  }
}
