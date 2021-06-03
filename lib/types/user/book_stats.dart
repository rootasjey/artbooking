class UserBooksStats {
  /// Total books this user has created.
  int created;

  /// Total books this user has deleted.
  int deleted;

  /// Total books this user has fav.
  int fav;

  /// Number of existing books this user own.
  int owned;

  UserBooksStats({
    this.created = 0,
    this.deleted = 0,
    this.fav = 0,
    this.owned = 0,
  });

  factory UserBooksStats.empty() {
    return UserBooksStats(
      created: 0,
      deleted: 0,
      fav: 0,
      owned: 0,
    );
  }

  factory UserBooksStats.fromJSON(Map<String, dynamic> data) {
    return UserBooksStats(
      created: data['created'],
      deleted: data['deleted'],
      fav: data['fav'],
      owned: data['owned'],
    );
  }
}
