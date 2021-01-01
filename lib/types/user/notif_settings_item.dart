class NotifSettingsItem {
  bool all;

  NotifSettingsItem({this.all});

  factory NotifSettingsItem.fromJSON(Map<String, dynamic> data) {
    return NotifSettingsItem(
      all: data['all'],
    );
  }
}
