class CalculatorResult {
  final double average;
  final double totalCoefficients;
  final double maxTotal;
  final double totalPoints;
  final String calculationType;
  final String status;
  final String message;

  const CalculatorResult({
    required this.average,
    required this.totalCoefficients,
    required this.maxTotal,
    required this.totalPoints,
    required this.calculationType,
    required this.status,
    required this.message,
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
    );
  }

  bool get isPassing => status == 'ناجح';
  bool get isPoints => calculationType == 'points';
}
