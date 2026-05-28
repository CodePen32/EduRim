import '../models/past_exam.dart';
import '../network/api_client.dart';

class PastExamService {
  Future<List<PastExam>> getPastExams({
    int? subjectId,
    int? learningPathId,
    int? bacBranchId,
    int? year,
  }) async {
    String path = '/past-exams?';
    if (subjectId != null) path += 'subject_id=$subjectId&';
    if (learningPathId != null) path += 'learning_path_id=$learningPathId&';
    if (bacBranchId != null) path += 'bac_branch_id=$bacBranchId&';
    if (year != null) path += 'year=$year&';
    final data = await apiClient.get(path);
    final list = data['past_exams'] as List<dynamic>? ?? [];
    return list.map((e) => PastExam.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<PastExam>> getBySubject(int subjectId) async {
    final data = await apiClient.get('/subjects/$subjectId/past-exams');
    final list = data['past_exams'] as List<dynamic>? ?? [];
    return list.map((e) => PastExam.fromJson(e as Map<String, dynamic>)).toList();
  }
}

final pastExamService = PastExamService();
