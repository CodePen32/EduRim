class Teacher {
  final int id;
  final String fullName;
  final int subjectId;
  final String avatarUrl;
  final String bio;

  const Teacher({
    required this.id,
    required this.fullName,
    required this.subjectId,
    required this.avatarUrl,
    required this.bio,
  });

  factory Teacher.fromJson(Map<String, dynamic> json) {
    return Teacher(
      id: json['id'] as int,
      fullName: json['full_name'] as String,
      subjectId: json['subject_id'] as int? ?? 0,
      avatarUrl: json['avatar_url'] as String? ?? '',
      bio: json['bio'] as String? ?? '',
    );
  }
}
