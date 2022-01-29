import 'dart:convert';

class NotifSettingsItem {
  NotifSettingsItem({
    this.all = false,
  });

  final bool all;

  NotifSettingsItem copyWith({
    bool? all,
  }) {
    return NotifSettingsItem(
      all: all ?? this.all,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'all': all,
    };
  }

  factory NotifSettingsItem.empty() {
    return NotifSettingsItem(all: true);
  }

  factory NotifSettingsItem.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return NotifSettingsItem.empty();
    }

    return NotifSettingsItem(
      all: map['all'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory NotifSettingsItem.fromJson(String source) =>
      NotifSettingsItem.fromMap(json.decode(source));

  @override
  String toString() => 'NotifSettingsItem(all: $all)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is NotifSettingsItem && other.all == all;
  }

  @override
  int get hashCode => all.hashCode;
}
