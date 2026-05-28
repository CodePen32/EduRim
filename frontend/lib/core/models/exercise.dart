class Exercise {
  final int id;
  final int subjectId;
  final int? lessonId;
  final String title;
  final int year;
  final String difficulty;
  final String exerciseFileUrl;
  final String solutionFileUrl;
  final String videoSolutionUrl;
  final String coverImageUrl;

  const Exercise({
    required this.id,
    required this.subjectId,
    this.lessonId,
    required this.title,
    required this.year,
    required this.difficulty,
    required this.exerciseFileUrl,
    required this.solutionFileUrl,
    required this.videoSolutionUrl,
    this.coverImageUrl = '',
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] as int,
      subjectId: json['subject_id'] as int? ?? 0,
      lessonId: json['lesson_id'] as int?,
      title: json['title'] as String,
      year: json['year'] as int? ?? 0,
      difficulty: json['difficulty'] as String? ?? 'متوسط',
      exerciseFileUrl: json['exercise_file_url'] as String? ?? '',
      solutionFileUrl: json['solution_file_url'] as String? ?? '',
      videoSolutionUrl: json['video_solution_url'] as String? ?? '',
      coverImageUrl: json['cover_image_url'] as String? ?? '',
    );
  }
}
