import '../models/download.dart';
import '../network/api_client.dart';

class DownloadService {
  Future<List<Download>> getDownloads() async {
    final data = await apiClient.get('/downloads');
    final list = data['downloads'] as List<dynamic>? ?? [];
    return list.map((e) => Download.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Returns true if saved, false if already existed.
  Future<bool> addDownload({required String itemType, required int itemId}) async {
    final data = await apiClient.post('/downloads', {
      'item_type': itemType,
      'item_id': itemId,
    });
    return data['already_exists'] != true;
  }

  Future<void> deleteDownload(int id) async {
    await apiClient.delete('/downloads/$id');
  }
}

final downloadService = DownloadService();
