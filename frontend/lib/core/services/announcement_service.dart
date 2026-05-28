import '../models/announcement.dart';
import '../network/api_client.dart';

class AnnouncementService {
  Future<List<Announcement>> getMyAnnouncements() async {
    try {
      final response = await apiClient.get('/me/announcements');
      final raw = response['data'];
      final list = raw is List ? raw : <dynamic>[];
      return list
          .map((e) => Announcement.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }
}

final announcementService = AnnouncementService();
