import '../models/subject.dart';
import '../network/api_client.dart';

class SubjectService {
  Future<List<Subject>> getSubjects({int? learningPathId, int? bacBranchId}) async {
    final params = <String>[];
    if (learningPathId != null) params.add('learning_path_id=$learningPathId');
    if (bacBranchId != null) params.add('bac_branch_id=$bacBranchId');
    final query = params.isEmpty ? '' : '?${params.join('&')}';
    final response = await apiClient.get('/subjects$query');
    final raw = response['data'];
    final data = raw is List ? raw : <dynamic>[];
    return data.map((e) => Subject.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// يرجع المواد المناسبة للمستخدم الحالي حسب token (يحتاج JWT)
  Future<List<Subject>> getMySubjects() async {
    final response = await apiClient.get('/me/subjects');
    final raw = response['data'];
    final data = raw is List ? raw : <dynamic>[];
    return data.map((e) => Subject.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Subject> getSubjectById(int id) async {
    final response = await apiClient.get('/subjects/$id');
    return Subject.fromJson(response['data'] as Map<String, dynamic>);
  }
}

final subjectService = SubjectService();
