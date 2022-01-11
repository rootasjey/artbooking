/// Define which actions are available for the target user.
class UserRights {
  const UserRights({this.isAdmin = false});

  /// If true, the current authenticated user is an admin.
  final bool isAdmin;

  factory UserRights.fromJSON(Map<String, dynamic>? data) {
    if (data == null) {
      return UserRights();
    }

    return UserRights(
      isAdmin: data['user:admin'] ?? false,
    );
  }

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> data = Map();
    data['user:admin'] = isAdmin;

    return data;
  }
}
