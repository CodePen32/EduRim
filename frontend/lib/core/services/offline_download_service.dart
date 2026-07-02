import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:hive_flutter/hive_flutter.dart';
import '../models/lesson.dart';
import '../models/offline_lesson.dart';
import '../utils/url_helper.dart';

// Conditional imports — dart:io and path_provider not available on Web
import 'offline_download_service_stub.dart'
    if (dart.library.io) 'offline_download_service_native.dart';

const _boxName = 'offline_lessons';

class OfflineDownloadService {
  Box<OfflineLesson>? _box;

  Future<void> init() async {
    if (kIsWeb) return;
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(OfflineLessonAdapter());
    }
    _box = await Hive.openBox<OfflineLesson>(_boxName);
  }

  bool get isWebPlatform => kIsWeb;

  bool isLessonDownloaded(int lessonId) {
    if (kIsWeb || _box == null) return false;
    return _box!.values.any((l) => l.lessonId == lessonId);
  }

  OfflineLesson? getDownloadedLesson(int lessonId) {
    if (kIsWeb || _box == null) return null;
    try {
      return _box!.values.firstWhere((l) => l.lessonId == lessonId);
    } catch (_) {
      return null;
    }
  }

  List<OfflineLesson> getDownloadedLessons() {
    if (kIsWeb || _box == null) return [];
    final list = _box!.values.toList();
    list.sort((a, b) => b.downloadedAt.compareTo(a.downloadedAt));
    return list;
  }

  Future<OfflineLesson?> downloadLesson(
    Lesson lesson, {
    void Function(double progress, String label)? onProgress,
  }) async {
    if (kIsWeb) return null;

    final videoUrl = buildFileUrl(lesson.videoUrl);
    final summaryUrl = buildFileUrl(lesson.summaryUrl);
    final coverUrl = buildFileUrl(lesson.coverImageUrl);

    try {
      final result = await nativeDownloadLesson(
        lessonId: lesson.id,
        videoUrl: videoUrl,
        summaryUrl: summaryUrl,
        coverUrl: coverUrl,
        onProgress: onProgress,
      );

      if (result == null) return null;

      final offline = OfflineLesson(
        lessonId: lesson.id,
        subjectId: lesson.subjectId,
        title: lesson.title,
        description: lesson.description,
        durationMinutes: lesson.durationMinutes,
        localVideoPath: result['videoPath'] ?? '',
        localSummaryPath: result['summaryPath'] ?? '',
        localCoverPath: result['coverPath'] ?? '',
        originalVideoUrl: lesson.videoUrl,
        originalSummaryUrl: lesson.summaryUrl,
        originalCoverUrl: lesson.coverImageUrl,
        downloadedAt: DateTime.now(),
        totalSizeBytes: result['totalBytes'] as int? ?? 0,
      );

      await _box!.put(lesson.id, offline);
      _lastDownloadHadMissingAttachments = result['missingAttachments'] == true;
      return offline;
    } catch (e) {
      rethrow;
    }
  }

  /// هل تعذّر تنزيل بعض الملفات المرفقة (الغلاف/الملخص) في آخر عملية تنزيل؟
  /// الفيديو نُزّل بنجاح رغم ذلك. للاستخدام في رسالة المستخدم فقط.
  bool _lastDownloadHadMissingAttachments = false;
  bool get lastDownloadHadMissingAttachments => _lastDownloadHadMissingAttachments;

  Future<void> deleteDownloadedLesson(int lessonId) async {
    if (kIsWeb || _box == null) return;
    final ol = getDownloadedLesson(lessonId);
    if (ol == null) return;
    await nativeDeleteLesson(lessonId);
    await _box!.delete(lessonId);
  }
}

final offlineDownloadService = OfflineDownloadService();
