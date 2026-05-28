import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/models/announcement.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/url_helper.dart';

class AnnouncementCarousel extends StatefulWidget {
  final List<Announcement> announcements;

  const AnnouncementCarousel({super.key, required this.announcements});

  @override
  State<AnnouncementCarousel> createState() => _AnnouncementCarouselState();
}

class _AnnouncementCarouselState extends State<AnnouncementCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.announcements.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 5), (_) {
        if (!mounted) return;
        final next = (_currentPage + 1) % widget.announcements.length;
        _pageController.animateToPage(
          next,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.announcements;
    if (items.isEmpty) return const SizedBox.shrink();

    final h = (MediaQuery.of(context).size.width * 0.55).clamp(170.0, 230.0);
    return SizedBox(
      height: h,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: items.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (_, i) => _BannerItem(announcement: items[i]),
          ),
          if (items.length > 1)
            Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(items.length, (i) {
                  final active = i == _currentPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: active ? 20 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: active ? AppColors.white : Colors.white54,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }
}

class _BannerItem extends StatelessWidget {
  final Announcement announcement;
  const _BannerItem({required this.announcement});

  @override
  Widget build(BuildContext context) {
    final hasImage = announcement.imageUrl.isNotEmpty;
    final hasLink = announcement.linkUrl.isNotEmpty;
    final resolvedImage = hasImage ? buildFileUrl(announcement.imageUrl) : '';

    return GestureDetector(
      onTap: hasLink ? () => openExternalUrl(announcement.linkUrl, context: context) : null,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ── طبقة 1: خلفية cover مع تعتيم (تملأ المساحة) ──
          if (hasImage)
            ColorFiltered(
              colorFilter: ColorFilter.mode(Colors.black.withValues(alpha: 0.35), BlendMode.darken),
              child: Image.network(
                resolvedImage,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _gradientBox(),
              ),
            )
          else
            _gradientBox(),

          // ── طبقة 2: الصورة الأمامية contain (كاملة بدون قص) ──
          if (hasImage)
            Positioned.fill(
              child: Image.network(
                resolvedImage,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            ),

          // ── طبقة 3: gradient أسفل للنص ──
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withValues(alpha: 0.70)],
                  stops: const [0.45, 1.0],
                ),
              ),
            ),
          ),

          // ── طبقة 4: النص في الأسفل ──
          Positioned(
            bottom: 28,
            right: 16,
            left: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  announcement.title,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [Shadow(color: Colors.black87, blurRadius: 8)],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (announcement.message.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    announcement.message,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      color: Colors.white70,
                      shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          // ── طبقة 5: badge رابط ──
          if (hasLink)
            Positioned(
              top: 12,
              left: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'اضغط للمزيد',
                  style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _gradientBox() => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
          ),
        ),
      );
}
