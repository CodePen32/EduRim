import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/i18n/app_strings.dart';
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
  late final PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  static const double _bannerHeight = 200.0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 1.0);
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

    // LayoutBuilder يعطينا العرض الحقيقي للـ widget بعد layout
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return SizedBox(
          width: width,
          height: _bannerHeight,
          child: Stack(
            children: [
              // PageView ملفوف بـ ClipRect بأبعاد صارمة
              Positioned.fill(
                child: ClipRect(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: items.length,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    itemBuilder: (_, i) => _BannerItem(
                      announcement: items[i],
                      width: width,
                      height: _bannerHeight,
                    ),
                  ),
                ),
              ),

              // Dots مؤشرات داخل البنر أسفله
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
      },
    );
  }
}

class _BannerItem extends StatelessWidget {
  final Announcement announcement;
  final double width;
  final double height;

  const _BannerItem({
    required this.announcement,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = announcement.imageUrl.isNotEmpty;
    final hasLink = announcement.linkUrl.isNotEmpty;
    final resolvedImage = hasImage ? buildFileUrl(announcement.imageUrl) : '';

    return GestureDetector(
      onTap: hasLink
          ? () => openExternalUrl(announcement.linkUrl, context: context)
          : null,
      // SizedBox بأبعاد صريحة + ClipRect يمنع أي overflow من الصورة
      child: SizedBox(
        width: width,
        height: height,
        child: ClipRect(
          child: Stack(
            children: [
              // ── طبقة 1: خلفية cover تملأ المساحة كاملاً ──
              Positioned.fill(
                child: hasImage
                    ? Image.network(
                        resolvedImage,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => _gradientBox(),
                      )
                    : _gradientBox(),
              ),

              // ── طبقة 2: dark overlay فوق الخلفية ──
              Positioned.fill(
                child: ColoredBox(
                  color: Colors.black.withValues(alpha: 0.28),
                ),
              ),

              // ── طبقة 3: الصورة contain مقيّدة بـ FittedBox ضمن حدود صارمة ──
              // FittedBox مع BoxFit.contain تعرض الصورة كاملة دون قص
              // وهي مقيّدة تمامًا ضمن حدود SizedBox الأب
              if (hasImage)
                Positioned.fill(
                  child: FittedBox(
                    fit: BoxFit.contain,
                    clipBehavior: Clip.hardEdge,
                    child: Image.network(
                      resolvedImage,
                      errorBuilder: (_, _, _) => const SizedBox.shrink(),
                    ),
                  ),
                ),

              // ── طبقة 4: gradient gradient أسفل للنص ──
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.75),
                      ],
                      stops: const [0.4, 1.0],
                    ),
                  ),
                ),
              ),

              // ── طبقة 5: النص أسفل ──
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

              // ── طبقة 6: badge رابط ──
              if (hasLink)
                Positioned(
                  top: 12,
                  left: 14,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      tr('ann.tapMore'),
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
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
