import 'dart:convert';

class UserGalleriesStats {
  UserGalleriesStats({
    this.created = 0,
    this.deleted = 0,
    this.entered = 0,
    this.opened = 0,
    this.owned = 0,
  });

  /// Total virtual galleries this user has created.
  int created;

  /// Total virtual galleries this user has deleted.
  int deleted;

  /// Total virtual galleries this user has entered.
  int entered;

  /// Total virtual galleries this user has entered.
  int opened;

  /// Number of existing virtual galleries this user own.
  int owned;

  UserGalleriesStats copyWith({
    int? created,
    int? deleted,
    int? entered,
    int? opened,
    int? owned,
  }) {
    return UserGalleriesStats(
      created: created ?? this.created,
      deleted: deleted ?? this.deleted,
      entered: entered ?? this.entered,
      opened: opened ?? this.opened,
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

  factory UserGalleriesStats.empty() {
    return UserGalleriesStats(
      created: 0,
      deleted: 0,
      entered: 0,
      opened: 0,
      owned: 0,
    );
  }

  factory UserGalleriesStats.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return UserGalleriesStats.empty();
    }

    return UserGalleriesStats(
      created: map['created']?.toInt() ?? 0,
      deleted: map['deleted']?.toInt() ?? 0,
      entered: map['entered']?.toInt() ?? 0,
      opened: map['opened']?.toInt() ?? 0,
      owned: map['owned']?.toInt() ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserGalleriesStats.fromJson(String source) =>
      UserGalleriesStats.fromMap(json.decode(source));

  @override
  String toString() {
    return 'UserGalleriesStats(created: $created, deleted: $deleted, entered: $entered, opened: $opened, owned: $owned)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserGalleriesStats &&
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
