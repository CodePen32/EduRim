import '../models/favorite.dart';
import '../network/api_client.dart';

class FavoriteService {
  Future<List<Favorite>> getFavorites() async {
    final data = await apiClient.get('/favorites');
    final list = data['favorites'] as List<dynamic>? ?? [];
    return list.map((e) => Favorite.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Returns true if added, false if already existed.
  Future<bool> addFavorite({required String itemType, required int itemId}) async {
    final data = await apiClient.post('/favorites', {
      'item_type': itemType,
      'item_id': itemId,
    });
    return data['already_exists'] != true;
  }

  Future<void> deleteFavorite(int id) async {
    await apiClient.delete('/favorites/$id');
  }
}

final favoriteService = FavoriteService();
