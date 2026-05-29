import '../models/exercise.dart';
import '../network/api_client.dart';

class ExerciseService {
  Future<List<Exercise>> getExercises({int? subjectId, int? lessonId, int? year, String? difficulty}) async {
    final params = <String>[];
    if (subjectId != null) params.add('subject_id=$subjectId');
    if (lessonId != null) params.add('lesson_id=$lessonId');
    if (year != null) params.add('year=$year');
    if (difficulty != null && difficulty.isNotEmpty) params.add('difficulty=${Uri.encodeComponent(difficulty)}');
    final query = params.isEmpty ? '' : '?${params.join('&')}';
    final response = await apiClient.get('/me/exercises$query');
    final raw = response['data'];
    final data = raw is List ? raw : <dynamic>[];
    return data.map((e) => Exercise.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Exercise> getExerciseById(int id) async {
    final response = await apiClient.get('/me/exercises/$id');
    return Exercise.fromJson(response['data'] as Map<String, dynamic>);
  }
}

final exerciseService = ExerciseService();
