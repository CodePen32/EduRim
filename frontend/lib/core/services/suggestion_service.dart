import '../network/api_client.dart';

class SuggestionService {
  /// Sends a development suggestion to the backend.
  /// Throws [ApiException] on failure (message is Arabic from the server).
  Future<void> submit({required String title, required String description}) async {
    await apiClient.post('/me/suggestions', {
      'title': title,
      'description': description,
    });
  }
}

final suggestionService = SuggestionService();
