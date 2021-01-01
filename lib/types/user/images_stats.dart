class UserImagesStats {
  /// Total illustrations this user has uploaded.
  int added;

  /// Total illustrations this user has deleted.
  int deleted;

  /// Total illustrations this user has fav.
  int fav;

  /// Number of existing illustrations this user own.
  int own;

  /// Total illustrations updates by providing a new version.
  int updated;

  UserImagesStats({
    this.added = 0,
    this.deleted = 0,
    this.fav = 0,
    this.own = 0,
    this.updated = 0,
  });

  factory UserImagesStats.fromJSON(Map<String, dynamic> data) {
    return UserImagesStats(
      added: data['added'],
      deleted: data['deleted'],
      fav: data['fav'],
      own: data['own'],
      updated: data['updated'],
    );
  }
}
