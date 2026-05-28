class Lesson {
  final int id;
  final int subjectId;
  final int teacherId;
  final String title;
  final String description;
  final String videoUrl;
  final String summaryUrl;
  final int durationMinutes;
  final bool isFree;
  final int sortOrder;
  final String coverImageUrl;

  const Lesson({
    required this.id,
    required this.subjectId,
    required this.teacherId,
    required this.title,
    required this.description,
    required this.videoUrl,
    required this.summaryUrl,
    required this.durationMinutes,
    required this.isFree,
    required this.sortOrder,
    this.coverImageUrl = '',
  });

  String get durationLabel {
    if (durationMinutes < 60) return '$durationMinutes دقيقة';
    final h = durationMinutes ~/ 60;
    final m = durationMinutes % 60;
    return m == 0 ? '$h ساعة' : '$h س $m د';
  }

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] as int,
      subjectId: json['subject_id'] as int? ?? 0,
      teacherId: json['teacher_id'] as int? ?? 0,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      videoUrl: json['video_url'] as String? ?? '',
      summaryUrl: json['summary_url'] as String? ?? '',
      durationMinutes: json['duration_minutes'] as int? ?? 0,
      isFree: json['is_free'] as bool? ?? false,
      sortOrder: json['sort_order'] as int? ?? 0,
      coverImageUrl: json['cover_image_url'] as String? ?? '',
    );
  }
}
