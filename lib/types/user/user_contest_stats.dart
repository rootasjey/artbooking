import 'dart:convert';

import 'package:artbooking/globals/utilities.dart';

class UserContestStats {
  const UserContestStats({
    this.created = 0,
    this.deleted = 0,
    this.entered = 0,
    this.owned = 0,
    this.participating = 0,
    this.won = 0,
    required this.updatedAt,
  });

  /// Total contests this user has created.
  final int created;

  /// Total contests this user has deleted.
  final int deleted;

  /// Total contests this user has entered.
  final int entered;

  /// Number of existing contests this user own.
  final int owned;

  /// Number of existing contests this user is doing.
  final int participating;

  /// Last time this statistic was updated.
  final DateTime updatedAt;

  /// Total contests this user has won.
  final int won;

  UserContestStats copyWith({
    int? created,
    int? deleted,
    int? entered,
    int? owned,
    int? participating,
    DateTime? updatedAt,
    int? won,
  }) {
    return UserContestStats(
      created: created ?? this.created,
      deleted: deleted ?? this.deleted,
      entered: entered ?? this.entered,
      owned: owned ?? this.owned,
      participating: participating ?? this.participating,
      updatedAt: updatedAt ?? this.updatedAt,
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

  factory UserContestStats.empty() {
    return UserContestStats(
      created: 0,
      deleted: 0,
      entered: 0,
      owned: 0,
      participating: 0,
      updatedAt: DateTime.now(),
      won: 0,
    );
  }

  factory UserContestStats.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return UserContestStats.empty();
    }

    return UserContestStats(
      created: map['created']?.toInt() ?? 0,
      deleted: map['deleted']?.toInt() ?? 0,
      entered: map['entered']?.toInt() ?? 0,
      owned: map['owned']?.toInt() ?? 0,
      participating: map['participating']?.toInt() ?? 0,
      updatedAt: Utilities.date.fromFirestore(map['updated_at']),
      won: map['won']?.toInt() ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserContestStats.fromJson(String source) =>
      UserContestStats.fromMap(json.decode(source));

  @override
  String toString() {
    return 'UserContestsStats(created: $created, deleted: $deleted, '
        'entered: $entered, owned: $owned, participating: $participating, '
        'won: $won)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserContestStats &&
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
