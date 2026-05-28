class Announcement {
  final int id;
  final String title;
  final String message;
  final String imageUrl;
  final String linkUrl;
  final String createdAt;

  const Announcement({
    required this.id,
    required this.title,
    this.message = '',
    this.imageUrl = '',
    this.linkUrl = '',
    this.createdAt = '',
  });

  factory Announcement.fromJson(Map<String, dynamic> json) => Announcement(
        id: (json['id'] as num?)?.toInt() ?? 0,
        title: json['title'] as String? ?? '',
        message: json['message'] as String? ?? '',
        imageUrl: json['image_url'] as String? ?? '',
        linkUrl: json['link_url'] as String? ?? '',
        createdAt: json['created_at']?.toString() ?? '',
      );
}
