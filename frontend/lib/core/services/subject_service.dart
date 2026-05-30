import '../models/subject.dart';
import '../network/api_client.dart';

class SubjectService {
  // ─── In-memory cache (cleared on logout via invalidate()) ───────────────
  List<Subject>? _mySubjectsCache;
  DateTime? _mySubjectsCachedAt;
  static const _cacheTtl = Duration(minutes: 5);

  bool get _isCacheValid =>
      _mySubjectsCache != null &&
      _mySubjectsCachedAt != null &&
      DateTime.now().difference(_mySubjectsCachedAt!) < _cacheTtl;

  void invalidate() {
    _mySubjectsCache = null;
    _mySubjectsCachedAt = null;
  }

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

  /// يرجع المواد المناسبة للمستخدم الحالي — مع cache 5 دقائق
  Future<List<Subject>> getMySubjects({bool forceRefresh = false}) async {
    if (!forceRefresh && _isCacheValid) return _mySubjectsCache!;
    final response = await apiClient.get('/me/subjects');
    final raw = response['data'];
    final data = raw is List ? raw : <dynamic>[];
    final result = data.map((e) => Subject.fromJson(e as Map<String, dynamic>)).toList();
    _mySubjectsCache = result;
    _mySubjectsCachedAt = DateTime.now();
    return result;
  }

  Future<Subject> getSubjectById(int id) async {
    final response = await apiClient.get('/subjects/$id');
    return Subject.fromJson(response['data'] as Map<String, dynamic>);
  }
}

final subjectService = SubjectService();
