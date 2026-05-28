class Subject {
  final int id;
  final int learningPathId;
  final int? bacBranchId;
  final String nameAr;
  final String nameFr;
  final String color;
  final int sortOrder;
  final String coverImageUrl;
  final int lessonsCount;

  const Subject({
    required this.id,
    required this.learningPathId,
    this.bacBranchId,
    required this.nameAr,
    required this.nameFr,
    required this.color,
    required this.sortOrder,
    this.coverImageUrl = '',
    this.lessonsCount = 0,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'] as int,
      learningPathId: json['learning_path_id'] as int,
      bacBranchId: json['bac_branch_id'] as int?,
      nameAr: json['name_ar'] as String,
      nameFr: json['name_fr'] as String,
      color: json['color'] as String? ?? '#1565C0',
      sortOrder: json['sort_order'] as int? ?? 0,
      coverImageUrl: json['cover_image_url'] as String? ?? '',
      lessonsCount: json['lessons_count'] as int? ?? 0,
    );
  }
}
