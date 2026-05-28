import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class VideoCard extends StatelessWidget {
  final String title;
  final String teacher;
  final String duration;
  final String subject;
  final VoidCallback? onTap;

  const VideoCard({
    super.key,
    required this.title,
    required this.teacher,
    required this.duration,
    required this.subject,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(topRight: Radius.circular(16), bottomRight: Radius.circular(16)),
              child: Container(
                width: 110,
                height: 80,
                color: AppColors.primaryDark,
                child: const Center(child: Icon(Icons.play_circle_filled, color: AppColors.white, size: 36)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(teacher, style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.textSecondary)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 13, color: AppColors.textLight),
                        const SizedBox(width: 4),
                        Text(duration, style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.textLight)),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: AppColors.accentLight, borderRadius: BorderRadius.circular(4)),
                          child: Text(subject, style: const TextStyle(fontFamily: 'Cairo', fontSize: 10, color: AppColors.primary)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
          ],
        ),
      ),
    );
  }
}
