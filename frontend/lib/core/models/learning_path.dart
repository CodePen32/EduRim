class LearningPath {
  final int id;
  final String code;
  final String nameAr;
  final String nameFr;
  final String description;

  const LearningPath({
    required this.id,
    required this.code,
    required this.nameAr,
    required this.nameFr,
    required this.description,
  });

  factory LearningPath.fromJson(Map<String, dynamic> json) {
    return LearningPath(
      id: json['id'] as int,
      code: json['code'] as String,
      nameAr: json['name_ar'] as String,
      nameFr: json['name_fr'] as String,
      description: json['description'] as String? ?? '',
    );
  }
}

class BacBranch {
  final int id;
  final String code;
  final String nameAr;
  final String nameFr;

  const BacBranch({
    required this.id,
    required this.code,
    required this.nameAr,
    required this.nameFr,
  });

  factory BacBranch.fromJson(Map<String, dynamic> json) {
    return BacBranch(
      id: json['id'] as int,
      code: json['code'] as String,
      nameAr: json['name_ar'] as String,
      nameFr: json['name_fr'] as String,
    );
  }
}
