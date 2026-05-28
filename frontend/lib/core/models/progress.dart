class Progress {
  final int id;
  final int userId;
  final int lessonId;
  final int watchedPercentage;
  final bool completed;
  final String updatedAt;

  const Progress({
    required this.id,
    required this.userId,
    required this.lessonId,
    required this.watchedPercentage,
    required this.completed,
    required this.updatedAt,
  });

  factory Progress.fromJson(Map<String, dynamic> json) => Progress(
        id: json['id'] as int? ?? 0,
        userId: json['user_id'] as int? ?? 0,
        lessonId: json['lesson_id'] as int? ?? 0,
        watchedPercentage: json['watched_percentage'] as int? ?? 0,
        completed: json['completed'] as bool? ?? false,
        updatedAt: json['updated_at'] as String? ?? '',
      );
}
