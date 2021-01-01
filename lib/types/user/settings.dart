import 'package:artbooking/types/user/notif_settings.dart';

class UserSettings {
  UserNotificationsSettings notifications;

  UserSettings({this.notifications});

  factory UserSettings.fromJSON(Map<String, dynamic> data) {
    return UserSettings(
      notifications: UserNotificationsSettings.fromJSON(data['notifications']),
    );
  }
}
