class PartialUser {
  PartialUser({
    this.id = "",
    this.name = "",
    this.email = "",
  });

  final String id;
  final String name;
  final String email;

  factory PartialUser.empty() {
    return PartialUser(
      id: "",
      name: "",
      email: "",
    );
  }

  factory PartialUser.fromJSON(Map<dynamic, dynamic>? data) {
    if (data == null) {
      return PartialUser.empty();
    }

    return PartialUser(
      id: data["id"] ?? "",
      name: data["name"] ?? "",
      email: data["email"] ?? "",
    );
  }
}
