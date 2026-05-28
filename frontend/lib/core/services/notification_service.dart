import '../models/notification.dart';
import '../network/api_client.dart';

class NotificationService {
  Future<List<AppNotification>> getNotifications() async {
    final data = await apiClient.get('/notifications');
    final list = data['notifications'] as List<dynamic>? ?? [];
    return list.map((e) => AppNotification.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> markRead(int id) async {
    await apiClient.patch('/notifications/$id/read', {});
  }

  Future<int> getUnreadCount() async {
    try {
      final data = await apiClient.get('/notifications/unread-count');
      return data['count'] as int? ?? 0;
    } catch (_) {
      return 0;
    }
  }
}

final notificationService = NotificationService();
