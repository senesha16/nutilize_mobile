class AppNotification {
  final String id;
  final String title;
  final String message;
  final String type; // approved | rejected
  final int reservationId;
  final DateTime createdAt;
  final bool isRead;

  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.reservationId,
    required this.createdAt,
    required this.isRead,
  });

  AppNotification copyWith({
    String? id,
    String? title,
    String? message,
    String? type,
    int? reservationId,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      reservationId: reservationId ?? this.reservationId,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type,
      'reservation_id': reservationId,
      'created_at': createdAt.toIso8601String(),
      'is_read': isRead,
    };
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      type: json['type'] as String? ?? 'approved',
      reservationId: json['reservation_id'] as int? ?? 0,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      isRead: json['is_read'] as bool? ?? false,
    );
  }
}
