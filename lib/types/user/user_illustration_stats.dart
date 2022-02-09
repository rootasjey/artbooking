import 'dart:convert';

import 'package:artbooking/globals/utilities.dart';

class UserIllustrationStats {
  const UserIllustrationStats({
    this.created = 0,
    this.deleted = 0,
    this.liked = 0,
    this.owned = 0,
    this.updated = 0,
    required this.updatedAt,
  });

  /// Total illustrations this user has uploaded.
  final int created;

  /// Total illustrations this user has deleted.
  final int deleted;

  /// Total illustrations this user has fav.
  final int liked;

  /// Number of existing illustrations this user own.
  final int owned;

  /// Total illustrations updates by providing a new version.
  final int updated;

  /// Last time this statistic was updated.
  final DateTime updatedAt;

  UserIllustrationStats copyWith({
    int? created,
    int? deleted,
    int? fav,
    int? owned,
    int? updated,
    DateTime? updatedAt,
  }) {
    return UserIllustrationStats(
      created: created ?? this.created,
      deleted: deleted ?? this.deleted,
      liked: fav ?? this.liked,
      owned: owned ?? this.owned,
      updated: updated ?? this.updated,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'created': created,
      'deleted': deleted,
      'liked': liked,
      'owned': owned,
      'updated': updated,
    };
  }

  factory UserIllustrationStats.empty() {
    return UserIllustrationStats(
      created: 0,
      deleted: 0,
      liked: 0,
      owned: 0,
      updated: 0,
      updatedAt: DateTime.now(),
    );
  }

  factory UserIllustrationStats.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return UserIllustrationStats.empty();
    }

    return UserIllustrationStats(
        created: map['created']?.toInt() ?? 0,
        deleted: map['deleted']?.toInt() ?? 0,
        liked: map['liked']?.toInt() ?? 0,
        owned: map['owned']?.toInt() ?? 0,
        updated: map['updated']?.toInt() ?? 0,
        updatedAt: Utilities.date.fromFirestore(map['updated_at']));
  }

  String toJson() => json.encode(toMap());

  factory UserIllustrationStats.fromJson(String source) =>
      UserIllustrationStats.fromMap(json.decode(source));

  @override
  String toString() {
    return 'UserIllustrationsStats(created: $created, deleted: $deleted, '
        'liked: $liked, owned: $owned, updated: $updated)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserIllustrationStats &&
        other.created == created &&
        other.deleted == deleted &&
        other.liked == liked &&
        other.owned == owned &&
        other.updated == updated;
  }

  @override
  int get hashCode {
    return created.hashCode ^
        deleted.hashCode ^
        liked.hashCode ^
        owned.hashCode ^
        updated.hashCode;
  }
}
