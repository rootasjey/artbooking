import 'dart:convert';

class UserNotificationStats {
  const UserNotificationStats({
    this.total = 0,
    this.unread = 0,
  });

  /// Number of all notifications.
  final int total;

  /// Number of unread notifications.
  final int unread;

  UserNotificationStats copyWith({
    int? total,
    int? unread,
  }) {
    return UserNotificationStats(
      total: total ?? this.total,
      unread: unread ?? this.unread,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'total': total,
      'unread': unread,
    };
  }

  factory UserNotificationStats.empty() {
    return UserNotificationStats(
      total: 0,
      unread: 0,
    );
  }

  factory UserNotificationStats.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return UserNotificationStats.empty();
    }

    return UserNotificationStats(
      total: map['total']?.toInt() ?? 0,
      unread: map['unread']?.toInt() ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserNotificationStats.fromJson(String source) =>
      UserNotificationStats.fromMap(json.decode(source));

  @override
  String toString() => 'UserNotificationsStats(total: $total, unread: $unread)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserNotificationStats &&
        other.total == total &&
        other.unread == unread;
  }

  @override
  int get hashCode => total.hashCode ^ unread.hashCode;
}
