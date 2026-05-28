import '../models/search_result.dart';
import '../network/api_client.dart';

class SearchService {
  Future<List<SearchResult>> search(String q) async {
    final data = await apiClient.get('/search?q=${Uri.encodeQueryComponent(q)}');
    final list = data['results'] as List<dynamic>? ?? [];
    return list.map((e) => SearchResult.fromJson(e as Map<String, dynamic>)).toList();
  }
}

final searchService = SearchService();
