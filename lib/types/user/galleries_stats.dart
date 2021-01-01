class UserGalleriesStats {
  /// Total virtual galleries this user has created.
  int created;

  /// Total virtual galleries this user has deleted.
  int deleted;

  /// Total virtual galleries this user has entered.
  int entered;

  /// Total virtual galleries this user has entered.
  int opened;

  /// Number of existing virtual galleries this user own.
  int own;

  UserGalleriesStats({
    this.created = 0,
    this.deleted = 0,
    this.entered = 0,
    this.opened = 0,
    this.own = 0,
  });

  factory UserGalleriesStats.fromJSON(Map<String, dynamic> data) {
    return UserGalleriesStats(
      created: data['created'],
      deleted: data['deleted'],
      entered: data['entered'],
      opened: data['opened'],
      own: data['own'],
    );
  }
}
