import '../models/learning_path.dart';
import '../network/api_client.dart';

class LearningPathService {
  Future<List<LearningPath>> getLearningPaths() async {
    final response = await apiClient.get('/learning-paths');
    final data = response['data'] as List<dynamic>;
    return data.map((e) => LearningPath.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<BacBranch>> getBacBranches() async {
    final response = await apiClient.get('/bac-branches');
    final data = response['data'] as List<dynamic>;
    return data.map((e) => BacBranch.fromJson(e as Map<String, dynamic>)).toList();
  }
}

final learningPathService = LearningPathService();
