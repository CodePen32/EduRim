class Download {
  final int id;
  final String itemType;
  final int itemId;
  final String title;
  final String videoUrl;
  final String summaryUrl;
  final String coverImageUrl;
  final String createdAt;

  const Download({
    required this.id,
    required this.itemType,
    required this.itemId,
    required this.title,
    this.videoUrl = '',
    this.summaryUrl = '',
    this.coverImageUrl = '',
    required this.createdAt,
  });

  factory Download.fromJson(Map<String, dynamic> json) => Download(
        id: json['id'] as int? ?? 0,
        itemType: json['item_type'] as String? ?? '',
        itemId: json['item_id'] as int? ?? 0,
        title: json['title'] as String? ?? '',
        videoUrl: json['video_url'] as String? ?? '',
        summaryUrl: json['summary_url'] as String? ?? '',
        coverImageUrl: json['cover_image_url'] as String? ?? '',
        createdAt: json['created_at'] as String? ?? '',
      );
}
