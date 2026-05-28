class SearchResult {
  final String type;
  final int id;
  final String title;
  final String extra;

  const SearchResult({
    required this.type,
    required this.id,
    required this.title,
    required this.extra,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) => SearchResult(
        type: json['type'] as String? ?? '',
        id: json['id'] as int? ?? 0,
        title: json['title'] as String? ?? '',
        extra: json['extra'] as String? ?? '',
      );
}
