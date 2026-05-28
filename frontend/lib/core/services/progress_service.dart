import '../models/progress.dart';
import '../models/progress_stats.dart';
import '../network/api_client.dart';

class ProgressService {
  Future<List<Progress>> getProgress() async {
    final data = await apiClient.get('/progress');
    final list = data['progress'] as List<dynamic>? ?? [];
    return list.map((e) => Progress.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Progress?> getLastProgress() async {
    final data = await apiClient.get('/progress/last');
    final p = data['progress'];
    if (p == null) return null;
    return Progress.fromJson(p as Map<String, dynamic>);
  }

  Future<void> saveProgress({
    required int lessonId,
    int watchedPercentage = 0,
    bool completed = false,
  }) async {
    await apiClient.post('/progress', {
      'lesson_id': lessonId,
      'watched_percentage': watchedPercentage,
      'completed': completed,
    });
  }

  Future<ProgressStats> getStats() async {
    final data = await apiClient.get('/progress/stats');
    return ProgressStats.fromJson(data);
  }

  Future<List<SubjectProgress>> getBySubject() async {
    final data = await apiClient.get('/progress/by-subject');
    final list = data['subjects'] as List<dynamic>? ?? [];
    return list.map((e) => SubjectProgress.fromJson(e as Map<String, dynamic>)).toList();
  }
}

final progressService = ProgressService();
