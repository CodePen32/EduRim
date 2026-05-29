class CalculatorSubject {
  final int subjectId;
  final String subjectName;
  final double coefficient;
  final double maxMark;
  final String calculationType;
  final bool isRequired;
  final int learningPathId;

  const CalculatorSubject({
    required this.subjectId,
    required this.subjectName,
    required this.coefficient,
    required this.maxMark,
    required this.calculationType,
    required this.isRequired,
    required this.learningPathId,
  });

  factory CalculatorSubject.fromJson(Map<String, dynamic> json) {
    return CalculatorSubject(
      subjectId: json['subject_id'] as int,
      subjectName: json['subject_name'] as String,
      coefficient: (json['coefficient'] as num).toDouble(),
      maxMark: (json['max_mark'] as num?)?.toDouble() ?? 20.0,
      calculationType: json['calculation_type'] as String? ?? 'weighted_average',
      isRequired: json['is_required'] == true || json['is_required'] == 1,
      learningPathId: (json['learning_path_id'] as num?)?.toInt() ?? 0,
    );
  }
}
