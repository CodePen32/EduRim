import '../models/past_exam.dart';
import '../network/api_client.dart';

class PastExamService {
  // /me/past-exams يفلتر تلقائياً حسب مستوى الطالب من JWT
  Future<List<PastExam>> getPastExams({
    int? subjectId,
    int? year,
  }) async {
    final params = <String>[];
    if (subjectId != null) params.add('subject_id=$subjectId');
    if (year != null) params.add('year=$year');
    final query = params.isEmpty ? '' : '?${params.join('&')}';
    final data = await apiClient.get('/me/past-exams$query');
    final list = data['past_exams'] as List<dynamic>? ?? [];
    return list.map((e) => PastExam.fromJson(e as Map<String, dynamic>)).toList();
  }

  // /me/subjects/:id/past-exams يتحقق أن المادة تابعة لمستوى الطالب
  Future<List<PastExam>> getBySubject(int subjectId) async {
    final data = await apiClient.get('/me/subjects/$subjectId/past-exams');
    final list = data['past_exams'] as List<dynamic>? ?? [];
    return list.map((e) => PastExam.fromJson(e as Map<String, dynamic>)).toList();
  }
}

final pastExamService = PastExamService();
