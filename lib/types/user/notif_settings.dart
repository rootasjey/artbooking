import 'package:artbooking/types/user/notif_settings_item.dart';

class UserNotificationsSettings {
  NotifSettingsItem email;
  NotifSettingsItem push;

  UserNotificationsSettings({this.email, this.push});

  factory UserNotificationsSettings.fromJSON(Map<String, dynamic> data) {
    return UserNotificationsSettings(
      email: NotifSettingsItem.fromJSON(data['email']),
      push: NotifSettingsItem.fromJSON(data['push']),
    );
  }
}
