import 'dart:convert';

import 'package:artbooking/globals/utilities.dart';

class UserBookStats {
  const UserBookStats({
    this.created = 0,
    this.deleted = 0,
    this.liked = 0,
    this.owned = 0,
    required this.updatedAt,
  });

  /// Total books this user has created.
  final int created;

  /// Total books this user has deleted.
  final int deleted;

  /// Total books this user has fav.
  final int liked;

  /// Number of existing books this user own.
  final int owned;

  /// Last time this statistic was updated.
  final DateTime updatedAt;

  UserBookStats copyWith({
    int? created,
    int? deleted,
    int? liked,
    int? owned,
    DateTime? updatedAt,
  }) {
    return UserBookStats(
      created: created ?? this.created,
      deleted: deleted ?? this.deleted,
      liked: liked ?? this.liked,
      owned: owned ?? this.owned,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'created': created,
      'deleted': deleted,
      'liked': liked,
      'owned': owned,
    };
  }

  factory UserBookStats.empty() {
    return UserBookStats(
      created: 0,
      deleted: 0,
      liked: 0,
      owned: 0,
      updatedAt: DateTime.now(),
    );
  }

  factory UserBookStats.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return UserBookStats.empty();
    }

    return UserBookStats(
        created: map['created']?.toInt() ?? 0,
        deleted: map['deleted']?.toInt() ?? 0,
        liked: map['liked']?.toInt() ?? 0,
        owned: map['owned']?.toInt() ?? 0,
        updatedAt: Utilities.date.fromFirestore(map['updated_at']));
  }

  String toJson() => json.encode(toMap());

  factory UserBookStats.fromJson(String source) =>
      UserBookStats.fromMap(json.decode(source));

  @override
  String toString() {
    return 'UserBooksStats(created: $created, deleted: $deleted, '
        'liked: $liked, owned: $owned)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserBookStats &&
        other.created == created &&
        other.deleted == deleted &&
        other.liked == liked &&
        other.owned == owned;
  }

  @override
  int get hashCode {
    return created.hashCode ^
        deleted.hashCode ^
        liked.hashCode ^
        owned.hashCode;
  }
}
