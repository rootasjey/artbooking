/// Define which actions are available for the target user.
class UserRights {
  const UserRights({
    this.isAdmin = false,
    this.canManageLicense = false,
  });

  /// If true, the current user is an admin.
  final bool isAdmin;

  /// True if the current user can manage (add, remove, edit) staff licenses.
  final bool canManageLicense;

  factory UserRights.fromJSON(Map<String, dynamic>? data) {
    if (data == null) {
      return UserRights();
    }

    return UserRights(
      isAdmin: data['user:admin'] ?? false,
      canManageLicense: data['user:managelicense'] ?? false,
    );
  }

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> data = Map();
    data['user:admin'] = isAdmin;
    data['user:managelicense'] = canManageLicense;

    return data;
  }
}
