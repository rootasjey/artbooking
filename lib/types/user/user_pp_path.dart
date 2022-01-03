class UserPPPath {
  final String edited;
  final String original;

  const UserPPPath({
    this.edited = '',
    this.original = '',
  });

  factory UserPPPath.empty() {
    return UserPPPath(
      edited: '',
      original: '',
    );
  }

  factory UserPPPath.fromJSON(Map<String, dynamic>? data) {
    if (data == null) {
      return UserPPPath.empty();
    }

    return UserPPPath(
      edited: data['edited'],
      original: data['original'],
    );
  }

  UserPPPath merge(UserPPPath userPPPath) {
    final newEdited = userPPPath.edited;
    final newOriginal = userPPPath.original;

    return UserPPPath(
      edited: newEdited.isNotEmpty ? newEdited : this.edited,
      original: newOriginal.isNotEmpty ? newOriginal : this.original,
    );
  }

  Map<String, dynamic> toJSON() {
    final data = Map<String, dynamic>();

    data['edited'] = edited;
    data['original'] = original;

    return data;
  }
}
