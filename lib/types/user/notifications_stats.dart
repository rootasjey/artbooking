import 'dart:convert';

class UserNotificationsStats {
  const UserNotificationsStats({
    this.total = 0,
    this.unread = 0,
  });

  /// Number of all notifications.
  final int total;

  /// Number of unread notifications.
  final int unread;

  UserNotificationsStats copyWith({
    int? total,
    int? unread,
  }) {
    return UserNotificationsStats(
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

  factory UserNotificationsStats.empty() {
    return UserNotificationsStats(
      total: 0,
      unread: 0,
    );
  }

  factory UserNotificationsStats.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return UserNotificationsStats.empty();
    }

    return UserNotificationsStats(
      total: map['total']?.toInt() ?? 0,
      unread: map['unread']?.toInt() ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserNotificationsStats.fromJson(String source) =>
      UserNotificationsStats.fromMap(json.decode(source));

  @override
  String toString() => 'UserNotificationsStats(total: $total, unread: $unread)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserNotificationsStats &&
        other.total == total &&
        other.unread == unread;
  }

  @override
  int get hashCode => total.hashCode ^ unread.hashCode;
}
