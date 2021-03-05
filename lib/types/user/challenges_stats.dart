class UserChallengesStats {
  /// Total challenges this user has created.
  int created;

  /// Total challenges this user has deleted.
  int deleted;

  /// Total challenges this user has entered.
  int entered;

  /// Number of existing challenges this user own.
  int owned;

  /// Number of existing challenges this user is doing.
  int participating;

  /// Total challenges this user has won.
  int won;

  UserChallengesStats({
    this.created = 0,
    this.deleted = 0,
    this.entered = 0,
    this.owned = 0,
    this.participating = 0,
    this.won = 0,
  });

  factory UserChallengesStats.fromJSON(Map<String, dynamic> data) {
    return UserChallengesStats(
      created: data['created'],
      deleted: data['deleted'],
      entered: data['entered'],
      owned: data['owned'],
      participating: data['participating'],
      won: data['won'],
    );
  }
}
