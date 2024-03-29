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
    this.canManagePages = false,
    this.canManagePosts = false,
  });

  /// If true, the current user can manage app data.
  final bool canManageData;

  /// True if the current user can manage (add, remove, edit) staff licenses.
  final bool canManageLicenses;

  /// True if the current user can manage (add, remove, edit) art movements.
  final bool canManageArtMovements;

  /// True if the current user can edit application's pages.
  final bool canManagePages;

  /// True if the current user can edit application's blog posts.
  final bool canManagePosts;

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
    bool? canManagePages,
    bool? canManagePosts,
  }) {
    return UserRights(
      canManageData: isAdmin ?? this.canManageData,
      canManageLicenses: canManageLicense ?? this.canManageLicenses,
      canManageReviews: canManageReviews ?? this.canManageReviews,
      canManagePages: canManagePages ?? this.canManagePages,
      canManagePosts: canManagePosts ?? this.canManagePosts,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user:manage_art_movements': canManageArtMovements,
      'user:manage_data': canManageData,
      'user:manage_licenses': canManageLicenses,
      'user:manage_pages': canManagePages,
      'user:manage_posts': canManagePosts,
      'user:manage_reviews': canManageReviews,
      'user:manage_sections': canManageUsers,
      'user:manage_users': canManageUsers,
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
      canManagePages: map["user:manage_pages"] ?? false,
      canManagePosts: map["user:manage_posts"] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserRights.fromJson(String source) =>
      UserRights.fromMap(json.decode(source));

  @override
  String toString() =>
      "UserRights(canManageArtMovements: $canManageArtMovements, "
      "canManageData: $canManageData, canManageLicenses: $canManageLicenses, "
      "canManageReviews: $canManageReviews, canManagePages: $canManagePages, "
      "canManageSections: $canManageSections, canManageUsers: $canManageUsers, "
      "canManagePosts: $canManagePosts)";

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserRights &&
        other.canManageArtMovements == canManageArtMovements &&
        other.canManageData == canManageData &&
        other.canManagePages == canManagePages &&
        other.canManageSections == canManageSections &&
        other.canManageSections == canManageSections &&
        other.canManageReviews == canManageReviews &&
        other.canManagePosts == canManagePosts &&
        other.canManageUsers == canManageUsers;
  }

  @override
  int get hashCode =>
      canManageArtMovements.hashCode ^
      canManageData.hashCode ^
      canManageLicenses.hashCode ^
      canManagePages.hashCode ^
      canManageSections.hashCode ^
      canManagePosts.hashCode ^
      canManageReviews.hashCode ^
      canManageUsers.hashCode;
}
