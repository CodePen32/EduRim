import '../models/lesson.dart';
import '../network/api_client.dart';

class LessonService {
  Future<List<Lesson>> getLessons({int? subjectId, int? teacherId, int? unitId}) async {
    final params = <String>[];
    if (subjectId != null) params.add('subject_id=$subjectId');
    if (teacherId != null) params.add('teacher_id=$teacherId');
    if (unitId != null) params.add('unit_id=$unitId');
    final query = params.isEmpty ? '' : '?${params.join('&')}';
    // /me/lessons يفلتر تلقائياً حسب مستوى الطالب من JWT
    final response = await apiClient.get('/me/lessons$query');
    final raw = response['data'];
    final data = raw is List ? raw : <dynamic>[];
    return data.map((e) => Lesson.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Lesson> getLessonById(int id) async {
    // /me/lessons/:id يتحقق أن الدرس تابع لمستوى الطالب
    final response = await apiClient.get('/me/lessons/$id');
    return Lesson.fromJson(response['data'] as Map<String, dynamic>);
  }
}

final lessonService = LessonService();
