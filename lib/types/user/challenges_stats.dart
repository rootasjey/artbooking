import 'dart:convert';

class UserChallengesStats {
  UserChallengesStats({
    this.created = 0,
    this.deleted = 0,
    this.entered = 0,
    this.owned = 0,
    this.participating = 0,
    this.won = 0,
  });

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

  UserChallengesStats copyWith({
    int? created,
    int? deleted,
    int? entered,
    int? owned,
    int? participating,
    int? won,
  }) {
    return UserChallengesStats(
      created: created ?? this.created,
      deleted: deleted ?? this.deleted,
      entered: entered ?? this.entered,
      owned: owned ?? this.owned,
      participating: participating ?? this.participating,
      won: won ?? this.won,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'created': created,
      'deleted': deleted,
      'entered': entered,
      'owned': owned,
      'participating': participating,
      'won': won,
    };
  }

  factory UserChallengesStats.empty() {
    return UserChallengesStats(
      created: 0,
      deleted: 0,
      entered: 0,
      owned: 0,
      participating: 0,
      won: 0,
    );
  }

  factory UserChallengesStats.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return UserChallengesStats.empty();
    }

    return UserChallengesStats(
      created: map['created']?.toInt() ?? 0,
      deleted: map['deleted']?.toInt() ?? 0,
      entered: map['entered']?.toInt() ?? 0,
      owned: map['owned']?.toInt() ?? 0,
      participating: map['participating']?.toInt() ?? 0,
      won: map['won']?.toInt() ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserChallengesStats.fromJson(String source) =>
      UserChallengesStats.fromMap(json.decode(source));

  @override
  String toString() {
    return 'UserChallengesStats(created: $created, deleted: $deleted, entered: $entered, owned: $owned, participating: $participating, won: $won)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserChallengesStats &&
        other.created == created &&
        other.deleted == deleted &&
        other.entered == entered &&
        other.owned == owned &&
        other.participating == participating &&
        other.won == won;
  }

  @override
  int get hashCode {
    return created.hashCode ^
        deleted.hashCode ^
        entered.hashCode ^
        owned.hashCode ^
        participating.hashCode ^
        won.hashCode;
  }
}
