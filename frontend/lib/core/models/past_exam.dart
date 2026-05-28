class PastExam {
  final int id;
  final int learningPathId;
  final int? bacBranchId;
  final int subjectId;
  final String subjectName;
  final String title;
  final int year;
  final String description;
  final String examFileUrl;
  final String solutionFileUrl;
  final String coverImageUrl;
  final bool isActive;

  const PastExam({
    required this.id,
    required this.learningPathId,
    this.bacBranchId,
    required this.subjectId,
    required this.subjectName,
    required this.title,
    required this.year,
    required this.description,
    required this.examFileUrl,
    required this.solutionFileUrl,
    required this.coverImageUrl,
    required this.isActive,
  });

  factory PastExam.fromJson(Map<String, dynamic> json) {
    return PastExam(
      id: json['id'] as int,
      learningPathId: json['learning_path_id'] as int,
      bacBranchId: json['bac_branch_id'] as int?,
      subjectId: json['subject_id'] as int,
      subjectName: json['subject_name'] as String? ?? '',
      title: json['title'] as String,
      year: json['year'] as int,
      description: json['description'] as String? ?? '',
      examFileUrl: json['exam_file_url'] as String? ?? '',
      solutionFileUrl: json['solution_file_url'] as String? ?? '',
      coverImageUrl: json['cover_image_url'] as String? ?? '',
      isActive: (json['is_active'] as int?) == 1 || json['is_active'] == true,
    );
  }

  bool get hasExam => examFileUrl.isNotEmpty;
  bool get hasSolution => solutionFileUrl.isNotEmpty;
  bool get hasCover => coverImageUrl.isNotEmpty;
}
