import '../models/calculator_subject.dart';
import '../models/calculator_result.dart';
import '../network/api_client.dart';

class CalculatorService {
  Future<List<CalculatorSubject>> getSubjects() async {
    final data = await apiClient.get('/calculator/subjects');
    final raw = data['subjects'];
    final list = raw is List ? raw : <dynamic>[];
    return list.map((e) => CalculatorSubject.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<CalculatorResult> calculate(List<Map<String, dynamic>> marks) async {
    final data = await apiClient.post('/calculator/calculate', {'marks': marks});
    return CalculatorResult.fromJson(data);
  }
}

final calculatorService = CalculatorService();
