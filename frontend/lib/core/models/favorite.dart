class Favorite {
  final int id;
  final String itemType;
  final int itemId;
  final String title;
  final String subtitle;
  final String createdAt;

  const Favorite({
    required this.id,
    required this.itemType,
    required this.itemId,
    required this.title,
    required this.subtitle,
    required this.createdAt,
  });

  factory Favorite.fromJson(Map<String, dynamic> json) => Favorite(
        id: json['id'] as int? ?? 0,
        itemType: json['item_type'] as String? ?? '',
        itemId: json['item_id'] as int? ?? 0,
        title: json['title'] as String? ?? '',
        subtitle: json['subtitle'] as String? ?? '',
        createdAt: json['created_at'] as String? ?? '',
      );
}
