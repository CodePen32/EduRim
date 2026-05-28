import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/url_helper.dart';

class SubjectCard extends StatelessWidget {
  final String name;
  final Color color;
  final int lessonsCount;
  final VoidCallback? onTap;
  final String? coverImageUrl;

  const SubjectCard({
    super.key,
    required this.name,
    required this.color,
    this.lessonsCount = 0,
    this.onTap,
    this.coverImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final hasCover = coverImageUrl != null && coverImageUrl!.isNotEmpty;
    final resolvedUrl = hasCover ? buildFileUrl(coverImageUrl) : '';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.15), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background
              hasCover
                  ? Image.network(
                      resolvedUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _placeholder(color, name),
                    )
                  : _placeholder(color, name),

              // Light scrim at bottom only — helps badge readability
              if (hasCover)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 48,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, Colors.black.withValues(alpha: 0.45)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),

              // Lessons count badge — bottom left
              Positioned(
                left: 10,
                bottom: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: hasCover
                        ? Colors.black.withValues(alpha: 0.55)
                        : color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$lessonsCount درس',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: hasCover ? Colors.white : color,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder(Color c, String label) => Container(
    color: c.withValues(alpha: 0.08),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: c.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(Icons.menu_book_rounded, color: c, size: 26),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );
}
