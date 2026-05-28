import 'package:hive/hive.dart';

part 'offline_lesson.g.dart';

@HiveType(typeId: 0)
class OfflineLesson extends HiveObject {
  @HiveField(0)
  final int lessonId;

  @HiveField(1)
  final int subjectId;

  @HiveField(2)
  final String title;

  @HiveField(3)
  final String description;

  @HiveField(4)
  final int durationMinutes;

  @HiveField(5)
  String localVideoPath;

  @HiveField(6)
  String localSummaryPath;

  @HiveField(7)
  String localCoverPath;

  @HiveField(8)
  final String originalVideoUrl;

  @HiveField(9)
  final String originalSummaryUrl;

  @HiveField(10)
  final String originalCoverUrl;

  @HiveField(11)
  final DateTime downloadedAt;

  @HiveField(12)
  int totalSizeBytes;

  OfflineLesson({
    required this.lessonId,
    required this.subjectId,
    required this.title,
    required this.description,
    required this.durationMinutes,
    this.localVideoPath = '',
    this.localSummaryPath = '',
    this.localCoverPath = '',
    required this.originalVideoUrl,
    required this.originalSummaryUrl,
    required this.originalCoverUrl,
    required this.downloadedAt,
    this.totalSizeBytes = 0,
  });

  String get durationLabel {
    if (durationMinutes < 60) return '$durationMinutes دقيقة';
    final h = durationMinutes ~/ 60;
    final m = durationMinutes % 60;
    return m == 0 ? '$h ساعة' : '$h س $m د';
  }

  String get sizeLabel {
    if (totalSizeBytes <= 0) return '';
    if (totalSizeBytes < 1024 * 1024) return '${(totalSizeBytes / 1024).toStringAsFixed(1)} KB';
    if (totalSizeBytes < 1024 * 1024 * 1024) return '${(totalSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(totalSizeBytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}
