import 'dart:convert';

class UserIllustrationsStats {
  UserIllustrationsStats({
    this.created = 0,
    this.deleted = 0,
    this.fav = 0,
    this.owned = 0,
    this.updated = 0,
  });

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

  UserIllustrationsStats copyWith({
    int? created,
    int? deleted,
    int? fav,
    int? owned,
    int? updated,
  }) {
    return UserIllustrationsStats(
      created: created ?? this.created,
      deleted: deleted ?? this.deleted,
      fav: fav ?? this.fav,
      owned: owned ?? this.owned,
      updated: updated ?? this.updated,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'created': created,
      'deleted': deleted,
      'fav': fav,
      'owned': owned,
      'updated': updated,
    };
  }

  factory UserIllustrationsStats.empty() {
    return UserIllustrationsStats(
      created: 0,
      deleted: 0,
      fav: 0,
      owned: 0,
      updated: 0,
    );
  }

  factory UserIllustrationsStats.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return UserIllustrationsStats.empty();
    }

    return UserIllustrationsStats(
      created: map['created']?.toInt() ?? 0,
      deleted: map['deleted']?.toInt() ?? 0,
      fav: map['fav']?.toInt() ?? 0,
      owned: map['owned']?.toInt() ?? 0,
      updated: map['updated']?.toInt() ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserIllustrationsStats.fromJson(String source) =>
      UserIllustrationsStats.fromMap(json.decode(source));

  @override
  String toString() {
    return 'UserIllustrationsStats(created: $created, deleted: $deleted, fav: $fav, owned: $owned, updated: $updated)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserIllustrationsStats &&
        other.created == created &&
        other.deleted == deleted &&
        other.fav == fav &&
        other.owned == owned &&
        other.updated == updated;
  }

  @override
  int get hashCode {
    return created.hashCode ^
        deleted.hashCode ^
        fav.hashCode ^
        owned.hashCode ^
        updated.hashCode;
  }
}
