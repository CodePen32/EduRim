import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

final _dio = Dio();

Future<Map<String, dynamic>?> nativeDownloadLesson({
  required int lessonId,
  required String videoUrl,
  required String summaryUrl,
  required String coverUrl,
  void Function(double progress, String label)? onProgress,
}) async {
  final dir = await _appDir();
  final lessonDir = Directory('${dir.path}/lessons/$lessonId');
  await lessonDir.create(recursive: true);

  String localVideo = '';
  String localSummary = '';
  String localCover = '';
  int totalBytes = 0;

  try {
    if (coverUrl.isNotEmpty) {
      onProgress?.call(0.05, 'تحميل الغلاف...');
      final ext = _ext(coverUrl, '.jpg');
      final dest = '${lessonDir.path}/cover$ext';
      await _download(coverUrl, dest);
      localCover = dest;
      totalBytes += await File(dest).length();
    }

    if (summaryUrl.isNotEmpty) {
      onProgress?.call(0.2, 'تحميل الملخص...');
      final ext = _ext(summaryUrl, '.pdf');
      final dest = '${lessonDir.path}/summary$ext';
      await _download(summaryUrl, dest, onReceiveProgress: (recv, total) {
        if (total > 0) onProgress?.call(0.2 + 0.2 * (recv / total), 'تحميل الملخص...');
      });
      localSummary = dest;
      totalBytes += await File(dest).length();
    }

    if (videoUrl.isNotEmpty) {
      onProgress?.call(0.4, 'تحميل الفيديو...');
      final ext = _ext(videoUrl, '.mp4');
      final dest = '${lessonDir.path}/video$ext';
      await _download(videoUrl, dest, onReceiveProgress: (recv, total) {
        if (total > 0) onProgress?.call(0.4 + 0.58 * (recv / total), 'تحميل الفيديو...');
      });
      localVideo = dest;
      totalBytes += await File(dest).length();
    }

    onProgress?.call(1.0, 'اكتمل التنزيل');

    return {
      'videoPath': localVideo,
      'summaryPath': localSummary,
      'coverPath': localCover,
      'totalBytes': totalBytes,
    };
  } catch (e) {
    try { await lessonDir.delete(recursive: true); } catch (_) {}
    rethrow;
  }
}

Future<void> nativeDeleteLesson(int lessonId) async {
  final dir = await _appDir();
  final lessonDir = Directory('${dir.path}/lessons/$lessonId');
  try { await lessonDir.delete(recursive: true); } catch (_) {}
}

Future<void> _download(String url, String savePath, {void Function(int, int)? onReceiveProgress}) async {
  await _dio.download(
    url,
    savePath,
    onReceiveProgress: onReceiveProgress,
    options: Options(receiveTimeout: const Duration(minutes: 15)),
  );
}

Future<Directory> _appDir() async {
  try {
    return await getApplicationDocumentsDirectory();
  } catch (_) {
    return await getTemporaryDirectory();
  }
}

String _ext(String url, String fallback) {
  final uri = Uri.tryParse(url);
  if (uri == null) return fallback;
  final path = uri.path;
  final dot = path.lastIndexOf('.');
  if (dot == -1) return fallback;
  final e = path.substring(dot);
  if (e.length > 5) return fallback;
  return e;
}
