import 'dart:convert';

class UserBooksStats {
  UserBooksStats({
    required this.created,
    required this.deleted,
    required this.fav,
    required this.owned,
  });

  /// Total books this user has created.
  int created;

  /// Total books this user has deleted.
  int deleted;

  /// Total books this user has fav.
  int fav;

  /// Number of existing books this user own.
  int owned;

  UserBooksStats copyWith({
    int? created,
    int? deleted,
    int? fav,
    int? owned,
  }) {
    return UserBooksStats(
      created: created ?? this.created,
      deleted: deleted ?? this.deleted,
      fav: fav ?? this.fav,
      owned: owned ?? this.owned,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'created': created,
      'deleted': deleted,
      'fav': fav,
      'owned': owned,
    };
  }

  factory UserBooksStats.empty() {
    return UserBooksStats(
      created: 0,
      deleted: 0,
      fav: 0,
      owned: 0,
    );
  }

  factory UserBooksStats.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return UserBooksStats.empty();
    }

    return UserBooksStats(
      created: map['created']?.toInt() ?? 0,
      deleted: map['deleted']?.toInt() ?? 0,
      fav: map['fav']?.toInt() ?? 0,
      owned: map['owned']?.toInt() ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserBooksStats.fromJson(String source) =>
      UserBooksStats.fromMap(json.decode(source));

  @override
  String toString() {
    return 'UserBooksStats(created: $created, deleted: $deleted, fav: $fav, owned: $owned)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserBooksStats &&
        other.created == created &&
        other.deleted == deleted &&
        other.fav == fav &&
        other.owned == owned;
  }

  @override
  int get hashCode {
    return created.hashCode ^ deleted.hashCode ^ fav.hashCode ^ owned.hashCode;
  }
}
