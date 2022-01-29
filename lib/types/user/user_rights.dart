import 'dart:convert';

/// Define which actions are available for the target user.
class UserRights {
  const UserRights({
    this.isAdmin = false,
    this.canManageLicense = false,
    this.canManageStyles = false,
    this.canManageUsers = false,
  });

  /// If true, the current user is an admin.
  final bool isAdmin;

  /// True if the current user can manage (add, remove, edit) staff licenses.
  final bool canManageLicense;

  /// True if the current user can manage (add, remove, edit) art styles.
  final bool canManageStyles;

  /// True if the current user can manage (add, remove, edit) users.
  final bool canManageUsers;

  UserRights copyWith({
    bool? isAdmin,
    bool? canManageLicense,
  }) {
    return UserRights(
      isAdmin: isAdmin ?? this.isAdmin,
      canManageLicense: canManageLicense ?? this.canManageLicense,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user:admin': isAdmin,
      'user:managelicense': canManageLicense,
      'user:managestyles': canManageStyles,
      'user:manageusers': canManageUsers,
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
      isAdmin: map['user:admin'] ?? false,
      canManageLicense: map['user:managelicense'] ?? false,
      canManageStyles: map['user:managestyles'] ?? false,
      canManageUsers: map['user:manageusers'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserRights.fromJson(String source) =>
      UserRights.fromMap(json.decode(source));

  @override
  String toString() =>
      'UserRights(isAdmin: $isAdmin, canManageLicense: $canManageLicense)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserRights &&
        other.isAdmin == isAdmin &&
        other.canManageLicense == canManageLicense;
  }

  @override
  int get hashCode => isAdmin.hashCode ^ canManageLicense.hashCode;
}
