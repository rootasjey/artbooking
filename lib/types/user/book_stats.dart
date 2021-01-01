class UserBooksStats {
  /// Total books this user has created.
  int created;

  /// Total books this user has deleted.
  int deleted;

  /// Total books this user has fav.
  int fav;

  /// Number of existing books this user own.
  int own;

  UserBooksStats({
    this.created = 0,
    this.deleted = 0,
    this.fav = 0,
    this.own = 0,
  });

  factory UserBooksStats.fromJSON(Map<String, dynamic> data) {
    return UserBooksStats(
      created: data['created'],
      deleted: data['deleted'],
      fav: data['fav'],
      own: data['own'],
    );
  }
}
