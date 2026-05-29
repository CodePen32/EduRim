class CalculatorResult {
  final double average;
  final double totalCoefficients;
  final double maxTotal;
  final double totalPoints;
  final String calculationType;
  final String status;
  final String message;
  final int learningPathId;

  const CalculatorResult({
    required this.average,
    required this.totalCoefficients,
    required this.maxTotal,
    required this.totalPoints,
    required this.calculationType,
    required this.status,
    required this.message,
    required this.learningPathId,
  });

  factory CalculatorResult.fromJson(Map<String, dynamic> json) {
    return CalculatorResult(
      average: (json['average'] as num).toDouble(),
      totalCoefficients: (json['total_coefficients'] as num).toDouble(),
      maxTotal: (json['max_total'] as num?)?.toDouble() ?? 20.0,
      totalPoints: (json['total_points'] as num?)?.toDouble() ?? 0.0,
      calculationType: json['calculation_type'] as String? ?? 'weighted_average',
      status: json['status'] as String,
      message: json['message'] as String,
      learningPathId: (json['learning_path_id'] as num?)?.toInt() ?? 0,
    );
  }

  bool get isPoints => calculationType == 'points';

  // Outcome based on level rules
  CalculatorOutcome get outcome {
    if (isPoints) {
      return totalPoints >= 85 ? CalculatorOutcome.passed : CalculatorOutcome.failed;
    }
    if (learningPathId == 2) {
      // BEPC
      if (average >= 8.5) return CalculatorOutcome.passed;
      if (average >= 7.0) return CalculatorOutcome.promoted;
      return CalculatorOutcome.failed;
    }
    // BAC (learningPathId == 3) or fallback
    if (average >= 10.0) return CalculatorOutcome.passed;
    if (average >= 8.0) return CalculatorOutcome.retake;
    return CalculatorOutcome.failed;
  }

  bool get isPassing => outcome == CalculatorOutcome.passed;
}

enum CalculatorOutcome { passed, failed, retake, promoted }
