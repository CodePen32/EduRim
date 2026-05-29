import '../models/teacher.dart';
import '../network/api_client.dart';

class TeacherService {
  // /me/teachers يفلتر تلقائياً حسب مستوى الطالب من JWT
  Future<List<Teacher>> getTeachers({int? subjectId}) async {
    final query = subjectId != null ? '?subject_id=$subjectId' : '';
    final response = await apiClient.get('/me/teachers$query');
    final raw = response['data'];
    final data = raw is List ? raw : <dynamic>[];
    return data.map((e) => Teacher.fromJson(e as Map<String, dynamic>)).toList();
  }

  // /me/teachers/:id يتحقق أن الأستاذ تابع لمستوى الطالب
  Future<Teacher> getTeacherById(int id) async {
    final response = await apiClient.get('/me/teachers/$id');
    return Teacher.fromJson(response['data'] as Map<String, dynamic>);
  }
}

final teacherService = TeacherService();
