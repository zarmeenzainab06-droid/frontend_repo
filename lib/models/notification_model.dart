class NotificationModel {
  final int id;
  final String role;
  final int? userId;
  final String type;
  final String title;
  final String message;
  final int? referenceId;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.role,
    this.userId,
    required this.type,
    required this.title,
    required this.message,
    this.referenceId,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] is String ? int.parse(json['id']) : json['id'],
      role: json['role']?.toString() ?? '',
      userId: json['user_id'] == null
          ? null
          : (json['user_id'] is String
                ? int.tryParse(json['user_id'])
                : json['user_id']),
      type: json['type']?.toString() ?? 'general',
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      referenceId: json['reference_id'] == null
          ? null
          : (json['reference_id'] is String
                ? int.tryParse(json['reference_id'])
                : json['reference_id']),
      isRead: json['is_read'] == 1 || json['is_read'] == true,
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}
