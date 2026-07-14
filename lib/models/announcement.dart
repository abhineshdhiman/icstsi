class Announcement {
  final String id;
  final String terminal;
  final String title;
  final String body;
  final String? imageUrl;
  final String? categoryIcon;
  final DateTime publishedAt;

  const Announcement({
    required this.id,
    required this.terminal,
    required this.title,
    required this.body,
    this.imageUrl,
    this.categoryIcon,
    required this.publishedAt,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['id'] as String,
      terminal: json['terminal'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      imageUrl: json['image_url'] as String?,
      categoryIcon: json['category_icon'] as String?,
      publishedAt: DateTime.parse(json['published_at'] as String),
    );
  }

  String get excerpt {
    const maxLength = 100;
    return body.length > maxLength ? '${body.substring(0, maxLength)}…' : body;
  }
}
