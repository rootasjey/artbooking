class UserNotificationsStats {
  /// Number of all notifications.
  int total;

  /// Number of unread notifications.
  int unread;

  UserNotificationsStats({
    this.total = 0,
    this.unread = 0,
  });

  factory UserNotificationsStats.empty() {
    return UserNotificationsStats(
      total: 0,
      unread: 0,
    );
  }

  factory UserNotificationsStats.fromJSON(Map<String, dynamic> data) {
    return UserNotificationsStats(
      total: data['total'],
      unread: data['unread'],
    );
  }
}
