class AppNotificationModel {
  const AppNotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  final int id;
  final String title;
  final String body;
  final String type;
  final bool isRead;
  final DateTime createdAt;

  factory AppNotificationModel.fromJson(Map<String, dynamic> json) => AppNotificationModel(
    id: json['id'] as int,
    title: json['title'] as String,
    body: json['body'] as String,
    type: json['type'] as String? ?? 'general',
    isRead: json['is_read'] as bool? ?? false,
    createdAt: DateTime.parse(json['created_at'] as String),
  );
}
