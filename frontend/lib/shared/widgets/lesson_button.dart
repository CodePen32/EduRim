import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class LessonButton extends StatelessWidget {
  final String title;
  final String duration;
  final bool isFree;
  final bool isCompleted;
  final VoidCallback? onTap;

  const LessonButton({
    super.key,
    required this.title,
    required this.duration,
    this.isFree = false,
    this.isCompleted = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isCompleted ? AppColors.success : AppColors.cardBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isCompleted ? AppColors.success.withValues(alpha: 0.1) : AppColors.accentLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isCompleted ? Icons.check_circle : Icons.play_circle_filled,
                color: isCompleted ? AppColors.success : AppColors.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600, fontSize: 14)),
                  Text(duration, style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
            if (isFree)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                child: const Text('مجاني', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.success, fontWeight: FontWeight.bold)),
              )
            else
              const Icon(Icons.lock_outline, color: AppColors.textLight, size: 18),
          ],
        ),
      ),
    );
  }
}
