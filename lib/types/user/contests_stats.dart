class UserContestsStats {
  /// Total contests this user has created.
  int? created;

  /// Total contests this user has deleted.
  int? deleted;

  /// Total contests this user has entered.
  int? entered;

  /// Number of existing contests this user own.
  int? owned;

  /// Number of existing contests this user is doing.
  int? participating;

  /// Total contests this user has won.
  int? won;

  UserContestsStats({
    this.created = 0,
    this.deleted = 0,
    this.entered = 0,
    this.owned = 0,
    this.participating = 0,
    this.won = 0,
  });

  factory UserContestsStats.empty() {
    return UserContestsStats(
      created: 0,
      deleted: 0,
      entered: 0,
      owned: 0,
      participating: 0,
      won: 0,
    );
  }

  factory UserContestsStats.fromJSON(Map<String, dynamic>? data) {
    if (data == null) {
      return UserContestsStats.empty();
    }

    return UserContestsStats(
      created: data['created'],
      deleted: data['deleted'],
      entered: data['entered'],
      owned: data['owned'],
      participating: data['participating'],
      won: data['won'],
    );
  }
}
