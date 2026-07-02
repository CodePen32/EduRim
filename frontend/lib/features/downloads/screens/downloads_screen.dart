import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'dart:io';
import '../../../core/constants/app_colors.dart';
import '../../../core/i18n/app_strings.dart';
import '../../../core/models/offline_lesson.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/offline_download_service.dart';
import '../../../shared/widgets/app_header.dart';

class DownloadsScreen extends StatefulWidget {
  final bool standalone;
  const DownloadsScreen({super.key, this.standalone = true});

  @override
  State<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends State<DownloadsScreen> {
  List<OfflineLesson> _lessons = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() => _loading = true);
    final list = offlineDownloadService.getDownloadedLessons();
    if (mounted) setState(() { _lessons = list; _loading = false; });
  }

  Future<void> _delete(OfflineLesson ol) async {
    try {
      await offlineDownloadService.deleteDownloadedLesson(ol.lessonId);
      if (mounted) setState(() => _lessons.remove(ol));
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(tr('common.deleteFailed'), style: const TextStyle(fontFamily: 'Cairo')), behavior: SnackBarBehavior.floating),
        );
      }
    }
  }

  void _openVideo(OfflineLesson ol) {
    if (ol.localVideoPath.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('downloads.videoMissing'), style: const TextStyle(fontFamily: 'Cairo')), behavior: SnackBarBehavior.floating),
      );
      return;
    }
    Navigator.pushNamed(context, AppRoutes.videoPlayer, arguments: {
      'title': ol.title,
      'videoUrl': ol.originalVideoUrl,
      'localPath': ol.localVideoPath,
    });
  }

  void _openSummary(OfflineLesson ol) {
    if (ol.localSummaryPath.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('downloads.summaryMissing'), style: const TextStyle(fontFamily: 'Cairo')), behavior: SnackBarBehavior.floating),
      );
      return;
    }
    Navigator.pushNamed(context, AppRoutes.pdfViewer, arguments: {
      'title': '${tr('summaryPrefix')}${ol.title}',
      'localPath': ol.localSummaryPath,
    });
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Scaffold(
        appBar: widget.standalone ? AppHeader(title: tr('downloads.title')) : null,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.phone_android_outlined, size: 72, color: AppColors.textLight),
                const SizedBox(height: 16),
                Text(
                  tr('downloads.webTitle'),
                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  tr('downloads.webBody'),
                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppColors.textSecondary, height: 1.7),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: widget.standalone ? AppHeader(title: tr('downloads.title')) : null,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!widget.standalone)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Text(tr('downloads.title'), style: const TextStyle(fontFamily: 'Cairo', fontSize: 20, fontWeight: FontWeight.bold)),
            ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _lessons.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.download_outlined, size: 64, color: AppColors.textLight),
                            const SizedBox(height: 12),
                            Text(tr('downloads.emptyTitle'), style: const TextStyle(fontFamily: 'Cairo', color: AppColors.textSecondary)),
                            const SizedBox(height: 4),
                            Text(tr('downloads.emptyHint'), style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.textLight)),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _lessons.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, i) => _LessonCard(
                          ol: _lessons[i],
                          formatDate: _formatDate,
                          onOpenVideo: () => _openVideo(_lessons[i]),
                          onOpenSummary: () => _openSummary(_lessons[i]),
                          onDelete: () => _delete(_lessons[i]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _LessonCard extends StatelessWidget {
  final OfflineLesson ol;
  final String Function(DateTime) formatDate;
  final VoidCallback onOpenVideo;
  final VoidCallback onOpenSummary;
  final VoidCallback onDelete;

  const _LessonCard({
    required this.ol,
    required this.formatDate,
    required this.onOpenVideo,
    required this.onOpenSummary,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final hasCover = ol.localCoverPath.isNotEmpty;
    final hasVideo = ol.localVideoPath.isNotEmpty;
    final hasSummary = ol.localSummaryPath.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Cover image or icon
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: hasCover
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(ol.localCoverPath),
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => const Icon(Icons.play_lesson_outlined, color: AppColors.primary, size: 28),
                          ),
                        )
                      : const Icon(Icons.play_lesson_outlined, color: AppColors.primary, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ol.title,
                        style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 14),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (ol.durationLabel.isNotEmpty) ...[
                            const Icon(Icons.access_time, size: 12, color: AppColors.textLight),
                            const SizedBox(width: 3),
                            Text(ol.durationLabel, style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.textLight)),
                            const SizedBox(width: 8),
                          ],
                          const Icon(Icons.calendar_today_outlined, size: 12, color: AppColors.textLight),
                          const SizedBox(width: 3),
                          Text(formatDate(ol.downloadedAt), style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.textLight)),
                        ],
                      ),
                      if (ol.sizeLabel.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(ol.sizeLabel, style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.textLight)),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 22),
                  tooltip: tr('downloads.deleteDevice'),
                  onPressed: onDelete,
                ),
              ],
            ),
          ),

          // Action buttons
          if (hasVideo || hasSummary)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Row(
                children: [
                  if (hasVideo)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onOpenVideo,
                        icon: const Icon(Icons.play_arrow_rounded, size: 18),
                        label: Text(tr('downloads.watch'), style: const TextStyle(fontFamily: 'Cairo', fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                      ),
                    ),
                  if (hasVideo && hasSummary) const SizedBox(width: 8),
                  if (hasSummary)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onOpenSummary,
                        icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
                        label: Text(tr('downloads.summary'), style: const TextStyle(fontFamily: 'Cairo', fontSize: 12)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
