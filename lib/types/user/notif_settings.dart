import 'dart:convert';

import 'package:artbooking/types/user/notif_settings_item.dart';

class UserNotificationsSettings {
  UserNotificationsSettings({
    required this.email,
    required this.push,
  });

  NotifSettingsItem email;
  NotifSettingsItem push;

  UserNotificationsSettings copyWith({
    NotifSettingsItem? email,
    NotifSettingsItem? push,
  }) {
    return UserNotificationsSettings(
      email: email ?? this.email,
      push: push ?? this.push,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email.toMap(),
      'push': push.toMap(),
    };
  }

  factory UserNotificationsSettings.empty() {
    return UserNotificationsSettings(
      email: NotifSettingsItem.empty(),
      push: NotifSettingsItem.empty(),
    );
  }

  factory UserNotificationsSettings.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return UserNotificationsSettings.empty();
    }

    return UserNotificationsSettings(
      email: NotifSettingsItem.fromMap(map['email']),
      push: NotifSettingsItem.fromMap(map['push']),
    );
  }

  String toJson() => json.encode(toMap());

  factory UserNotificationsSettings.fromJson(String source) =>
      UserNotificationsSettings.fromMap(json.decode(source));

  @override
  String toString() => 'UserNotificationsSettings(email: $email, push: $push)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserNotificationsSettings &&
        other.email == email &&
        other.push == push;
  }

  @override
  int get hashCode => email.hashCode ^ push.hashCode;
}
