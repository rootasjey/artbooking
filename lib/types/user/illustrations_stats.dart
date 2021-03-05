class UserIllustrationsStats {
  /// Total illustrations this user has uploaded.
  int created;

  /// Total illustrations this user has deleted.
  int deleted;

  /// Total illustrations this user has fav.
  int fav;

  /// Number of existing illustrations this user own.
  int owned;

  /// Total illustrations updates by providing a new version.
  int updated;

  UserIllustrationsStats({
    this.created = 0,
    this.deleted = 0,
    this.fav = 0,
    this.owned = 0,
    this.updated = 0,
  });

  factory UserIllustrationsStats.fromJSON(Map<String, dynamic> data) {
    return UserIllustrationsStats(
      created: data['created'],
      deleted: data['deleted'],
      fav: data['fav'],
      owned: data['owned'],
      updated: data['updated'],
    );
  }
}
