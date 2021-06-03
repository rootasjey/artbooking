class UserPPPath {
  final String edited;
  final String original;

  UserPPPath({
    this.edited,
    this.original,
  });

  factory UserPPPath.empty() {
    return UserPPPath(
      edited: '',
      original: '',
    );
  }

  factory UserPPPath.fromJSON(Map<String, dynamic> data) {
    if (data == null) {
      return UserPPPath.empty();
    }

    return UserPPPath(
      edited: data['edited'],
      original: data['original'],
    );
  }

  UserPPPath merge(UserPPPath userPPPath) {
    final newEditedValue =
        userPPPath.edited != null ? userPPPath.edited : this.edited;

    final newOriginalValue =
        userPPPath.original != null ? userPPPath.original : this.original;

    return UserPPPath(
      edited: newEditedValue,
      original: newOriginalValue,
    );
  }

  Map<String, dynamic> toJSON() {
    final data = Map<String, dynamic>();

    data['edited'] = edited;
    data['original'] = original;

    return data;
  }
}
