import 'dart:convert';

class UserContestsStats {
  UserContestsStats({
    this.created = 0,
    this.deleted = 0,
    this.entered = 0,
    this.owned = 0,
    this.participating = 0,
    this.won = 0,
  });

  /// Total contests this user has created.
  int created;

  /// Total contests this user has deleted.
  int deleted;

  /// Total contests this user has entered.
  int entered;

  /// Number of existing contests this user own.
  int owned;

  /// Number of existing contests this user is doing.
  int participating;

  /// Total contests this user has won.
  int won;

  UserContestsStats copyWith({
    int? created,
    int? deleted,
    int? entered,
    int? owned,
    int? participating,
    int? won,
  }) {
    return UserContestsStats(
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

  factory UserContestsStats.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return UserContestsStats.empty();
    }

    return UserContestsStats(
      created: map['created']?.toInt() ?? 0,
      deleted: map['deleted']?.toInt() ?? 0,
      entered: map['entered']?.toInt() ?? 0,
      owned: map['owned']?.toInt() ?? 0,
      participating: map['participating']?.toInt() ?? 0,
      won: map['won']?.toInt() ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserContestsStats.fromJson(String source) =>
      UserContestsStats.fromMap(json.decode(source));

  @override
  String toString() {
    return 'UserContestsStats(created: $created, deleted: $deleted, entered: $entered, owned: $owned, participating: $participating, won: $won)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserContestsStats &&
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
