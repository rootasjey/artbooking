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
  int owned;

  UserGalleriesStats({
    this.created = 0,
    this.deleted = 0,
    this.entered = 0,
    this.opened = 0,
    this.owned = 0,
  });

  factory UserGalleriesStats.empty() {
    return UserGalleriesStats(
      created: 0,
      deleted: 0,
      entered: 0,
      opened: 0,
      owned: 0,
    );
  }

  factory UserGalleriesStats.fromJSON(Map<String, dynamic>? data) {
    if (data == null) {
      return UserGalleriesStats.empty();
    }

    return UserGalleriesStats(
      created: data['created'] ?? 0,
      deleted: data['deleted'] ?? 0,
      entered: data['entered'] ?? 0,
      opened: data['opened'] ?? 0,
      owned: data['owned'] ?? 0,
    );
  }
}
