import 'dart:convert';

/// Define which actions are available for the target user.
class UserRights {
  const UserRights({
    this.canManageArtMovements = false,
    this.canManageData = false,
    this.canManageLicenses = false,
    this.canManageSections = false,
    this.canManageUsers = false,
    this.canManageReviews = false,
  });

  /// If true, the current user can manage app data.
  final bool canManageData;

  /// True if the current user can manage (add, remove, edit) staff licenses.
  final bool canManageLicenses;

  /// True if the current user can manage (add, remove, edit) art movements.
  final bool canManageArtMovements;

  /// True if the current user can approve & unapprove books & illustrations.
  final bool canManageReviews;

  /// True if the current user can manage (add, remove, edit) sections.
  final bool canManageSections;

  /// True if the current user can manage (add, remove, edit) users.
  final bool canManageUsers;

  UserRights copyWith({
    bool? isAdmin,
    bool? canManageLicense,
    bool? canManageReviews,
  }) {
    return UserRights(
      canManageData: isAdmin ?? this.canManageData,
      canManageLicenses: canManageLicense ?? this.canManageLicenses,
      canManageReviews: canManageReviews ?? this.canManageReviews,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user:manage_art_movements': canManageArtMovements,
      'user:manage_data': canManageArtMovements,
      'user:manage_licenses': canManageLicenses,
      'user:manage_sections': canManageUsers,
      'user:manage_users': canManageUsers,
      'user:manage_reviews': canManageReviews,
    };
  }

  factory UserRights.empty() {
    return UserRights();
  }

  factory UserRights.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return UserRights.empty();
    }

    return UserRights(
      canManageArtMovements: map["user:manage_art_movements"] ?? false,
      canManageData: map["user:manage_data"] ?? false,
      canManageLicenses: map["user:manage_licenses"] ?? false,
      canManageSections: map["user:manage_sections"] ?? false,
      canManageUsers: map["user:manage_users"] ?? false,
      canManageReviews: map["user:manage_reviews"] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserRights.fromJson(String source) =>
      UserRights.fromMap(json.decode(source));

  @override
  String toString() =>
      "UserRights(canManageArtMovements: $canManageArtMovements, "
      "canManageData: $canManageData, canManageLicenses: $canManageLicenses, "
      "canManageReviews: $canManageReviews "
      "canManageSections: $canManageSections, canManageUsers: $canManageUsers)";

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserRights &&
        other.canManageArtMovements == canManageArtMovements &&
        other.canManageData == canManageData &&
        other.canManageSections == canManageSections &&
        other.canManageSections == canManageSections &&
        other.canManageReviews == canManageReviews &&
        other.canManageUsers == canManageUsers;
  }

  @override
  int get hashCode =>
      canManageArtMovements.hashCode ^
      canManageData.hashCode ^
      canManageLicenses.hashCode ^
      canManageSections.hashCode ^
      canManageReviews.hashCode ^
      canManageUsers.hashCode;
}
