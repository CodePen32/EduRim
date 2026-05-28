class ProgressStats {
  final int completedLessons;
  final int totalProgressRecords;
  final double averagePercentage;
  final String lastLessonTitle;

  const ProgressStats({
    required this.completedLessons,
    required this.totalProgressRecords,
    required this.averagePercentage,
    required this.lastLessonTitle,
  });

  factory ProgressStats.fromJson(Map<String, dynamic> json) {
    return ProgressStats(
      completedLessons: json['completed_lessons'] as int? ?? 0,
      totalProgressRecords: json['total_progress_records'] as int? ?? 0,
      averagePercentage: (json['average_percentage'] as num?)?.toDouble() ?? 0.0,
      lastLessonTitle: json['last_lesson_title'] as String? ?? '',
    );
  }
}

class SubjectProgress {
  final int subjectId;
  final String subjectName;
  final int completedLessons;
  final int totalLessons;
  final int percentage;

  const SubjectProgress({
    required this.subjectId,
    required this.subjectName,
    required this.completedLessons,
    required this.totalLessons,
    required this.percentage,
  });

  factory SubjectProgress.fromJson(Map<String, dynamic> json) {
    return SubjectProgress(
      subjectId: json['subject_id'] as int? ?? 0,
      subjectName: json['subject_name'] as String? ?? '',
      completedLessons: json['completed_lessons'] as int? ?? 0,
      totalLessons: json['total_lessons'] as int? ?? 0,
      percentage: json['percentage'] as int? ?? 0,
    );
  }
}
