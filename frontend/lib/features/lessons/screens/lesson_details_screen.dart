import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/lesson.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/download_service.dart';
import '../../../core/services/favorite_service.dart';
import '../../../core/services/offline_download_service.dart';
import '../../../core/services/progress_service.dart';
import '../../../core/services/subscription_service.dart';
import '../../../core/utils/url_helper.dart';
import '../../../shared/widgets/primary_button.dart';

class LessonDetailsScreen extends StatefulWidget {
  const LessonDetailsScreen({super.key});

  @override
  State<LessonDetailsScreen> createState() => _LessonDetailsScreenState();
}

class _LessonDetailsScreenState extends State<LessonDetailsScreen> {
  bool _marking = false;
  bool _marked = false;
  bool _favorited = false;
  bool _saved = false;
  bool _downloading = false;
  double _downloadProgress = 0;
  String _downloadLabel = '';
  bool _isDownloaded = false;
  bool _checkingSubscription = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final lesson = ModalRoute.of(context)?.settings.arguments as Lesson?;
    if (lesson != null && !kIsWeb) {
      _isDownloaded = offlineDownloadService.isLessonDownloaded(lesson.id);
    }
  }

  Future<void> _toggleFavorite(int lessonId) async {
    try {
      final added = await favoriteService.addFavorite(itemType: 'lesson', itemId: lessonId);
      if (!mounted) return;
      if (added) {
        setState(() => _favorited = true);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('تمت الإضافة إلى المفضلة', style: TextStyle(fontFamily: 'Cairo')),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('الدرس موجود في المفضلة بالفعل', style: TextStyle(fontFamily: 'Cairo')),
          behavior: SnackBarBehavior.floating,
        ));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('تعذر الإضافة', style: TextStyle(fontFamily: 'Cairo')),
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  Future<void> _saveLesson(int lessonId) async {
    try {
      final saved = await downloadService.addDownload(itemType: 'lesson', itemId: lessonId);
      if (!mounted) return;
      if (saved) {
        setState(() => _saved = true);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('تم حفظ الدرس في القائمة', style: TextStyle(fontFamily: 'Cairo')),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('الدرس محفوظ بالفعل', style: TextStyle(fontFamily: 'Cairo')),
          behavior: SnackBarBehavior.floating,
        ));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('تعذر الحفظ', style: TextStyle(fontFamily: 'Cairo')),
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  Future<void> _markComplete(int lessonId) async {
    setState(() => _marking = true);
    try {
      await progressService.saveProgress(lessonId: lessonId, watchedPercentage: 100, completed: true);
      if (mounted) {
        setState(() { _marking = false; _marked = true; });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('تم تحديد الدرس كمكتمل', style: TextStyle(fontFamily: 'Cairo')),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } catch (_) {
      if (mounted) {
        setState(() => _marking = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('تعذر حفظ التقدم', style: TextStyle(fontFamily: 'Cairo')),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  Future<void> _downloadOffline(Lesson lesson) async {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          'التنزيل بدون إنترنت متاح في تطبيق الهاتف. على الويب يمكنك فتح الفيديو أو الملخص مباشرة.',
          style: TextStyle(fontFamily: 'Cairo'),
        ),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 4),
      ));
      return;
    }

    if (!lesson.videoUrl.isNotEmpty && !lesson.summaryUrl.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('لا توجد ملفات قابلة للتنزيل لهذا الدرس', style: TextStyle(fontFamily: 'Cairo')),
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    setState(() { _downloading = true; _downloadProgress = 0; _downloadLabel = 'جاري التنزيل...'; });

    try {
      await offlineDownloadService.downloadLesson(
        lesson,
        onProgress: (progress, label) {
          if (mounted) setState(() { _downloadProgress = progress; _downloadLabel = label; });
        },
      );
      if (mounted) {
        setState(() { _downloading = false; _isDownloaded = true; });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('تم تنزيل الدرس بنجاح للمشاهدة بدون إنترنت', style: TextStyle(fontFamily: 'Cairo')),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } catch (e) {
      if (mounted) {
        setState(() { _downloading = false; });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('فشل التنزيل: ${e.toString().replaceFirst('Exception:', '').trim()}', style: const TextStyle(fontFamily: 'Cairo')),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  Future<void> _checkSubscriptionAndOpenVideo(Lesson lesson) async {
    if (lesson.isFree) {
      _openVideo(lesson);
      return;
    }
    setState(() => _checkingSubscription = true);
    try {
      final sub = await subscriptionService.getMySubscription();
      if (!mounted) return;
      if (sub.hasSubscription && sub.isActive) {
        _openVideo(lesson);
      } else {
        _showSubscriptionDialog();
      }
    } catch (_) {
      if (mounted) _showSubscriptionDialog();
    } finally {
      if (mounted) setState(() => _checkingSubscription = false);
    }
  }

  void _showSubscriptionDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'اشتراك مطلوب',
          style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
          textAlign: TextAlign.right,
        ),
        content: const Text(
          'هذا الدرس يحتاج إلى اشتراك نشط للمشاهدة.',
          style: TextStyle(fontFamily: 'Cairo'),
          textAlign: TextAlign.right,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo', color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: AppColors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushNamed(context, AppRoutes.mySubscription);
            },
            child: const Text('عرض الاشتراك', style: TextStyle(fontFamily: 'Cairo')),
          ),
        ],
      ),
    );
  }

  void _openVideo(Lesson lesson) {
    if (!lesson.videoUrl.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('الفيديو غير متاح حالياً', style: TextStyle(fontFamily: 'Cairo')),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ));
      return;
    }
    Navigator.pushNamed(context, AppRoutes.videoPlayer, arguments: lesson);
  }

  void _openOfflineVideo(Lesson lesson) {
    if (kIsWeb) return;
    final ol = offlineDownloadService.getDownloadedLesson(lesson.id);
    if (ol == null || ol.localVideoPath.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('الفيديو غير موجود محلياً', style: TextStyle(fontFamily: 'Cairo')),
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    Navigator.pushNamed(context, AppRoutes.videoPlayer, arguments: {
      'title': lesson.title,
      'videoUrl': '',
      'localPath': ol.localVideoPath,
    });
  }

  void _openPdf(Lesson lesson) {
    if (!lesson.summaryUrl.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('الملخص غير متاح حالياً', style: TextStyle(fontFamily: 'Cairo')),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ));
      return;
    }
    Navigator.pushNamed(context, AppRoutes.pdfViewer, arguments: {
      'title': 'ملخص: ${lesson.title}',
      'pdfUrl': lesson.summaryUrl,
    });
  }

  @override
  Widget build(BuildContext context) {
    final lesson = ModalRoute.of(context)?.settings.arguments as Lesson?;

    final title = lesson?.title ?? 'تفاصيل الدرس';
    final description = lesson?.description.isNotEmpty == true
        ? lesson!.description
        : 'لا يوجد وصف لهذا الدرس حالياً.';
    final duration = lesson?.durationLabel ?? '';
    final isFree = lesson?.isFree ?? false;
    final hasVideo = lesson?.videoUrl.isNotEmpty == true;
    final hasSummary = lesson?.summaryUrl.isNotEmpty == true;
    final lessonId = lesson?.id ?? 0;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColors.primaryDark,
            foregroundColor: AppColors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: _LessonHeader(
                coverImageUrl: lesson?.coverImageUrl ?? '',
                isFree: isFree,
                hasVideo: hasVideo,
                onPlayTap: lesson != null ? () => _checkSubscriptionAndOpenVideo(lesson) : null,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (duration.isNotEmpty) ...[
                        const Icon(Icons.access_time, size: 16, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(duration, style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppColors.textSecondary)),
                        const SizedBox(width: 16),
                      ],
                      if (isFree)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('مجاني', style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.success, fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _ActionButton(
                        icon: _favorited ? Icons.favorite : Icons.favorite_border,
                        label: 'مفضلة',
                        color: _favorited ? AppColors.error : AppColors.primary,
                        onTap: lessonId > 0 ? () => _toggleFavorite(lessonId) : () {},
                      ),
                      const SizedBox(width: 12),
                      _ActionButton(
                        icon: _saved ? Icons.bookmark : Icons.bookmark_add_outlined,
                        label: _saved ? 'محفوظ' : 'حفظ',
                        color: _saved ? AppColors.success : AppColors.primary,
                        onTap: lessonId > 0 && !_saved ? () => _saveLesson(lessonId) : () {},
                      ),
                      const SizedBox(width: 12),
                      _ActionButton(icon: Icons.share_outlined, label: 'مشاركة', onTap: () {}),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text('وصف الدرس', style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(description, style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, color: AppColors.textSecondary, height: 1.7)),
                  const SizedBox(height: 24),

                  // زر مشاهدة الفيديو داخل التطبيق
                  PrimaryButton(
                    label: hasVideo ? 'مشاهدة الدرس' : 'الفيديو غير متاح حالياً',
                    icon: Icons.play_arrow_rounded,
                    onPressed: _checkingSubscription
                        ? () {}
                        : lesson != null ? () => _checkSubscriptionAndOpenVideo(lesson) : () {},
                  ),
                  const SizedBox(height: 12),

                  // زر فتح الملخص PDF داخل التطبيق
                  OutlinedButton.icon(
                    onPressed: lesson != null ? () => _openPdf(lesson) : null,
                    icon: const Icon(Icons.picture_as_pdf_outlined),
                    label: Text(
                      hasSummary ? 'فتح الملخص PDF' : 'الملخص غير متاح حالياً',
                      style: const TextStyle(fontFamily: 'Cairo'),
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      foregroundColor: hasSummary ? AppColors.primary : AppColors.textLight,
                      side: BorderSide(color: hasSummary ? AppColors.primary : AppColors.textLight),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // زر التنزيل offline
                  _buildOfflineButton(lesson),
                  const SizedBox(height: 12),

                  // زر تحديد كمكتمل
                  if (_marked)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.success),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle, color: AppColors.success, size: 20),
                          SizedBox(width: 8),
                          Text('تم تحديد الدرس كمكتمل', style: TextStyle(fontFamily: 'Cairo', color: AppColors.success, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    )
                  else
                    OutlinedButton.icon(
                      onPressed: lessonId > 0 && !_marking ? () => _markComplete(lessonId) : null,
                      icon: _marking
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.check_circle_outline),
                      label: Text(
                        _marking ? 'جارٍ الحفظ...' : 'تحديد كدرس مكتمل',
                        style: const TextStyle(fontFamily: 'Cairo'),
                      ),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        foregroundColor: AppColors.success,
                        side: const BorderSide(color: AppColors.success),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineButton(Lesson? lesson) {
    if (lesson == null) return const SizedBox.shrink();

    final hasFiles = lesson.videoUrl.isNotEmpty || lesson.summaryUrl.isNotEmpty;

    // Web fallback
    if (kIsWeb) {
      return OutlinedButton.icon(
        onPressed: () => _downloadOffline(lesson),
        icon: const Icon(Icons.phone_android_outlined),
        label: const Text('التنزيل بدون إنترنت (تطبيق الهاتف)', style: TextStyle(fontFamily: 'Cairo')),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 48),
          foregroundColor: AppColors.textSecondary,
          side: const BorderSide(color: AppColors.textLight),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }

    // No files
    if (!hasFiles) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.textLight.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.textLight),
        ),
        child: const Text(
          'لا توجد ملفات قابلة للتنزيل لهذا الدرس',
          style: TextStyle(fontFamily: 'Cairo', color: AppColors.textLight, fontSize: 13),
          textAlign: TextAlign.center,
        ),
      );
    }

    // Already downloaded
    if (_isDownloaded) {
      return Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.offline_pin, color: AppColors.primary, size: 20),
                SizedBox(width: 8),
                Text('متاح بدون إنترنت', style: TextStyle(fontFamily: 'Cairo', color: AppColors.primary, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              if (lesson.videoUrl.isNotEmpty)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _openOfflineVideo(lesson),
                    icon: const Icon(Icons.play_arrow_rounded, size: 18),
                    label: const Text('مشاهدة offline', style: TextStyle(fontFamily: 'Cairo', fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              if (lesson.videoUrl.isNotEmpty && lesson.summaryUrl.isNotEmpty)
                const SizedBox(width: 8),
              if (lesson.summaryUrl.isNotEmpty)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      final ol = offlineDownloadService.getDownloadedLesson(lesson.id);
                      if (ol != null && ol.localSummaryPath.isNotEmpty) {
                        Navigator.pushNamed(context, AppRoutes.pdfViewer, arguments: {
                          'title': 'ملخص: ${lesson.title}',
                          'localPath': ol.localSummaryPath,
                        });
                      } else {
                        _openPdf(lesson);
                      }
                    },
                    icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
                    label: const Text('ملخص offline', style: TextStyle(fontFamily: 'Cairo', fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
            ],
          ),
        ],
      );
    }

    // Downloading in progress
    if (_downloading) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                const SizedBox(width: 10),
                Text(_downloadLabel, style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppColors.primary)),
                const Spacer(),
                Text('${(_downloadProgress * 100).toInt()}%', style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: _downloadProgress,
              backgroundColor: AppColors.primary.withValues(alpha: 0.15),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
    }

    // Download button
    return OutlinedButton.icon(
      onPressed: () => _downloadOffline(lesson),
      icon: const Icon(Icons.download_outlined),
      label: const Text('تنزيل للمشاهدة بدون إنترنت', style: TextStyle(fontFamily: 'Cairo')),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _LessonHeader extends StatelessWidget {
  final String coverImageUrl;
  final bool isFree;
  final bool hasVideo;
  final VoidCallback? onPlayTap;

  const _LessonHeader({
    required this.coverImageUrl,
    required this.isFree,
    this.hasVideo = false,
    this.onPlayTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasCover = coverImageUrl.isNotEmpty;
    final resolvedUrl = buildFileUrl(coverImageUrl);

    return Stack(
      fit: StackFit.expand,
      children: [
        if (hasCover)
          Image.network(
            resolvedUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(color: AppColors.primaryDark),
          )
        else
          Container(color: AppColors.primaryDark),
        if (hasCover)
          Container(color: Colors.black.withValues(alpha: 0.45)),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 30),
            GestureDetector(
              onTap: hasVideo ? onPlayTap : null,
              child: Icon(
                isFree ? Icons.play_circle_filled : Icons.lock_rounded,
                color: hasVideo ? AppColors.white : Colors.white38,
                size: 72,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              isFree ? 'درس مجاني' : 'درس مدفوع',
              style: TextStyle(
                fontFamily: 'Cairo',
                color: isFree ? Colors.greenAccent : Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _ActionButton({required this.icon, required this.label, required this.onTap, this.color = AppColors.primary});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
          child: Column(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 4),
              Text(label, style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: color)),
            ],
          ),
        ),
      ),
    );
  }
}
