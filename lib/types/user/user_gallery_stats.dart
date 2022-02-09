import 'dart:convert';

import 'package:artbooking/globals/utilities.dart';

class UserGalleryStats {
  const UserGalleryStats({
    this.created = 0,
    this.deleted = 0,
    this.entered = 0,
    this.opened = 0,
    this.owned = 0,
    required this.updatedAt,
  });

  /// Total virtual galleries this user has created.
  final int created;

  /// Total virtual galleries this user has deleted.
  final int deleted;

  /// Total virtual galleries this user has entered.
  final int entered;

  /// Total virtual galleries this user has entered.
  final int opened;

  /// Number of existing virtual galleries this user own.
  final int owned;

  /// Last time this statistic was updated.
  final DateTime updatedAt;

  UserGalleryStats copyWith({
    int? created,
    int? deleted,
    int? entered,
    int? opened,
    int? owned,
    DateTime? updatedAt,
  }) {
    return UserGalleryStats(
      created: created ?? this.created,
      deleted: deleted ?? this.deleted,
      entered: entered ?? this.entered,
      opened: opened ?? this.opened,
      updatedAt: updatedAt ?? this.updatedAt,
      owned: owned ?? this.owned,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'created': created,
      'deleted': deleted,
      'entered': entered,
      'opened': opened,
      'owned': owned,
    };
  }

  factory UserGalleryStats.empty() {
    return UserGalleryStats(
      created: 0,
      deleted: 0,
      entered: 0,
      opened: 0,
      owned: 0,
      updatedAt: DateTime.now(),
    );
  }

  factory UserGalleryStats.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return UserGalleryStats.empty();
    }

    return UserGalleryStats(
      created: map['created']?.toInt() ?? 0,
      deleted: map['deleted']?.toInt() ?? 0,
      entered: map['entered']?.toInt() ?? 0,
      opened: map['opened']?.toInt() ?? 0,
      owned: map['owned']?.toInt() ?? 0,
      updatedAt: Utilities.date.fromFirestore(map['updated_at']),
    );
  }

  String toJson() => json.encode(toMap());

  factory UserGalleryStats.fromJson(String source) =>
      UserGalleryStats.fromMap(json.decode(source));

  @override
  String toString() {
    return 'UserGalleriesStats(created: $created, deleted: $deleted, '
        'entered: $entered, opened: $opened, owned: $owned)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserGalleryStats &&
        other.created == created &&
        other.deleted == deleted &&
        other.entered == entered &&
        other.opened == opened &&
        other.owned == owned;
  }

  @override
  int get hashCode {
    return created.hashCode ^
        deleted.hashCode ^
        entered.hashCode ^
        opened.hashCode ^
        owned.hashCode;
  }
}
