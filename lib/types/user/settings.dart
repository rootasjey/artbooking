import 'dart:convert';

import 'package:artbooking/types/user/notif_settings.dart';

class UserSettings {
  UserSettings({
    required this.notifications,
  });

  UserNotificationsSettings notifications;

  UserSettings copyWith({
    UserNotificationsSettings? notifications,
  }) {
    return UserSettings(
      notifications: notifications ?? this.notifications,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'notifications': notifications.toMap(),
    };
  }

  factory UserSettings.empty() {
    return UserSettings(
      notifications: UserNotificationsSettings.empty(),
    );
  }

  factory UserSettings.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return UserSettings.empty();
    }

    return UserSettings(
      notifications: UserNotificationsSettings.fromMap(map['notifications']),
    );
  }

  String toJson() => json.encode(toMap());

  factory UserSettings.fromJson(String source) =>
      UserSettings.fromMap(json.decode(source));

  @override
  String toString() => 'UserSettings(notifications: $notifications)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserSettings && other.notifications == notifications;
  }

  @override
  int get hashCode => notifications.hashCode;
}
